// lib/screens/attendance_summary_screen.dart

import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
import 'package:amde_haymanot_abalat_guday/providers/profile_config_provider.dart';
import 'package:amde_haymanot_abalat_guday/role%20based/attendance_detail.dart';
import 'package:amde_haymanot_abalat_guday/services/attendance_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

// --- UI Theme Constants ---
const Color primaryColor = Color.fromARGB(255, 1, 37, 100);
const Color surfaceColor = Color(0xFFF4F7FC);
const Color onSurfaceColor = Color(0xFF212529);
const Color subtleTextColor = Color(0xFF6C757D);
const Color successColor = Color(0xFF198754);
const Color warningColor = Color(0xFFFD7E14);
const Color dangerColor = Color(0xFFDC3545);
const Color permissionColor = Color(0xFF0D6EFD);

enum Session { morning, afternoon }

enum AttendanceType { learning, hymnLearning, awudemihiret, special }

// A simple class to hold a range of EthiopianDate objects
class EthiopianDateRange {
  final EthiopianDate start;
  final EthiopianDate end;
  EthiopianDateRange({required this.start, required this.end});
}

class AttendanceSummaryScreen extends StatefulWidget {
  const AttendanceSummaryScreen({super.key});

  @override
  State<AttendanceSummaryScreen> createState() =>
      _AttendanceSummaryScreenState();
}

class _AttendanceSummaryScreenState extends State<AttendanceSummaryScreen> {
  // State for Filters - NOW USES ETHIOPIAN DATE
  late EthiopianDateRange _selectedDateRange;
  String _selectedPreset = 'This Week'; // This key remains in English for logic
  AttendanceType? _selectedAttendanceType;
  Session? _selectedSession;
  dynamic _dynamicFilterField;
  int? _selectedDynamicOptionId;

  Future<Map<String, dynamic>>? _summaryFuture;

  // Translation map for presets
  final Map<String, String> _presetTranslations = {
    'Today': 'ዛሬ',
    'This Week': 'በዚህ ሳምንት',
    'This Month': 'በዚህ ወር',
    'This Year': 'በዚህ ዓመት',
    'Custom': 'ብጁ',
  };

