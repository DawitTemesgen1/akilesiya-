import 'dart:convert';
import 'dart:io';

import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:amde_haymanot_abalat_guday/services/app_theme.dart';
import 'package:amde_haymanot_abalat_guday/services/learning_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';

// --- Amharic Localization Strings for Learning Admin Hub ---
// Localized Learning Admin Hub

// Data model from your learning_screen.dart
class LearningContent {
  final String id;
  final String title;
  final String description;
  final String type;
  final String imageUrl;
  final String content;
  final String duration;
  final String category;
  final String difficulty;

  LearningContent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.imageUrl,
    required this.content,
    required this.duration,
    required this.category,
    required this.difficulty,
  });

  factory LearningContent.fromJson(Map<String, dynamic> json) {
    return LearningContent(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'article',
      imageUrl: json['imageUrl'] ?? '',
      content: json['content'] ?? '',
      duration: json['duration'] ?? '',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? '',
    );
  }
}

// ==========================================================
// --- UNIFIED ADMIN HUB SCREEN (THE MAIN WIDGET) ---
// ==========================================================
class LearningAdminHubScreen extends StatelessWidget {
  final VoidCallback onDataChanged;
  const LearningAdminHubScreen({super.key, required this.onDataChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = context.watch<UserProvider>();
    final isSuperiorAdmin = userProvider.roles.contains('superior_admin');

    // SUPERIOR ADMIN gets the full-featured tabbed view
    if (isSuperiorAdmin) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.learningAdminHubTitle,
                style: GoogleFonts.notoSansEthiopic(
                    fontWeight: FontWeight.bold)), // Translated
            bottom: TabBar(
              indicatorColor: AppTheme.accent,
              tabs: [
                Tab(
                    icon: const Icon(Iconsax.document),
                    text: l10n.learningAdminTabManageContent), // Translated
                Tab(
                    icon: const Icon(Iconsax.user_add),
                    text: l10n.learningAdminTabPromoteAdmins), // Translated
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _ManageContentTab(onDataChanged: onDataChanged),
              const _PromoteAdminsTab(),
            ],
          ),
        ),
      );
    }
    // REGULAR LEARNING ADMIN gets only the content management view
    else {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.learningAdminManageContentTitle,
              style: GoogleFonts.notoSansEthiopic(
                  fontWeight: FontWeight.bold)), // Translated
        ),
        body: _ManageContentTab(onDataChanged: onDataChanged),
      );
    }
  }
}

// ==========================================================
// --- TAB 1: MANAGE CONTENT WIDGET ---
// ==========================================================
class _ManageContentTab extends StatefulWidget {
  final VoidCallback onDataChanged;
  const _ManageContentTab({required this.onDataChanged});

  @override
  State<_ManageContentTab> createState() => _ManageContentTabState();
}

