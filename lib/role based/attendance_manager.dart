import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
import 'package:amde_haymanot_abalat_guday/providers/profile_config_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/sync_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';

import 'package:amde_haymanot_abalat_guday/services/attendance_service.dart';
import 'package:amde_haymanot_abalat_guday/services/sync_service.dart';

import 'package:amde_haymanot_abalat_guday/services/user_admin_service.dart';
import 'package:amde_haymanot_abalat_guday/widgets/sync_status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';

import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';

// --- (Constants are unchanged) ---
// --- (Constants are unchanged) ---
const Color kDefaultPrimaryColor = Color(0xFFFFC107); // Gold
const Color kDefaultAccentColor = Color(0xFFFFC107);
const Color kDefaultSurfaceColor = Color(0xFF151522); // Card Background
const Color kDefaultBackgroundColor = Color(0xFF050511); // Main Background
const Color kDefaultOnSurfaceColor = Colors.white;
const Color kDefaultSubtleTextColor = Colors.white54;
const Color successColor = Color(0xFF10B981);
const Color warningColor = Color(0xFFFD7E14);
const Color dangerColor = Color(0xFFEF4444);

class Student {
  final String id;
  final String name;
  final Map<String, int> customFields;
  Student({required this.id, required this.name, required this.customFields});
  factory Student.fromJson(Map<String, dynamic> json) {
    Map<String, int> fields = {};
    if (json['custom_fields'] is Map) {
      (json['custom_fields'] as Map).forEach((key, value) {
        if (value is int) {
          fields[key] = value;
        } else if (value != null) {
          fields[key] = int.tryParse(value.toString()) ?? 0;
        }
      });
    }
    return Student(
        id: json['id'].toString(),
        name: json['full_name'] as String? ?? 'Unnamed Student',
        customFields: fields);
  }
}

enum AttendanceStatus { present, absent, late, permission }

enum Session { morning, afternoon }

enum AttendanceType { learning, hymnLearning, awudemihiret, special }

// ===============================================================
// MAIN WIDGET: AttendanceScreen
// ===============================================================
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  Color get primaryColor =>
      Provider.of<ThemeProvider>(context).getPrimaryColor(context);
  Color get backgroundColor =>
      Provider.of<ThemeProvider>(context).getBackgroundColor(context);
  Color get surfaceColor =>
      Provider.of<ThemeProvider>(context).getSurfaceColor(context);
  Color get onSurfaceColor =>
      Provider.of<ThemeProvider>(context).getOnSurfaceColor(context);
  Color get subtleTextColor =>
      Provider.of<ThemeProvider>(context).getSubtleTextColor(context);
  Color get accentColor =>
      Provider.of<ThemeProvider>(context).getPrimaryColor(context);
  Color get dangerColor => const Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isSuperiorAdmin = userProvider.roles.contains('superior_admin');
    final isAttendanceAdmin = userProvider.roles.contains('attendance_admin');

    if (!isSuperiorAdmin && !isAttendanceAdmin) {
      return Scaffold(
          appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.attendanceScreenTitle,
                  style: GoogleFonts.notoSansEthiopic())),
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Icon(Iconsax.lock, size: 48, color: dangerColor),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)!.attendanceAccessDenied,
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(AppLocalizations.of(context)!.attendanceNoPermission,
                    style: GoogleFonts.notoSansEthiopic())
              ])));
    }

    List<Widget> tabs = [];
    List<Widget> tabViews = [];
    if (isAttendanceAdmin || isSuperiorAdmin) {
      tabs.add(Tab(
          icon: const Icon(Iconsax.document_text),
          text:
              AppLocalizations.of(context)!.attendanceTabRecord)); // Translated
      final bool isReadOnly = !isAttendanceAdmin;
      tabViews.add(AttendanceTakerView(isReadOnly: isReadOnly));
    }
    if (isSuperiorAdmin) {
      tabs.add(Tab(
          icon: const Icon(Iconsax.security_user),
          text: AppLocalizations.of(context)!
              .attendanceTabManageAdmins)); // Translated
      tabViews.add(const _AttendanceAdminManagementView());
    }

    return DefaultTabController(
      length: tabs.isNotEmpty ? tabs.length : 1,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
              '📊 ${AppLocalizations.of(context)!.attendanceScreenTitle}', // Translated
              style: GoogleFonts.notoSansEthiopic(
                  fontWeight: FontWeight.bold, color: onSurfaceColor)),
          backgroundColor: backgroundColor,
          elevation: 0,
          iconTheme: IconThemeData(color: primaryColor),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: SyncStatusIndicator(compact: true)),
            ),
          ],
          bottom: TabBar(
              labelColor: primaryColor,
              unselectedLabelColor: subtleTextColor,
              indicatorColor: primaryColor,
              tabs: tabs),
        ),
        body: TabBarView(
          children: tabViews,
        ),
      ),
    );
  }
}

