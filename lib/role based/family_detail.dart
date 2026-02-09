// lib/screens/family/family_member_detail_screen.dart

import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';

import 'package:amde_haymanot_abalat_guday/services/family_service.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:iconsax/iconsax.dart';

// --- UI Theme Constants ---
const Color kBackgroundColor = Color(0xFFF4F7FC);
const Color kCardColor = Colors.white;
const Color kPrimaryColor = Color.fromARGB(255, 1, 37, 100);
const Color kAccentColor = Color(0xFFFFD700);
const Color kSubtleTextColor = Color(0xFF6C757D);
const Color successColor = Color(0xFF198754);
const Color warningColor = Color(0xFFFD7E14);
const Color dangerColor = Color(0xFFDC3545);

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

enum DateFilter { weekly, monthly, yearly, custom }

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
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // State for fetched data
  Map<String, dynamic>? _studentData;
  String? _error;

  // State for UI interactions
  AttendanceType _selectedAttendanceType = AttendanceType.all;
  DateFilter _selectedDateFilter = DateFilter.yearly;
  Map<String, dynamic> _attendanceStats = {};
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
    DateFilter.custom: 'ብጁ',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchStudentDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchStudentDetails() async {
    final result = await FamilyService.getStudentDetails(widget.studentId);

    // DEBUG LOGGING
    debugPrint("---------------- FAMILY DETAIL DEBUG ----------------");
    debugPrint("Success: ${result['success']}");
    if (result['data'] != null) {
      final data = result['data'];
      debugPrint("Data Keys: ${data.keys.toList()}");

      if (data['gradeHistory'] != null) {
        debugPrint("gradeHistory Type: ${data['gradeHistory'].runtimeType}");
        if (data['gradeHistory'] is List) {
          debugPrint(
              "gradeHistory Length: ${(data['gradeHistory'] as List).length}");
          if ((data['gradeHistory'] as List).isNotEmpty) {
            debugPrint(
                "First Grade Entry: ${(data['gradeHistory'] as List).first}");
          }
        }
      } else {
        debugPrint("gradeHistory is NULL. Checking grade_history...");
        debugPrint("grade_history: ${data['grade_history']}");
      }

      if (data['attendanceHistory'] != null) {
        debugPrint(
            "attendanceHistory (camel) found. Length: ${(data['attendanceHistory'] as List).length}");
      } else if (data['attendance_history'] != null) {
        debugPrint(
            "attendance_history (snake) found. Length: ${(data['attendance_history'] as List).length}");
      } else {
        debugPrint("NO ATTENDANCE DATA FOUND");
      }

      final rawBooks = data['recommendedBooks'] ?? data['recommended_books'];
      debugPrint("Books Data: $rawBooks");
    } else {
      debugPrint("DATA IS NULL");
    }
    debugPrint("-----------------------------------------------------");

    if (mounted && result['success']) {
      final data = result['data'];

      // Parse data safely outside setState to prevent crashes aborting strict updates
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
                  debugPrint("Error parsing book: $e");
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

  // --- Filtering Logic ---
  void _handleFilterChange() {
    if (_studentData == null) return;

    final rawHistory = _studentData!['attendanceHistory'] ??
        _studentData!['attendance_history'] ??
        [];
    final history = List<Map<String, dynamic>>.from(rawHistory);

    final newStats = _calculateAttendanceStats(history);
    setState(() {
      _attendanceStats = newStats;
    });
  }

  Map<String, dynamic> _calculateAttendanceStats(List<dynamic> history) {
    DateTime now = DateTime.now();
    DateTime startDate;
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
      case DateFilter.custom:
        startDate = now.subtract(const Duration(days: 90));
        break;
    }

    var filteredHistory = history.where((r) {
      // Robustly check for date key
      final dateString = r['attendance_date'] ?? r['date'] as String?;
      if (dateString == null) return false;
      final recordDate = DateTime.tryParse(dateString);
      return recordDate != null && recordDate.isAfter(startDate);
    }).toList();

    if (_selectedAttendanceType != AttendanceType.all) {
      filteredHistory = filteredHistory
          .where((r) => r['type'] == _selectedAttendanceType.name)
          .toList();
    }

    int present = filteredHistory.where((r) => r['status'] == 'present').length;
    int absent = filteredHistory.where((r) => r['status'] == 'absent').length;
    int late = filteredHistory.where((r) => r['status'] == 'late').length;
    int total = filteredHistory.length;
    double percentage = total > 0 ? ((present + late) / total * 100) : 0.0;

    return {
      'totalSessions': total,
      'present': present,
      'absent': absent,
      'late': late,
      'percentage': percentage
    };
  }

  // --- UI Build Methods ---
  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
          appBar: AppBar(title: Text(widget.studentName)),
          body: Center(child: Text(_error!)));
    }
    if (_studentData == null) {
      return Scaffold(
          appBar: AppBar(title: Text(widget.studentName)),
          body: const Center(
              child: CircularProgressIndicator(color: kPrimaryColor)));
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text(widget.studentName,
                  style: GoogleFonts.notoSansEthiopic(
                      fontWeight: FontWeight.bold)),
              backgroundColor: kBackgroundColor,
              foregroundColor: kPrimaryColor,
              pinned: true,
              floating: true,
              elevation: innerBoxIsScrolled ? 2 : 0,
            ),
            SliverToBoxAdapter(child: _buildDetailHeader(_studentData!)),
            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: kPrimaryColor,
                  unselectedLabelColor: kSubtleTextColor,
                  indicatorColor: kPrimaryColor,
                  tabs: const [
                    Tab(icon: Icon(Iconsax.chart_21), text: "መገኘት"),
                    Tab(icon: Icon(Iconsax.book_1), text: "ውጤቶች"),
                    Tab(icon: Icon(Iconsax.bookmark), text: "ንባብ"),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAttendanceTab(),
            _buildGradesTab(),
            _buildReadingTab(),
          ],
        ),
      ),
    );
  }

  String _getAbsoluteUrl(String path) {
    if (path.startsWith('http') || path.startsWith('https')) {
      return path;
    }
    // Remove /api from base url if present to get root url
    final baseUrl = ApiService.baseUrl.endsWith('/api')
        ? ApiService.baseUrl.substring(0, ApiService.baseUrl.length - 4)
        : ApiService.baseUrl;

    // Ensure properly joined path
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    return '$cleanBase/$cleanPath';
  }

  Widget _buildDetailHeader(Map<String, dynamic> data) {
    // Unique tag for the Hero animation
    final heroTag = 'family-member-avatar-${widget.studentId}';

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Hero(
            tag: heroTag,
            child: CircleAvatar(
              radius: 40,
              child: ClipOval(
                child: (data['profile_image_url'] != null &&
                        data['profile_image_url'].toString().isNotEmpty)
                    ? Image.network(
                        _getAbsoluteUrl(data['profile_image_url']),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => const Icon(
                          Iconsax.user,
                          size: 40,
                          color: kPrimaryColor,
                        ),
                      )
                    : const Icon(Iconsax.user, size: 40, color: kPrimaryColor),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['full_name'],
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor)),
                const SizedBox(height: 4),
                Text(data['spiritual_class'] ?? 'ክፍል የለውም',
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 16, color: kSubtleTextColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildAttendanceFilters(),
          const SizedBox(height: 24),
          _buildAttendanceSummaryCard(_attendanceStats),
        ],
      ),
    );
  }

  Widget _buildGradesTab() {
    final rawGrades =
        _studentData!['gradeHistory'] ?? _studentData!['grade_history'] ?? [];
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildGradesCard(List<Map<String, dynamic>>.from(rawGrades)));
  }

  Widget _buildReadingTab() {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildBookRecommendationCard());
  }

  Widget _buildAttendanceFilters() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("መገኘትን አጣራ",
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
      const SizedBox(height: 12),
      DropdownButtonFormField<AttendanceType>(
        initialValue: _selectedAttendanceType,
        decoration: InputDecoration(
            prefixIcon: const Icon(Iconsax.category, size: 20),
            labelText: 'የመገኘት ዓይነት',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      Wrap(
          spacing: 8.0,
          children: DateFilter.values.map((filter) {
            return FilterChip(
              label: Text(_dateFilterTranslations[filter]!),
              selected: _selectedDateFilter == filter,
              onSelected: (isSelected) {
                if (isSelected) {
                  setState(() => _selectedDateFilter = filter);
                  _handleFilterChange();
                }
              },
              selectedColor: kPrimaryColor,
              checkmarkColor: kAccentColor,
              labelStyle: TextStyle(
                  color: _selectedDateFilter == filter
                      ? Colors.white
                      : kPrimaryColor),
            );
          }).toList())
    ]);
  }

  Widget _buildAttendanceSummaryCard(Map<String, dynamic> attendance) {
    double percentage = (attendance['percentage'] ?? 0.0) / 100.0;
    return Card(
        elevation: 4,
        shadowColor: kPrimaryColor.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("የመገኘት ማጠቃለያ",
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  flex: 2,
                  child: CircularPercentIndicator(
                      radius: 60.0,
                      lineWidth: 12.0,
                      animation: true,
                      percent: percentage,
                      center: Text("${(percentage * 100).toStringAsFixed(0)}%",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              color: kPrimaryColor)),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: kPrimaryColor,
                      backgroundColor: kPrimaryColor.withValues(alpha: 0.1))),
              Expanded(
                  flex: 3,
                  child: Column(children: [
                    _buildStatRow("ጠቅላላ", attendance['totalSessions'] ?? 0,
                        Iconsax.activity, kPrimaryColor),
                    _buildStatRow("የተገኙ", attendance['present'] ?? 0,
                        Iconsax.user_tick, successColor),
                    _buildStatRow("የቀሩ", attendance['absent'] ?? 0,
                        Iconsax.user_minus, dangerColor),
                    _buildStatRow("ያረፈዱ", attendance['late'] ?? 0,
                        Iconsax.clock, warningColor),
                  ])),
            ]),
          ]),
        ));
  }

  Widget _buildStatRow(String label, int value, IconData icon, Color color) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text("$label:", style: GoogleFonts.poppins(color: kSubtleTextColor)),
          const Spacer(),
          Text(value.toString(),
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, color: kPrimaryColor)),
        ]));
  }

  Widget _buildGradesCard(List<Map<String, dynamic>> gradeHistory) {
    // Ensure we are using the correct data in case parameters are passed incorrectly
    // But since we pass it from build() we should make sure the build() call is correct
    // Let's rely on the passed gradeHistory, but update the build() text.

    final selectedYearData = _selectedGradeYear == null
        ? null
        : gradeHistory.firstWhere((g) {
            final spClass = g['spiritual_class'] ?? g['spiritualClass'] ?? '';
            final acYear = g['academic_year'] ?? g['academicYear'] ?? '';
            return "$spClass - $acYear" == _selectedGradeYear;
          }, orElse: () => {'grades': [], 'average': 0.0});
    final gradesForTable = selectedYearData?['grades'] as List<dynamic>? ?? [];
    final overallAverage = selectedYearData?['average'] as double? ?? 0.0;

    // Deduplicate history items for dropdown
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
      elevation: 4,
      shadowColor: kPrimaryColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("የትምህርት ውጤት ሪፖርት",
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor)),
            const SizedBox(height: 16),
            if (uniqueHistory.isNotEmpty)
              DropdownButtonFormField<String>(
                initialValue: _selectedGradeYear,
                isExpanded: true,
                decoration: const InputDecoration(
                    labelText: 'የትምህርት ዓመት ይምረጡ',
                    prefixIcon: Icon(Iconsax.calendar_1),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10)),
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
                          style: GoogleFonts.notoSansEthiopic(),
                          overflow: TextOverflow.ellipsis));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedGradeYear = value),
              ),
            const SizedBox(height: 16),
            if (gradeHistory.isEmpty)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("ለዚህ ተማሪ ምንም የውጤት ታሪክ የለም።")))
            else if (gradesForTable.isEmpty)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("ለዚህ ምርጫ ምንም ውጤት አልተገኘም።")))
            else ...[
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                        kPrimaryColor.withValues(alpha: 0.05)),
                    columns: const [
                      DataColumn(
                          label: Text('የትምህርት ዓይነት',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('የቤት ሥራ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          numeric: true),
                      DataColumn(
                          label: Text('የመሀል ፈተና',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          numeric: true),
                      DataColumn(
                          label: Text('የፍጻሜ ፈተና',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          numeric: true),
                      DataColumn(
                          label: Text('ጠቅላላ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          numeric: true),
                    ],
                    rows: gradesForTable.map((grade) {
                      int total = grade['total'] is int
                          ? grade['total']
                          : int.tryParse(grade['total'].toString()) ?? 0;
                      Color gradeColor = total >= 85
                          ? successColor
                          : (total >= 50 ? warningColor : dangerColor);

                      // Handle data mapping
                      String courseName =
                          grade['course_name'] ?? grade['courseName'] ?? '';
                      List scores =
                          grade['scores'] is List ? grade['scores'] : [];

                      // Helper to find score
                      dynamic getScore(String key, String legacyKey) {
                        // 1. Try legacy direct key
                        if (grade.containsKey(legacyKey)) {
                          return grade[legacyKey];
                        }
                        // 2. Try searching in scores list
                        if (scores.isNotEmpty) {
                          final match = scores.firstWhere((s) {
                            final name = s['assessment_name']
                                    ?.toString()
                                    .toLowerCase() ??
                                '';
                            return name.contains(key.toLowerCase());
                          }, orElse: () => null);
                          if (match != null) return match['score'];
                        }
                        return '-';
                      }

                      var assignment = getScore('assignment', 'assignment');
                      var midExam =
                          getScore('mid', 'mid_exam'); // Matches 'mid exam'
                      var finalExam = getScore('final', 'final_exam');

                      return DataRow(cells: [
                        DataCell(Text(courseName,
                            style: GoogleFonts.notoSansEthiopic())),
                        DataCell(Text(assignment.toString())),
                        DataCell(Text(midExam.toString())),
                        DataCell(Text(finalExam.toString())),
                        DataCell(Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("$total%",
                                  style: GoogleFonts.poppins(
                                      color: gradeColor,
                                      fontWeight: FontWeight.bold))
                            ])),
                      ]);
                    }).toList(),
                  )),
              const Divider(height: 24),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("አጠቃላይ አማካይ:",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("${overallAverage.toStringAsFixed(1)}%",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: kPrimaryColor)),
                      ])),
            ]
          ])),
    );
  }

  Widget _buildBookRecommendationCard() {
    final unreadBooks = _books.where((book) => !book.isRead).toList();
    final readBooks = _books.where((book) => book.isRead).toList();

    return Card(
      elevation: 4,
      shadowColor: kPrimaryColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("የንባብ ዝርዝር",
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor)),
            if (unreadBooks.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text("የሚቀጥለው",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ...unreadBooks.map((book) => _buildBookTile(book)),
            ],
            if (readBooks.isNotEmpty) ...[
              const Divider(height: 24),
              Text("የተጠናቀቁ",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ...readBooks.map((book) => _buildBookTile(book)),
            ],
            if (_books.isEmpty)
              const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text("እስካሁን የተመከሩ መጽሐፍት የሉም።"))),
          ])),
    );
  }

  Widget _buildBookTile(RecommendedBook book) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Checkbox(
        value: book.isRead,
        onChanged: (bool? value) async {
          if (value == null) return;
          setState(() => book.isRead = value); // Optimistic UI update

          final result =
              await FamilyService.toggleBookStatus(book.id.toString(), value);

          if (mounted && !result['success']) {
            // Revert on failure
            setState(() => book.isRead = !value);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(result['message'] ?? "ሁኔታውን ማዘመን አልተቻለም"),
              backgroundColor: dangerColor,
            ));
          }
        },
        activeColor: kPrimaryColor,
      ),
      title: Text(book.title,
          style: GoogleFonts.notoSansEthiopic(
              decoration: book.isRead ? TextDecoration.lineThrough : null,
              color: book.isRead ? kSubtleTextColor : null)),
      subtitle: Text("መመለሻ ቀን: ${EthiopianDate.fromGregorian(book.deadline)}",
          style: GoogleFonts.poppins(
              fontSize: 12,
              color: book.isRead ? kSubtleTextColor : warningColor)),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(color: kBackgroundColor, child: _tabBar);
  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

extension StringExtension on String {
  String capitalize() =>
      isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
}