class _ManageContentTabState extends State<_ManageContentTab> {
  List<LearningContent> _contentList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final result = await LearningService.getLearningContent();
    if (mounted && result['success']) {
      setState(() {
        _contentList = (result['data'] as List)
            .map((i) => LearningContent.fromJson(i))
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              result['message'] ?? l10n.learningAdminFailedToLoadContent,
              style: GoogleFonts.notoSansEthiopic()), // Translated
          backgroundColor: AppTheme.danger,
        ));
      }
    }
  }

  void _showContentForm([LearningContent? content]) {
    showDialog(
      context: context,
      builder: (context) => _ContentFormDialog(
        content: content,
        onSave: () {
          _fetchData();
          widget.onDataChanged();
        },
      ),
    );
  }

  Future<void> _deleteContent(String id) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(l10n.learningAdminConfirmDeletion,
                  style: GoogleFonts.notoSansEthiopic()), // Translated
              content: Text(l10n.learningAdminDeleteConfirmation,
                  style: GoogleFonts.notoSansEthiopic()), // Translated
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.learningAdminCancel,
                      style: GoogleFonts.notoSansEthiopic()), // Translated
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.learningAdminDelete,
                      style: GoogleFonts.notoSansEthiopic(
                          color: AppTheme.danger)), // Translated
                ),
              ],
            ));

    if (shouldDelete != true) return;

    final result = await LearningService.deleteContent(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? l10n.learningAdminDeleteFailed,
            style: GoogleFonts.notoSansEthiopic()), // Translated
        backgroundColor: result['success'] ? AppTheme.success : AppTheme.danger,
      ));
      if (result['success']) {
        _fetchData();
        widget.onDataChanged();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _contentList.length,
                itemBuilder: (context, index) {
                  final item = _contentList[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      leading: Icon(item.type == 'video'
                          ? Iconsax.video
                          : Iconsax.document),
                      title: Text(
                          item.title.isEmpty
                              ? AppLocalizations.of(context)!.defaultNoTitle
                              : item.title,
                          style: GoogleFonts.notoSansEthiopic(
                              fontWeight: FontWeight.bold)), // Use Amharic font
                      subtitle: Text(
                          "${item.category.isEmpty ? AppLocalizations.of(context)!.defaultContentCategory : item.category} • ${item.difficulty == 'Beginner' ? AppLocalizations.of(context)!.learningAdminBeginner : (item.difficulty == 'Intermediate' ? AppLocalizations.of(context)!.learningAdminIntermediate : (item.difficulty == 'Advanced' ? AppLocalizations.of(context)!.learningAdminAdvanced : item.difficulty))}", // Keep structure, content is data
                          style: GoogleFonts
                              .notoSansEthiopic()), // Use Amharic font
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon:
                                const Icon(Iconsax.edit, color: AppTheme.info),
                            onPressed: () => _showContentForm(item),
                          ),
                          IconButton(
                            icon: const Icon(Iconsax.trash,
                                color: AppTheme.danger),
                            onPressed: () => _deleteContent(item.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContentForm(),
        backgroundColor: AppTheme.primary,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
    );
  }
}

// ==========================================================
// --- TAB 2: PROMOTE ADMINS WIDGET ---
// ==========================================================
class AdminUser {
  final String id;
  final String fullName;
  bool isLearningAdmin;

  AdminUser(
      {required this.id,
      required this.fullName,
      required this.isLearningAdmin});

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      fullName: json['fullName'] ?? 'No name provided', // Translated
      isLearningAdmin: json['isLearningAdmin'] ?? false,
    );
  }
}

class _PromoteAdminsTab extends StatefulWidget {
  const _PromoteAdminsTab();

  @override
  State<_PromoteAdminsTab> createState() => _PromoteAdminsTabState();
}

class _PromoteAdminsTabState extends State<_PromoteAdminsTab> {
  List<AdminUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('admin/learning-admins/users');
      final body = json.decode(response.body);

      if (mounted && body['success']) {
        setState(() {
          _users =
              (body['data'] as List).map((i) => AdminUser.fromJson(i)).toList();
        });
      } else {
        throw Exception(
            body['message'] ?? 'ተጠቃሚዎችን መጫን አልተሳካም።'); // Translated error
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${l10n.learningAdminHubTitle}: ${e.toString()}',
              style: GoogleFonts.notoSansEthiopic()), // Translated
          backgroundColor: AppTheme.danger,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateRole(AdminUser user, bool isLearningAdmin) async {
    final originalValue = user.isLearningAdmin;
    setState(
        () => user.isLearningAdmin = isLearningAdmin); // Optimistic UI update

    try {
      final response = await ApiService.put(
        'admin/learning-admins/users/${user.id}/roles',
        {'isLearningAdmin': isLearningAdmin},
      );
      final body = json.decode(response.body);

      if (!body['success']) {
        throw Exception(body['message']);
      }
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${user.fullName}${l10n.learningAdminRoleUpdated}',
              style: GoogleFonts.notoSansEthiopic()), // Translated
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (e) {
      setState(() => user.isLearningAdmin = originalValue); // Revert on failure
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${l10n.learningAdminFailedToUpdateRole} ${e.toString()}',
              style: GoogleFonts.notoSansEthiopic()), // Translated
          backgroundColor: AppTheme.danger,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (_users.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.user_remove,
                size: 60, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(l10n.learningAdminNoUsersFound,
                style: GoogleFonts.notoSansEthiopic(
                    color: AppTheme.textSecondary)), // Translated
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchUsers,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            child: CheckboxListTile(
              title: Text(user.fullName,
                  style: GoogleFonts.notoSansEthiopic()), // Use Amharic font
              value: user.isLearningAdmin,
              onChanged: (bool? newValue) {
                if (newValue != null) {
                  _updateRole(user, newValue);
                }
              },
              controlAffinity: ListTileControlAffinity.trailing,
              activeColor: AppTheme.primary,
            ),
          );
        },
      ),
    );
  }
}

