import 'package:amde_haymanot_abalat_guday/system%20admin/edit_school.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/promote_admin.dart';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class SchoolDetailScreen extends StatefulWidget {
  final String schoolId;
  final String heroTag; // Add heroTag to the constructor

  const SchoolDetailScreen({
    super.key,
    required this.schoolId,
    this.heroTag = 'sys-admin-hero-schools', // Provide a default tag
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

  Widget _buildOverviewTab() {
    final school = _schoolData?['school'];
    final stats = _schoolData?['statistics'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (school?['logo_url'] != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: NetworkImage(school!['logo_url']),
                        ),
                      ),
                    ),
                  Text(
                    'መሰረታዊ መረጃ',
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('የት/ቤት ስም', _safeParseString(school?['name'])),
                  if (school?['motto'] != null)
                    _buildInfoRow('መሪ ቃል', _safeParseString(school?['motto'])),
                  if (school?['founding_year'] != null)
                    _buildInfoRow('የተመሰረተበት ዓ.ም',
                        _safeParseString(school?['founding_year'])),
                  _buildInfoRow(
                      'ፓስተር', _safeParseString(school?['pastor_name'])),
                  _buildInfoRow('ኢሜል', _safeParseString(school?['email'])),
                  _buildInfoRow('ስልክ', _safeParseString(school?['phone'])),
                  _buildInfoRow('አድራሻ', _safeParseString(school?['address'])),
                  _buildInfoRow(
                      'የተቋቋመበት', _safeParseString(school?['established_date'])),
                  _buildInfoRow(
                      'ሁኔታ',
                      _safeParseBool(school?['is_active'])
                          ? 'በሥራ ላይ'
                          : 'ከሥራ ውጭ'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'የአባላት ስታቲስቲክስ',
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildStatCard(
                          'ጠቅላላ አባላት',
                          _safeParseInt(stats?['total_members']),
                          Iconsax.people,
                          Colors.blue),
                      _buildStatCard(
                          'ንቁ አባላት',
                          _safeParseInt(stats?['active_members']),
                          Iconsax.user_tick,
                          Colors.green),
                      _buildStatCard(
                          'የተረጋገጡ አባላት',
                          _safeParseInt(stats?['verified_members']),
                          Iconsax.verify,
                          Colors.orange),
                      _buildStatCard(
                          'አስተዳዳሪዎች',
                          _safeParseInt(stats?['admin_count']),
                          Iconsax.security_user,
                          Colors.purple),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ፈጣን እርምጃዎች',
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ActionChip(
                        avatar: const Icon(Iconsax.edit, size: 16),
                        label: Text('ት/ቤቱን አስተካክል',
                            style: GoogleFonts.notoSansEthiopic()),
                        onPressed: () => _editSchool(),
                      ),
                      ActionChip(
                        avatar: Icon(
                          _safeParseBool(school?['is_active'])
                              ? Iconsax.close_circle
                              : Iconsax.tick_circle,
                          size: 16,
                        ),
                        label: Text(
                            _safeParseBool(school?['is_active'])
                                ? 'አቦዝን'
                                : 'አንቃ',
                            style: GoogleFonts.notoSansEthiopic()),
                        onPressed: () => _toggleSchoolStatus(),
                      ),
                      ActionChip(
                        avatar: const Icon(Iconsax.user_add, size: 16),
                        label: Text('አስተዳዳሪ ሹም',
                            style: GoogleFonts.notoSansEthiopic()),
                        onPressed: () => _promoteAdmin(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    final members = _schoolData?['recentActivity'] ?? [];
    final roleDistribution = _schoolData?['roleDistribution'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'የሚና ስርጭት',
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...roleDistribution
                      .map<Widget>((role) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(_safeParseString(role['role']),
                                      style: GoogleFonts.notoSansEthiopic()),
                                ),
                                Chip(
                                    label: Text(_safeParseInt(role['count'])
                                        .toString())),
                              ],
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'የቅርብ ጊዜ እንቅስቃሴ',
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (members.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Iconsax.user_search,
                                size: 48, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text(
                              'ምንም የቅርብ ጊዜ እንቅስቃሴ አልተገኘም',
                              style: GoogleFonts.notoSansEthiopic(
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: members.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: Colors.grey[200]),
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  (_safeParseString(member['full_name'])
                                          .isNotEmpty
                                      ? _safeParseString(member['full_name'])[0]
                                          .toUpperCase()
                                      : '?'),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _safeParseString(member['full_name']),
                                      style: GoogleFonts.notoSansEthiopic(
                                          fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      _safeParseString(member['email']),
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (_safeParseString(
                                            member['spiritual_class'])
                                        .isNotEmpty)
                                      Text(
                                        'ክፍል: ${_safeParseString(member['spiritual_class'])}',
                                        style: GoogleFonts.notoSansEthiopic(
                                            fontSize: 11, color: Colors.blue),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 140, // Constraint for the roles wrap
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 4,
                                  alignment: WrapAlignment.end,
                                  children: _safeParseString(member['role'])
                                      .split(',')
                                      .where((r) => r.trim().isNotEmpty)
                                      .map((role) => Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              role.trim(),
                                              style:
                                                  GoogleFonts.notoSansEthiopic(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    final growthData = _schoolData?['growthData'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'የእድገት አዝማሚያዎች',
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (growthData.isEmpty)
                    Center(
                      child: Text(
                        'ምንም የእድገት መረጃ የለም',
                        style: GoogleFonts.notoSansEthiopic(color: Colors.grey),
                      ),
                    )
                  else
                    ...growthData
                        .map<Widget>((data) => ListTile(
                              title: Text(_safeParseString(data['date']),
                                  style: GoogleFonts.notoSansEthiopic()),
                              trailing: Chip(
                                label: Text(
                                    '+${_safeParseInt(data['new_members'])}'),
                              ),
                            ))
                        .toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value, style: GoogleFonts.notoSansEthiopic())),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, int value, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 20),
          const Spacer(),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: GoogleFonts.notoSansEthiopic(
                fontSize: 12, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_safeParseString(_schoolData?['school']?['name']),
            style: GoogleFonts.notoSansEthiopic()),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'አጠቃላይ እይታ'),
            Tab(text: 'አባላት'),
            Tab(text: 'ስታቲስቲክስ'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildMembersTab(),
                _buildStatisticsTab(),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
