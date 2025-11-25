// lib/screens/admin/all_members_screen.dart

import 'package:amde_haymanot_abalat_guday/services/admin_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

// --- UI Theme Constants ---
const Color kAdminPrimary = Color.fromARGB(255, 1, 37, 100);
const Color kAdminAccent = Color(0xFFFFD700);

class AllMembersScreen extends StatefulWidget {
  const AllMembersScreen({super.key});

  @override
  State<AllMembersScreen> createState() => _AllMembersScreenState();
}

class _AllMembersScreenState extends State<AllMembersScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    final result = await AdminService.getAllUsers();
    if (mounted) {
      if (result['success']) {
        setState(() {
          _allUsers = List<Map<String, dynamic>>.from(result['data']);
          _filteredUsers = _allUsers;
          _isLoading = false;
        });
      } else {
        // Handle error
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? 'Failed to fetch users.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final name = (user['full_name'] as String? ?? '').toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAdminPrimary,
      appBar: AppBar(
        title: const Text('Select a Member'),
        backgroundColor: kAdminPrimary,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon:
                    const Icon(Iconsax.search_normal_1, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAdminAccent))
          : RefreshIndicator(
              onRefresh: _fetchUsers,
              color: kAdminAccent,
              backgroundColor: kAdminPrimary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return Card(
                    color: Colors.white.withOpacity(0.1),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: kAdminAccent,
                        child: Icon(Iconsax.user, color: kAdminPrimary),
                      ),
                      title: Text(
                        user['full_name'] ?? 'No Name',
                        style: GoogleFonts.notoSansEthiopic(
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(user['email'] ?? 'No Email'),
                      trailing: const Icon(Iconsax.arrow_right_3),
                      onTap: () {
                        // Navigate to the development screen, passing the user data
                        context.push('/admin/member-development', extra: user);
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