// ==========================================================
// --- HELPER WIDGETS FOR CONTENT FORM (Translated) ---
// ==========================================================

class _ContentFormDialog extends StatefulWidget {
  final LearningContent? content;
  final VoidCallback onSave;
  const _ContentFormDialog({this.content, required this.onSave});

  @override
  State<_ContentFormDialog> createState() => _ContentFormDialogState();
}

class _ContentFormDialogState extends State<_ContentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl,
      _descCtrl,
      _contentCtrl,
      _durationCtrl,
      _categoryCtrl;
  String _type = 'video';
  String _difficulty = 'Beginner'; // Use translated default
  String _visibility = 'tenant';
  XFile? _pickedImageXFile;
  String? _networkImageUrl;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final c = widget.content;
    _titleCtrl = TextEditingController(text: c?.title);
    _descCtrl = TextEditingController(text: c?.description);
    _contentCtrl = TextEditingController(text: c?.content);
    _durationCtrl = TextEditingController(text: c?.duration);
    _categoryCtrl = TextEditingController(text: c?.category);
    if (c != null) {
      _type = c.type;
      _difficulty = c.difficulty;
      _networkImageUrl = c.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _contentCtrl.dispose();
    _durationCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null) return;
    setState(() {
      _pickedImageXFile = image;
      _isUploading = true;
    });
    try {
      final response = await ApiService.uploadImage(image);
      final responseBody = await response.stream.bytesToString();
      final decodedBody = json.decode(responseBody);
      if (response.statusCode == 201) {
        setState(() => _networkImageUrl = decodedBody['url']);
      } else {
        throw Exception(decodedBody['message'] ?? 'Failed to upload image.');
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${l10n.learningAdminUploadFailed} ${e.toString()}',
              style: GoogleFonts.notoSansEthiopic()), // Translated
          backgroundColor: AppTheme.danger,
        ));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isUploading) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.learningAdminPleaseWaitUpload,
            style: GoogleFonts.notoSansEthiopic()), // Translated
        backgroundColor: AppTheme.warning,
      ));
      return;
    }
    final data = {
      'title': _titleCtrl.text,
      'description': _descCtrl.text,
      'imageUrl': _networkImageUrl ?? '',
      'type': _type,
      'content': _contentCtrl.text,
      'duration': _durationCtrl.text,
      'category': _categoryCtrl.text,
      'difficulty': _difficulty,
      'visibility': _visibility,
    };
    final result = widget.content == null
        ? await LearningService.createContent(data)
        : await LearningService.updateContent(widget.content!.id, data);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? '...'),
        backgroundColor: result['success'] ? AppTheme.success : AppTheme.danger,
      ));
      if (result['success']) {
        widget.onSave();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
          widget.content == null
              ? l10n.learningAdminCreateContent
              : l10n.learningAdminEditContent,
          style: GoogleFonts.notoSansEthiopic()), // Translated
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ImagePickerWidget(
                pickedImageXFile: _pickedImageXFile,
                networkImageUrl: _networkImageUrl,
                isUploading: _isUploading,
                onTap: _pickAndUploadImage,
              ),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                      labelText: l10n.learningAdminTitle), // Translated
                  validator: (v) =>
                      v!.isEmpty ? l10n.learningAdminRequired : null,
                  style: GoogleFonts.notoSansEthiopic()), // Use Amharic font
              const SizedBox(height: 8),
              TextFormField(
                  controller: _descCtrl,
                  decoration: InputDecoration(
                      labelText: l10n.learningAdminDescription), // Translated
                  maxLines: 3,
                  validator: (v) =>
                      v!.isEmpty ? l10n.learningAdminRequired : null,
                  style: GoogleFonts.notoSansEthiopic()), // Use Amharic font
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(
                    labelText: l10n.learningAdminType), // Translated
                items: ['video', 'article']
                    .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                            t == 'video'
                                ? l10n.learningAdminVideo
                                : l10n
                                    .learningAdminArticle, // Translated options
                            style: GoogleFonts.notoSansEthiopic())))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _contentCtrl,
                  decoration: InputDecoration(
                      labelText: _type == 'video'
                          ? l10n.learningAdminYoutubeURL
                          : l10n
                              .learningAdminArticleMarkdown), // Translated labels
                  maxLines: 5,
                  validator: (v) =>
                      v!.isEmpty ? l10n.learningAdminRequired : null,
                  style: GoogleFonts.notoSansEthiopic()), // Use Amharic font
              const SizedBox(height: 8),
              TextFormField(
                  controller: _categoryCtrl,
                  decoration: InputDecoration(
                      labelText: l10n.learningAdminCategory), // Translated
                  style: GoogleFonts.notoSansEthiopic()), // Use Amharic font
              const SizedBox(height: 8),
              TextFormField(
                  controller: _durationCtrl,
                  decoration: InputDecoration(
                      labelText: l10n.learningAdminDuration), // Translated
                  style: GoogleFonts.notoSansEthiopic()), // Use Amharic font
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _difficulty,
                decoration: InputDecoration(
                    labelText: l10n.learningAdminDifficulty), // Translated
                items: [
                  'Beginner',
                  'Intermediate',
                  'Advanced',
                ].map((t) {
                  String label;
                  if (t == 'Beginner') {
                    label = l10n.learningAdminBeginner;
                  } else if (t == 'Intermediate') {
                    label = l10n.learningAdminIntermediate;
                  } else {
                    label = l10n.learningAdminAdvanced;
                  }

                  return DropdownMenuItem(
                      value: t,
                      child:
                          Text(label, style: GoogleFonts.notoSansEthiopic()));
                }).toList(),
                onChanged: (v) => setState(() => _difficulty = v!),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _visibility,
                decoration: InputDecoration(
                    labelText: l10n.learningAdminVisibility), // Translated
                items: [
                  DropdownMenuItem(
                      value: 'tenant',
                      child: Text(l10n.learningAdminForMySsOnly,
                          style: GoogleFonts.notoSansEthiopic())), // Translated
                  DropdownMenuItem(
                      value: 'public',
                      child: Text(l10n.learningAdminForEveryone,
                          style: GoogleFonts.notoSansEthiopic())), // Translated
                ],
                onChanged: (v) => setState(() => _visibility = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.learningAdminCancel,
                style: GoogleFonts.notoSansEthiopic())), // Translated
        ElevatedButton(
            onPressed: _submitForm,
            child: Text(l10n.learningAdminSave,
                style: GoogleFonts.notoSansEthiopic())), // Translated
      ],
    );
  }
}