// ===============================================================
// VIEW 1: Attendance Taker (This is where the fix is)
// ===============================================================
class AttendanceTakerView extends StatefulWidget {
  final bool isReadOnly;
  const AttendanceTakerView({super.key, required this.isReadOnly});
  @override
  State<AttendanceTakerView> createState() => _AttendanceTakerViewState();
}

class _AttendanceTakerViewState extends State<AttendanceTakerView> {
  // Theme Getters
  Color get primaryColor =>
      Provider.of<ThemeProvider>(context).getPrimaryColor(context);
  Color get backgroundColor =>
      Provider.of<ThemeProvider>(context).getBackgroundColor(context);
  Color get surfaceColor =>
      Provider.of<ThemeProvider>(context).getSurfaceColor(context);
  Color get onSurfaceColor =>
      Provider.of<ThemeProvider>(context).getOnSurfaceColor(context);
  Color get subtleTextColor =>
      Provider.of<ThemeProvider>(context).getSubtleTextColor(context);
  Color get accentColor =>
      Provider.of<ThemeProvider>(context).getPrimaryColor(context);
  Color get dangerColor => const Color(0xFFEF4444);
  Color get warningColor => const Color(0xFFFD7E14);
  Color get successColor => const Color(0xFF10B981);

  // final bool _isLoading = false; // Unused field
  List<Student> _allStudents = [];
  List<Student> _filteredStudents = [];
  dynamic _dynamicFilterField;
  List<dynamic> _dynamicFilterOptions = [];
  int? _selectedDynamicOptionId;
  Map<String, AttendanceStatus> _attendanceMap = {};
  Map<String, TimeOfDay?> _lateTimesMap = {};
  final TextEditingController _topicController = TextEditingController();
  late EthiopianDate _selectedDate;
  bool _isSaving = false;
  bool _isLoadingRecords = true;
  bool _isLoadingStudents = true;
  Session _selectedSession = Session.morning;
  AttendanceType _selectedAttendanceType = AttendanceType.learning;