  @override
  void initState() {
    super.initState();
    // Initialize with "This Week" in E.C. and then fetch data
    _setDateRangePreset('This Week');
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchSummary());
  }

  void _fetchSummary() {
    setState(() {
      _summaryFuture = AttendanceService.getDetailedAttendanceSummary(
        startDate: _selectedDateRange.start.toDatabaseString(),
        endDate: _selectedDateRange.end.toDatabaseString(),
        attendanceType: _selectedAttendanceType?.name,
        session: _selectedSession?.name,
        dynamicFilterFieldId: _dynamicFilterField?['id'],
        dynamicFilterOptionId: _selectedDynamicOptionId,
      );
    });
  }

  void _setDateRangePreset(String preset) {
    final etNow = EthiopianDate.now();
    EthiopianDate etStart;
    EthiopianDate etEnd = etNow;

    switch (preset) {
      case 'Today':
        etStart = etNow;
        break;
      case 'This Week':
        int gregorianWeekday =
            etNow.toGregorian().weekday; // Sunday=7, Monday=1
        int daysToSubtract = gregorianWeekday == 7
            ? 0
            : gregorianWeekday; // Sunday is start of week
        etStart = EthiopianDate.fromGregorian(
            etNow.toGregorian().subtract(Duration(days: daysToSubtract)));
        break;
      case 'This Month':
        etStart = EthiopianDate(year: etNow.year, month: etNow.month, day: 1);
        break;
      case 'This Year':
        etStart = EthiopianDate(year: etNow.year, month: 1, day: 1);
        break;
      default:
        return;
    }

    setState(() {
      _selectedDateRange = EthiopianDateRange(start: etStart, end: etEnd);
      _selectedPreset = preset;
    });
  }

  Future<void> _selectCustomDateRange() async {
    final startDate = await showDialog<EthiopianDate>(
      context: context,
      builder: (context) =>
          EthiopianDatePickerDialog(initialDate: _selectedDateRange.start),
    );
    if (startDate == null) return;

    final endDate = await showDialog<EthiopianDate>(
      context: context,
      builder: (context) =>
          EthiopianDatePickerDialog(initialDate: _selectedDateRange.end),
    );
    if (endDate == null) return;

    setState(() {
      _selectedDateRange = EthiopianDateRange(start: startDate, end: endDate);
      _selectedPreset = 'Custom';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: Text('የመገኘት ሪፖርት',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: primaryColor)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          _buildFilterCard(),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _summaryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('ስህተት: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: Colors.red.shade700))));
                }
                final summaryData = snapshot.data ?? {};
                final overallStats =
                    summaryData['overall_stats'] as Map<String, dynamic>? ?? {};
                final studentStats = List<Map<String, dynamic>>.from(
                    summaryData['student_stats'] ?? []);

                if (studentStats.isEmpty) {
                  return Center(
                      child: Text('ለተመረጡት ማጣሪያዎች ምንም መዝገብ አልተገኘም።',
                          style: GoogleFonts.poppins(color: subtleTextColor)));
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOverallStatsGrid(overallStats),
                      const SizedBox(height: 24),
                      Text('የተማሪዎች ዝርዝር (${studentStats.length})',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: onSurfaceColor)),
                      const SizedBox(height: 8),
                      _buildStudentDataTable(studentStats),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    final profileConfig = context.watch<ProfileConfigProvider>();
    final filterableFields = profileConfig.customFields
        .where((f) => f['type'] == 'DROPDOWN')
        .toList();

    return ExpansionTile(
      title: const Text('ማጣሪያዎች'),
      leading: const Icon(Iconsax.filter),
      initiallyExpanded: false,
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              _buildDatePresetChips(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                      child: DropdownButtonFormField<AttendanceType?>(
                          value: _selectedAttendanceType,
                          decoration: const InputDecoration(labelText: 'ዓይነት'),
                          items: [
                            const DropdownMenuItem<AttendanceType?>(
                                value: null, child: Text('ሁሉም ዓይነቶች')),
                            ...AttendanceType.values.map((type) =>
                                DropdownMenuItem(
                                    value: type, child: Text(type.name)))
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedAttendanceType = val))),
                  const SizedBox(width: 16),
                  Expanded(
                      child: DropdownButtonFormField<Session?>(
                          value: _selectedSession,
                          decoration:
                              const InputDecoration(labelText: 'ክፍለ ጊዜ'),
                          items: [
                            const DropdownMenuItem<Session?>(
                                value: null, child: Text('ሁሉም ክፍለ ጊዜያት')),
                            ...Session.values.map((session) => DropdownMenuItem(
                                value: session, child: Text(session.name)))
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedSession = val))),
                ],
              ),
              if (filterableFields.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: DropdownButtonFormField<dynamic>(
                            value: _dynamicFilterField,
                            hint: const Text("በ... ማጣራት"),
                            decoration:
                                const InputDecoration(labelText: 'በ... ማጣራት'),
                            items: [
                              const DropdownMenuItem<dynamic>(
                                  value: null, child: Text("ምንም")),
                              ...filterableFields.map((field) =>
                                  DropdownMenuItem<dynamic>(
                                      value: field, child: Text(field['name'])))
                            ],
                            onChanged: (val) => setState(() {
                                  _dynamicFilterField = val;
                                  _selectedDynamicOptionId = null;
                                }))),
                    if (_dynamicFilterField != null) ...[
                      const SizedBox(width: 16),
                      Expanded(
                          child: DropdownButtonFormField<int?>(
                              value: _selectedDynamicOptionId,
                              hint: Text(
                                  'ሁሉም ${_dynamicFilterField?['name'] ?? 'ምርጫዎች'}'),
                              decoration: InputDecoration(
                                  labelText:
                                      _dynamicFilterField?['name'] ?? 'ምርጫ'),
                              items: [
                                DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text(
                                        'ሁሉም ${_dynamicFilterField?['name'] ?? 'ምርጫዎች'}')),
                                ...(_dynamicFilterField?['options']
                                            as List<dynamic>? ??
                                        [])
                                    .map((opt) => DropdownMenuItem(
                                        value: opt['id'] as int,
                                        child: Text(opt['option_value'])))
                              ],
                              onChanged: (val) => setState(
                                  () => _selectedDynamicOptionId = val)))
                    ],
                  ],
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                      onPressed: _fetchSummary,
                      icon: const Icon(Iconsax.search_normal),
                      label: const Text("ማጣሪያዎችን ተግብር"),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePresetChips() {
    final presets = ['Today', 'This Week', 'This Month', 'This Year'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...presets
              .map((preset) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(_presetTranslations[preset]!),
                      selected: _selectedPreset == preset,
                      onSelected: (selected) {
                        if (selected) _setDateRangePreset(preset);
                      },
                    ),
                  ))
              .toList(),
          ActionChip(
            avatar: const Icon(Iconsax.calendar, size: 16),
            label: Text(_selectedPreset == 'Custom'
                ? _selectedDateRange.start.toString()
                : _presetTranslations['Custom']!),
            onPressed: _selectCustomDateRange,
            backgroundColor: _selectedPreset == 'Custom'
                ? Theme.of(context).chipTheme.selectedColor
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStatsGrid(Map<String, dynamic> stats) {
    final double overallPercentage =
        double.tryParse(stats['overall_percentage']?.toString() ?? '0.0') ??
            0.0;
    final int uniqueDays = stats['unique_days_count'] ?? 0;

    return Column(
      children: [
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            _buildStatCard('መዝገብ ያለባቸው ቀናት', uniqueDays.toString(),
                Iconsax.calendar_tick, Colors.blueGrey),
            _buildStatCard(
                'የመገኘት መጠን',
                '${overallPercentage.toStringAsFixed(1)}%',
                Iconsax.chart_2,
                primaryColor),
            _buildStatCard('ጠቅላላ የቀሩ', (stats['total_absent'] ?? 0).toString(),
                Iconsax.close_circle, dangerColor),
            _buildStatCard(
                'ጠቅላላ የተገኙ',
                (stats['total_present'] ?? 0).toString(),
                Iconsax.tick_circle,
                successColor),
            _buildStatCard('ጠቅላላ ያረፈዱ', (stats['total_late'] ?? 0).toString(),
                Iconsax.clock, warningColor),
            _buildStatCard(
                'ጠቅላላ በፈቃድ የቀሩ',
                (stats['total_permission'] ?? 0).toString(),
                Iconsax.document_text,
                permissionColor),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
// lib/role based/attendance_summary_screen.dart

// ... (keep the rest of the file the same)

  Widget _buildStudentDataTable(List<Map<String, dynamic>> students) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300)),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor:
              MaterialStateProperty.all(primaryColor.withOpacity(0.05)),
          showCheckboxColumn: false,
          // =========== THE FIX IS HERE ===========
          // The 'const' keyword has been removed from this list.
          columns: [
            DataColumn(
                label: Text(
                    AppLocalizations.of(context)?.attendanceColumnIndex ??
                        '#')),
            DataColumn(
                label: Text(
                    AppLocalizations.of(context)?.attendanceColumnName ??
                        'Name')),
            DataColumn(
                label: Text(
                    AppLocalizations.of(context)?.attendanceColumnPresent ??
                        'Present'),
                numeric: true),
            DataColumn(
                label: Text(
                    AppLocalizations.of(context)?.attendanceColumnAbsent ??
                        'Absent'),
                numeric: true),
            DataColumn(
                label: Text(
                    AppLocalizations.of(context)?.attendanceColumnLate ??
                        'Late'),
                numeric: true),
            DataColumn(
                label: Text(
                    AppLocalizations.of(context)?.attendanceColumnPercent ??
                        'Percent %'),
                numeric: true),
          ],
          // =======================================
          rows: students.asMap().entries.map((entry) {
            final index = entry.key;
            final student = entry.value;
            final double percentage =
                double.tryParse(student['percentage']?.toString() ?? '0.0') ??
                    0.0;

            final uniqueHeroTag = 'student-name-${student['user_id']}';

            return DataRow(
              onSelectChanged: (selected) {
                if (selected != null && selected) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserAttendanceDetailScreen(
                          userId: student['user_id'],
                          userName: student['full_name'],
                          heroTag: uniqueHeroTag,
                        ),
                      ));
                }
              },
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(
                  Hero(
                    tag: uniqueHeroTag,
                    child: Material(
                      color: Colors.transparent,
                      child: Text(student['full_name'] ?? 'N/A'),
                    ),
                  ),
                ),
                DataCell(Text((student['present_count'] ?? 0).toString())),
                DataCell(Text((student['absent_count'] ?? 0).toString())),
                DataCell(Text((student['late_count'] ?? 0).toString())),
                DataCell(
                  Text(percentage.toStringAsFixed(1),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: percentage >= 80
                              ? successColor
                              : (percentage >= 50
                                  ? warningColor
                                  : dangerColor))),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ... (keep the rest of the file the same)}
