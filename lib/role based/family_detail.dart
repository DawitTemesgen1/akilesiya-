// lib/screens/family/family_member_detail_screen.dart

import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
import 'package:amde_haymanot_abalat_guday/models/ethiopian_date_picker.dart'; // Import for EthiopianDate
import 'package:amde_haymanot_abalat_guday/services/family_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

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
    return RecommendedBook(
      id: json['id'],
      title: json['title'],
      deadline: DateTime.parse(json['deadline']),
      isRead: json['is_read'] == 1 || json['is_read'] == true,
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
    if (mounted && result['success']) {
      final data = result['data'];
      setState(() {
        _studentData = data;
        _books = (data['recommendedBooks'] as List? ?? [])
            .map((bookJson) => RecommendedBook.fromJson(bookJson))
            .toList();

        final gradeHistory = data['gradeHistory'] as List<dynamic>?;
        if (gradeHistory != null && gradeHistory.isNotEmpty) {
          final lastYear = gradeHistory.last as Map<String, dynamic>;
          _selectedGradeYear =
              "${lastYear['spiritualClass']} - ${lastYear['academicYear']}";
        }
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
    final history = List<Map<String, dynamic>>.from(
        _studentData!['attendanceHistory'] ?? []);
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
      final dateString = r['attendance_date'] as String?;
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
                child: (data['profile_image_url'] != null)
                    ? Image.network(
                        data['profile_image_url'],
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
          Column(
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
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _buildGradesCard(List<Map<String, dynamic>>.from(
            _studentData!['gradeHistory'] ?? [])));
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
        value: _selectedAttendanceType,
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
        shadowColor: kPrimaryColor.withOpacity(0.1),
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
                      backgroundColor: kPrimaryColor.withOpacity(0.1))),
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
    final selectedYearData = _selectedGradeYear == null
        ? null
        : gradeHistory.firstWhere(
            (g) =>
                "${g['spiritualClass']} - ${g['academicYear']}" ==
                _selectedGradeYear,
            orElse: () => {'grades': [], 'average': 0.0});
    final gradesForTable = selectedYearData?['grades'] as List<dynamic>? ?? [];
    final overallAverage = selectedYearData?['average'] as double? ?? 0.0;

    return Card(
      elevation: 4,
      shadowColor: kPrimaryColor.withOpacity(0.1),
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
            if (gradeHistory.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedGradeYear,
                isExpanded: true,
                decoration: const InputDecoration(
                    labelText: 'የትምህርት ዓመት ይምረጡ',
                    prefixIcon: Icon(Iconsax.calendar_1),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                items: gradeHistory.map((history) {
                  final yearString =
                      "${history['spiritualClass']} - ${history['academicYear']}";
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
                    headingRowColor: MaterialStateProperty.all(
                        kPrimaryColor.withOpacity(0.05)),
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
                      int total = grade['total'] as int;
                      Color gradeColor = total >= 85
                          ? successColor
                          : (total >= 50 ? warningColor : dangerColor);
                      return DataRow(cells: [
                        DataCell(Text(grade['courseName'],
                            style: GoogleFonts.notoSansEthiopic())),
                        DataCell(Text(grade['assignment'].toString())),
                        DataCell(Text(grade['mid_exam'].toString())),
                        DataCell(Text(grade['final_exam'].toString())),
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
      shadowColor: kPrimaryColor.withOpacity(0.1),
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
              ...unreadBooks.map((book) => _buildBookTile(book)).toList(),
            ],
            if (readBooks.isNotEmpty) ...[
              const Divider(height: 24),
              Text("የተጠናቀቁ",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ...readBooks.map((book) => _buildBookTile(book)).toList(),
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
