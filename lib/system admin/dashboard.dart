import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/schools_list.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/user_management.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/audit_logs.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/platform_analytics.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/system_settings.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:iconsax/iconsax.dart';

class SystemAdminDashboard extends StatefulWidget {
  const SystemAdminDashboard({Key? key}) : super(key: key);

  @override
  State<SystemAdminDashboard> createState() => _SystemAdminDashboardState();
}

class _SystemAdminDashboardState extends State<SystemAdminDashboard> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  // Hero Tags for smooth navigation animations
  static const String _heroTagSchoolsTotal = 'sys-admin-hero-schools-total';
  static const String _heroTagSchoolsActive = 'sys-admin-hero-schools-active';
  static const String _heroTagUsersTotal = 'sys-admin-hero-users-total';
  static const String _heroTagUsersActive = 'sys-admin-hero-users-active';
  static const String _heroTagAnalytics = 'sys-admin-hero-analytics';
  static const String _heroTagAudit = 'sys-admin-hero-audit';
  static const String _heroTagSettings = 'sys-admin-hero-settings';

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

  Widget _buildStatCard(String title, dynamic value, IconData icon, Color color,
      String heroTag, VoidCallback onTap) {
    final int safeValue = _safeParseInt(value);

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4.0), // Default Card radius
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Hero(
                tag: heroTag,
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      safeValue.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.notoSansEthiopic(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon,
      String heroTag, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Hero(
                  tag: heroTag,
                  child: Icon(icon,
                      size: 30, color: Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.notoSansEthiopic(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final recentActivity = _dashboardData?['recentActivity'] ?? [];
    if (recentActivity.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)?.sysAdminRecentActivity ?? 'Recent Activity',
              style: GoogleFonts.notoSansEthiopic(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...recentActivity.take(5).map<Widget>((activity) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Iconsax.activity, color: Colors.blue),
                title: Text(
                  activity['school_name'] ?? (AppLocalizations.of(context)?.sysAdminUnknownSchool ?? 'Unknown School'),
                  style: GoogleFonts.notoSansEthiopic(fontSize: 14),
                ),
                subtitle: Text(
                  '${_safeParseInt(activity['active_members'])} ንቁ አባላት',
                  style: GoogleFonts.notoSansEthiopic(fontSize: 12),
                ),
                trailing: Text(
                  _formatLastActivity(activity['last_activity']),
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _formatLastActivity(dynamic lastActivity) {
    if (lastActivity == null) return 'ምንም እንቅስቃሴ የለም';
    try {
      final date = DateTime.tryParse(lastActivity.toString());
      if (date == null) return 'በቅርቡ';

      final difference = DateTime.now().difference(date);
      if (difference.inDays > 1) return 'ከ${difference.inDays} ቀናት በፊት';
      if (difference.inDays == 1) return 'ትላንት';
      if (difference.inHours > 0) return 'ከ${difference.inHours} ሰዓታት በፊት';
      if (difference.inMinutes > 0) return 'ከ${difference.inMinutes} ደቂቃዎች በፊት';
      return 'በቅርቡ';
    } catch (e) {
      return 'በቅርቡ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('የስርዓት አስተዳዳሪ ዳሽቦርድ', style: GoogleFonts.notoSansEthiopic()),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'ዳግም አስጀምር',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('ዳሽቦርድ በማዘጋጀት ላይ...',
                      style: GoogleFonts.notoSansEthiopic()),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)?.managementPageTitle ?? 'Management',
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.sysAdminOverviewSubtitle ?? 'Overall platform status and statistics',
                    style: GoogleFonts.notoSansEthiopic(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.7, // Adjusted for Amharic text
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildStatCard(
                        'ጠቅላላ ትምህርት ቤቶች',
                        _dashboardData?['schools']?['total_schools'],
                        Iconsax.teacher,
                        Colors.blue,
                        _heroTagSchoolsTotal,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SchoolsListScreen())),
                      ),
                      _buildStatCard(
                        'ንቁ ትምህርት ቤቶች',
                        _dashboardData?['schools']?['active_schools'],
                        Iconsax.building_4,
                        Colors.green,
                        _heroTagSchoolsActive,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SchoolsListScreen())),
                      ),
                      _buildStatCard(
                        'ጠቅላላ ተጠቃሚዎች',
                        _dashboardData?['users']?['total_users'],
                        Iconsax.profile_2user,
                        Colors.orange,
                        _heroTagUsersTotal,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const UserManagementScreen())),
                      ),
                      _buildStatCard(
                        'ንቁ ተጠቃሚዎች',
                        _dashboardData?['users']?['active_users'],
                        Iconsax.user_tick,
                        Colors.purple,
                        _heroTagUsersActive,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const UserManagementScreen())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    AppLocalizations.of(context)?.sysAdminQuickActions ?? 'Quick Actions',
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)?.sysAdminToolsLabel ?? 'System Admin Tools',
                    style: GoogleFonts.notoSansEthiopic(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      _buildActionCard(
                        AppLocalizations.of(context)?.drawerSchoolsManagement ?? 'Schools Management',
                        'ሁሉንም ትምህርት ቤቶች ይመልከቱ እና ያስተዳድሩ',
                        Iconsax.teacher,
                        _heroTagSchoolsTotal,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SchoolsListScreen())),
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        AppLocalizations.of(context)?.drawerUserManagement ?? 'User Management',
                        'በሁሉም ትምህርት ቤቶች ያሉ ተጠቃሚዎችን ያስተዳድሩ',
                        Iconsax.profile_2user,
                        _heroTagUsersTotal,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const UserManagementScreen())),
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        AppLocalizations.of(context)?.drawerPlatformAnalytics ?? 'Platform Analytics',
                        'የአጠቃቀም እና የእድገት አዝማሚያዎችን ይመልከቱ',
                        Iconsax.diagram,
                        _heroTagAnalytics,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PlatformAnalyticsScreen())),
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        AppLocalizations.of(context)?.drawerAuditReport ?? 'Audit Report',
                        'አስፈላጊ የስርዓት እንቅስቃሴ መዝገቦችን ይከታተሉ',
                        Iconsax.document_text,
                        _heroTagAudit,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AuditLogsScreen())),
                      ),
                      const SizedBox(height: 12),
                      _buildActionCard(
                        AppLocalizations.of(context)?.drawerSystemSettings ?? 'System Settings',
                        'አጠቃላይ የፕላትፎርም ቅንብሮችን ያስተዳድሩ',
                        Iconsax.setting_2,
                        _heroTagSettings,
                        () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SystemSettingsScreen())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildRecentActivity(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
