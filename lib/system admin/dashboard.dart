import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/schools_list.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/user_management.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/audit_logs.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/platform_analytics.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/system_settings.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SystemAdminDashboard extends StatefulWidget {
  const SystemAdminDashboard({super.key});

  @override
  State<SystemAdminDashboard> createState() => _SystemAdminDashboardState();
}

class _SystemAdminDashboardState extends State<SystemAdminDashboard> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final result = await SystemAdminService.getDashboardStats();
    if (mounted) {
      if (result['success'] == true) {
        setState(() => _dashboardData = result['data']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  int _safeParseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
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
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Text(
                    'System Admin',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            primaryColor.withOpacity(0.2),
                            Colors.black.withOpacity(0.1),
                          ]
                        : [
                            primaryColor.withOpacity(0.1),
                            Colors.white.withOpacity(0.5),
                          ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Iconsax.refresh, color: primaryColor),
                onPressed: _loadDashboardData,
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _isLoading
                  ? _buildShimmerGrid(isDark)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeInDown(
                          duration: const Duration(milliseconds: 500),
                          child: _buildHeaderSection(context, isDark),
                        ),
                        const SizedBox(height: 24),
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: _buildStatGrid(context, isDark),
                        ),
                        const SizedBox(height: 32),
                        FadeInUp(
                          duration: const Duration(milliseconds: 700),
                          child: _buildQuickActionsSection(context, isDark),
                        ),
                        const SizedBox(height: 32),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: _buildRecentActivitySection(context, isDark),
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

  Widget _buildHeaderSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ሰላም፣ የስርዓት አስተዳዳሪ',
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'የአጠቃላይ መድረኩን ሁኔታ እዚህ መከታተል ይችላሉ',
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatGrid(BuildContext context, bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildStatCard(
          'Schools',
          _dashboardData?['schools']?['total_schools'],
          Iconsax.teacher,
          Colors.blue,
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SchoolsListScreen())),
          isDark,
        ),
        _buildStatCard(
          'Active Schools',
          _dashboardData?['schools']?['active_schools'],
          Iconsax.building_4,
          Colors.green,
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SchoolsListScreen())),
          isDark,
        ),
        _buildStatCard(
          'Total Users',
          _dashboardData?['users']?['total_users'],
          Iconsax.profile_2user,
          Colors.orange,
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UserManagementScreen())),
          isDark,
        ),
        _buildStatCard(
          'Active Users',
          _dashboardData?['users']?['active_users'],
          Iconsax.user_tick,
          Colors.purple,
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UserManagementScreen())),
          isDark,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, dynamic value, IconData icon, Color color,
      VoidCallback onTap, bool isDark) {
    final int safeValue = _safeParseInt(value);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]!.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const Spacer(),
                Text(
                  safeValue.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'ፈጣን እርምጃዎች (Quick Actions)',
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildModernActionCard(
          'የአብያተ ክርስቲያናት ስራ አመራር',
          'Schools Management',
          Iconsax.teacher,
          Colors.blue,
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SchoolsListScreen())),
          isDark,
        ),
        const SizedBox(height: 12),
        _buildModernActionCard(
          'የተጠቃሚዎች ስራ አመራር',
          'User Management',
          Iconsax.profile_2user,
          Colors.orange,
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const UserManagementScreen())),
          isDark,
        ),
        const SizedBox(height: 12),
        _buildModernActionCard(
          'የአጠቃቀም መረጃዎች',
          'Platform Analytics',
          Iconsax.diagram,
          Colors.green,
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const PlatformAnalyticsScreen())),
          isDark,
        ),
        const SizedBox(height: 12),
        _buildModernActionCard(
          'የስርዓት እንቅስቃሴ መዝገብ',
          'Audit Report',
          Iconsax.document_text,
          Colors.purple,
          () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AuditLogsScreen())),
          isDark,
        ),
        const SizedBox(height: 12),
        _buildModernActionCard(
          'የስርዓት ቅንብሮች',
          'System Settings',
          Iconsax.setting_2,
          Colors.grey,
          () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SystemSettingsScreen())),
          isDark,
        ),
      ],
    );
  }

  Widget _buildModernActionCard(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]!.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Iconsax.arrow_right_3,
                    size: 18, color: color.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context, bool isDark) {
    final recentActivity = _dashboardData?['recentActivity'] ?? [];
    if (recentActivity.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'የቅርብ ጊዜ እንቅስቃሴዎች (Recent)',
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900]!.withOpacity(0.5) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[200]!,
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentActivity.length > 5 ? 5 : recentActivity.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: isDark ? Colors.white10 : Colors.grey[100],
            ),
            itemBuilder: (context, index) {
              final activity = recentActivity[index];
              return ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.activity,
                      size: 20, color: Colors.blue),
                ),
                title: Text(
                  activity['school_name'] ?? 'Unknown School',
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${_safeParseInt(activity['active_members'])} ንቁ አባላት',
                  style: GoogleFonts.notoSansEthiopic(fontSize: 12),
                ),
                trailing: Text(
                  _formatLastActivity(activity['last_activity']),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatLastActivity(dynamic lastActivity) {
    if (lastActivity == null) return 'No activity';
    try {
      final date = DateTime.tryParse(lastActivity.toString());
      if (date == null) return 'Recently';

      final difference = DateTime.now().difference(date);
      if (difference.inDays > 1) return '${difference.inDays}d ago';
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inHours > 0) return '${difference.inHours}h ago';
      if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
      return 'Just now';
    } catch (e) {
      return 'Recently';
    }
  }

  Widget _buildShimmerGrid(bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: List.generate(4, (index) => _buildShimmerBox(isDark)),
    );
  }

  Widget _buildShimmerBox(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
