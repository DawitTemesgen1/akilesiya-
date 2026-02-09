import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
import 'package:amde_haymanot_abalat_guday/services/attendance_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';

// --- የዩአይ ገጽታ ቋሚዎች ---
const Color primaryColor = Color.fromARGB(255, 1, 37, 100);
const Color surfaceColor = Color(0xFFF4F7FC);
const Color onSurfaceColor = Color(0xFF212529);
const Color subtleTextColor = Color(0xFF6C757D);
const Color successColor = Color(0xFF198754);
const Color warningColor = Color(0xFFFD7E14);
const Color dangerColor = Color(0xFFDC3545);
const Color permissionColor = Color(0xFF0D6EFD);

class UserAttendanceDetailScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String heroTag; // አስተያየት: ልዩ የ hero tag ለመቀበል ፓራሜትር ታክሏል

  const UserAttendanceDetailScreen({
    super.key,
    required this.userId,
    required this.userName,
    required this.heroTag, // አስተያየት: አስገዳጅ እንዲሆን ተደርጓል
  });

  @override
  State<UserAttendanceDetailScreen> createState() =>
      _UserAttendanceDetailScreenState();
}

class _UserAttendanceDetailScreenState
    extends State<UserAttendanceDetailScreen> {
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historyFuture =
          AttendanceService.getAttendanceHistoryForUser(widget.userId);
    });
  }

  Widget _buildStatusChip(String status) {
    IconData icon;
    Color color;
    String text; // <<< የተተረጎመውን ጽሑፍ ለመያዝ

    switch (status) {
      case 'present':
        icon = Iconsax.tick_circle;
        color = successColor;
        text = AppLocalizations.of(context)?.attendanceStatusPresent ?? 'Present';
        break;
      case 'absent':
        icon = Iconsax.close_circle;
        color = dangerColor;
        text = AppLocalizations.of(context)?.attendanceStatusAbsent ?? 'Absent';
        break;
      case 'late':
        icon = Iconsax.clock;
        color = warningColor;
        text = AppLocalizations.of(context)?.attendanceStatusLate ?? 'Late';
        break;
      case 'permission':
        icon = Iconsax.document_text;
        color = permissionColor;
        text = AppLocalizations.of(context)?.attendanceStatusPermission ?? 'Permission';
        break;
      default:
        icon = Iconsax.info_circle;
        color = subtleTextColor;
        text = AppLocalizations.of(context)?.attendanceStatusUnknown ?? 'Unknown';
    }

    return Chip(
      avatar: Icon(icon, color: color, size: 16),
      label: Text(text), // <<< የተተረጎመውን ጽሑፍ ይጠቀማል
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.bold),
      backgroundColor: color.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      side: BorderSide(color: color.withValues(alpha: 0.2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // አስተያየት: የርዕስ ጽሑፉን በልዩ መለያ በ Hero መግብር ውስጥ ማስቀመጥ
            Hero(
              tag: widget.heroTag,
              child: Material(
                color: Colors.transparent,
                child: Text(
                  widget.userName,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontSize: 18),
                ),
              ),
            ),
            Text(AppLocalizations.of(context)?.attendanceHistoryTitle ?? 'Attendance History',
                style:
                    GoogleFonts.poppins(fontSize: 12, color: subtleTextColor)),
          ],
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadHistory(),
        child: FutureBuilder<List<dynamic>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: Text('${AppLocalizations.of(context)?.attendanceErrorPrefix ?? 'Error:'} ${snapshot.error}'));
            }
            final history = snapshot.data ?? [];
            if (history.isEmpty) {
              return Center(
                  child: Text(AppLocalizations.of(context)?.attendanceNoRecords ?? 'No attendance records found for this user.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final record = history[index];

                // ይህ መስመር አሁን ይሰራል ምክንያቱም `parse` የሚለው መეთድ ስላለ
                final ethiopianDate =
                    EthiopianDate.parse(record['attendance_date']);

                final status = record['status'] as String? ?? 'unknown';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(ethiopianDate.day.toString(),
                              style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text(
                              EthiopianDate.monthNames[ethiopianDate.month - 1]
                                  .substring(0, 2),
                              style: const TextStyle(
                                  color: primaryColor, fontSize: 10)),
                        ],
                      ),
                    ),
                    title: Text(ethiopianDate.toString(),
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: _buildStatusChip(status),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                          children: [
                            const Divider(height: 16),
                            _buildHistoryDetailRow(
                                icon: Iconsax.category,
                                label: AppLocalizations.of(context)?.attendanceDetailTypeLabel ?? 'Type',
                                value: record['attendance_type'] ??
                                    'N/A'),
                            const SizedBox(height: 8),
                            _buildHistoryDetailRow(
                                icon: Iconsax.clock,
                                label: AppLocalizations.of(context)?.attendanceDetailSessionLabel ?? 'Session',
                                value:
                                    record['session'] ?? 'N/A'),
                            if (record['late_time'] != null) ...[
                              const SizedBox(height: 8),
                              _buildHistoryDetailRow(
                                  icon: Iconsax.timer_1,
                                  label: AppLocalizations.of(context)?.attendanceDetailArrivalTimeLabel ?? 'Arrival Time',
                                  value:
                                      record['late_time']),
                            ],
                            const SizedBox(height: 8),
                            _buildHistoryDetailRow(
                                icon: Iconsax.note_text,
                                label: AppLocalizations.of(context)?.attendanceDetailTopicLabel ?? 'Topic',
                                value: record['topic'] ??
                                    (AppLocalizations.of(context)?.attendanceDetailNoTopic ?? 'No topic recorded.')),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryDetailRow(
      {required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: subtleTextColor),
        const SizedBox(width: 12),
        SizedBox(
            width: 70,
            child: Text(label,
                style: GoogleFonts.poppins(
                    color: subtleTextColor, fontWeight: FontWeight.w600))),
        Expanded(
            child:
                Text(value, style: GoogleFonts.poppins(color: onSurfaceColor))),
      ],
    );
  }
}
