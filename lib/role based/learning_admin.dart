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

// --- Amharic Localization Strings for Learning Admin Hub ---
abstract class AmharicStringsLearningAdmin {
  static const String hubTitle = 'የትምህርት አስተዳደር ማዕከል';
  static const String manageContentTitle = 'የትምህርት ይዘትን አስተዳድር';
  static const String tabManageContent = 'ይዘትን አስተዳድር';
  static const String tabPromoteAdmins = 'አስተዳዳሪዎችን ሹም';
  static const String failedToLoadContent = 'የአስተዳዳሪ ይዘትን መጫን አልተሳካም።';
  static const String confirmDeletion = 'መሰረዝን ያረጋግጡ';
  static const String deleteConfirmation =
      'ይህንን ይዘት መሰረዝ ይፈልጋሉ? ይህ እርምጃ ሊቀለበስ አይችልም።';
  static const String cancel = 'ይቅር';
  static const String delete = 'ሰርዝ';
  static const String deleteFailed = 'መሰረዝ አልተሳካም።';
  static const String video = 'ቪዲዮ';
  static const String article = 'ጽሑፍ';
  static const String noTitle = 'ርዕስ የለም';
  static const String createContent = 'ይዘት ፍጠር';
  static const String editContent = 'ይዘት አስተካክል';
  static const String required = 'ያስፈልጋል';
  static const String pleaseWaitUpload = 'እባክዎን ምስሉ እስኪሰቀል ይጠብቁ።';
  static const String uploadFailed = 'መስቀል አልተሳካም:';
  static const String title = 'ርዕስ';
  static const String description = 'መግለጫ';
  static const String type = 'ዓይነት';
  static const String youtubeURL = 'የዩቲዩብ አድራሻ';
  static const String articleMarkdown = 'የጽሑፍ ማርክዳውን';
  static const String category = 'ምድብ';
  static const String duration = 'የጊዜ ርዝመት (ለምሳሌ፣ 15:30 ወይም 10 ደቂቃ ንባብ)';
  static const String difficulty = 'ችግር';
  static const String visibility = 'የሚታይበት ቦታ';
  static const String beginner = 'ጀማሪ';
  static const String intermediate = 'መካከለኛ';
  static const String advanced = 'የላቀ';
  static const String forMySsOnly = 'ለሰንበት ትምህርት ቤቴ ብቻ';
  static const String forEveryone = 'ለሁሉም';
  static const String save = 'አስቀምጥ';
  static const String tapToUploadImage = 'ምስል ለመስቀል ይጫኑ';
  static const String uploadImage = 'ምስል ስቀል';
  static const String noNameProvided = 'ስም አልተሰጠም';
  static const String roleUpdated = '\'s ሚና ተዘምኗል።';
  static const String failedToUpdateRole = 'ሚና ማዘመን አልተሳካም:';
  static const String noUsersFound = 'ምንም ተጠቃሚዎች አልተገኙም።';
}

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
      title: json['title'] ?? AmharicStringsLearningAdmin.noTitle,
      description: json['description'] ?? '',
      type: json['type'] ?? AmharicStringsLearningAdmin.article.toLowerCase(),
      imageUrl: json['imageUrl'] ?? '',
      content: json['content'] ?? '',
      duration: json['duration'] ?? 'N/A',
      category: json['category'] ?? 'General',
      difficulty: json['difficulty'] ?? AmharicStringsLearningAdmin.beginner,
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
    final userProvider = context.watch<UserProvider>();
    final isSuperiorAdmin = userProvider.roles.contains('superior_admin');

    // SUPERIOR ADMIN gets the full-featured tabbed view
    if (isSuperiorAdmin) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(AmharicStringsLearningAdmin.hubTitle,
                style: GoogleFonts.notoSansEthiopic(
                    fontWeight: FontWeight.bold)), // Translated
            bottom: TabBar(
              indicatorColor: AppTheme.accent,
              tabs: [
                Tab(
                    icon: const Icon(Iconsax.document),
                    text: AmharicStringsLearningAdmin
                        .tabManageContent), // Translated
                Tab(
                    icon: const Icon(Iconsax.user_add),
                    text: AmharicStringsLearningAdmin
                        .tabPromoteAdmins), // Translated
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
          title: Text(AmharicStringsLearningAdmin.manageContentTitle,
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              result['message'] ??
                  AmharicStringsLearningAdmin.failedToLoadContent,
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
    final bool? shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(AmharicStringsLearningAdmin.confirmDeletion,
                  style: GoogleFonts.notoSansEthiopic()), // Translated
              content: Text(AmharicStringsLearningAdmin.deleteConfirmation,
                  style: GoogleFonts.notoSansEthiopic()), // Translated
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(AmharicStringsLearningAdmin.cancel,
                      style: GoogleFonts.notoSansEthiopic()), // Translated
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(AmharicStringsLearningAdmin.delete,
                      style: GoogleFonts.notoSansEthiopic(
                          color: AppTheme.danger)), // Translated
                ),
              ],
            ));

    if (shouldDelete != true) return;

    final result = await LearningService.deleteContent(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            result['message'] ?? AmharicStringsLearningAdmin.deleteFailed,
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
                      title: Text(item.title,
                          style: GoogleFonts.notoSansEthiopic(
                              fontWeight: FontWeight.bold)), // Use Amharic font
                      subtitle: Text(
                          "${item.category} • ${item.difficulty}", // Keep structure, content is data
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
      fullName: json['fullName'] ??
          AmharicStringsLearningAdmin.noNameProvided, // Translated
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${AmharicStringsLearningAdmin.hubTitle}: ${e.toString()}',
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${user.fullName}${AmharicStringsLearningAdmin.roleUpdated}',
              style: GoogleFonts.notoSansEthiopic()), // Translated
          backgroundColor: AppTheme.success,
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (e) {
      setState(() => user.isLearningAdmin = originalValue); // Revert on failure
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${AmharicStringsLearningAdmin.failedToUpdateRole} ${e.toString()}',
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.user_remove,
                size: 60, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(AmharicStringsLearningAdmin.noUsersFound,
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
  String _difficulty =
      AmharicStringsLearningAdmin.beginner; // Use translated default
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${AmharicStringsLearningAdmin.uploadFailed} ${e.toString()}',
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AmharicStringsLearningAdmin.pleaseWaitUpload,
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
    return AlertDialog(
      title: Text(
          widget.content == null
              ? AmharicStringsLearningAdmin.createContent
              : AmharicStringsLearningAdmin.editContent,
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
                      labelText:
                          AmharicStringsLearningAdmin.title), // Translated
                  validator: (v) =>
                      v!.isEmpty ? AmharicStringsLearningAdmin.required : null,
                  style: GoogleFonts.notoSansEthiopic()), // Use Amharic font
              const SizedBox(height: 8),
              TextFormField(
                  controller: _descCtrl,
                  decoration: InputDecoration(
                      labelText: AmharicStringsLearningAdmin
                          .description), // Translated
                  maxLines: 3,
                  validator: (v) =>
                      v!.isEmpty ? AmharicStringsLearningAdmin.required : null,
                  style: GoogleFonts.notoSansEthiopic()), // Use Amharic font
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: InputDecoration(
                    labelText: AmharicStringsLearningAdmin.type), // Translated
                items: ['video', 'article']
                    .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                            t == 'video'
                                ? AmharicStringsLearningAdmin.video
                                : AmharicStringsLearningAdmin
                                    .article, // Translated options
                            style: GoogleFonts.notoSansEthiopic())))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _contentCtrl,
                  decoration: InputDecoration(
                      labelText: _type == 'video'
                          ? AmharicStringsLearningAdmin.youtubeURL
                          : AmharicStringsLearningAdmin
                              .articleMarkdown), // Translated labels
                  maxLines: 5,
                  validator: (v) =>
                      v!.isEmpty ? AmharicStringsLearningAdmin.required : null,
                  style: GoogleFonts.notoSansEthiopic()), // Use Amharic font
              const SizedBox(height: 8),
              TextFormField(
                  controller: _categoryCtrl,
                  decoration: InputDecoration(
                      labelText:
                          AmharicStringsLearningAdmin.category), // Translated
                  style: GoogleFonts.notoSansEthiopic()), // Use Amharic font
              const SizedBox(height: 8),
              TextFormField(
                  controller: _durationCtrl,
                  decoration: InputDecoration(
                      labelText:
                          AmharicStringsLearningAdmin.duration), // Translated
                  style: GoogleFonts.notoSansEthiopic()), // Use Amharic font
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _difficulty,
                decoration: InputDecoration(
                    labelText:
                        AmharicStringsLearningAdmin.difficulty), // Translated
                items: [
                  AmharicStringsLearningAdmin.beginner, // Translated option
                  AmharicStringsLearningAdmin.intermediate, // Translated option
                  AmharicStringsLearningAdmin.advanced, // Translated option
                ]
                    .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t,
                            style: GoogleFonts
                                .notoSansEthiopic()))) // Use Amharic font
                    .toList(),
                onChanged: (v) => setState(() => _difficulty = v!),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _visibility,
                decoration: InputDecoration(
                    labelText:
                        AmharicStringsLearningAdmin.visibility), // Translated
                items: [
                  DropdownMenuItem(
                      value: 'tenant',
                      child: Text(AmharicStringsLearningAdmin.forMySsOnly,
                          style: GoogleFonts.notoSansEthiopic())), // Translated
                  DropdownMenuItem(
                      value: 'public',
                      child: Text(AmharicStringsLearningAdmin.forEveryone,
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
            child: Text(AmharicStringsLearningAdmin.cancel,
                style: GoogleFonts.notoSansEthiopic())), // Translated
        ElevatedButton(
            onPressed: _submitForm,
            child: Text(AmharicStringsLearningAdmin.save,
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
                          Text(AmharicStringsLearningAdmin.tapToUploadImage,
                              style: GoogleFonts.notoSansEthiopic(
                                  color: AppTheme.textSecondary)), // Translated
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