class _ImagePickerWidget extends StatelessWidget {
  final XFile? pickedImageXFile;
  final String? networkImageUrl;
  final bool isUploading;
  final VoidCallback onTap;

  const _ImagePickerWidget({
    required this.pickedImageXFile,
    required this.networkImageUrl,
    required this.isUploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: isUploading ? null : onTap,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                image: _buildImage(),
              ),
              child: (pickedImageXFile == null &&
                      (networkImageUrl == null || networkImageUrl!.isEmpty))
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.gallery_add,
                              color: AppTheme.textSecondary),
                          const SizedBox(height: 4),
                          Builder(builder: (context) {
                            return Text(
                                AppLocalizations.of(context)!
                                    .learningAdminTapToUploadImage,
                                style: GoogleFonts.notoSansEthiopic(
                                    color: AppTheme.textSecondary));
                          }), // Translated
                        ],
                      ),
                    )
                  : null,
            ),
          ),
          if (isUploading)
            const CircularProgressIndicator(color: AppTheme.primary),
        ],
      ),
    );
  }

  DecorationImage? _buildImage() {
    if (pickedImageXFile != null) {
      if (kIsWeb) {
        return DecorationImage(
          image: NetworkImage(pickedImageXFile!.path),
          fit: BoxFit.cover,
        );
      } else {
        return DecorationImage(
          image: FileImage(File(pickedImageXFile!.path)),
          fit: BoxFit.cover,
        );
      }
    }
    if (networkImageUrl != null && networkImageUrl!.isNotEmpty) {
      return DecorationImage(
          image: CachedNetworkImageProvider(networkImageUrl!),
          fit: BoxFit.cover);
    }
    return null;
  }
}

extension StringExtension on String {
  String capitalize() =>
      isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
}