  @override
  void initState() {
    super.initState();
    _selectedDate = EthiopianDate.now();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profileConfig = context.watch<ProfileConfigProvider>();
    final filterableFields = profileConfig.customFields
        .where((f) => f['type'] == 'DROPDOWN')
        .toList();
    if (filterableFields.isNotEmpty && _dynamicFilterField == null) {
      _dynamicFilterField = filterableFields.first;
      _dynamicFilterOptions = _dynamicFilterField['options'] ?? [];
    }
    if (_allStudents.isEmpty) {
      _loadStudentsAndInitialRecords();
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _loadStudentsAndInitialRecords() async {
    await _loadStudents();
    if (_allStudents.isNotEmpty) {
      _onFilterChanged(isInitialLoad: true);
    }
  }

  Future<void> _loadStudents() async {
    if (!mounted) return;
    setState(() => _isLoadingStudents = true);
    try {
      final students = await AttendanceService.getStudents();
      if (mounted) setState(() => _allStudents = students);
    } catch (error) {
      if (!mounted) return;
      _handleError(
          '${AppLocalizations.of(context)!.attendanceErrorLoadingStudents} $error'); // Translated
    } finally {
      if (mounted) setState(() => _isLoadingStudents = false);
    }
  }

  // =========================================================================
  // ===================== THE FIX IS IN THIS FUNCTION =====================
  // =========================================================================
  Future<void> _loadDataForDate(EthiopianDate date) async {
    if (!mounted) return;
    setState(() => _isLoadingRecords = true);
    _attendanceMap = {
      for (var s in _filteredStudents) s.id: AttendanceStatus.absent
    };
    _lateTimesMap = {};
    _topicController.clear();
    try {
      final result = await AttendanceService.getAttendanceRecords(
          date.toDatabaseString(),
          _selectedSession.name,
          _selectedAttendanceType.name);

      // CRITICAL FIX: Safely handle a 'null' attendance list from the API
      // by providing an empty list `[]` as a default. This prevents the crash.
      final records = result['attendance'] as List<dynamic>? ?? [];

      final topic = result['topic'] as String?;
      if (!mounted) return;

      for (var record in records) {
        final studentId = record['user_id']?.toString() ??
            record['student_id']?.toString() ??
            '';
        if (_attendanceMap.containsKey(studentId)) {
          _attendanceMap[studentId] = AttendanceStatus.values.firstWhere(
              (e) => e.name == record['status'],
              orElse: () => AttendanceStatus.absent);
          if (record['late_time'] != null) {
            final parts = record['late_time'].split(':');
            _lateTimesMap[studentId] = TimeOfDay(
                hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          }
        }
      }
      setState(() {
        if (topic != null) _topicController.text = topic;
      });
    } catch (e) {
      // This catch block is what shows the snackbar. Our fix prevents
      // the code from ever reaching here due to a null list.
      _handleError(
          '${AppLocalizations.of(context)!.attendanceErrorLoadingRecords} $e'); // Translated
    } finally {
      if (mounted) setState(() => _isLoadingRecords = false);
    }
  }
  // =========================================================================
  // =========================================================================

  void _onFilterChanged({bool isInitialLoad = false}) {
    setState(() {
      _filteredStudents = _allStudents.where((student) {
        if (isInitialLoad) return true;
        if (_dynamicFilterField == null || _selectedDynamicOptionId == null) {
          return true;
        }
        final fieldId = _dynamicFilterField['id'].toString();
        return student.customFields[fieldId] == _selectedDynamicOptionId;
      }).toList();
      _loadDataForDate(_selectedDate);
    });
  }

  Future<void> _handleSave() async {
    if (widget.isReadOnly) {
      _handleError(
          AppLocalizations.of(context)!.attendanceReadOnlyError); // Translated
      return;
    }
    setState(() => _isSaving = true);
    try {
      final records = _filteredStudents.map((student) {
        final status = _attendanceMap[student.id] ?? AttendanceStatus.absent;
        final lateTime = _lateTimesMap[student.id];
        return {
          'student_id': student.id,
          'date': _selectedDate.toDatabaseString(),
          'session': _selectedSession.name,
          'status': status.name,
          'attendance_type': _selectedAttendanceType.name,
          'late_time': status == AttendanceStatus.late && lateTime != null
              ? '${lateTime.hour.toString().padLeft(2, '0')}:${lateTime.minute.toString().padLeft(2, '0')}:00'
              : null
        };
      }).toList();
      final topicPayload = (_topicController.text.isNotEmpty)
          ? {
              'date': _selectedDate.toDatabaseString(),
              'session': _selectedSession.name,
              'topic': _topicController.text,
              'attendance_type': _selectedAttendanceType.name
            }
          : null;
      // Check connectivity before saving
      final syncService = SyncService();
      final isOnline = await syncService.isOnline();

      await AttendanceService.saveAttendance(
          records: records, dailyTopic: topicPayload);

      // Update sync provider to refresh pending count
      if (mounted) {
        final syncProvider = context.read<SyncProvider>();
        await syncProvider.updatePendingCount();
        if (!mounted) return;

        if (isOnline) {
          _handleSuccess(AppLocalizations.of(context)!.attendanceSaveSuccess);
        } else {
          _handleSuccess(AppLocalizations.of(context)!.attendanceSaveOffline);
        }
      }
    } catch (e) {
      if (!mounted) return;
      _handleError(
          '${AppLocalizations.of(context)!.attendanceErrorSaving} ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDate() async {
    if (widget.isReadOnly) return;
    final EthiopianDate? picked = await showDialog<EthiopianDate>(
        context: context,
        builder: (context) =>
            EthiopianDatePickerDialog(initialDate: _selectedDate));
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _loadDataForDate(picked);
    }
  }

  Future<void> _updateStatus(
      String studentId, AttendanceStatus newStatus) async {
    if (widget.isReadOnly) return;
    if (_attendanceMap[studentId] == newStatus) {
      setState(() {
        _attendanceMap[studentId] = AttendanceStatus.absent;
        _lateTimesMap.remove(studentId);
      });
      return;
    }
    setState(() => _attendanceMap[studentId] = newStatus);
    if (newStatus == AttendanceStatus.late) {
      final time =
          await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (time != null && mounted) {
        setState(() => _lateTimesMap[studentId] = time);
      } else if (mounted) {
        setState(() => _attendanceMap[studentId] = AttendanceStatus.absent);
      }
    } else if (mounted) {
      setState(() => _lateTimesMap.remove(studentId));
    }
  }

  void _handleError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message,
              style: GoogleFonts.notoSansEthiopic()), // Use Amharic font
          backgroundColor: dangerColor));
    }
  }

  void _handleSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message,
              style: GoogleFonts.notoSansEthiopic()), // Use Amharic font
          backgroundColor: successColor));
    }
  }

  Map<String, int> _getAttendanceStats() {
    int present = 0, absent = 0, late = 0, permission = 0;
    _attendanceMap.forEach((key, status) {
      if (_filteredStudents.any((s) => s.id == key)) {
        if (status == AttendanceStatus.present) present++;
        if (status == AttendanceStatus.absent) absent++;
        if (status == AttendanceStatus.late) late++;
        if (status == AttendanceStatus.permission) permission++;
      }
    });
    return {
      'present': present,
      'absent': absent,
      'late': late,
      'permission': permission,
      'total': _filteredStudents.length
    };
  }

  // Helper function for Amharic text display
  String _getAmharicDisplayText(dynamic item) {
    if (item is int?) {
      if (_dynamicFilterField != null &&
          _dynamicFilterField['options'] != null) {
        try {
          final option = (_dynamicFilterField['options'] as List)
              .firstWhere((opt) => opt['id'] == item, orElse: () => null);
          return option != null
              ? option['option_value']
              : AppLocalizations.of(context)!.attendanceSelectOption;
        } catch (e) {
          return AppLocalizations.of(context)!.attendanceSelectOption;
        }
      }
    }
    if (item == null) return AppLocalizations.of(context)!.attendanceAll;
    if (item is Map) {
      return item['name'] ?? AppLocalizations.of(context)!.attendanceFilterBy;
    }
    if (item is AttendanceType) {
      switch (item) {
        case AttendanceType.learning:
          return AppLocalizations.of(context)!.attendanceTypeLearning;
        case AttendanceType.hymnLearning:
          return AppLocalizations.of(context)!.attendanceTypeHymnLearning;
        case AttendanceType.awudemihiret:
          return AppLocalizations.of(context)!.attendanceTypeAwudemihiret;
        case AttendanceType.special:
          return AppLocalizations.of(context)!.attendanceTypeSpecial;
      }
    } else if (item is Session) {
      return item == Session.morning
          ? AppLocalizations.of(context)!.attendanceSessionMorning
          : AppLocalizations.of(context)!.attendanceSessionAfternoon;
    } else if (item is AttendanceStatus) {
      switch (item) {
        case AttendanceStatus.present:
          return AppLocalizations.of(context)!.attendanceStatusPresent;
        case AttendanceStatus.absent:
          return AppLocalizations.of(context)!.attendanceStatusAbsent;
        case AttendanceStatus.late:
          return AppLocalizations.of(context)!.attendanceStatusLate;
        case AttendanceStatus.permission:
          return AppLocalizations.of(context)!.attendanceStatusPermission;
      }
    }
    return item.toString();
  }

  @override
  Widget build(BuildContext context) {
    final profileConfig = context.watch<ProfileConfigProvider>();
    final filterableFields = profileConfig.customFields
        .where((f) => f['type'] == 'DROPDOWN')
        .toList();
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: _buildHeader(filterableFields)),
      _isLoadingStudents
          ? SliverFillRemaining(
              child: _buildLoadingState(AppLocalizations.of(context)!
                  .attendanceLoadingStudents)) // Translated
          : _buildContentSlivers()
    ]);
  }

  Widget _buildContentSlivers() {
    final stats = _getAttendanceStats();
    return SliverMainAxisGroup(slivers: [
      SliverToBoxAdapter(child: _buildDateHeader(stats)),
      if (_isLoadingRecords)
        SliverFillRemaining(
            child: _buildLoadingState(AppLocalizations.of(context)!
                .attendanceLoadingRecords)) // Translated
      else if (_filteredStudents.isEmpty)
        SliverFillRemaining(child: _buildEmptyState())
      else
        SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              final student = _filteredStudents[index];
              return _buildStudentCard(
                  student,
                  _attendanceMap[student.id] ?? AttendanceStatus.absent,
                  _lateTimesMap[student.id],
                  index);
            }, childCount: _filteredStudents.length))),
      SliverToBoxAdapter(child: _buildFooter(stats))
    ]);
  }

  Widget _buildHeader(List<dynamic> filterableFields) {
    return Column(children: [
      Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
              boxShadow: []),
          child: Column(children: [
            Row(children: [
              Expanded(
                  child: _buildEnhancedDropdown<AttendanceType>(
                      value: _selectedAttendanceType,
                      items: AttendanceType.values,
                      label: AppLocalizations.of(context)!
                          .attendanceTypeLabel, // Translated
                      icon: Iconsax.calendar_edit,
                      dropdownColor: surfaceColor,
                      textColor: onSurfaceColor,
                      onChanged: widget.isReadOnly
                          ? null
                          : (v) => setState(() {
                                _selectedAttendanceType = v!;
                                _loadDataForDate(_selectedDate);
                              }))),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildEnhancedDropdown<Session>(
                      value: _selectedSession,
                      items: Session.values,
                      label: AppLocalizations.of(context)!
                          .attendanceSessionLabel, // Translated
                      icon: Iconsax.clock,
                      dropdownColor: surfaceColor,
                      textColor: onSurfaceColor,
                      onChanged: widget.isReadOnly
                          ? null
                          : (v) => setState(() {
                                _selectedSession = v!;
                                _loadDataForDate(_selectedDate);
                              }))),
            ]),
            if (filterableFields.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildEnhancedDropdown<dynamic>(
                        value: _dynamicFilterField,
                        items: filterableFields,
                        label: AppLocalizations.of(context)!
                            .attendanceFilterBy, // Translated
                        icon: Iconsax.filter,
                        dropdownColor: surfaceColor,
                        textColor: onSurfaceColor,
                        onChanged: widget.isReadOnly
                            ? null
                            : (newField) {
                                if (newField == null) return;
                                setState(() {
                                  _dynamicFilterField = newField;
                                  _dynamicFilterOptions =
                                      newField['options'] ?? [];
                                  _selectedDynamicOptionId = null;
                                  _onFilterChanged();
                                });
                              }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildEnhancedDropdown<int?>(
                        value: _selectedDynamicOptionId,
                        items: [
                          null,
                          ..._dynamicFilterOptions
                              .map((opt) => opt['id'] as int)
                        ],
                        label: _dynamicFilterField != null
                            ? _dynamicFilterField['name']
                            : AppLocalizations.of(context)!
                                .attendanceGroup, // Translated
                        icon: Iconsax.people,
                        dropdownColor: surfaceColor,
                        textColor: onSurfaceColor,
                        onChanged: widget.isReadOnly
                            ? null
                            : (newOptionId) {
                                setState(() {
                                  _selectedDynamicOptionId = newOptionId;
                                  _onFilterChanged();
                                });
                              }),
                  ),
                ],
              ),
            ]
          ])),
      Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _buildStatChip(
                    '${_filteredStudents.length} ${AppLocalizations.of(context)!.attendanceStudents}', // Translated
                    Iconsax.profile_2user,
                    successColor),
                if (_dynamicFilterField != null &&
                    _selectedDynamicOptionId != null) ...[
                  const SizedBox(width: 8),
                  _buildStatChip(
                      _getAmharicDisplayText(_selectedDynamicOptionId),
                      Iconsax.people,
                      primaryColor),
                ]
              ])))
    ]);
  }

  Widget _buildDateHeader(Map<String, int> stats) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            InkWell(
              onTap: _selectDate,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          Icon(Iconsax.calendar, color: primaryColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedDate.toString(),
                            style: GoogleFonts.notoSansEthiopic(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: onSurfaceColor),
                          ),
                          Text(
                            EthiopianDate.fromGregorian(
                                    _selectedDate.toGregorian())
                                .toString(),
                            style: GoogleFonts.notoSansEthiopic(
                                fontSize: 13, color: subtleTextColor),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            color: Colors.white38),
                        Text(
                          AppLocalizations.of(context)!.attendanceChangeDate,
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 10,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat(
                    AppLocalizations.of(context)!.attendanceStatusPresent,
                    stats['present']!,
                    successColor), // Translated
                _buildMiniStat(
                    AppLocalizations.of(context)!.attendanceStatusAbsent,
                    stats['absent']!,
                    dangerColor), // Translated
                _buildMiniStat(
                    AppLocalizations.of(context)!.attendanceStatusLate,
                    stats['late']!,
                    warningColor), // Translated
                _buildMiniStat(
                    AppLocalizations.of(context)!.attendanceStatusPermission,
                    stats['permission']!,
                    Colors.blue.shade700), // Translated
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(Map<String, int> stats) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: surfaceColor,
          border: Border.all(color: Colors.white10),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          TextField(
            controller: _topicController,
            readOnly: widget.isReadOnly,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!
                  .attendanceTopicLabel, // Translated
              labelStyle: GoogleFonts.notoSansEthiopic(color: subtleTextColor),
              filled: true,
              fillColor: backgroundColor,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white10)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white10)),
              prefixIcon: Icon(Iconsax.note_text, color: subtleTextColor),
            ),
            maxLines: 2,
          ),
          if (!widget.isReadOnly) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                icon: _isSaving
                    ? const SizedBox.shrink()
                    : const Icon(Iconsax.tick_circle, size: 20),
                label: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 3, color: Colors.white))
                    : Text(
                        '${AppLocalizations.of(context)!.attendanceSaveButton} (${stats['present']! + stats['late']! + stats['permission']!}/${stats['total']!})', // Translated + dynamic stats
                        style: GoogleFonts.notoSansEthiopic(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                onPressed:
                    (_isSaving || _isLoadingRecords || _isLoadingStudents)
                        ? null
                        : _handleSave,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedDropdown<T>(
      {required T value,
      required List<T> items,
      required String label,
      required IconData icon,
      required Function(T?)? onChanged,
      Color? dropdownColor,
      Color? textColor}) {
    return Container(
      decoration: BoxDecoration(
          color: surfaceColor,
          border: Border.all(color: Colors.white10),
          borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        items: items
            .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(_getAmharicDisplayText(item), // Use Amharic helper
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 14,
                        color: textColor ??
                            onSurfaceColor), // Use Amharic font with optional color
                    overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.notoSansEthiopic(color: subtleTextColor),
          prefixIcon: Icon(icon, size: 20, color: primaryColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        isExpanded: true,
        dropdownColor: dropdownColor ?? surfaceColor,
        icon: Icon(Icons.arrow_drop_down, color: subtleTextColor),
      ),
    );
  }

  // NOTE: This is the old English display helper. We now use _getAmharicDisplayText
  // String _getDisplayText(dynamic item) { ... }

  Widget _buildStatChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(text,
              style: GoogleFonts.notoSansEthiopic(
                  // Use Amharic font
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Student student, AttendanceStatus status,
      TimeOfDay? lateTime, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
          boxShadow: []),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                      child: Text((index + 1).toString(),
                          style: GoogleFonts.poppins(
                              // Keep Poppins for number
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)))),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(
                      student.name == 'Unnamed Student'
                          ? AppLocalizations.of(context)!
                              .attendanceUnnamedStudent
                          : student.name,
                      style: GoogleFonts.notoSansEthiopic(
                          // Use Amharic font
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: onSurfaceColor)))
            ]),
            const SizedBox(height: 12),
            if (lateTime != null) ...[
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: warningColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text(
                      '${AppLocalizations.of(context)!.attendanceLateTimeLabel}: ${lateTime.format(context)}', // Translated
                      style: GoogleFonts.notoSansEthiopic(
                          // Use Amharic font
                          color: warningColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold))),
              const SizedBox(height: 12)
            ],
            Wrap(spacing: 8, runSpacing: 8, children: [
              _buildStatusButton(
                  student.id,
                  status,
                  AttendanceStatus.present,
                  Iconsax.tick_circle,
                  AppLocalizations.of(context)!
                      .attendanceStatusPresent, // Translated
                  successColor),
              _buildStatusButton(
                  student.id,
                  status,
                  AttendanceStatus.absent,
                  Iconsax.close_circle,
                  AppLocalizations.of(context)!
                      .attendanceStatusAbsent, // Translated
                  dangerColor),
              _buildStatusButton(
                  student.id,
                  status,
                  AttendanceStatus.late,
                  Iconsax.clock,
                  AppLocalizations.of(context)!
                      .attendanceStatusLate, // Translated
                  warningColor),
              _buildStatusButton(
                  student.id,
                  status,
                  AttendanceStatus.permission,
                  Iconsax.document,
                  AppLocalizations.of(context)!
                      .attendanceStatusPermission, // Translated
                  Colors.blue.shade700)
            ])
          ])),
    );
  }

  Widget _buildStatusButton(
      String studentId,
      AttendanceStatus currentStatus,
      AttendanceStatus buttonStatus,
      IconData icon,
      String tooltip,
      Color activeColor) {
    final isSelected = currentStatus == buttonStatus;
    return Tooltip(
        message: tooltip, // Tooltip is already the translated status name
        child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: isSelected
                    ? activeColor.withValues(alpha: 0.2)
                    : backgroundColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: isSelected ? activeColor : Colors.white24,
                    width: 1.5)),
            child: IconButton(
                icon: Icon(icon,
                    color: isSelected ? activeColor : subtleTextColor,
                    size: 20),
                onPressed: () => _updateStatus(studentId, buttonStatus),
                padding: EdgeInsets.zero)));
  }

  Widget _buildMiniStat(String label, int count, Color color) =>
      Column(children: [
        Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Center(
                child: Text(count.toString(),
                    style: GoogleFonts.poppins(
                        // Keep Poppins for number
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)))),
        const SizedBox(height: 6),
        Text(label,
            style: GoogleFonts.notoSansEthiopic(
                // Use Amharic font
                fontSize: 11,
                color: onSurfaceColor,
                fontWeight: FontWeight.w500))
      ]);
  Widget _buildLoadingState(String message) => Center(
      child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(primaryColor)),
            const SizedBox(height: 16),
            Text(message,
                style: GoogleFonts.notoSansEthiopic(
                    color: onSurfaceColor, fontSize: 14)) // Use Amharic font
          ])));
  Widget _buildEmptyState() => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle),
            child: Icon(Iconsax.profile_2user, color: primaryColor, size: 50)),
        const SizedBox(height: 20),
        Text(
            AppLocalizations.of(context)!
                .attendanceEmptyStateTitle, // Translated
            style: GoogleFonts.notoSansEthiopic(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: subtleTextColor)),
        const SizedBox(height: 8),
        Text(
            AppLocalizations.of(context)!
                .attendanceEmptyStateSubtitle, // Translated
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansEthiopic(
                fontSize: 14, color: subtleTextColor))
      ]));
}

