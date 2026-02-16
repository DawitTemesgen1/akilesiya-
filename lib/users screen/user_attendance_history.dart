// lib/screens/user_attendance_history_screen.dart
import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
import 'package:amde_haymanot_abalat_guday/services/attendance_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

// --- UI Theme Constants ---
// Replaced by ThemeProvider
// const Color kPrimaryColor = Color(0xFF1E3A8A);
// const Color kBackgroundColor = Color(0xFFF8FAFC);
// const Color kCardColor = Colors.white;
// const Color kTextColor = Color(0xFF1E293B);
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';

const Color successColor = Color(0xFF10B981); // Green
const Color warningColor = Color(0xFFF59E0B); // Amber
const Color dangerColor = Color(0xFFEF4444); // Red
const Color infoColor = Color(0xFF3B82F6); // Blue

class UserAttendanceHistoryScreen extends StatefulWidget {
  const UserAttendanceHistoryScreen({super.key});

  @override
  State<UserAttendanceHistoryScreen> createState() =>
      _UserAttendanceHistoryScreenState();
}

class _UserAttendanceHistoryScreenState
    extends State<UserAttendanceHistoryScreen> {
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historyFuture = AttendanceService.getMyAttendanceHistory();
    });
  }

  // Theme Getters
  Color get primaryColor =>
      Provider.of<ThemeProvider>(context).getPrimaryColor(context);
  Color get surfaceColor =>
      Provider.of<ThemeProvider>(context).getSurfaceColor(context);
  Color get backgroundColor =>
      Provider.of<ThemeProvider>(context).getBackgroundColor(context);
  Color get onSurfaceColor =>
      Provider.of<ThemeProvider>(context).getOnSurfaceColor(context);
  Color get subtleTextColor =>
      Provider.of<ThemeProvider>(context).getSubtleTextColor(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'የመገኘት ታሪክ', // Attendance History
          style: GoogleFonts.notoSansEthiopic(
            fontWeight: FontWeight.bold,
            color: onSurfaceColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: onSurfaceColor),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadHistory(),
        color: primaryColor,
        child: FutureBuilder<List<dynamic>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error loading history: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)),
              );
            }
            final history = snapshot.data ?? [];
            if (history.isEmpty) {
              return const Center(child: Text('No attendance records found.'));
            }

            // Calculate stats
            int present = history.where((r) => r['status'] == 'present').length;
            int absent = history.where((r) => r['status'] == 'absent').length;
            int permission =
                history.where((r) => r['status'] == 'permission').length;
            int lateCount = history.where((r) => r['status'] == 'late').length;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: _buildSummaryCards(present, absent, permission,
                          lateCount, surfaceColor, onSurfaceColor),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final record = history[index];
                        return FadeInUp(
                          duration: Duration(
                              milliseconds: 300 + (index * 50).clamp(0, 500)),
                          child: _AttendanceTimelineItem(
                              record: record,
                              surfaceColor: surfaceColor,
                              onSurfaceColor: onSurfaceColor,
                              backgroundColor: backgroundColor),
                        );
                      },
                      childCount: history.length,
                    ),
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 50)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCards(int present, int absent, int permission,
      int lateCount, Color surfaceColor, Color onSurfaceColor) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'ተገኝቷል',
            count: present,
            color: successColor,
            icon: Iconsax.tick_circle,
            surfaceColor: surfaceColor,
            onSurfaceColor: onSurfaceColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            label: 'ቀርቷል',
            count: absent,
            color: dangerColor,
            icon: Iconsax.close_circle,
            surfaceColor: surfaceColor,
            onSurfaceColor: onSurfaceColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            label: 'ፈቃድ',
            count: permission,
            color: infoColor,
            icon: Iconsax.document_text,
            surfaceColor: surfaceColor,
            onSurfaceColor: onSurfaceColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            label: 'አርፍዷል',
            count: lateCount,
            color: warningColor,
            icon: Iconsax.timer_1,
            surfaceColor: surfaceColor,
            onSurfaceColor: onSurfaceColor,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  final Color surfaceColor;
  final Color onSurfaceColor;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
    required this.surfaceColor,
    required this.onSurfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: onSurfaceColor),
          ),
          Text(
            label,
            style: GoogleFonts.notoSansEthiopic(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AttendanceTimelineItem extends StatelessWidget {
  final dynamic record;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final Color backgroundColor;

  const _AttendanceTimelineItem(
      {required this.record,
      required this.surfaceColor,
      required this.onSurfaceColor,
      required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    final recordDate = DateTime.parse(record['attendance_date']);
    final status = record['status'] as String? ?? 'unknown';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Line
          Column(
            children: [
              Container(
                width: 2,
                height: 20,
                color: Colors.grey.shade300,
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: _getStatusColor(status), width: 2),
                ),
                child: Icon(
                  _getStatusIcon(status),
                  size: 14,
                  color: _getStatusColor(status),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: Colors.grey.shade300,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Content Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        EthiopianDate.fromGregorian(recordDate).toString(),
                        style: GoogleFonts.notoSansEthiopic(
                            fontWeight: FontWeight.bold,
                            color: onSurfaceColor,
                            fontSize: 14),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusText(status),
                          style: GoogleFonts.notoSansEthiopic(
                              color: _getStatusColor(status),
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _CompactInfo(
                          icon: Iconsax.category,
                          text: record['attendance_type'] ?? 'N/A'),
                      _CompactInfo(
                          icon: Iconsax.clock,
                          text: record['session'] ?? 'N/A'),
                      if (status == 'late' && record['late_time'] != null)
                        _CompactInfo(
                            icon: Iconsax.timer_1,
                            text: '-${record['late_time']}',
                            color: warningColor),
                    ],
                  ),
                  if (record['topic'] != null) ...[
                    const Divider(height: 16),
                    Text(
                      record['topic'] ?? '',
                      style: GoogleFonts.notoSansEthiopic(
                          color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'present':
        return successColor;
      case 'absent':
        return dangerColor;
      case 'late':
        return warningColor;
      case 'permission':
        return infoColor;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'present':
        return Iconsax.tick_circle;
      case 'absent':
        return Iconsax.close_circle;
      case 'late':
        return Iconsax.clock;
      case 'permission':
        return Iconsax.document_text;
      default:
        return Iconsax.info_circle;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'present':
        return 'ተገኝቷል';
      case 'absent':
        return 'ቀርቷል';
      case 'late':
        return 'አርፍዷል';
      case 'permission':
        return 'ፈቃድ';
      default:
        return '---';
    }
  }
}

class _CompactInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _CompactInfo(
      {required this.icon, required this.text, this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text,
            style: GoogleFonts.notoSansEthiopic(fontSize: 12, color: color)),
      ],
    );
  }
}
