import 'dart:ui';
import 'package:amde_haymanot_abalat_guday/system%20admin/user_detail.dart';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  String _searchQuery = '';
  String _schoolFilter = '';
  String _roleFilter = '';
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _schools = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadSchools();
  }

  Future<void> _loadUsers({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
      });
    }

    final result = await SystemAdminService.searchUsers(
      query: _searchQuery,
      schoolId: _schoolFilter,
      role: _roleFilter,
      page: _currentPage,
      limit: _itemsPerPage,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'];
      setState(() {
        if (loadMore) {
          _users.addAll(data['users']);
        } else {
          _users = data['users'];
        }
        _hasMore = _currentPage < data['pagination']['totalPages'];
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSchools() async {
    final result = await SystemAdminService.getSchools();
    if (!mounted) return;
    if (result['success'] == true) {
      setState(() => _schools = result['data']['schools']);
    }
  }

  void _loadMore() {
    if (_hasMore && !_isLoading) {
      setState(() => _currentPage++);
      _loadUsers(loadMore: true);
    }
  }

  void _onSearch(String query) {
    _searchQuery = query;
    _loadUsers();
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
                    'User Management',
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

          // Filters Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: FadeInUp(
                duration: const Duration(milliseconds: 700),
                child: _buildFilters(isDark, primaryColor),
              ),
            ),
          ),

          // Users List
          _isLoading && _users.isEmpty
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()))
              : _users.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.user_search,
                                size: 64,
                                color: Colors.grey.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text('No users found',
                                style: GoogleFonts.poppins(
                                    fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.only(bottom: 20)
                          .copyWith(left: 20, right: 20, top: 10),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index == _users.length) {
                              _loadMore();
                              return const Padding(
                                padding: EdgeInsets.all(20),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            return FadeInUp(
                              duration: Duration(
                                  milliseconds: 400 + (index % 10 * 50)),
                              child: _buildUserCard(
                                  _users[index], isDark, primaryColor),
                            );
                          },
                          childCount: _users.length + (_hasMore ? 1 : 0),
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
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),
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

  Widget _buildFilters(bool isDark, Color primaryColor) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _schoolFilter.isEmpty ? null : _schoolFilter,
                hint: Text('All Schools',
                    style: GoogleFonts.poppins(fontSize: 12)),
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.white : Colors.black87),
                items: [
                  const DropdownMenuItem(value: '', child: Text('All Schools')),
                  ..._schools.map((s) => DropdownMenuItem(
                      value: s['id'].toString(),
                      child: Text(s['name'] ?? '',
                          overflow: TextOverflow.ellipsis))),
                ],
                onChanged: (v) {
                  setState(() => _schoolFilter = v ?? '');
                  _loadUsers();
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _roleFilter.isEmpty ? null : _roleFilter,
                hint: Text('Role', style: GoogleFonts.poppins(fontSize: 12)),
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: isDark ? Colors.white : Colors.black87),
                items: const [
                  DropdownMenuItem(value: '', child: Text('All')),
                  DropdownMenuItem(value: 'user', child: Text('Regular')),
                  DropdownMenuItem(
                      value: 'superior_admin', child: Text('Superior')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(
                      value: 'system_admin', child: Text('System')),
                ],
                onChanged: (v) {
                  setState(() => _roleFilter = v ?? '');
                  _loadUsers();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(
      Map<String, dynamic> user, bool isDark, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]!.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showUserActions(user),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Profile Image
                  Hero(
                    tag: 'user-${user['id']}',
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.1),
                        image: user['profile_image_url'] != null
                            ? DecorationImage(
                                image: NetworkImage(user['profile_image_url']),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: user['profile_image_url'] == null
                          ? Center(
                              child: Text(
                                  (user['full_name'] ?? 'U')[0].toUpperCase(),
                                  style: GoogleFonts.poppins(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)))
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['full_name'] ?? 'Unknown User',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          user['email'],
                          style: GoogleFonts.poppins(
                              color: Colors.grey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Iconsax.building,
                                size: 12, color: primaryColor.withOpacity(0.6)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                user['school_name'] ?? 'No School',
                                style: GoogleFonts.poppins(
                                    fontSize: 11, color: Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Role & Status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildRoleBadge(user['role'], isDark),
                      const SizedBox(height: 8),
                      _buildStatusIndicator(user['is_active'] == 1),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(Iconsax.arrow_right_3,
                      size: 16, color: Colors.grey.withOpacity(0.5)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role, bool isDark) {
    Color color;
    String label = role.toUpperCase();

    if (role.contains('system')) {
      color = Colors.purple;
    } else if (role.contains('superior')) {
      color = Colors.blue;
    } else if (role.contains('admin')) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
            fontSize: 9, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildStatusIndicator(bool isActive) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.green : Colors.red,
        boxShadow: [
          BoxShadow(
            color: (isActive ? Colors.green : Colors.red).withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  void _showUserActions(Map<String, dynamic> user) {
    final isDark =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            _buildActionItem(Iconsax.eye, 'View Details', () {
              Navigator.pop(context);
              _viewUserDetails(user);
            }, Colors.blue),
            _buildActionItem(
              user['is_active'] == 1 ? Iconsax.user_remove : Iconsax.user_tick,
              user['is_active'] == 1 ? 'Deactivate User' : 'Activate User',
              () {
                Navigator.pop(context);
                _toggleUserStatus(user);
              },
              user['is_active'] == 1 ? Colors.red : Colors.green,
            ),
            if (!user['role'].contains('superior_admin') &&
                !user['role'].contains('system_admin'))
              _buildActionItem(Iconsax.setting_4, 'Promote to Superior Admin',
                  () {
                Navigator.pop(context);
                _promoteToSuperiorAdmin(user);
              }, Colors.purple),
            if (user['role'].contains('superior_admin'))
              _buildActionItem(Iconsax.user_minus, 'Demote from Superior Admin',
                  () {
                Navigator.pop(context);
                _demoteFromSuperiorAdmin(user);
              }, Colors.orange),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
      IconData icon, String label, VoidCallback onTap, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label,
          style:
              GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _promoteToSuperiorAdmin(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => FadeInScale(
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Promote User',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Promote ${user['full_name']} to Superior Admin?',
                  style: GoogleFonts.poppins(fontSize: 14)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  'This user will gain administrative privileges for their school.',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: Colors.purple[700]),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style: GoogleFonts.poppins(color: Colors.grey))),
            ElevatedButton(
              onPressed: () => _confirmPromotion(user),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: const Text('Promote'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmPromotion(Map<String, dynamic> user) async {
    Navigator.pop(context);
    _showLoadingDialog('Promoting ${user['full_name']}...');

    try {
      final result = await SystemAdminService.promoteToSuperiorAdmin(
          user['tenant_id'], user['id']);
      if (!mounted) return;
      Navigator.pop(context);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('User promoted successfully!'),
            backgroundColor: Colors.green));
        _loadUsers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed: ${result['message']}'),
            backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _demoteFromSuperiorAdmin(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Demotion coming soon!'),
        backgroundColor: Colors.orange));
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message, style: GoogleFonts.poppins()),
            ],
          ),
        ),
      ),
    );
  }

  void _viewUserDetails(Map<String, dynamic> user) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserDetailsScreen(userId: user['id'])));
  }

  void _toggleUserStatus(Map<String, dynamic> user) async {
    final result = await SystemAdminService.toggleUserStatus(
        user['id'], user['is_active'] != 1);
    if (!mounted) return;
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message']), backgroundColor: Colors.green));
      _loadUsers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message']), backgroundColor: Colors.red));
    }
  }
}

class FadeInScale extends StatefulWidget {
  final Widget child;
  const FadeInScale({super.key, required this.child});
  @override
  State<FadeInScale> createState() => _FadeInScaleState();
}

class _FadeInScaleState extends State<FadeInScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
        scale: _animation,
        child: FadeTransition(opacity: _animation, child: widget.child));
  }
}
