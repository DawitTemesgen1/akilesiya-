// lib/screens/admin/member_development_hub_screen.dart

import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/admin_services.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';

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
      content: Text(message, style: GoogleFonts.notoSansEthiopic()),
      backgroundColor:
          isError ? ThemeProvider.dangerColor : ThemeProvider.successColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  String _getAbsoluteUrl(String path) {
    if (path.isEmpty) return "";
    if (path.startsWith('http')) return path;

    try {
      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      final cleanBase = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
      final cleanPath = path.startsWith('/') ? path.substring(1) : path;

      return '$cleanBase/$cleanPath';
    } catch (_) {
      return path;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final bgColor = themeProvider.getBackgroundColor(context);
    final surfaceColor = themeProvider.getSurfaceColor(context);
    final primaryColor = themeProvider.getPrimaryColor(context);
    final textColor = themeProvider.getOnSurfaceColor(context);
    final subtleTextColor = themeProvider.getSubtleTextColor(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(AmharicStringsDevelopmentHub.screenTitle,
            style: GoogleFonts.notoSansEthiopic(
                fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: subtleTextColor,
          tabs: [
            Tab(
                icon: const Icon(Iconsax.user),
                text: AmharicStringsDevelopmentHub.tabMembers),
            if (_isSuperiorAdmin)
              Tab(
                  icon: const Icon(Iconsax.user_tick),
                  text: AmharicStringsDevelopmentHub.tabPermissions),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingShimmer(surfaceColor, subtleTextColor)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSelectMemberTab(
                    primaryColor, surfaceColor, textColor, subtleTextColor),
                if (_isSuperiorAdmin)
                  _buildPermissionsTab(
                      primaryColor, surfaceColor, textColor, subtleTextColor),
              ],
            ),
    );
  }

  Widget _buildLoadingShimmer(Color surfaceColor, Color subtleTextColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: surfaceColor,
        highlightColor: surfaceColor.withValues(alpha: 0.5),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 80,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // --- TAB BUILDERS ---

  Widget _buildSelectMemberTab(Color primaryColor, Color surfaceColor,
      Color textColor, Color subtleTextColor) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: textColor.withValues(alpha: 0.05)),
            ),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.notoSansEthiopic(color: textColor),
              decoration: InputDecoration(
                hintText: AmharicStringsDevelopmentHub.searchHint,
                hintStyle: GoogleFonts.notoSansEthiopic(color: subtleTextColor),
                prefixIcon: Icon(Iconsax.search_normal_1, color: primaryColor),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
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
                return FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: 50 * index),
                  child: Card(
                    color: surfaceColor,
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side:
                          BorderSide(color: textColor.withValues(alpha: 0.05)),
                    ),
                    child: ListTile(
                      leading: Hero(
                        tag: 'user_avatar_${user.id}',
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: primaryColor.withValues(alpha: 0.2)),
                          ),
                          child: CircleAvatar(
                            backgroundColor: surfaceColor,
                            backgroundImage: (user.avatarUrl != null &&
                                    user.avatarUrl!.isNotEmpty)
                                ? NetworkImage(_getAbsoluteUrl(user.avatarUrl!))
                                : null,
                            child: (user.avatarUrl == null ||
                                    user.avatarUrl!.isEmpty)
                                ? Icon(Iconsax.user, color: primaryColor)
                                : null,
                          ),
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: GoogleFonts.notoSansEthiopic(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      subtitle: Text(
                        user.email,
                        style: GoogleFonts.notoSansEthiopic(
                            color: subtleTextColor, fontSize: 13),
                      ),
                      trailing: Icon(Iconsax.arrow_right_3,
                          color: primaryColor, size: 18),
                      onTap: () {
                        context.push('/admin/member-development/notes', extra: {
                          'id': user.id,
                          'full_name': user.name,
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsTab(Color primaryColor, Color surfaceColor,
      Color textColor, Color subtleTextColor) {
    const String role = 'development_admin';
    final admins =
        _allUsers.where((user) => user.roles.contains(role)).toList();

    return RefreshIndicator(
      onRefresh: _fetchAllUsers,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(AmharicStringsDevelopmentHub.developmentAdmins,
              style: GoogleFonts.notoSansEthiopic(
                  fontSize: 22, color: textColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            AmharicStringsDevelopmentHub.adminDescription,
            style: GoogleFonts.notoSansEthiopic(color: subtleTextColor),
          ),
          const SizedBox(height: 24),
          if (admins.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48.0),
              child: Center(
                  child: Text(AmharicStringsDevelopmentHub.noAdminsAssigned,
                      style: GoogleFonts.notoSansEthiopic(
                          color: subtleTextColor))),
            )
          else
            ...admins.map((admin) => Card(
                  color: surfaceColor,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: textColor.withValues(alpha: 0.05)),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        foregroundColor: primaryColor,
                        child: Text(admin.name.isNotEmpty ? admin.name[0] : '?',
                            style: GoogleFonts.notoSansEthiopic(
                                fontWeight: FontWeight.bold))),
                    title: Text(admin.name,
                        style: GoogleFonts.notoSansEthiopic(
                            color: textColor, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        admin.roles
                            .join(', ')
                            .replaceAll('development_admin', 'የዕድገት አስተዳዳሪ'),
                        style: GoogleFonts.notoSansEthiopic(
                            color: subtleTextColor, fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Iconsax.minus_cirlce,
                          color: ThemeProvider.dangerColor),
                      onPressed: () => _updateRole(admin, role, 'remove'),
                      tooltip: AmharicStringsDevelopmentHub.removeRoleTooltip,
                    ),
                  ),
                )),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              foregroundColor: primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => _showAddAdminDialog(
                role, primaryColor, surfaceColor, textColor, subtleTextColor),
            icon: const Icon(Iconsax.add, size: 20),
            label: Text(AmharicStringsDevelopmentHub.addDevelopmentAdmin,
                style:
                    GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- ROLE MANAGEMENT LOGIC ---
  Future<void> _showAddAdminDialog(String role, Color primaryColor,
      Color surfaceColor, Color textColor, Color subtleTextColor) async {
    // Show a loading indicator while fetching candidates
    showDialog(
        context: context,
        builder: (_) =>
            Center(child: CircularProgressIndicator(color: primaryColor)));

    // This fetches users who are NOT already development admins
    final result = await AdminService.getDevelopmentAdminCandidates();

    if (!mounted) return;
    Navigator.pop(context); // Dismiss loading indicator

    if (!result['success']) {
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
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(AmharicStringsDevelopmentHub.addDevelopmentAdmin,
            style: GoogleFonts.notoSansEthiopic(
                color: textColor, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: eligibleCandidates.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                      AmharicStringsDevelopmentHub
                          .noEligibleUsers, // Translated
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSansEthiopic(
                          color: subtleTextColor)), // Use Amharic font
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: eligibleCandidates.length,
                  itemBuilder: (context, index) {
                    final user = eligibleCandidates[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        child: Text(user.name[0],
                            style: TextStyle(color: primaryColor)),
                      ),
                      title: Text(user.name,
                          style: GoogleFonts.notoSansEthiopic(
                              color: textColor,
                              fontWeight: FontWeight.w500)), // Use Amharic font
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
                    color: primaryColor,
                    fontWeight: FontWeight.bold)), // Translated
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
