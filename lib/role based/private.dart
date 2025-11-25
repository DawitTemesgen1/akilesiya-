// lib/screens/admin/member_development_hub_screen.dart

import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/admin_services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

// --- Amharic Localization Strings for Member Development Hub ---
abstract class AmharicStringsDevelopmentHub {
  static const String screenTitle = 'የአባላት ዕድገት ማዕከል';
  static const String tabMembers = 'አባላት';
  static const String tabPermissions = 'ፈቃዶች';
  static const String searchHint = 'በአባል ስም ይፈልጉ...';
  static const String loading = 'በመጫን ላይ...';
  static const String fetchUsersFailed = 'ተጠቃሚዎችን መጫን አልተሳካም።';
  static const String developmentAdmins = 'የዕድገት አስተዳዳሪዎች';
  static const String adminDescription =
      'እነዚህ ተጠቃሚዎች የሁሉንም አባላት የዕድገት ማስታወሻዎች ማየት እና ማስተዳደር ይችላሉ።';
  static const String noAdminsAssigned = 'ለዚህ ሚና የተመደቡ አስተዳዳሪዎች የሉም።';
  static const String removeRole = 'ሚና አስወግድ';
  static const String addDevelopmentAdmin = 'የዕድገት አስተዳዳሪ ጨምር';
  static const String addRole = 'ሚና ጨምር';
  static const String fetchCandidatesFailed = 'ተጠቃሚዎችን ማምጣት አልተቻለም።';
  static const String noEligibleUsers = 'ለማስተዋወቅ ብቁ የሆኑ ተጠቃሚዎች የሉም።';
  static const String addAdminDialogTitle = 'የዕድገት አስተዳዳሪ ጨምር';
  static const String genericError = 'ስህተት ተከስቷል።';
  static const String roleUpdateSuccess = 'ሚናው በተሳካ ሁኔታ ተዘምኗል።';
  static const String memberProfileLink = 'የአባል ገጽ';
  static const String removeRoleTooltip = 'ሚናውን ያስወግዱ';
}

// --- UI Theme Constants ---
const Color kAdminPrimary = Color.fromARGB(255, 1, 37, 100);
const Color kAdminAccent = Color(0xFFFFD700);
const Color kAdminCard = Color(0xFF1E293B);

// Simple User model for this screen
class AdminUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final List<String> roles;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.roles,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    final roleString = json['role'] as String? ?? 'user';
    final roles = roleString.split(',').where((r) => r.isNotEmpty).toList();

    return AdminUser(
      id: json['id'].toString(),
      name: json['full_name'] ?? 'ስም አልተሰጠም',
      email: json['email'] ?? 'ኢሜይል የለም',
      avatarUrl: json['profile_image_url'],
      roles: roles,
    );
  }
}

class MemberDevelopmentHubScreen extends StatefulWidget {
  const MemberDevelopmentHubScreen({super.key});

  @override
  State<MemberDevelopmentHubScreen> createState() =>
      _MemberDevelopmentHubScreenState();
}

