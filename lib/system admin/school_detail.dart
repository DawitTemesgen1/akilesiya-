import 'dart:ui';
import 'package:amde_haymanot_abalat_guday/system%20admin/edit_school.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/promote_admin.dart';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SchoolDetailScreen extends StatefulWidget {
  final String schoolId;
  final String heroTag;

  const SchoolDetailScreen({
    super.key,
    required this.schoolId,
    this.heroTag = 'sys-admin-hero-schools',
  });

  @override
  State<SchoolDetailScreen> createState() => _SchoolDetailScreenState();
}

class _SchoolDetailScreenState extends State<SchoolDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _schoolData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSchoolDetail();
  }

  Future<void> _loadSchoolDetail() async {
    setState(() => _isLoading = true);
    final result = await SystemAdminService.getSchoolDetail(widget.schoolId);
    if (mounted) {
      if (result['success'] == true) {
        setState(() => _schoolData = result['data']);
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

  String _safeParseString(dynamic value) {
    if (value == null) return 'አልተገለጸም';
    return value.toString();
  }

  bool _safeParseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode(context);
    final primaryColor = Theme.of(context).primaryColor;
    final school = _schoolData?['school'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? _buildLoadingOverlay(isDark, primaryColor)
          : CustomScrollView(
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
                          _safeParseString(school?['name']),
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
                        if (school?['logo_url'] != null &&
                            school!['logo_url'].toString().isNotEmpty)
                          Center(
                            child: FadeInDown(
                              duration: const Duration(milliseconds: 600),
                              child: Hero(
                                tag: widget.heroTag,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            primaryColor.withValues(alpha: 0.2),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    image: DecorationImage(
                                      image: NetworkImage(school['logo_url']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Center(
                            child: FadeInDown(
                              duration: const Duration(milliseconds: 600),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor:
                                    primaryColor.withValues(alpha: 0.1),
                                child: Text(
                                  _safeParseString(school?['name'])[0]
                                      .toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Iconsax.edit, color: primaryColor),
                      onPressed: _editSchool,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                // Sticky Tabs
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: primaryColor,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: const [
                        Tab(text: 'Overview'),
                        Tab(text: 'Members'),
                        Tab(text: 'Growth'),
                      ],
                    ),
                    isDark,
                  ),
                ),

                // Tab Content
                SliverFillRemaining(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(isDark, primaryColor),
                      _buildMembersTab(isDark, primaryColor),
                      _buildStatisticsTab(isDark, primaryColor),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOverviewTab(bool isDark, Color primaryColor) {
    final school = _schoolData?['school'];
    final stats = _schoolData?['statistics'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: _buildSectionCard(
              isDark,
              'Base Information',
              Iconsax.info_circle,
              [
                _buildInfoRow('Motto', _safeParseString(school?['motto']),
                    Iconsax.quote_down),
                _buildInfoRow('Pastor',
                    _safeParseString(school?['pastor_name']), Iconsax.user),
                _buildInfoRow(
                    'Phone', _safeParseString(school?['phone']), Iconsax.call),
                _buildInfoRow('Email', _safeParseString(school?['email']),
                    Iconsax.direct),
                _buildInfoRow('Address', _safeParseString(school?['address']),
                    Iconsax.location),
                _buildInfoRow(
                    'Est. Year',
                    _safeParseString(school?['founding_year']),
                    Iconsax.calendar),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Statistics Grid
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 12),
                  child: Text(
                    'Key Metrics',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildStatCard(
                        'Total Members',
                        _safeParseInt(stats?['total_members']),
                        Iconsax.people,
                        Colors.blue),
                    _buildStatCard(
                        'Active',
                        _safeParseInt(stats?['active_members']),
                        Iconsax.user_tick,
                        Colors.green),
                    _buildStatCard(
                        'Verified',
                        _safeParseInt(stats?['verified_members']),
                        Iconsax.verify,
                        Colors.orange),
                    _buildStatCard(
                        'Admins',
                        _safeParseInt(stats?['admin_count']),
                        Iconsax.security_user,
                        Colors.purple),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Actions
          FadeInUp(
            duration: const Duration(milliseconds: 700),
            child: _buildSectionCard(
              isDark,
              'Quick Actions',
              Iconsax.flash,
              [
                _buildActionRow(
                  'Manage Status',
                  _safeParseBool(school?['is_active'])
                      ? 'Deactivate School'
                      : 'Activate School',
                  _safeParseBool(school?['is_active'])
                      ? Colors.red
                      : Colors.green,
                  _safeParseBool(school?['is_active'])
                      ? Iconsax.close_circle
                      : Iconsax.tick_circle,
                  _toggleSchoolStatus,
                ),
                const Divider(height: 1),
                _buildActionRow(
                  'Administrators',
                  'Promote New Admin',
                  primaryColor,
                  Iconsax.user_add,
                  _promoteAdmin,
                ),
              ],
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMembersTab(bool isDark, Color primaryColor) {
    final members = _schoolData?['recentActivity'] ?? [];
    final roleDistribution = _schoolData?['roleDistribution'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Role Distribution
          FadeInUp(
            duration: const Duration(milliseconds: 500),
            child: _buildSectionCard(
              isDark,
              'Role Distribution',
              Iconsax.diagram,
              roleDistribution
                  .map<Widget>((role) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _safeParseString(role['role']),
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _safeParseInt(role['count']).toString(),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Recent Activity
          Text(
            'Recent Joiners',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (members.isEmpty)
            _buildEmptyState('No recent activity found', Iconsax.user_search)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return FadeInUp(
                  duration: Duration(milliseconds: 400 + (index * 50)),
                  child: _buildMemberTile(member, isDark, primaryColor),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(bool isDark, Color primaryColor) {
    final growthData = _schoolData?['growthData'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            isDark,
            'Growth Trends',
            Iconsax.chart_2,
            growthData.isEmpty
                ? [const Center(child: Text('No data available'))]
                : growthData
                    .map<Widget>((data) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_safeParseString(data['date'])),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '+${_safeParseInt(data['new_members'])} New',
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                        ))
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
      bool isDark, String title, IconData icon, List<Widget> children,
      {EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]!.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: padding ?? const EdgeInsets.all(20.0),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500, fontSize: 13),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(String title, String subtitle, Color color,
      IconData icon, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style:
              GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle,
          style: GoogleFonts.poppins(fontSize: 12, color: color)),
      trailing: const Icon(Iconsax.arrow_right_3, size: 16),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(
            value.toString(),
            style:
                GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(
      Map<String, dynamic> member, bool isDark, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]!.withValues(alpha: 0.3) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100]!,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryColor.withValues(alpha: 0.1),
            child: Text(
              _safeParseString(member['full_name'])[0].toUpperCase(),
              style:
                  TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _safeParseString(member['full_name']),
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  _safeParseString(member['email']),
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(Iconsax.info_circle, size: 16, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(icon, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(bool isDark, Color primaryColor) {
    return Center(
      child: Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[900]! : Colors.grey[200]!,
        highlightColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
        child: Column(
          children: [
            Container(height: 200, color: Colors.white),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: List.generate(
                    4,
                    (i) => Container(
                          height: 100,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                        )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSchoolStatus() async {
    final school = _schoolData?['school'];
    final newStatus = !_safeParseBool(school?['is_active']);

    final result = await SystemAdminService.toggleSchoolStatus(
      widget.schoolId,
      newStatus,
    );

    if (mounted) {
      if (result['success'] == true) {
        await _loadSchoolDetail();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  void _editSchool() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSchoolScreen(school: _schoolData!['school']),
      ),
    ).then((success) {
      if (success == true) {
        _loadSchoolDetail();
      }
    });
  }

  void _promoteAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PromoteAdminScreen(
          schoolId: widget.schoolId,
          schoolName: _safeParseString(_schoolData?['school']?['name']),
        ),
      ),
    ).then((_) {
      _loadSchoolDetail();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final bool isDark;

  _SliverAppBarDelegate(this._tabBar, this.isDark);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? const Color(0xFF050511) : Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
