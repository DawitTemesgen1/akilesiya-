import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class PlatformAnalyticsScreen extends StatefulWidget {
  const PlatformAnalyticsScreen({super.key});

  @override
  State<PlatformAnalyticsScreen> createState() =>
      _PlatformAnalyticsScreenState();
}

class _PlatformAnalyticsScreenState extends State<PlatformAnalyticsScreen> {
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;
  String _selectedPeriod = '30d';

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    final result =
        await SystemAdminService.getPlatformAnalytics(period: _selectedPeriod);
    if (result['success'] == true) {
      if (mounted) setState(() => _analyticsData = result['data']);
    } else {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['message']), backgroundColor: Colors.red));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode(context);
    final primaryColor = Theme.of(context).primaryColor;

    // Handle data parsing safely
    final rawAvg = _analyticsData?['schoolStats']?['avg_members_per_school'];
    double avgMembers = 0.0;
    if (rawAvg is num)
      avgMembers = rawAvg.toDouble();
    else if (rawAvg is String) avgMembers = double.tryParse(rawAvg) ?? 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Glassmorphic App Bar
          SliverAppBar(
            expandedHeight: 200.0,
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
                    'Analytics',
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
                    right: 20,
                    child: FadeInRight(
                      duration: const Duration(milliseconds: 600),
                      child: _buildPeriodSelector(isDark, primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                  icon: Icon(Iconsax.refresh, color: primaryColor),
                  onPressed: _loadAnalytics),
              const SizedBox(width: 8),
            ],
          ),

          if (_isLoading)
            const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()))
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Grid Stats
                    FadeInUp(
                      duration: const Duration(milliseconds: 700),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.4,
                        children: [
                          _buildStatCard(
                              'Total Schools',
                              _analyticsData?['schoolStats']
                                      ?['total_schools'] ??
                                  0,
                              Iconsax.bank,
                              Colors.blue,
                              isDark),
                          _buildStatCard(
                              'Active Schools',
                              _analyticsData?['schoolStats']
                                      ?['active_schools'] ??
                                  0,
                              Iconsax.verify,
                              Colors.green,
                              isDark),
                          _buildStatCard(
                              'Avg. Members',
                              avgMembers.toStringAsFixed(1),
                              Iconsax.people,
                              Colors.orange,
                              isDark),
                          _buildStatCard(
                              'Active Users',
                              _analyticsData?['activityMetrics']
                                      ?['active_users_30d'] ??
                                  0,
                              Iconsax.user_tick,
                              Colors.purple,
                              isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // User Growth Section
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: _buildSectionCard(
                          'User Growth',
                          Iconsax.chart_21,
                          _buildGrowthList(isDark, primaryColor),
                          isDark,
                          primaryColor),
                    ),
                    const SizedBox(height: 20),

                    // Role Distribution
                    FadeInUp(
                      duration: const Duration(milliseconds: 900),
                      child: _buildSectionCard(
                          'Role Distribution',
                          Iconsax.user_octagon,
                          _buildRoleDistribution(isDark, primaryColor),
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

  Widget _buildPeriodSelector(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          icon: Icon(Iconsax.arrow_down_1, size: 16, color: primaryColor),
          style: GoogleFonts.poppins(
              fontSize: 12, color: isDark ? Colors.white : Colors.black87),
          onChanged: (v) {
            if (v != null) {
              setState(() => _selectedPeriod = v);
              _loadAnalytics();
            }
          },
          items: const [
            DropdownMenuItem(value: '7d', child: Text('7 Days')),
            DropdownMenuItem(value: '30d', child: Text('30 Days')),
            DropdownMenuItem(value: '90d', child: Text('90 Days')),
            DropdownMenuItem(value: '1y', child: Text('1 Year')),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, dynamic value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]!.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value.toString(),
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget content,
      bool isDark, Color primaryColor) {
    return Container(
      width: double.infinity,
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
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }

  Widget _buildGrowthList(bool isDark, Color primaryColor) {
    final growthData = _analyticsData?['userGrowth'] ?? [];
    if (growthData.isEmpty)
      return Center(
          child: Text('No growth data',
              style: GoogleFonts.poppins(color: Colors.grey)));

    return Column(
      children: growthData.map<Widget>((data) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: Icon(Iconsax.trend_up, color: primaryColor, size: 16),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['date'] ?? '',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                    Text('Total: ${data['cumulative_users']}',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Text('+${data['new_users']}',
                    style: GoogleFonts.poppins(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoleDistribution(bool isDark, Color primaryColor) {
    final roles = _analyticsData?['roleDistribution'] ?? [];
    if (roles.isEmpty)
      return Center(
          child:
              Text('No data', style: GoogleFonts.poppins(color: Colors.grey)));

    return Column(
      children: roles.map<Widget>((role) {
        final rType = role['role_type'] as String;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(_getRoleIcon(rType), color: primaryColor, size: 20),
          title: Text(_formatRoleType(rType),
              style: GoogleFonts.poppins(fontSize: 14)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Text(role['count'].toString(),
                style: GoogleFonts.poppins(
                    color: primaryColor, fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  IconData _getRoleIcon(String roleType) {
    switch (roleType) {
      case 'system_admin':
        return Iconsax.security_safe;
      case 'superior_admin':
        return Iconsax.shield_search;
      case 'other_admin':
        return Iconsax.user_octagon;
      default:
        return Iconsax.user;
    }
  }

  String _formatRoleType(String roleType) {
    switch (roleType) {
      case 'system_admin':
        return 'System Admins';
      case 'superior_admin':
        return 'Superior Admins';
      case 'other_admin':
        return 'School Admins';
      default:
        return 'General Users';
    }
  }
}
