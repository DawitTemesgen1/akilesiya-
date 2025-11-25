import 'dart:typed_data';
import 'package:amde_haymanot_abalat_guday/users%20screen/homepage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer';
// Import the intl package for date formatting
import 'package:intl/intl.dart';

import 'package:amde_haymanot_abalat_guday/services/public_feed_service.dart';

class AdminPublicPostManagementScreen extends StatefulWidget {
  const AdminPublicPostManagementScreen({super.key});

  @override
  State<AdminPublicPostManagementScreen> createState() =>
      _AdminPublicPostManagementScreenState();
}

class _AdminPublicPostManagementScreenState
    extends State<AdminPublicPostManagementScreen> {
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await PublicFeedService.getPublicPosts();
      if (mounted) {
        if (result['success']) {
          setState(() {
            _posts =
                (result['data'] as List).map((p) => Post.fromJson(p)).toList();
            _isLoading = false;
          });
        } else {
          throw Exception(result['message']);
        }
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString().replaceAll("Exception: ", "");
          _isLoading = false;
        });
    }
  }

  Future<void> _deletePost(String postId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
            'Are you sure you want to permanently delete this public post?'),
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
      final result = await PublicFeedService.deletePublicPost(postId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? '...'),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ));
        if (result['success']) {
          _loadData();
        }
      }
    }
  }

  void _showAddOrEditPostDialog({Post? post}) {
    final formKey = GlobalKey<FormState>();
    final isEditing = post != null;
    final titleController = TextEditingController(text: post?.title ?? '');
    final descriptionController =
        TextEditingController(text: post?.description ?? '');
    final imageUrlController =
        TextEditingController(text: post?.imageUrl ?? '');
    // ==========================================================
    // --- NEW CONTROLLERS FOR EVENT DETAILS ---
    // ==========================================================
    final locationController =
        TextEditingController(text: post?.location ?? '');
    DateTime? selectedEventDate = post?.eventDate;

    PostType selectedType = post?.type ?? PostType.news;
    bool isImportant = post?.isImportant ?? false;
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
                });
              }
            }

            Future<void> handleSubmit() async {
              if (!formKey.currentState!.validate() || isSubmitting) return;

              // ==========================================================
              // --- VALIDATE EVENT DATE ---
              // ==========================================================
              if (selectedType == PostType.event && selectedEventDate == null) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(
                    content:
                        Text("Event date and time are required for events."),
                    backgroundColor: Colors.red));
                return;
              }

              setDialogState(() => isSubmitting = true);
              // ==========================================================
              // --- ADDED NEW FIELDS TO THE REQUEST ---
              // ==========================================================
              Map<String, String> fields = {
                'title': titleController.text,
                'description': descriptionController.text,
                'type': selectedType.name,
                'isImportant': isImportant.toString(),
                'imageUrl':
                    selectedImageXFile == null ? imageUrlController.text : '',
                if (selectedType == PostType.event) ...{
                  'location': locationController.text,
                  if (selectedEventDate != null)
                    'eventDate': selectedEventDate!.toIso8601String(),
                }
              };

              try {
                Map<String, dynamic> result;
                if (isEditing) {
                  result = await PublicFeedService.updatePublicPost(
                      post!.id, Map<String, dynamic>.from(fields));
                } else {
                  if (selectedImageXFile != null) {
                    result = await PublicFeedService.createPublicPostWithImage(
                      fields: fields,
                      file: selectedImageXFile!,
                    );
                  } else {
                    result = await PublicFeedService.createPublicPost(
                        Map<String, dynamic>.from(fields));
                  }
                }
                if (!Navigator.of(dialogContext).mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(
                  content: Text(result['message'] ?? 'Operation failed.'),
                  backgroundColor:
                      result['success'] ? Colors.green : Colors.red,
                ));
                if (result['success']) {
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
              title:
                  Text(isEditing ? "Edit Public Post" : "Create Public Post"),
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
                                icon: const Icon(Iconsax.gallery),
                                label: const Text("Gallery"),
                                onPressed: () =>
                                    pickImage(ImageSource.gallery)),
                            ElevatedButton.icon(
                                icon: const Icon(Iconsax.camera),
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
                          value: selectedType,
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
                        // ==========================================================
                        // --- NEW CONDITIONAL FIELDS FOR EVENTS ---
                        // ==========================================================
                        if (selectedType == PostType.event) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: locationController,
                            decoration: const InputDecoration(
                              labelText: "Event Location*",
                              prefixIcon: Icon(Iconsax.location),
                            ),
                            validator: (v) {
                              if (selectedType == PostType.event &&
                                  (v == null || v.isEmpty)) {
                                return 'Location is required for events';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Iconsax.calendar_1),
                            title: const Text("Event Date & Time*"),
                            subtitle: Text(
                              selectedEventDate == null
                                  ? 'Tap to select date and time'
                                  : DateFormat('E, MMM d, yyyy @ h:mm a')
                                      .format(selectedEventDate!),
                            ),
                            onTap: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate:
                                    selectedEventDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null && context.mounted) {
                                final TimeOfDay? pickedTime =
                                    await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                      selectedEventDate ?? DateTime.now()),
                                );
                                if (pickedTime != null) {
                                  setDialogState(() {
                                    selectedEventDate = DateTime(
                                      pickedDate.year,
                                      pickedDate.month,
                                      pickedDate.day,
                                      pickedTime.hour,
                                      pickedTime.minute,
                                    );
                                  });
                                }
                              }
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text("Important Post"),
                          value: isImportant,
                          onChanged: (val) =>
                              setDialogState(() => isImportant = val),
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
      if (result == true) {
        _loadData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Public Posts'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add_square),
            onPressed: () => _showAddOrEditPostDialog(),
            tooltip: 'Add New Public Post',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
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
            Text("No Public Posts Found",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Create a new public post using the '+' button.",
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
                    ? const Icon(Iconsax.gallery)
                    : null,
              ),
              title: Text(post.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(post.author),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Iconsax.edit, color: Colors.blue),
                      onPressed: () => _showAddOrEditPostDialog(post: post)),
                  IconButton(
                      icon: const Icon(Iconsax.trash, color: Colors.red),
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
