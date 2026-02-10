import 'dart:developer' as developer;
import 'dart:typed_data';
import 'package:amde_haymanot_abalat_guday/services/refresh_ervice.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/private_homepage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amde_haymanot_abalat_guday/services/private_feed_service.dart';
import 'package:amde_haymanot_abalat_guday/services/public_feed_service.dart'; // Added
import 'package:amde_haymanot_abalat_guday/providers/tenant_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart'; // Added
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart'; // Fixed import path

// =================================================================
// --- FIX: Import the new, centralized refresh service ---
// =================================================================

class AdminPostManagementScreen extends StatefulWidget {
  final String? tenantId;
  const AdminPostManagementScreen({super.key, this.tenantId});

  @override
  State<AdminPostManagementScreen> createState() =>
      _AdminPostManagementScreenState();
}

class _AdminPostManagementScreenState extends State<AdminPostManagementScreen> {
  List<PrivatePost> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _triggerRefresh() {
    // This now correctly accesses the global notifier from the imported file.
    privateFeedRefresher.value++;
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final tenantId = widget.tenantId ??
        Provider.of<TenantProvider>(context, listen: false).currentTenant?.id;
    if (tenantId == null) {
      if (mounted) {
        setState(() {
          _error = "Tenant information not available.";
          _isLoading = false;
        });
      }
      return;
    }
    try {
      final postsResult = await PrivateFeedService.getPrivatePosts(tenantId);
      if (mounted) {
        if (postsResult['success']) {
          final dynamic rawData = postsResult['data'];
          List<dynamic> postsList = [];

          if (rawData is List) {
            postsList = rawData;
          } else if (rawData is Map && rawData['posts'] is List) {
            postsList = rawData['posts'];
          }

          setState(() {
            _posts = postsList.map((p) => PrivatePost.fromJson(p)).toList();
            _isLoading = false;
          });
        } else {
          throw Exception(postsResult['message']);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deletePost(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
            'Are you sure you want to permanently delete this post?'),
        actions: [
          TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(false)),
          TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(ctx).pop(true)),
        ],
      ),
    );
    if (confirmed == true) {
      final result = await PrivateFeedService.deletePrivatePost(postId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? '...'),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ));
        if (result['success']) {
          _triggerRefresh();
          _loadData();
        }
      }
    }
  }

  void _showAddOrEditPostDialog({PrivatePost? post}) {
    final formKey = GlobalKey<FormState>();
    final isEditing = post != null;
    final titleController = TextEditingController(text: post?.title ?? '');
    final descriptionController =
        TextEditingController(text: post?.description ?? '');
    final imageUrlController =
        TextEditingController(text: post?.imageUrl ?? '');
    PostType selectedType = post?.type ?? PostType.news;
    bool isImportant = post?.isImportant ?? false;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final canManagePublicPosts = userProvider.canManagePublicPosts;
    bool isGlobalPost = false; // By default private in this screen
    // Note: Since this screen lists private posts, newly created ones are private by default.
    // In edit mode, if we were to support switching, we'd need more metadata.
    // For now, let's keep it simple as per user request.

    // Removed availableGroups and selectedTargetGroups for school-scope targeting.

    bool isSubmitting = false;
    XFile? selectedImageXFile;
    Uint8List? selectedImageBytes;
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            Future<void> pickImage(ImageSource source) async {
              final pickedFile = await picker.pickImage(
                  source: source, imageQuality: 60, maxWidth: 1024);
              if (pickedFile != null) {
                final bytes = await pickedFile.readAsBytes();
                setDialogState(() {
                  selectedImageXFile = pickedFile;
                  selectedImageBytes = bytes;
                  imageUrlController.clear();
                  developer.log(
                      'Debug: Selected Image Byte Length: ${bytes.length}',
                      name: 'PostManagement');
                  developer.log(
                      'Debug: Selected Image Path: ${pickedFile.path}',
                      name: 'PostManagement');
                });
              }
            }

            Future<void> handleSubmit() async {
              if (!formKey.currentState!.validate() || isSubmitting) return;
              final currentPost = post;
              setDialogState(() => isSubmitting = true);
              Map<String, String> fields = {
                'title': titleController.text,
                'description': descriptionController.text,
                'type': selectedType.name,
                'isImportant': isImportant.toString(),
                'imageUrl':
                    selectedImageXFile == null ? imageUrlController.text : '',
              };

              try {
                Map<String, dynamic> result;
                if (isEditing) {
                  if (selectedImageXFile != null) {
                    result = await PrivateFeedService.updatePostWithImage(
                      postId: currentPost!.id,
                      fields: fields,
                      file: selectedImageXFile!,
                      targetGroups: [], // No longer using specific roles
                    );
                  } else {
                    final data = Map<String, dynamic>.from(fields);
                    data['targetGroups'] = [];
                    result = await PrivateFeedService.updatePrivatePost(
                        currentPost!.id, data);
                  }
                } else {
                  if (isGlobalPost) {
                    // Call Public Feed Service
                    if (selectedImageXFile != null) {
                      result =
                          await PublicFeedService.createPublicPostWithImage(
                        fields: fields,
                        file: selectedImageXFile!,
                      );
                    } else {
                      result = await PublicFeedService.createPublicPost(fields);
                    }
                  } else {
                    // Call Private Feed Service
                    if (selectedImageXFile != null) {
                      result = await PrivateFeedService.createPostWithImage(
                        fields: fields,
                        file: selectedImageXFile!,
                        targetGroups: [],
                      );
                    } else {
                      final data = Map<String, dynamic>.from(fields);
                      data['targetGroups'] = [];
                      result = await PrivateFeedService.createPrivatePost(data);
                    }
                  }
                }
                if (!Navigator.of(dialogContext).mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(
                  content: Text(result['message'] ?? 'Operation failed.'),
                  backgroundColor:
                      result['success'] ? Colors.green : Colors.red,
                ));
                if (result['success']) {
                  _triggerRefresh();
                  Navigator.of(dialogContext).pop(true);
                }
              } catch (e) {
                if (!Navigator.of(dialogContext).mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(
                    content: Text("An error occurred: $e"),
                    backgroundColor: Colors.red));
              } finally {
                if (Navigator.of(dialogContext).mounted) {
                  setDialogState(() => isSubmitting = false);
                }
              }
            }

            return AlertDialog(
              title: Text(isEditing ? "Edit Post" : "Create New Post"),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selectedImageBytes != null)
                          Image.memory(selectedImageBytes!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover)
                        else if (imageUrlController.text.isNotEmpty)
                          CachedNetworkImage(
                              imageUrl: imageUrlController.text,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                                icon: const Icon(IconsaxPlusLinear.gallery),
                                label: const Text("Gallery"),
                                onPressed: () =>
                                    pickImage(ImageSource.gallery)),
                            ElevatedButton.icon(
                                icon: const Icon(IconsaxPlusLinear.camera),
                                label: const Text("Camera"),
                                onPressed: () => pickImage(ImageSource.camera)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                            controller: titleController,
                            decoration:
                                const InputDecoration(labelText: "Title*"),
                            validator: (v) => v!.isEmpty ? 'Required' : null),
                        const SizedBox(height: 16),
                        TextFormField(
                            controller: descriptionController,
                            decoration: const InputDecoration(
                                labelText: "Description*"),
                            maxLines: 4,
                            validator: (v) => v!.isEmpty ? 'Required' : null),
                        const SizedBox(height: 16),
                        TextFormField(
                            controller: imageUrlController,
                            enabled: selectedImageXFile == null,
                            decoration: const InputDecoration(
                                labelText: "Or enter Image URL")),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<PostType>(
                          initialValue: selectedType,
                          decoration:
                              const InputDecoration(labelText: "Post Type"),
                          items: PostType.values
                              .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type.name[0].toUpperCase() +
                                      type.name.substring(1))))
                              .toList(),
                          onChanged: (val) => setDialogState(
                              () => selectedType = val ?? PostType.news),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                            title: const Text("Important Post"),
                            value: isImportant,
                            onChanged: (val) =>
                                setDialogState(() => isImportant = val)),
                        const Divider(height: 32),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              AppLocalizations.of(context)!.postScopeSelection,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        RadioListTile<bool>(
                          contentPadding: EdgeInsets.zero,
                          title: Text(AppLocalizations.of(context)!
                              .postScopeMySchoolOnly),
                          value: false,
                          groupValue: isGlobalPost,
                          onChanged: isEditing
                              ? null // Disable scope change on edit for now
                              : (val) =>
                                  setDialogState(() => isGlobalPost = val!),
                        ),
                        RadioListTile<bool>(
                          contentPadding: EdgeInsets.zero,
                          title: Text(AppLocalizations.of(context)!
                              .postScopeAllSchools),
                          value: true,
                          groupValue: isGlobalPost,
                          onChanged: (isEditing || !canManagePublicPosts)
                              ? null
                              : (val) =>
                                  setDialogState(() => isGlobalPost = val!),
                          subtitle: !canManagePublicPosts
                              ? const Text("Requires higher permissions",
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.red))
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: isSubmitting ? null : handleSubmit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isEditing ? "Update" : "Create"),
                ),
              ],
            );
          },
        );
      },
    ).then((result) {
      if (result == true) _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Community Posts'),
        actions: [
          IconButton(
            icon: const Icon(IconsaxPlusLinear.add_square),
            onPressed: () => _showAddOrEditPostDialog(),
            tooltip: 'Add New Post',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.warning_2, color: Colors.red, size: 50),
              const SizedBox(height: 16),
              const Text("Failed to Load Posts",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_error!,
                  style: TextStyle(color: Colors.grey[700]),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                  icon: const Icon(Iconsax.refresh),
                  label: const Text("Retry"),
                  onPressed: _loadData)
            ],
          ),
        ),
      );
    }
    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.document_text, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text("No Posts Found",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Create a new post using the '+' button.",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    post.imageUrl != null && post.imageUrl!.isNotEmpty
                        ? CachedNetworkImageProvider(post.imageUrl!)
                        : null,
                child: (post.imageUrl == null || post.imageUrl!.isEmpty)
                    ? const Icon(IconsaxPlusLinear.gallery)
                    : null,
              ),
              title: Text(post.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(post.author),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(IconsaxPlusLinear.edit,
                          color: Colors.blue),
                      onPressed: () => _showAddOrEditPostDialog(post: post)),
                  IconButton(
                      icon: const Icon(IconsaxPlusLinear.trash,
                          color: Colors.red),
                      onPressed: () => _deletePost(post.id)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
