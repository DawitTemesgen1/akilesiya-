// lib/admin only/manage_family.dart

import 'package:amde_haymanot_abalat_guday/services/admin_services.dart';
import 'package:amde_haymanot_abalat_guday/services/family_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

// ለተጠቃሚ ምርጫ ቀላል ሞዴል
class LinkUser {
  final String id;
  final String name;
  LinkUser({required this.id, required this.name});

  @override
  String toString() => name;
}

class ManageFamilyLinksScreen extends StatefulWidget {
  const ManageFamilyLinksScreen({super.key});
  @override
  State<ManageFamilyLinksScreen> createState() =>
      _ManageFamilyLinksScreenState();
}

class _ManageFamilyLinksScreenState extends State<ManageFamilyLinksScreen> {
  bool _isLoading = true;
  List<dynamic> _links = [];
  List<LinkUser> _allUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      final linksResult = await FamilyService.getAllFamilyLinks();
      final usersResult = await AdminService.getAllUsers();

      if (mounted) {
        if (linksResult['success'] && usersResult['success']) {
          setState(() {
            _links = linksResult['data'];
            _allUsers = (usersResult['data'] as List)
                .map((u) => LinkUser(
                    id: u['id'].toString(), name: u['full_name'] ?? 'ያልታወቀ'))
                .toList();
            _isLoading = false;
          });
        } else {
          throw Exception(linksResult['message'] ??
              usersResult['message'] ??
              'መረጃ መጫን አልተሳካም');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }

  void _showAddLinkDialog() {
    final formKey = GlobalKey<FormState>();
    LinkUser? selectedParent;
    LinkUser? selectedStudent;

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return AlertDialog(
                title: Text("አዲስ የቤተሰብ ትስስር ይፍጠሩ"),
                content: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ወላጅ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final result = await _showUserSelectionDialog(
                              _allUsers, "ወላጅ ይምረጡ");
                          if (result != null) {
                            setModalState(() => selectedParent = result);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(selectedParent?.name ?? "ወላጅ ይምረጡ..."),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      if (selectedParent == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                          child: Text("እባክዎ ወላጅ ይምረጡ",
                              style: TextStyle(
                                  color: Colors.red.shade700, fontSize: 12)),
                        ),
                      SizedBox(height: 24),
                      Text("ተማሪ",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final result = await _showUserSelectionDialog(
                              _allUsers, "ተማሪ ይምረጡ");
                          if (result != null) {
                            setModalState(() => selectedStudent = result);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(selectedStudent?.name ?? "ተማሪ ይምረጡ..."),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      if (selectedStudent == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                          child: Text("እባክዎ ተማሪ ይምረጡ",
                              style: TextStyle(
                                  color: Colors.red.shade700, fontSize: 12)),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("ይቅር")),
                  ElevatedButton(
                      onPressed: () async {
                        if (selectedParent == null || selectedStudent == null) {
                          setModalState(() {});
                          return;
                        }

                        if (selectedParent!.id == selectedStudent!.id) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("ወላጅ እና ተማሪ አንድ ሰው መሆን አይችሉም።"),
                              backgroundColor: Colors.red));
                          return;
                        }

                        final result = await FamilyService.createFamilyLink(
                            parentUserId: selectedParent!.id,
                            studentUserId: selectedStudent!.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(result['message'] ?? '...')));
                          if (result['success']) {
                            Navigator.pop(context);
                            _fetchInitialData();
                          }
                        }
                      },
                      child: Text("ትስስር ይፍጠሩ")),
                ],
              );
            },
          );
        });
  }

  Future<LinkUser?> _showUserSelectionDialog(
      List<LinkUser> users, String title) {
    return showDialog<LinkUser>(
      context: context,
      builder: (context) => _UserSearchDialog(allUsers: users, title: title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("የቤተሰብ ትስስሮችን ያቀናብሩ")),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'manage-family-fab',
        onPressed: _showAddLinkDialog,
        icon: Icon(Iconsax.add),
        label: Text("አዲስ ትስስር"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchInitialData,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: _links.length,
                itemBuilder: (context, index) {
                  final link = _links[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: Icon(Iconsax.user_octagon,
                          color: Theme.of(context).primaryColor),
                      title: Text(link['parent_name'],
                          style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.bold)),
                      subtitle: Row(
                        children: [
                          Icon(Iconsax.arrow_right_2,
                              size: 14, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                              child: Text(link['student_name'],
                                  style: GoogleFonts.notoSansEthiopic())),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Iconsax.trash, color: Colors.red.shade700),
                        onPressed: () async {
                          final result =
                              await FamilyService.deleteFamilyLink(link['id']);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(result['message'] ?? '...')));
                            if (result['success']) _fetchInitialData();
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// --- ለፍለጋ ዲያሎግ የተለየ መግብር ---
class _UserSearchDialog extends StatefulWidget {
  final List<LinkUser> allUsers;
  final String title;
  const _UserSearchDialog({required this.allUsers, required this.title});

  @override
  State<_UserSearchDialog> createState() => _UserSearchDialogState();
}

class _UserSearchDialogState extends State<_UserSearchDialog> {
  late List<LinkUser> _filteredUsers;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredUsers = widget.allUsers;
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredUsers = widget.allUsers.where((user) {
          return user.name.toLowerCase().contains(query);
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "በስም ይፈልጉ...",
                prefixIcon: Icon(Iconsax.search_normal_1),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return ListTile(
                    title: Text(user.name),
                    onTap: () {
                      Navigator.of(context).pop(user);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(), child: Text("ይቅር")),
      ],
    );
  }
}