class _MemberDevelopmentHubScreenState extends State<MemberDevelopmentHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<AdminUser> _allUsers = [];

  List<AdminUser> _filteredUsers = [];
  final _searchController = TextEditingController();

  // Flag to determine if the current user has superior privileges
  bool _isSuperiorAdmin = false;

  @override
  void initState() {
    super.initState();
    // Use 'listen: false' in initState to read the provider's initial state
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _isSuperiorAdmin = userProvider.roles.contains('superior_admin');

    // Tab controller length now depends on the user's role
    _tabController =
        TabController(length: _isSuperiorAdmin ? 2 : 1, vsync: this);

    _fetchAllUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllUsers() async {
    setState(() => _isLoading = true);
    final result = await AdminService.getAllUsers();
    if (mounted && result['success']) {
      setState(() {
        _allUsers =
            (result['data'] as List).map((u) => AdminUser.fromJson(u)).toList();
        _filterUsers();
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
      _showSnackbar(
          result['message'] ?? AmharicStringsDevelopmentHub.fetchUsersFailed,
          isError: true); // Translated
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        return user.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showSnackbar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: GoogleFonts.notoSansEthiopic()), // Use Amharic font
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAdminPrimary,
      appBar: AppBar(
        title: Text(AmharicStringsDevelopmentHub.screenTitle,
            style: GoogleFonts.notoSansEthiopic(
                fontWeight: FontWeight.bold)), // Translated
        backgroundColor: kAdminPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kAdminAccent,
          labelColor: kAdminAccent,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
                icon: const Icon(Iconsax.user),
                text: AmharicStringsDevelopmentHub.tabMembers), // Translated
            // Only show the Permissions tab if the user is a superior admin
            if (_isSuperiorAdmin)
              Tab(
                  icon: const Icon(Iconsax.user_tick),
                  text: AmharicStringsDevelopmentHub
                      .tabPermissions), // Translated
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAdminAccent))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSelectMemberTab(),
                // Conditionally build the permissions tab
                if (_isSuperiorAdmin) _buildPermissionsTab(),
              ],
            ),
    );
  }

  // --- TAB BUILDERS ---

  Widget _buildSelectMemberTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.notoSansEthiopic(
                color: Colors.white), // Use Amharic font
            decoration: InputDecoration(
              hintText: AmharicStringsDevelopmentHub.searchHint, // Translated
              hintStyle: GoogleFonts.notoSansEthiopic(
                  color: Colors.white70), // Use Amharic font
              prefixIcon:
                  const Icon(Iconsax.search_normal_1, color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchAllUsers,
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
                    leading: Hero(
                      tag: 'user_avatar_${user.id}',
                      child: const CircleAvatar(
                        backgroundColor: kAdminAccent,
                        child: Icon(Iconsax.user, color: kAdminPrimary),
                      ),
                    ),
                    title: Hero(
                      tag: 'user_name_${user.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          user.name,
                          style: GoogleFonts.notoSansEthiopic(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    subtitle: Text(
                      user.email,
                      style: GoogleFonts.notoSansEthiopic(
                        color: Colors.white70,
                      ),
                    ),
                    trailing: const Icon(
                      Iconsax.arrow_right_3,
                      color: Colors.white70,
                    ),
                    onTap: () {
                      context.push('/admin/member-development/notes', extra: {
                        'id': user.id,
                        'full_name': user.name,
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsTab() {
    const String role = 'development_admin';
    final admins =
        _allUsers.where((user) => user.roles.contains(role)).toList();

    return RefreshIndicator(
      onRefresh: _fetchAllUsers,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(AmharicStringsDevelopmentHub.developmentAdmins, // Translated
              style: GoogleFonts.notoSansEthiopic(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            AmharicStringsDevelopmentHub.adminDescription, // Translated
            style: GoogleFonts.notoSansEthiopic(
                color: Colors.white70), // Use Amharic font
          ),
          const SizedBox(height: 16),
          if (admins.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48.0),
              child: Center(
                  child: Text(
                      AmharicStringsDevelopmentHub
                          .noAdminsAssigned, // Translated
                      style: GoogleFonts.notoSansEthiopic(
                          color: Colors.white70))), // Use Amharic font
            )
          else
            ...admins.map((admin) => Card(
                  color: kAdminCard,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                        child: Text(admin.name.isNotEmpty ? admin.name[0] : '?',
                            style: GoogleFonts
                                .notoSansEthiopic())), // Use Amharic font
                    title: Text(admin.name,
                        style: GoogleFonts.notoSansEthiopic(
                            color: Colors.white)), // Use Amharic font
                    subtitle: Text(
                        admin.roles.join(', ').replaceAll('development_admin',
                            'የዕድገት አስተዳዳሪ'), // Translate role in join
                        style: GoogleFonts.notoSansEthiopic(
                            color: Colors.white70,
                            fontSize: 12)), // Use Amharic font
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline,
                          color: Colors.redAccent),
                      onPressed: () => _updateRole(admin, role, 'remove'),
                      tooltip: AmharicStringsDevelopmentHub
                          .removeRoleTooltip, // Translated
                    ),
                  ),
                )),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAdminAccent.withOpacity(0.2),
              foregroundColor: kAdminAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => _showAddAdminDialog(role),
            icon: const Icon(Icons.add),
            label: Text(
                AmharicStringsDevelopmentHub.addDevelopmentAdmin, // Translated
                style: GoogleFonts.notoSansEthiopic(
                    fontWeight: FontWeight.bold)), // Use Amharic font
          ),
        ],
      ),
    );
  }

  // --- ROLE MANAGEMENT LOGIC ---
  Future<void> _showAddAdminDialog(String role) async {
    // Show a loading indicator while fetching candidates
    showDialog(
        context: context,
        builder: (_) => Center(
            child: CircularProgressIndicator(
                color: kAdminAccent,
                valueColor:
                    AlwaysStoppedAnimation(kAdminAccent)))); // Use kAdminAccent

    // This fetches users who are NOT already development admins
    final result = await AdminService.getDevelopmentAdminCandidates();

    Navigator.pop(context); // Dismiss loading indicator

    if (!mounted || !result['success']) {
      _showSnackbar(
          result['message'] ??
              AmharicStringsDevelopmentHub.fetchCandidatesFailed,
          isError: true); // Translated
      return;
    }

    // We filter the candidates to ensure we don't show users who already have the role,
    // which can happen if they have multiple roles.
    final allCandidates =
        (result['data'] as List).map((u) => AdminUser.fromJson(u)).toList();
    final eligibleCandidates = allCandidates
        .where((user) => !_allUsers
            .firstWhere((u) => u.id == user.id, orElse: () => user)
            .roles
            .contains(role)) // Use orElse for safety
        .toList();

    final AdminUser? selectedUser = await showDialog<AdminUser>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kAdminCard,
        title: Text(
            AmharicStringsDevelopmentHub.addDevelopmentAdmin, // Translated
            style: GoogleFonts.notoSansEthiopic(
                color: Colors.white)), // Use Amharic font
        content: SizedBox(
          width: double.maxFinite,
          child: eligibleCandidates.isEmpty
              ? Text(AmharicStringsDevelopmentHub.noEligibleUsers, // Translated
                  style: GoogleFonts.notoSansEthiopic(
                      color: Colors.white70)) // Use Amharic font
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: eligibleCandidates.length,
                  itemBuilder: (context, index) {
                    final user = eligibleCandidates[index];
                    return ListTile(
                      title: Text(user.name,
                          style: GoogleFonts.notoSansEthiopic(
                              color: Colors.white)), // Use Amharic font
                      onTap: () => Navigator.of(context).pop(user),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('ይቅር',
                style: GoogleFonts.notoSansEthiopic(
                    color: kAdminAccent)), // Translated
          ),
        ],
      ),
    );

    if (selectedUser != null) {
      _updateRole(selectedUser, role, 'add');
    }
  }

  Future<void> _updateRole(AdminUser user, String role, String action) async {
    final result = await AdminService.updateUserRoles(
        userId: user.id, role: role, action: action);

    if (mounted) {
      _showSnackbar(
          result['message'] ?? AmharicStringsDevelopmentHub.genericError,
          isError: !result['success']); // Translated
      if (result['success']) {
        _fetchAllUsers();
      }
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return split('_')
        .map((str) =>
            str.isNotEmpty ? str[0].toUpperCase() + str.substring(1) : '')
        .join(' ');
  }
}
