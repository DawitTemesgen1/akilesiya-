// lib/screens/admin/all_members_screen.dart

import 'package:amde_haymanot_abalat_guday/services/admin_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';

// --- UI Theme Constants ---
// Replaced by ThemeProvider
// const Color kAdminPrimary = Color.fromARGB(255, 1, 37, 100);
// const Color kAdminAccent = Color(0xFFFFD700);

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

  // Theme Getters
  Color get primaryColor =>
      Provider.of<ThemeProvider>(context).getPrimaryColor(context);
  Color get backgroundColor =>
      Provider.of<ThemeProvider>(context).getBackgroundColor(context);
  Color get surfaceColor =>
      Provider.of<ThemeProvider>(context).getSurfaceColor(context);
  Color get onSurfaceColor =>
      Provider.of<ThemeProvider>(context).getOnSurfaceColor(context);
  Color get subtleTextColor =>
      Provider.of<ThemeProvider>(context).getSubtleTextColor(context);

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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Select a Member', style: TextStyle(color: onSurfaceColor)),
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintStyle: TextStyle(color: onSurfaceColor.withValues(alpha: 0.7)),
                prefixIcon: Icon(Iconsax.search_normal_1,
                    color: onSurfaceColor.withValues(alpha: 0.7)),
                filled: true,
                fillColor: surfaceColor,
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
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              onRefresh: _fetchUsers,
              color: primaryColor,
              backgroundColor: surfaceColor,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  return Card(
                    color: surfaceColor,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.white10)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: primaryColor,
                        child: Icon(Iconsax.user, color: Colors.white),
                      ),
                      title: Text(
                        user['full_name'] ?? 'No Name',
                        style: GoogleFonts.notoSansEthiopic(
                            fontWeight: FontWeight.bold, color: onSurfaceColor),
                      ),
                      subtitle: Text(user['email'] ?? 'No Email',
                          style: TextStyle(
                              color: onSurfaceColor.withValues(alpha: 0.7))),
                      trailing:
                          Icon(Iconsax.arrow_right_3, color: onSurfaceColor),
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
