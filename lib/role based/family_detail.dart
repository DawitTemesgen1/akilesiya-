// lib/screens/family/family_member_detail_screen.dart

import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';

import 'package:amde_haymanot_abalat_guday/services/family_service.dart';
import 'package:amde_haymanot_abalat_guday/services/attendance_service.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:iconsax/iconsax.dart';

// --- UI Theme Constants are now handled by ThemeProvider ---

// --- Models ---
class RecommendedBook {
  final int id;
  final String title;
  final DateTime deadline;
  bool isRead;

  RecommendedBook(
      {required this.id,
      required this.title,
      required this.deadline,
      this.isRead = false});

  factory RecommendedBook.fromJson(Map<String, dynamic> json) {
    int parsedId;
    if (json['id'] is int) {
      parsedId = json['id'];
    } else if (json['id'] is String) {
      parsedId = int.tryParse(json['id']) ?? 0;
    } else {
      parsedId = 0;
    }

    DateTime parsedDeadline;
    try {
      parsedDeadline = DateTime.parse(json['deadline'].toString());
    } catch (_) {
      parsedDeadline = DateTime.now().add(const Duration(days: 7)); // Fallback
    }

    return RecommendedBook(
      id: parsedId,
      title: json['title']?.toString() ?? 'No Title',
      deadline: parsedDeadline,
      isRead: json['is_read'] == 1 ||
          json['is_read'] == true ||
          json['is_read'].toString() == 'true',
    );
  }
}

// --- Enums ---
enum AttendanceType { all, learning, hymnLearning, awudemihiret, special }

enum DateFilter { weekly, monthly, yearly, allTime, custom }

// #########################################################################
// SCREEN: FamilyMemberDetailScreen (Fully Connected)
// #########################################################################

class FamilyMemberDetailScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const FamilyMemberDetailScreen(
      {super.key, required this.studentId, required this.studentName});

  @override
  State<FamilyMemberDetailScreen> createState() =>
      _FamilyMemberDetailScreenState();
}