// ===============================================================
// VIEW 2: Admin Management (Translated)
// ===============================================================
class _AttendanceAdminManagementView extends StatefulWidget {
  const _AttendanceAdminManagementView();
  @override
  State<_AttendanceAdminManagementView> createState() =>
      _AttendanceAdminManagementViewState();
}

class _AttendanceAdminManagementViewState
    extends State<_AttendanceAdminManagementView> {
  // Theme Getters
  Color get primaryColor =>
      Provider.of<ThemeProvider>(context).getPrimaryColor(context);
  Color get backgroundColor =>
      Provider.of<ThemeProvider>(context).getBackgroundColor(context);
  Color get surfaceColor =>
      Provider.of<ThemeProvider>(context).getSurfaceColor(context);
  Color get onSurfaceColor =>
      Provider.of<ThemeProvider>(context).getOnSurfaceColor(context);
  Color get subtleTextColor =>
      Provider.of<ThemeProvider>(context).getSubtleTextColor(context);
  Color get accentColor =>
      Provider.of<ThemeProvider>(context).getPrimaryColor(context);
  Color get dangerColor => const Color(0xFFEF4444);
  Color get successColor => const Color(0xFF10B981);

  Future<List<dynamic>>? _usersFuture;
  String _searchTerm = '';
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = UserAdminService.getAllUsers();
    });
  }

  Future<void> _toggleAdmin(String userId, String currentRoleString) async {
    bool isCurrentlyAdmin = currentRoleString.contains('attendance_admin');
    try {
      await UserAdminService.updateUserRoles(
        userId: userId,
        shouldBeAdmin: !isCurrentlyAdmin,
        role: 'attendance_admin',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                AppLocalizations.of(context)!.attendanceRolesUpdateSuccess,
                style: GoogleFonts.notoSansEthiopic()), // Translated
            backgroundColor: successColor));
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.attendanceGenericError} $e',
                style: GoogleFonts.notoSansEthiopic()), // Translated
            backgroundColor: dangerColor));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!
                        .attendanceSearchUserHint, // Translated
                    hintStyle:
                        GoogleFonts.notoSansEthiopic(color: subtleTextColor),
                    filled: true,
                    fillColor: surfaceColor,
                    prefixIcon:
                        Icon(Iconsax.search_normal, color: subtleTextColor),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white10)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white10))),
                onChanged: (value) =>
                    setState(() => _searchTerm = value.toLowerCase()))),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _loadUsers(),
            child: FutureBuilder<List<dynamic>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          '${AppLocalizations.of(context)!.attendanceGenericError} ${snapshot.error}',
                          style: GoogleFonts.notoSansEthiopic())); // Translated
                }
                final allUsers = snapshot.data ?? [];
                final filteredUsers = allUsers.where((user) {
                  final name =
                      user['full_name']?.toString().toLowerCase() ?? '';
                  final email = user['email']?.toString().toLowerCase() ?? '';
                  return name.contains(_searchTerm) ||
                      email.contains(_searchTerm);
                }).toList();

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final String roleString = user['role'] as String? ?? '';
                    final bool isAdmin =
                        roleString.contains('attendance_admin');
                    final bool isVerified = user['is_verified'] == 1;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      color: surfaceColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.white10)),
                      child: ListTile(
                        leading: CircleAvatar(
                            child: Text(
                                (user['full_name'] != null &&
                                        user['full_name'].toString().isNotEmpty)
                                    ? user['full_name'].toString()[0]
                                    : '?',
                                style: GoogleFonts.notoSansEthiopic())),
                        title: Row(children: [
                          Text(
                              user['full_name'] ??
                                  AppLocalizations.of(context)!
                                      .attendanceNoName,
                              style:
                                  GoogleFonts.notoSansEthiopic()), // Translated
                          const SizedBox(width: 8),
                          if (!isVerified)
                            Chip(
                                label: Text(
                                    AppLocalizations.of(context)!
                                        .attendanceUserStatusPending,
                                    style: GoogleFonts.notoSansEthiopic(
                                        fontSize: 10,
                                        color: Colors.black87)), // Translated
                                backgroundColor: warningColor,
                                padding: EdgeInsets.zero)
                        ]),
                        subtitle: Text(
                            user['email'] ??
                                AppLocalizations.of(context)!.attendanceNoEmail,
                            style:
                                GoogleFonts.notoSansEthiopic()), // Translated
                        trailing: Switch(
                            value: isAdmin,
                            onChanged: (value) =>
                                _toggleAdmin(user['id'], roleString),
                            activeThumbColor: primaryColor),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
