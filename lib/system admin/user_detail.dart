import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId;

  const UserDetailsScreen({super.key, required this.userId});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    setState(() => _isLoading = true);
    final result = await SystemAdminService.getUserDetails(widget.userId);
    if (result['success'] == true) {
      setState(() => _userData = result['data']);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message']), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode(context);
    final primaryColor = Theme.of(context).primaryColor;
    final user = _userData?['user'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : user == null
              ? _buildErrorView(isDark, primaryColor)
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Glassmorphic App Bar
                    SliverAppBar(
                      expandedHeight: 220.0,
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
                              user['full_name'] ?? 'User Profile',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
                            Center(
                              child: FadeInDown(
                                duration: const Duration(milliseconds: 600),
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                          color: primaryColor.withValues(
                                              alpha: 0.2),
                                          blurRadius: 20,
                                          spreadRadius: 5)
                                    ],
                                    image: user['profile_image_url'] != null
                                        ? DecorationImage(
                                            image: NetworkImage(
                                                user['profile_image_url']),
                                            fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: user['profile_image_url'] == null
                                      ? Center(
                                          child: Text(
                                              (user['full_name'] ?? 'U')[0]
                                                  .toUpperCase(),
                                              style: GoogleFonts.poppins(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor)))
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        IconButton(
                            icon: Icon(Iconsax.refresh, color: primaryColor),
                            onPressed: _loadUserDetails),
                        const SizedBox(width: 8),
                      ],
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // Status & Role Badges
                            FadeInUp(
                              duration: const Duration(milliseconds: 700),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildBadge(
                                      user['role'].toString().toUpperCase(),
                                      Colors.blue,
                                      isDark),
                                  const SizedBox(width: 12),
                                  _buildBadge(
                                      user['is_active'] == 1
                                          ? 'ACTIVE'
                                          : 'INACTIVE',
                                      user['is_active'] == 1
                                          ? Colors.green
                                          : Colors.red,
                                      isDark),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Info Cards
                            FadeInUp(
                              duration: const Duration(milliseconds: 800),
                              child: _buildInfoCard(
                                  'Account Information',
                                  Iconsax.user,
                                  [
                                    _buildInfoRow(Iconsax.profile_2user,
                                        'Full Name', user['full_name']),
                                    _buildInfoRow(Iconsax.sms, 'Email Address',
                                        user['email']),
                                    _buildInfoRow(
                                        Iconsax.bank,
                                        'Associated School',
                                        user['school_name']),
                                    _buildInfoRow(
                                        Iconsax.verify,
                                        'Account Verified',
                                        user['is_verified'] == 1
                                            ? 'Yes'
                                            : 'No'),
                                  ],
                                  isDark,
                                  primaryColor),
                            ),
                            const SizedBox(height: 20),
                            FadeInUp(
                              duration: const Duration(milliseconds: 900),
                              child: _buildInfoCard(
                                  'Activity History',
                                  Iconsax.activity,
                                  [
                                    _buildInfoRow(
                                        Iconsax.login,
                                        'Last Login',
                                        user['last_login'] != null
                                            ? _formatDate(user['last_login'])
                                            : 'Never'),
                                    _buildInfoRow(
                                        Iconsax.calendar_add,
                                        'Registered On',
                                        _formatDate(user['created_at'])),
                                    if (user['tenant_id'] != null)
                                      _buildInfoRow(Iconsax.key, 'Tenant ID',
                                          user['tenant_id'].toString()),
                                  ],
                                  isDark,
                                  primaryColor),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildBadge(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children,
      bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]!.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 20),
              const SizedBox(width: 12),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              Text(value ?? 'Not available',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(bool isDark, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.user_remove,
              size: 64, color: Colors.red.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('User not found or error loading data',
              style: GoogleFonts.poppins(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
              onPressed: _loadUserDetails, child: const Text('Try Again')),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