class _FamilyMemberDetailScreenState extends State<FamilyMemberDetailScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  // State for fetched data
  Map<String, dynamic>? _studentData;
  String? _error;

  // State for UI interactions
  AttendanceType _selectedAttendanceType = AttendanceType.all;
  DateFilter _selectedDateFilter = DateFilter.allTime;
  Map<String, dynamic> _attendanceStats = {};
  List<dynamic> _filteredHistory = [];
  String? _selectedGradeYear;
  late List<RecommendedBook> _books = [];

  // --- Translation Maps ---
  final Map<AttendanceType, String> _attendanceTypeTranslations = {
    AttendanceType.all: 'ሁሉም',
    AttendanceType.learning: 'ትምህርት',
    AttendanceType.hymnLearning: 'ዝማሬ',
    AttendanceType.awudemihiret: 'ዐውደ ምሕረት',
    AttendanceType.special: 'ልዩ',
  };

  final Map<DateFilter, String> _dateFilterTranslations = {
    DateFilter.weekly: 'ሳምንታዊ',
    DateFilter.monthly: 'ወርሃዊ',
    DateFilter.yearly: 'ዓመታዊ',
    DateFilter.allTime: 'ሁሉንም',
    DateFilter.custom: 'ብጁ',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addObserver(this);
    _fetchStudentDetails();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh student details when app resumes
      _fetchStudentDetails();
    }
  }

  Future<void> _fetchStudentDetails() async {
    final result = await FamilyService.getStudentDetails(widget.studentId);

    if (mounted && result['success']) {
      final data = Map<String, dynamic>.from(result['data']);

      // CRITICAL FIX: Fetch detailed attendance history separately to get topics
      // Tries to find the correct user ID from the response, falling back to the widget ID
      try {
        final String targetId = data['user_id']?.toString() ??
            data['student_id']?.toString() ??
            data['id']?.toString() ??
            widget.studentId;

        final detailedHistory =
            await AttendanceService.getAttendanceHistoryForUser(targetId);

        data['attendanceHistory'] = detailedHistory;
      } catch (e) {
        debugPrint("Error fetching detailed attendance history: $e");
        // Fallback to existing history in data if fetch fails
      }

      List<RecommendedBook> parsedBooks = [];
      String? initialGradeYear;

      try {
        final rawBooks =
            data['recommendedBooks'] ?? data['recommended_books'] ?? [];
        if (rawBooks is List) {
          parsedBooks = rawBooks
              .map((bookJson) {
                try {
                  return RecommendedBook.fromJson(bookJson);
                } catch (e) {
                  return null;
                }
              })
              .whereType<RecommendedBook>()
              .toList();
        }
      } catch (e) {
        debugPrint("Error processing books list: $e");
      }

      try {
        final gradeHistory = data['gradeHistory'] ?? data['grade_history'];
        if (gradeHistory != null && (gradeHistory as List).isNotEmpty) {
          final lastYear = gradeHistory.last as Map<String, dynamic>;
          final spClass =
              lastYear['spiritual_class'] ?? lastYear['spiritualClass'] ?? '';
          final acYear =
              lastYear['academic_year'] ?? lastYear['academicYear'] ?? '';
          initialGradeYear = "$spClass - $acYear";
        }
      } catch (e) {
        debugPrint("Error calculating initial grade year: $e");
      }

      setState(() {
        _studentData = data;
        _books = parsedBooks;
        _selectedGradeYear = initialGradeYear;
        _handleFilterChange();
      });
    } else if (mounted) {
      setState(() {
        _error = result['message'] ?? "የተማሪውን መረጃ ማግኘት አልተቻለም።";
      });
    }
  }

  void _handleFilterChange() {
    if (_studentData == null) return;

    final rawHistory = _studentData!['attendanceHistory'] ??
        _studentData!['attendance_history'] ??
        [];

    final history = List<Map<String, dynamic>>.from(rawHistory);

    final results = _calculateAttendanceStats(history);
    setState(() {
      _attendanceStats = results;
      _filteredHistory = results['history'] ?? [];
    });
  }

  Map<String, dynamic> _calculateAttendanceStats(List<dynamic> history) {
    DateTime now = DateTime.now();
    DateTime? startDate;
    switch (_selectedDateFilter) {
      case DateFilter.weekly:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case DateFilter.monthly:
        startDate = now.subtract(const Duration(days: 30));
        break;
      case DateFilter.yearly:
        startDate = now.subtract(const Duration(days: 365));
        break;
      case DateFilter.allTime:
        startDate = null;
        break;
      case DateFilter.custom:
        startDate = now.subtract(const Duration(days: 90));
        break;
    }

    var filteredHistory = history.where((r) {
      if (startDate == null) return true;
      final dateVal = r['attendance_date'] ?? r['date'] ?? r['created_at'];
      if (dateVal == null) return false;
      final recordDate = DateTime.tryParse(dateVal.toString());
      if (recordDate == null) return false;
      return recordDate.isAfter(startDate);
    }).toList();

    if (_selectedAttendanceType != AttendanceType.all) {
      filteredHistory = filteredHistory.where((r) {
        // Fix: check both 'attendance_type' and 'type'
        final type =
            (r['attendance_type'] ?? r['type'])?.toString().toLowerCase();
        return type == _selectedAttendanceType.name.toLowerCase();
      }).toList();
    }

    int present = filteredHistory
        .where((r) => r['status']?.toString().toLowerCase() == 'present')
        .length;
    int absent = filteredHistory
        .where((r) => r['status']?.toString().toLowerCase() == 'absent')
        .length;
    int late = filteredHistory
        .where((r) => r['status']?.toString().toLowerCase() == 'late')
        .length;
    int total = filteredHistory.length;
    double percentage = total > 0 ? ((present + late) / total * 100) : 0.0;

    return {
      'totalSessions': total,
      'present': present,
      'absent': absent,
      'late': late,
      'percentage': percentage,
      'history': filteredHistory // Included history here
    };
  }

  // --- UI Build Methods ---

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final bgColor = themeProvider.getBackgroundColor(context);
    final surfaceColor = themeProvider.getSurfaceColor(context);
    final primaryColor = themeProvider.getPrimaryColor(context);
    final textColor = themeProvider.getOnSurfaceColor(context);
    final subtleTextColor = themeProvider.getSubtleTextColor(context);
    final isDark = themeProvider.isDarkMode(context);

    const successColor = ThemeProvider.successColor;
    const warningColor = ThemeProvider.warningColor;
    const dangerColor = ThemeProvider.dangerColor;

    if (_error != null) {
      return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(widget.studentName,
                style: GoogleFonts.notoSansEthiopic(color: textColor)),
            backgroundColor: bgColor,
            elevation: 0,
            iconTheme: IconThemeData(color: primaryColor),
          ),
          body: Center(
              child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.warning_2, color: dangerColor, size: 60),
                const SizedBox(height: 16),
                Text(_error!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansEthiopic(color: textColor)),
              ],
            ),
          )));
    }

    if (_studentData == null) {
      return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: Text(widget.studentName,
                style: GoogleFonts.notoSansEthiopic(color: textColor)),
            backgroundColor: bgColor,
            elevation: 0,
            iconTheme: IconThemeData(color: primaryColor),
          ),
          body: Center(child: CircularProgressIndicator(color: primaryColor)));
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text(widget.studentName,
                  style: GoogleFonts.notoSansEthiopic(
                      fontWeight: FontWeight.bold, color: textColor)),
              backgroundColor: bgColor,
              foregroundColor: primaryColor,
              pinned: true,
              floating: true,
              elevation: innerBoxIsScrolled ? 2 : 0,
              iconTheme: IconThemeData(color: primaryColor),
            ),
            SliverToBoxAdapter(
                child: _buildDetailHeader(_studentData!, primaryColor,
                    surfaceColor, textColor, subtleTextColor)),
            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: primaryColor,
                  unselectedLabelColor: subtleTextColor,
                  indicatorColor: primaryColor,
                  tabs: const [
                    Tab(icon: Icon(Iconsax.chart_2), text: "ሁኔታ"),
                    Tab(icon: Icon(Iconsax.chart_21), text: "መገኘት"),
                    Tab(icon: Icon(Iconsax.book_1), text: "ውጤቶች"),
                    Tab(icon: Icon(Iconsax.bookmark), text: "ንባብ"),
                  ],
                ),
                bgColor,
              ),
              pinned: true,
            ),
          ];
        },
        body: Container(
          color: bgColor,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildStatusTab(_studentData!, primaryColor, surfaceColor,
                  textColor, subtleTextColor, isDark),
              _buildAttendanceTab(primaryColor, surfaceColor, textColor,
                  subtleTextColor, successColor, warningColor, dangerColor),
              _buildGradesTab(primaryColor, surfaceColor, textColor,
                  subtleTextColor, successColor, warningColor, dangerColor),
              _buildReadingTab(primaryColor, surfaceColor, textColor,
                  subtleTextColor, successColor, dangerColor),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Methods ---

  Widget _buildStatusTab(Map<String, dynamic> data, Color primaryColor,
      Color surfaceColor, Color textColor, Color subtleTextColor, bool isDark) {
    // Determine status based on service_status with fallbacks
    // Use the first non-empty, non-null status field
    final List<String?> statusFields = [
      data['service_status']?.toString(),
      data['status']?.toString(),
      data['account_status']?.toString(),
      data['user_status']?.toString(),
    ];

    String statusRaw = 'inactive';
    for (var field in statusFields) {
      if (field != null && field.trim().isNotEmpty) {
        statusRaw = field.trim();
        break;
      }
    }

    final status = statusRaw.toLowerCase();

    final isActive = status == 'active';
    final isOnBreak = status == 'onbreak';

    // Calculate attendance for status tab (all time/history)
    final rawHistory =
        data['attendanceHistory'] ?? data['attendance_history'] ?? [];
    final history = List<Map<String, dynamic>>.from(rawHistory);
    int present = history
        .where((i) => i['status']?.toString().toLowerCase() == 'present')
        .length;
    int absent = history
        .where((i) => i['status']?.toString().toLowerCase() == 'absent')
        .length;
    double percent = history.isNotEmpty ? present / history.length : 0;

    return ListView(
      primary: false,
      padding: const EdgeInsets.all(20),
      children: [
        // Status Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: textColor.withValues(alpha: 0.05))),
          child: Column(
            children: [
              Text("የአገልግሎት ሁኔታ",
                  style: GoogleFonts.notoSansEthiopic(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              if (isActive)
                const Icon(Icons.check_circle, color: Colors.green, size: 48)
              else if (isOnBreak)
                const Icon(Icons.pause_circle_filled,
                    color: Colors.orange, size: 48)
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: ThemeProvider.dangerColor, width: 2)),
                  child: const Icon(Icons.close,
                      color: ThemeProvider.dangerColor, size: 36),
                ),
              const SizedBox(height: 20),
              Text(
                  isActive
                      ? (data['service_sector']?.toString() ?? "በአገልግሎት ላይ ያለ")
                      : (isOnBreak ? "በእረፍት ላይ" : "አገልግሎት ላይ ያልሆነ"),
                  style: GoogleFonts.notoSansEthiopic(
                      color: isActive
                          ? Colors.green
                          : (isOnBreak
                              ? Colors.orange
                              : ThemeProvider.dangerColor),
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("ይህ ሁኔታ የሚተዳደረው በስተዳደር ነው::",
                  style: GoogleFonts.notoSansEthiopic(
                      color: subtleTextColor, fontSize: 13)),

              // Last Activity Section
              if (history.isNotEmpty) ...[
                const SizedBox(height: 24),
                Divider(color: textColor.withValues(alpha: 0.1)),
                const SizedBox(height: 16),
                Text("የመጨረሻ እንቅስቃሴ",
                    style: GoogleFonts.notoSansEthiopic(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                () {
                  // Get the most recent attendance record
                  final latestRecord = history.first;
                  final recordDate =
                      latestRecord['date'] ?? latestRecord['attendance_date'];
                  final recordStatus =
                      latestRecord['status']?.toString().toLowerCase() ??
                          'unknown';
                  final topic = latestRecord['topic'] ??
                      latestRecord['lesson_topic'] ??
                      latestRecord['daily_topic'] ??
                      latestRecord['title'] ??
                      'ርዕስ የለም';

                  // Format date
                  String formattedDate = '';
                  bool isToday = false;
                  if (recordDate != null) {
                    try {
                      final parsedDate = DateTime.parse(recordDate.toString());
                      final ethDate = EthiopianDate.fromGregorian(parsedDate);
                      final now = DateTime.now();
                      final todayEth = EthiopianDate.fromGregorian(now);

                      isToday = ethDate.day == todayEth.day &&
                          ethDate.month == todayEth.month &&
                          ethDate.year == todayEth.year;

                      if (isToday) {
                        formattedDate = 'ዛሬ';
                      } else {
                        formattedDate = ethDate.toString();
                      }
                    } catch (e) {
                      formattedDate = recordDate.toString();
                    }
                  }

                  // Determine status color and text
                  Color statusColor;
                  String statusText;
                  IconData statusIcon;

                  switch (recordStatus) {
                    case 'present':
                      statusColor = ThemeProvider.successColor;
                      statusText = 'ተገኝቷል';
                      statusIcon = Iconsax.tick_circle;
                      break;
                    case 'absent':
                      statusColor = ThemeProvider.dangerColor;
                      statusText = 'አልተገኘም';
                      statusIcon = Iconsax.close_circle;
                      break;
                    case 'late':
                      statusColor = ThemeProvider.warningColor;
                      statusText = 'ዘግይቷል';
                      statusIcon = Iconsax.timer_1;
                      break;
                    default:
                      statusColor = subtleTextColor;
                      statusText = 'ያልታወቀ';
                      statusIcon = Iconsax.info_circle;
                  }

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: statusColor.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(statusIcon, color: statusColor, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              statusText,
                              style: GoogleFonts.notoSansEthiopic(
                                color: statusColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              formattedDate,
                              style: GoogleFonts.notoSansEthiopic(
                                color: isToday ? statusColor : subtleTextColor,
                                fontSize: 13,
                                fontWeight: isToday
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        if (topic != 'ርዕስ የለም') ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Iconsax.book_1,
                                  color: primaryColor, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  topic,
                                  style: GoogleFonts.notoSansEthiopic(
                                    color: textColor,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                }(),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Attendance Card
        InkWell(
          onTap: () => _tabController.animateTo(1),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: textColor.withValues(alpha: 0.05))),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("የመገኘት ማጠቃለያ",
                        style: GoogleFonts.notoSansEthiopic(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                    Icon(Iconsax.chart_2, color: primaryColor, size: 24),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularPercentIndicator(
                      radius: 50,
                      lineWidth: 10,
                      percent: percent.clamp(0.0, 1.0),
                      animation: true,
                      center: Text("${(percent * 100).toInt()}%",
                          style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      progressColor: primaryColor,
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    const SizedBox(width: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _legendRow(Iconsax.user_tick, "ተገኝቷል: $present",
                            Colors.green, textColor),
                        const SizedBox(height: 12),
                        _legendRow(Iconsax.user_minus, "ቀርቷል: $absent",
                            ThemeProvider.dangerColor, textColor),
                        const SizedBox(height: 12),
                        _legendRow(Iconsax.clock, "አስፈቅዷል: 0",
                            ThemeProvider.warningColor, textColor),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 24),
                Text("ለዝርዝር መረጃ 'መገኘት' የሚለውን ገጽ ይመልከቱ",
                    style: GoogleFonts.notoSansEthiopic(
                        color: primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _legendRow(IconData icon, String text, Color color, Color textColor) {
    return Row(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 10),
      Text(text,
          style: GoogleFonts.notoSansEthiopic(color: textColor, fontSize: 14))
    ]);
  }

  String _getAbsoluteUrl(String path) {
    if (path.isEmpty) return "";
    if (path.startsWith('http')) return path;

    try {
      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      final cleanBase = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
      final cleanPath = path.startsWith('/') ? path.substring(1) : path;

      return '$cleanBase/$cleanPath';
    } catch (_) {
      return path;
    }
  }

  Widget _buildDetailHeader(Map<String, dynamic> data, Color primaryColor,
      Color surfaceColor, Color textColor, Color subtleTextColor) {
    final heroTag = 'family-member-avatar-${widget.studentId}';

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Hero(
            tag: heroTag,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: primaryColor.withValues(alpha: 0.2), width: 2),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: surfaceColor,
                child: ClipOval(
                  child: (data['profile_image_url'] != null &&
                          data['profile_image_url'].toString().isNotEmpty)
                      ? Image.network(
                          _getAbsoluteUrl(data['profile_image_url']),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Icon(
                            Iconsax.user,
                            size: 40,
                            color: primaryColor,
                          ),
                        )
                      : Icon(Iconsax.user, size: 40, color: primaryColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['full_name'] ?? widget.studentName,
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                const SizedBox(height: 4),
                Text(data['spiritual_class'] ?? 'ክፍል የለውም',
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 16, color: subtleTextColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab(
      Color primaryColor,
      Color surfaceColor,
      Color textColor,
      Color subtleTextColor,
      Color successColor,
      Color warningColor,
      Color dangerColor) {
    return SingleChildScrollView(
      primary: false,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildAttendanceFilters(primaryColor, surfaceColor, textColor),
          const SizedBox(height: 24),
          _buildAttendanceSummaryCard(
              _attendanceStats,
              primaryColor,
              surfaceColor,
              textColor,
              subtleTextColor,
              successColor,
              warningColor,
              dangerColor),
          const SizedBox(height: 24),
          _buildAttendanceLogList(
              textColor, subtleTextColor, surfaceColor, primaryColor),
        ],
      ),
    );
  }

  Widget _buildAttendanceFilters(
      Color primaryColor, Color surfaceColor, Color textColor) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("መገኘትን አጣራ",
          style: GoogleFonts.notoSansEthiopic(
              fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor)),
      const SizedBox(height: 12),
      DropdownButtonFormField<AttendanceType>(
        initialValue: _selectedAttendanceType,
        dropdownColor: surfaceColor,
        style: GoogleFonts.notoSansEthiopic(color: textColor),
        decoration: InputDecoration(
            prefixIcon: Icon(Iconsax.category, size: 20, color: primaryColor),
            labelText: 'የመገኘት ዓይነት',
            labelStyle: TextStyle(color: textColor.withValues(alpha: 0.7)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: textColor.withValues(alpha: 0.1)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        items: AttendanceType.values
            .map((type) => DropdownMenuItem(
                value: type, child: Text(_attendanceTypeTranslations[type]!)))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedAttendanceType = value);
            _handleFilterChange();
          }
        },
      ),
      const SizedBox(height: 16),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: DateFilter.values.map((filter) {
            final isSelected = _selectedDateFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(_dateFilterTranslations[filter]!),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedDateFilter = filter);
                    _handleFilterChange();
                  }
                },
                selectedColor: primaryColor,
                checkmarkColor: Colors.white,
                labelStyle: GoogleFonts.notoSansEthiopic(
                    color: isSelected ? Colors.white : textColor, fontSize: 13),
                backgroundColor: surfaceColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? primaryColor
                        : textColor.withValues(alpha: 0.1),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      )
    ]);
  }

  Widget _buildAttendanceSummaryCard(
      Map<String, dynamic> attendance,
      Color primaryColor,
      Color surfaceColor,
      Color textColor,
      Color subtleTextColor,
      Color successColor,
      Color warningColor,
      Color dangerColor) {
    double percentage = (attendance['percentage'] ?? 0.0) / 100.0;
    return Card(
        elevation: 0,
        color: surfaceColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: textColor.withValues(alpha: 0.05))),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("የመገኘት ማጠቃለያ",
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                Icon(Iconsax.chart_2, color: primaryColor, size: 24),
              ],
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                  flex: 2,
                  child: CircularPercentIndicator(
                      radius: 55.0,
                      lineWidth: 10.0,
                      animation: true,
                      percent: percentage,
                      center: Text("${(percentage * 100).toStringAsFixed(0)}%",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: textColor)),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: primaryColor,
                      backgroundColor: primaryColor.withValues(alpha: 0.1))),
              const SizedBox(width: 24),
              Expanded(
                  flex: 3,
                  child: Column(children: [
                    _buildStatRow(
                        "ጠቅላላ",
                        attendance['totalSessions'] ?? 0,
                        Iconsax.activity,
                        primaryColor,
                        textColor,
                        subtleTextColor),
                    _buildStatRow(
                        "የተገኙ",
                        attendance['present'] ?? 0,
                        Iconsax.user_tick,
                        successColor,
                        textColor,
                        subtleTextColor),
                    _buildStatRow(
                        "የቀሩ",
                        attendance['absent'] ?? 0,
                        Iconsax.user_minus,
                        dangerColor,
                        textColor,
                        subtleTextColor),
                    _buildStatRow(
                        "የዘገየ",
                        attendance['late'] ?? 0,
                        Iconsax.timer_1,
                        ThemeProvider.warningColor,
                        textColor,
                        subtleTextColor),
                  ])),
            ]),
          ]),
        ));
  }

  Widget _buildStatRow(String label, int value, IconData icon, Color color,
      Color textColor, Color subtleTextColor) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: GoogleFonts.notoSansEthiopic(
                  color: subtleTextColor, fontSize: 13)),
          const Spacer(),
          Text(value.toString(),
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
        ]));
  }

  Widget _buildAttendanceLogList(Color textColor, Color subtleTextColor,
      Color surfaceColor, Color primaryColor) {
    if (_filteredHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Iconsax.info_circle,
                  size: 48, color: subtleTextColor.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                "ምንም መረጃ አልተገኘም",
                style: GoogleFonts.notoSansEthiopic(
                  color: subtleTextColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 16.0),
          child: Text("ዝርዝር መግለጫ",
              style: GoogleFonts.notoSansEthiopic(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        ),
        ListView.builder(
          primary: false,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredHistory.length,
          itemBuilder: (context, index) {
            final record = _filteredHistory[index];
            final isLast = index == _filteredHistory.length - 1;
            final isFirst = index == 0;
            // Using logic to determine first/last for timeline
            return _buildTimelineLogItem(record, isFirst, isLast, textColor,
                subtleTextColor, surfaceColor, primaryColor);
          },
        ),
      ],
    );
  }

  Widget _buildTimelineLogItem(
      Map<String, dynamic> record,
      bool isFirst,
      bool isLast,
      Color textColor,
      Color subtleTextColor,
      Color surfaceColor,
      Color primaryColor) {
    final status = record['status']?.toString().toLowerCase() ?? 'unknown';
    final dateVal =
        record['attendance_date'] ?? record['date'] ?? record['created_at'];

    String formattedDate = 'N/A';
    if (dateVal != null) {
      try {
        final etDate = EthiopianDate.parse(dateVal.toString());
        formattedDate = etDate.toString();
      } catch (e) {
        formattedDate = dateVal.toString();
      }
    }

    // Get attendance type and localize it
    String typeRaw =
        (record['attendance_type'] ?? record['type'] ?? 'learning').toString();
    String typeLocalized = typeRaw;
    // Simple localization based on common types
    if (typeRaw.toLowerCase().contains('hymn')) {
      typeLocalized = 'ዝማሬ';
    } else if (typeRaw.toLowerCase().contains('awude')) {
      typeLocalized = 'ዐውደ ምሕረት';
    } else if (typeRaw.toLowerCase().contains('special')) {
      typeLocalized = 'ልዩ';
    } else {
      typeLocalized = 'ትምህርት';
    }

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'present':
        statusColor = ThemeProvider.successColor;
        statusIcon = Iconsax.tick_circle;
        statusText = "ተገኝቷል";
        break;
      case 'absent':
        statusColor = ThemeProvider.dangerColor;
        statusIcon = Iconsax.close_circle;
        statusText = "ቀርቷል";
        break;
      case 'late':
        statusColor = ThemeProvider.warningColor;
        statusIcon = Iconsax.clock;
        statusText = "ዘግይቷል";
        break;
      case 'permission':
        statusColor = ThemeProvider.permissionColor;
        statusIcon = Iconsax.document_text;
        statusText = "ፍቃድ";
        break;
      default:
        statusColor = subtleTextColor;
        statusIcon = Iconsax.info_circle;
        statusText = "አልታወቀም";
    }

    final topic = record['topic'] ??
        record['lesson_topic'] ??
        record['daily_topic'] ??
        record['title'] ??
        "ርዕስ አልተጠቀሰም";

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline logic
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 24,
                  color: isFirst
                      ? Colors.transparent
                      : textColor.withValues(alpha: 0.1),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: surfaceColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: statusColor, width: 2)),
                  child: Icon(statusIcon, color: statusColor, size: 16),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : textColor.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: textColor.withValues(alpha: 0.05)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ]),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(formattedDate,
                            style: GoogleFonts.notoSansEthiopic(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: statusColor.withValues(alpha: 0.3))),
                          child: Text(statusText,
                              style: GoogleFonts.notoSansEthiopic(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: textColor.withValues(alpha: 0.05)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Iconsax.book_1, color: primaryColor, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            topic,
                            style: GoogleFonts.notoSansEthiopic(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(Iconsax.category,
                                size: 16, color: subtleTextColor),
                            const SizedBox(width: 6),
                            Text(typeLocalized,
                                style: GoogleFonts.notoSansEthiopic(
                                    color: subtleTextColor, fontSize: 13))
                          ],
                        ),
                        const SizedBox(width: 16),
                        Row(
                          children: [
                            Icon(Iconsax.clock,
                                size: 16, color: subtleTextColor),
                            const SizedBox(width: 6),
                            Text(record['session'] ?? 'Session',
                                style: GoogleFonts.notoSansEthiopic(
                                    color: subtleTextColor, fontSize: 13))
                          ],
                        ),
                      ],
                    ),
                    if (record['late_time'] != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Iconsax.timer_1,
                              size: 16, color: ThemeProvider.warningColor),
                          const SizedBox(width: 6),
                          Text("የመጣበት ሰዓት: ${record['late_time']}",
                              style: GoogleFonts.notoSansEthiopic(
                                  color: subtleTextColor, fontSize: 12))
                        ],
                      )
                    ]
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGradesTab(
      Color primaryColor,
      Color surfaceColor,
      Color textColor,
      Color subtleTextColor,
      Color successColor,
      Color warningColor,
      Color dangerColor) {
    final rawGrades =
        _studentData!['gradeHistory'] ?? _studentData!['grade_history'] ?? [];
    return ListView(
      primary: false,
      padding: const EdgeInsets.all(20),
      children: [
        _buildGradesCard(
            List<Map<String, dynamic>>.from(rawGrades),
            primaryColor,
            surfaceColor,
            textColor,
            successColor,
            warningColor,
            dangerColor)
      ],
    );
  }

  Widget _buildGradesCard(
      List<Map<String, dynamic>> gradeHistory,
      Color primaryColor,
      Color surfaceColor,
      Color textColor,
      Color successColor,
      Color warningColor,
      Color dangerColor) {
    final selectedYearData = _selectedGradeYear == null
        ? null
        : gradeHistory.where((g) {
            final spClass = g['spiritual_class'] ?? g['spiritualClass'] ?? '';
            final acYear = g['academic_year'] ?? g['academicYear'] ?? '';
            return "$spClass - $acYear" == _selectedGradeYear;
          }).firstOrNull;

    final gradesForTable = selectedYearData?['grades'] as List<dynamic>? ?? [];
    final overallAverage = selectedYearData?['average'] is num
        ? (selectedYearData!['average'] as num).toDouble()
        : 0.0;

    final historySet = <String>{};
    final uniqueHistory = gradeHistory.where((h) {
      final spClass = h['spiritual_class'] ?? h['spiritualClass'] ?? '';
      final acYear = h['academic_year'] ?? h['academicYear'] ?? '';
      final key = "$spClass - $acYear";
      if (historySet.contains(key)) return false;
      historySet.add(key);
      return true;
    }).toList();

    return Card(
      elevation: 0,
      color: surfaceColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: textColor.withValues(alpha: 0.05))),
      child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("የትምህርት ውጤት",
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                Icon(Iconsax.book_1, color: primaryColor, size: 24),
              ],
            ),
            const SizedBox(height: 20),
            if (uniqueHistory.isNotEmpty)
              DropdownButtonFormField<String>(
                initialValue: _selectedGradeYear,
                isExpanded: true,
                dropdownColor: surfaceColor,
                style: GoogleFonts.notoSansEthiopic(color: textColor),
                decoration: InputDecoration(
                    labelText: 'የትምህርት ዓመት ይምረጡ',
                    labelStyle:
                        TextStyle(color: textColor.withValues(alpha: 0.6)),
                    prefixIcon: Icon(Iconsax.calendar_1, color: primaryColor),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: textColor.withValues(alpha: 0.1)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10)),
                items: uniqueHistory.map((history) {
                  final spClass = history['spiritual_class'] ??
                      history['spiritualClass'] ??
                      '';
                  final acYear =
                      history['academic_year'] ?? history['academicYear'] ?? '';
                  final yearString = "$spClass - $acYear";
                  return DropdownMenuItem(
                      value: yearString,
                      child: Text(yearString,
                          style: GoogleFonts.notoSansEthiopic(
                              color: textColor, fontSize: 14),
                          overflow: TextOverflow.ellipsis));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedGradeYear = value),
              ),
            const SizedBox(height: 24),
            if (gradeHistory.isEmpty)
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                      child: Text("ለዚህ ተማሪ ምንም የውጤት ታሪክ የለም።",
                          style: GoogleFonts.notoSansEthiopic(
                              color: textColor.withValues(alpha: 0.5)))))
            else if (gradesForTable.isEmpty)
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                      child: Text("ለዚህ ምርጫ ምንም ውጤት አልተገኘም።",
                          style: GoogleFonts.notoSansEthiopic(
                              color: textColor.withValues(alpha: 0.5)))))
            else ...[
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                        dividerColor: textColor.withValues(alpha: 0.05)),
                    child: DataTable(
                      headingRowHeight: 45,
                      dataRowMinHeight: 45,
                      dataRowMaxHeight: 55,
                      horizontalMargin: 12,
                      columnSpacing: 20,
                      headingRowColor: WidgetStateProperty.all(
                          primaryColor.withValues(alpha: 0.05)),
                      columns: [
                        DataColumn(
                            label: Text('የትምህርት ዓይነት',
                                style: GoogleFonts.notoSansEthiopic(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    fontSize: 13))),
                        DataColumn(
                            label: Text('ጠቅላላ',
                                style: GoogleFonts.notoSansEthiopic(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                    fontSize: 13)),
                            numeric: true),
                      ],
                      rows: gradesForTable.map((grade) {
                        int total = grade['total'] is int
                            ? grade['total']
                            : int.tryParse(grade['total'].toString()) ?? 0;
                        Color gradeColor = total >= 85
                            ? successColor
                            : (total >= 50 ? warningColor : dangerColor);

                        String courseName =
                            grade['course_name'] ?? grade['courseName'] ?? '';

                        return DataRow(cells: [
                          DataCell(Text(courseName,
                              style: GoogleFonts.notoSansEthiopic(
                                  color: textColor, fontSize: 13))),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: gradeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text("$total%",
                                style: GoogleFonts.poppins(
                                    color: gradeColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold)),
                          )),
                        ]);
                      }).toList(),
                    ),
                  )),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("አጠቃላይ አማካይ",
                          style: GoogleFonts.notoSansEthiopic(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: textColor)),
                      Text("${overallAverage.toStringAsFixed(1)}%",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: primaryColor)),
                    ]),
              ),
            ]
          ])),
    );
  }

  Widget _buildReadingTab(
      Color primaryColor,
      Color surfaceColor,
      Color textColor,
      Color subtleTextColor,
      Color successColor,
      Color dangerColor) {
    return ListView(
      primary: false,
      padding: const EdgeInsets.all(20),
      children: [
        _buildBookRecommendationCard(primaryColor, surfaceColor, textColor,
            subtleTextColor, successColor, dangerColor)
      ],
    );
  }

  Widget _buildBookRecommendationCard(
      Color primaryColor,
      Color surfaceColor,
      Color textColor,
      Color subtleTextColor,
      Color successColor,
      Color dangerColor) {
    final unreadBooks = _books.where((book) => !book.isRead).toList();
    final readBooks = _books.where((book) => book.isRead).toList();

    return Card(
      elevation: 0,
      color: surfaceColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: textColor.withValues(alpha: 0.05))),
      child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("የንባብ ክትትል",
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                Icon(Iconsax.bookmark, color: primaryColor, size: 24),
              ],
            ),
            if (unreadBooks.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text("የሚቀጥለው",
                  style: GoogleFonts.notoSansEthiopic(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      fontSize: 15)),
              ...unreadBooks.map((book) => _buildBookTile(book, primaryColor,
                  textColor, subtleTextColor, successColor, dangerColor)),
            ],
            if (readBooks.isNotEmpty) ...[
              const Divider(height: 32),
              Text("የተጠናቀቁ",
                  style: GoogleFonts.notoSansEthiopic(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      fontSize: 15)),
              ...readBooks.map((book) => _buildBookTile(book, primaryColor,
                  textColor, subtleTextColor, successColor, dangerColor)),
            ],
            if (_books.isEmpty)
              Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                      child: Column(
                    children: [
                      Icon(Iconsax.book,
                          color: textColor.withValues(alpha: 0.1), size: 48),
                      const SizedBox(height: 16),
                      Text("እስካሁን የተመከሩ መጽሐፍት የሉም።",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSansEthiopic(
                              color: textColor.withValues(alpha: 0.5))),
                    ],
                  ))),
          ])),
    );
  }

  Widget _buildBookTile(
      RecommendedBook book,
      Color primaryColor,
      Color textColor,
      Color subtleTextColor,
      Color successColor,
      Color dangerColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: book.isRead,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        onChanged: (bool? value) async {
          if (value == null) return;
          setState(() => book.isRead = value);

          final result =
              await FamilyService.toggleBookStatus(book.id.toString(), value);

          if (mounted && !result['success']) {
            setState(() => book.isRead = !value);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(result['message'] ?? "ሁኔታውን ማዘመን አልተቻለም"),
              backgroundColor: dangerColor,
            ));
          }
        },
        activeColor: primaryColor,
      ),
      title: Text(book.title,
          style: GoogleFonts.notoSansEthiopic(
              decoration: book.isRead ? TextDecoration.lineThrough : null,
              fontWeight: book.isRead ? FontWeight.normal : FontWeight.w500,
              fontSize: 14,
              color: book.isRead ? subtleTextColor : textColor)),
      subtitle: Text("መመለሻ ቀን: ${EthiopianDate.fromGregorian(book.deadline)}",
          style: GoogleFonts.poppins(fontSize: 11, color: subtleTextColor)),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar, this.backgroundColor);
  final TabBar _tabBar;
  final Color backgroundColor;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: backgroundColor, child: _tabBar);
  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor;
}

extension StringExtension on String {
  String capitalize() =>
      isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
}
