import 'package:amde_haymanot_abalat_guday/services/audit_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

// --- UI Theme Constants ---
const Color primaryColor = Color.fromARGB(255, 1, 37, 100);
const Color surfaceColor = Color(0xFFF4F7FC);
const Color onSurfaceColor = Color(0xFF212529);
const Color subtleTextColor = Color(0xFF6C757D);

class AuditTrailScreen extends StatefulWidget {
  const AuditTrailScreen({super.key});

  @override
  State<AuditTrailScreen> createState() => _AuditTrailScreenState();
}

class _AuditTrailScreenState extends State<AuditTrailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: Text('የፍተሻ መዝገብ',
            style: GoogleFonts.notoSansEthiopic(
                fontWeight: FontWeight.bold, color: primaryColor)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: subtleTextColor,
          indicatorColor: primaryColor,
          tabs: [
            Tab(
                icon: const Icon(Iconsax.calendar_tick),
                child: Text('መገኘት', style: GoogleFonts.notoSansEthiopic())),
            Tab(
                icon: const Icon(Iconsax.edit),
                child: Text('ውጤቶች', style: GoogleFonts.notoSansEthiopic())),
            Tab(
                icon: const Icon(Iconsax.security_user),
                child: Text('አስተዳደር', style: GoogleFonts.notoSansEthiopic())),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AuditLogListView(logType: 'ATTENDANCE_UPDATE'),
          AuditLogListView(logType: 'GRADE_UPDATE'),
          AuditLogListView(logType: 'ROLE_CHANGE'),
        ],
      ),
    );
  }
}

class AuditLogListView extends StatefulWidget {
  final String logType;
  const AuditLogListView({super.key, required this.logType});

  @override
  State<AuditLogListView> createState() => _AuditLogListViewState();
}

class _AuditLogListViewState extends State<AuditLogListView>
    with AutomaticKeepAliveClientMixin {
  late Future<List<dynamic>> _auditLogsFuture;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() {
    setState(() {
      _auditLogsFuture = AuditService.getAuditTrail(type: widget.logType);
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: () async => _loadLogs(),
      child: FutureBuilder<List<dynamic>>(
        future: _auditLogsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('ስህተት: ${snapshot.error}'));
          }
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return Center(
                child: Text('በዚህ ምድብ ምንም መዝገብ አልተገኘም።',
                    style:
                        GoogleFonts.notoSansEthiopic(color: subtleTextColor)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return _buildLogCard(log);
            },
          );
        },
      ),
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log) {
    final logTimestamp = DateTime.parse(log['timestamp']);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log['action_description'] ?? 'ድርጊት',
                style: GoogleFonts.notoSansEthiopic(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Iconsax.user, size: 14, color: subtleTextColor),
                const SizedBox(width: 4),
                Text('በተጠቃሚ:',
                    style: GoogleFonts.notoSansEthiopic(
                        color: subtleTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(log['user_name'] ?? 'N/A',
                        style: GoogleFonts.notoSansEthiopic(fontSize: 12))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Iconsax.user_edit, size: 14, color: subtleTextColor),
                const SizedBox(width: 4),
                Text('በአስተዳዳሪ:',
                    style: GoogleFonts.notoSansEthiopic(
                        color: subtleTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(log['admin_name'] ?? 'N/A',
                        style: GoogleFonts.notoSansEthiopic(fontSize: 12))),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChangeIndicator(log['previous_value'], "ከዚህ"),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(Iconsax.arrow_right_3, color: primaryColor),
                ),
                _buildChangeIndicator(log['new_value'], "ወደዚህ"),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                DateFormat.yMMMd().add_jm().format(logTimestamp.toLocal()),
                style:
                    GoogleFonts.poppins(color: subtleTextColor, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeIndicator(String? value, String label) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.notoSansEthiopic(
                color: subtleTextColor, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300)),
          child: Text(value ?? 'N/A',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: onSurfaceColor)),
        ),
      ],
    );
  }
}
