// lib/screens/user_attendance_history_screen.dart
import 'package:amde_haymanot_abalat_guday/services/attendance_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

// --- UI Theme Constants ---
const Color primaryColor = Color.fromARGB(255, 1, 37, 100);
const Color surfaceColor = Color(0xFFF4F7FC);
const Color onSurfaceColor = Color(0xFF212529);
const Color subtleTextColor = Color(0xFF6C757D);
const Color successColor = Color(0xFF198754);
const Color warningColor = Color(0xFFFD7E14);
const Color dangerColor = Color(0xFFDC3545);
const Color permissionColor = Color(0xFF0D6EFD);

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

  Widget _buildStatusChip(String status) {
    IconData icon;
    Color color;
    String text;

    switch (status) {
      case 'present':
        icon = Iconsax.tick_circle;
        color = successColor;
        text = 'ተገኝቷል';
        break;
      case 'absent':
        icon = Iconsax.close_circle;
        color = dangerColor;
        text = 'ቀርቷል';
        break;
      case 'late':
        icon = Iconsax.clock;
        color = warningColor;
        text = 'አርፍዷል';
        break;
      case 'permission':
        icon = Iconsax.document_text;
        color = permissionColor;
        text = 'በፍቃድ';
        break;
      default:
        icon = Iconsax.info_circle;
        color = subtleTextColor;
        text = 'ያልታወቀ';
    }

    return Chip(
      avatar: Icon(icon, color: color, size: 16),
      label: Text(text),
      labelStyle: GoogleFonts.notoSansEthiopic(
          color: color, fontWeight: FontWeight.bold),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: Text(
          'የእኔ የመገኘት ታሪክ',
          style: GoogleFonts.notoSansEthiopic(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        backgroundColor: surfaceColor,
        elevation: 0,
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
                child: Text(
                  'ታሪክዎን በመጫን ላይ ስህተት ተፈጥሯል:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style:
                      GoogleFonts.notoSansEthiopic(color: Colors.red.shade700),
                ),
              );
            }
            final history = snapshot.data ?? [];
            if (history.isEmpty) {
              return Center(
                child: Text(
                  'ለእርስዎ ምንም የመገኘት መዝገብ አልተገኘም።',
                  style: GoogleFonts.notoSansEthiopic(color: subtleTextColor),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final record = history[index];
                final recordDate = DateTime.parse(record['attendance_date']);
                final status = record['status'] as String? ?? 'unknown';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('d', 'am_ET').format(recordDate),
                            style: const TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          Text(
                            DateFormat('MMM', 'am_ET')
                                .format(recordDate)
                                .toUpperCase(),
                            style: const TextStyle(
                                color: primaryColor, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      DateFormat.yMMMMEEEEd('am_ET').format(recordDate),
                      style: GoogleFonts.notoSansEthiopic(
                          fontWeight: FontWeight.bold,
                          color: onSurfaceColor,
                          fontSize: 15),
                    ),
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
                              label: 'ዓይነት',
                              value: record['attendance_type'] ?? 'የለም',
                            ),
                            const SizedBox(height: 8),
                            _buildHistoryDetailRow(
                              icon: Iconsax.clock,
                              label: 'ክፍለ ጊዜ',
                              value: record['session'] ?? 'የለም',
                            ),
                            if (record['late_time'] != null) ...[
                              const SizedBox(height: 8),
                              _buildHistoryDetailRow(
                                  icon: Iconsax.timer_1,
                                  label: 'የደረሰበት ሰዓት',
                                  value: 'በ ${record['late_time']} አርፍዷል'),
                            ],
                            const SizedBox(height: 8),
                            _buildHistoryDetailRow(
                              icon: Iconsax.note_text,
                              label: 'ርዕስ',
                              value: record['topic'] ?? 'ምንም ርዕስ አልተመዘገበም።',
                            ),
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

  Widget _buildHistoryDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: subtleTextColor),
        const SizedBox(width: 12),
        SizedBox(
          width: 80, // Increased width for Amharic labels
          child: Text(
            label,
            style: GoogleFonts.notoSansEthiopic(
              color: subtleTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.notoSansEthiopic(color: onSurfaceColor),
          ),
        ),
      ],
    );
  }
}
