import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class PromoteAdminScreen extends StatefulWidget {
  final String schoolId;
  final String schoolName;

  const PromoteAdminScreen({
    super.key,
    required this.schoolId,
    required this.schoolName,
  });

  @override
  State<PromoteAdminScreen> createState() => _PromoteAdminScreenState();
}

class _PromoteAdminScreenState extends State<PromoteAdminScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final Map<String, String> _roleTranslations = {
    'user': 'ተጠቃሚ',
    'admin': 'አስተዳዳሪ',
    'superior_admin': 'የበላይ አስተዳዳሪ',
    'platform_admin': 'የፕላትፎርም አስተዳዳሪ',
    'library_admin': 'የቤተ-መጽሐፍት አስተዳዳሪ',
  };

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final result = await SystemAdminService.searchUsers(
      schoolId: widget.schoolId,
      limit: 1000,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _users = result['data']['users'] ?? [];
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "ተጠቃሚዎችን መጫን አልተቻለም።"),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query);
  }

  List<String> _parseRoles(String? roleString) {
    if (roleString == null || roleString.isEmpty) return ['user'];
    return roleString
        .split(',')
        .map((r) => r.trim())
        .where((r) => r.isNotEmpty)
        .toList();
  }

  bool _isSuperiorAdmin(Map<String, dynamic> user) {
    final roles = _parseRoles(user['role']?.toString());
    return roles.contains('superior_admin');
  }

  Future<void> _toggleSuperiorAdminStatus(
      Map<String, dynamic> user, bool shouldBeAdmin) async {
    final userName = user['full_name'] ?? 'ይህ ተጠቃሚ';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  shouldBeAdmin
                      ? '$userNameን በመሾም ላይ...'
                      : 'የ$userNameን ሚና በማዘመን ላይ...',
                  style: GoogleFonts.notoSansEthiopic(),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Map<String, dynamic> result;
    if (shouldBeAdmin) {
      result = await SystemAdminService.promoteToSuperiorAdmin(
          widget.schoolId, user['id']);
    } else {
      result = await SystemAdminService.removeSuperiorAdmin(
          widget.schoolId, user['id']);
    }

    if (!mounted) return;
    Navigator.pop(context);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('የ$userName ሚና በተሳካ ሁኔታ ተዘምኗል!',
              style: GoogleFonts.notoSansEthiopic()),
          backgroundColor: Colors.green,
        ),
      );
      await _loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ተጠቃሚውን ማዘመን አልተቻለም: ${result['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<dynamic> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((user) {
      final name = user['full_name']?.toString().toLowerCase() ?? '';
      final email = user['email']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Glassmorphic App Bar
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.of(context).pop(),
              color: isDark ? Colors.white : Colors.black87,
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Text(
                    'Manage Admins',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                primaryColor.withValues(alpha: 0.3),
                                Colors.black
                              ]
                            : [
                                primaryColor.withValues(alpha: 0.1),
                                Colors.white
                              ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 20,
                    right: 20,
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: _buildSearchBar(isDark, primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Info Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: FadeInUp(
                duration: const Duration(milliseconds: 700),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: primaryColor.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.info_circle, color: primaryColor, size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Promote users to Superior Admin for ${widget.schoolName}.',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Users List
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
              : _filteredUsers.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.user_search,
                                size: 64,
                                color: Colors.grey.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text('No users found for this school',
                                style: GoogleFonts.poppins(
                                    fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return FadeInUp(
                              duration: Duration(
                                  milliseconds: 400 + (index % 10 * 50)),
                              child: _buildUserCard(
                                  _filteredUsers[index], isDark, primaryColor),
                            );
                          },
                          childCount: _filteredUsers.length,
                        ),
                      ),
                    ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark, Color primaryColor) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        style: GoogleFonts.poppins(
            fontSize: 14, color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          prefixIcon:
              Icon(Iconsax.search_normal, color: primaryColor, size: 20),
          hintText: 'Search by name or email...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildUserCard(
      Map<String, dynamic> user, bool isDark, Color primaryColor) {
    final bool isSuperior = _isSuperiorAdmin(user);
    final List<String> roles = _parseRoles(user['role']?.toString());
    final bool isPlatformAdmin = roles.contains('platform_admin');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]!.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
        border: Border.all(
          color: isSuperior
              ? primaryColor.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: isSuperior
                  ? primaryColor
                  : primaryColor.withValues(alpha: 0.1),
              child: isPlatformAdmin
                  ? const Icon(Iconsax.crown_1, color: Colors.white, size: 24)
                  : Text(
                      (user['full_name']?.toString().isNotEmpty ?? false)
                          ? user['full_name'][0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          color: isSuperior ? Colors.white : primaryColor,
                          fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['full_name'] ?? 'Unknown User',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(user['email'] ?? 'No email',
                      style: GoogleFonts.poppins(
                          color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: roles
                        .map((role) => _buildMiniBadge(role, isDark))
                        .toList(),
                  ),
                ],
              ),
            ),
            if (isPlatformAdmin)
              const Icon(Iconsax.shield_tick, color: Colors.green, size: 24)
            else
              Switch.adaptive(
                value: isSuperior,
                activeColor: primaryColor,
                onChanged: (v) => _toggleSuperiorAdminStatus(user, v),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String role, bool isDark) {
    final label = _roleTranslations[role] ?? role.toUpperCase();
    final color = role.contains('admin') ? Colors.blue : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: GoogleFonts.notoSansEthiopic(
              fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
