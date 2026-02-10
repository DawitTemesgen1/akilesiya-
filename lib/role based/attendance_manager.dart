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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';

// --- Amharic Localization Strings for Attendance Screen ---
abstract class AmharicStringsAttendance {
  static const String screenTitle = 'የተማሪ ክትትል አስተዳደር';
  static const String accessDenied = 'መዳረሻ ተከልክሏል';
  static const String noPermission = 'ይህንን ክፍል ለመጠቀም ፈቃድ የለዎትም።';
  static const String tabTakeAttendance = 'ክትትል ይመዝግቡ';
  static const String tabManageAdmins = 'አስተዳዳሪዎችን ያቀናብሩ';

  static const String statusPresent = 'ቀርቧል';
  static const String statusAbsent = 'ቀርቷል';
  static const String statusLate = 'ዘግይቷል';
  static const String statusPermission = 'በፈቃድ';

  static const String typeLabel = 'የክትትል ዓይነት';
  static const String typeLearning = 'የትምህርት ክፍለ ጊዜ';
  static const String typeHymnLearning = 'የዜማ ትምህርት';
  static const String typeAwudemihiret = 'አውደ ምሕረት';
  static const String typeSpecial = 'ልዩ መርሃ ግብር';

  static const String sessionLabel = 'ክፍለ ጊዜ';
  static const String sessionMorning = 'ጥዋት';
  static const String sessionAfternoon = 'ከሰዓት';

  static const String filterBy = 'ማጣሪያ በ';
  static const String group = 'ቡድን';
  static const String all = 'ሁሉም';
  static const String students = 'ተማሪዎች';
  static const String selectOption = 'አማራጭ ይምረጡ';
  static const String unnamedStudent = 'ስም ያልተሰጠው ተማሪ';
  static const String lateTimeLabel = 'ዘግይቷል'; // Prefix for time

  static const String loadingStudents = 'ተማሪዎችን በመጫን ላይ...';
  static const String loadingRecords = 'መረጃዎችን በመጫን ላይ...';
  static const String emptyStateTitle = 'ምንም ተማሪዎች አልተገኙም';
  static const String emptyStateSubtitle =
      'ማጣሪያዎችዎን ለማስተካከል ይሞክሩ ወይም ተማሪዎችን ወደዚህ ትምህርት ቤት ያክሉ።';

  static const String topicLabel = '📝 የቀን ርዕስ';
  static const String saveAttendanceButton = 'ክትትልን ያስቀምጡ';
  static const String readOnlyError = 'ለማንበብ ብቻ: ክትትል ማስቀመጥ አይቻልም።';
  static const String errorLoadingStudents = 'ተማሪዎችን በመጫን ላይ ስህተት:';
  static const String errorLoadingRecords = 'መረጃዎችን በመጫን ላይ ስህተት:';
  static const String saveSuccess = 'ክትትል በተሳካ ሁኔታ ተመዝግቧል! 🎉';
  static const String saveOffline =
      'ክትትል ኦፍላይን ተመዝግቧል። ኢንተርኔት ሲገኝ በራስ-ሰር ይላካል።';
  static const String errorSavingAttendance = 'ክትትል ማስቀመጥ ላይ ስህተት:';

  static const String searchUserHint = 'ተጠቃሚ ይፈልጉ...';
  static const String rolesUpdateSuccess = 'ሚናዎች በተሳካ ሁኔታ ተዘምነዋል።';
  static const String genericError = 'ስህተት:';
  static const String userStatusPending = 'በመጠባበቅ ላይ';
  static const String noName = 'ስም የለም';
  static const String noEmail = 'ኢሜይል የለም';
}

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
        name: json['full_name'] as String? ??
            AmharicStringsAttendance.unnamedStudent,
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

class _AttendanceScreenState extends State<AttendanceScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

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
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    final canManage = userProvider.canManageAttendance;
    final isSuperiorAdmin = userProvider.isSuperiorOrSystemAdmin;
    int tabCount = 0;
    if (canManage) tabCount = 1;
    if (isSuperiorAdmin) tabCount = 2;
    _tabController =
        TabController(length: tabCount > 0 ? tabCount : 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final canManage = userProvider.canManageAttendance;
    final isSuperiorAdmin = userProvider.isSuperiorOrSystemAdmin;

    if (!canManage) {
      return Scaffold(
          appBar: AppBar(
              title: Text(AmharicStringsAttendance.screenTitle,
                  style: GoogleFonts.notoSansEthiopic())),
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Icon(Iconsax.lock, size: 48, color: dangerColor),
                const SizedBox(height: 16),
                Text(AmharicStringsAttendance.accessDenied,
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(AmharicStringsAttendance.noPermission,
                    style: GoogleFonts.notoSansEthiopic())
              ])));
    }

    List<Widget> tabs = [];
    List<Widget> tabViews = [];
    if (canManage) {
      tabs.add(Tab(
          icon: const Icon(Iconsax.document_text),
          text: AmharicStringsAttendance.tabTakeAttendance));
      final bool isReadOnly = !canManage;
      tabViews.add(AttendanceTakerView(isReadOnly: isReadOnly));
    }
    if (isSuperiorAdmin) {
      tabs.add(Tab(
          icon: const Icon(Iconsax.security_user),
          text: AmharicStringsAttendance.tabManageAdmins)); // Translated
      tabViews.add(const _AttendanceAdminManagementView());
    }

    if (_tabController.length != tabs.length) {
      _tabController = TabController(length: tabs.length, vsync: this);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('📊 ${AmharicStringsAttendance.screenTitle}', // Translated
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
            controller: _tabController,
            labelColor: primaryColor,
            unselectedLabelColor: subtleTextColor,
            indicatorColor: primaryColor,
            tabs: tabs),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabViews,
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

  final bool _isLoading = false;
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
      _handleError(
          '${AmharicStringsAttendance.errorLoadingStudents} $error'); // Translated
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
          '${AmharicStringsAttendance.errorLoadingRecords} $e'); // Translated
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
      _handleError(AmharicStringsAttendance.readOnlyError); // Translated
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

        if (isOnline) {
          _handleSuccess(AmharicStringsAttendance.saveSuccess);
        } else {
          _handleSuccess(AmharicStringsAttendance.saveOffline);
        }
      }
    } catch (e) {
      _handleError(
          '${AmharicStringsAttendance.errorSavingAttendance} ${e.toString()}');
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
              : AmharicStringsAttendance.selectOption;
        } catch (e) {
          return AmharicStringsAttendance.selectOption;
        }
      }
    }
    if (item == null) return AmharicStringsAttendance.all;
    if (item is Map) return item['name'] ?? AmharicStringsAttendance.filterBy;
    if (item is AttendanceType) {
      switch (item) {
        case AttendanceType.learning:
          return AmharicStringsAttendance.typeLearning;
        case AttendanceType.hymnLearning:
          return AmharicStringsAttendance.typeHymnLearning;
        case AttendanceType.awudemihiret:
          return AmharicStringsAttendance.typeAwudemihiret;
        case AttendanceType.special:
          return AmharicStringsAttendance.typeSpecial;
      }
    } else if (item is Session) {
      return item == Session.morning
          ? AmharicStringsAttendance.sessionMorning
          : AmharicStringsAttendance.sessionAfternoon;
    } else if (item is AttendanceStatus) {
      switch (item) {
        case AttendanceStatus.present:
          return AmharicStringsAttendance.statusPresent;
        case AttendanceStatus.absent:
          return AmharicStringsAttendance.statusAbsent;
        case AttendanceStatus.late:
          return AmharicStringsAttendance.statusLate;
        case AttendanceStatus.permission:
          return AmharicStringsAttendance.statusPermission;
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
              child: _buildLoadingState(
                  AmharicStringsAttendance.loadingStudents)) // Translated
          : _buildContentSlivers()
    ]);
  }

  Widget _buildContentSlivers() {
    final stats = _getAttendanceStats();
    return SliverMainAxisGroup(slivers: [
      SliverToBoxAdapter(child: _buildDateHeader(stats)),
      if (_isLoadingRecords)
        SliverFillRemaining(
            child: _buildLoadingState(
                AmharicStringsAttendance.loadingRecords)) // Translated
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
                      label: AmharicStringsAttendance.typeLabel, // Translated
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
                      label:
                          AmharicStringsAttendance.sessionLabel, // Translated
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
                        label: AmharicStringsAttendance.filterBy, // Translated
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
                            : AmharicStringsAttendance.group, // Translated
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
                    '${_filteredStudents.length} ${AmharicStringsAttendance.students}', // Translated
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
                            DateFormat.yMMMEd()
                                .format(_selectedDate.toGregorian()),
                            style: GoogleFonts.poppins(
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
                          'ቀን ቀይር',
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
                _buildMiniStat(AmharicStringsAttendance.statusPresent,
                    stats['present']!, successColor), // Translated
                _buildMiniStat(AmharicStringsAttendance.statusAbsent,
                    stats['absent']!, dangerColor), // Translated
                _buildMiniStat(AmharicStringsAttendance.statusLate,
                    stats['late']!, warningColor), // Translated
                _buildMiniStat(AmharicStringsAttendance.statusPermission,
                    stats['permission']!, Colors.blue.shade700), // Translated
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
              labelText: AmharicStringsAttendance.topicLabel, // Translated
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
                        '${AmharicStringsAttendance.saveAttendanceButton} (${stats['present']! + stats['late']! + stats['permission']!}/${stats['total']!})', // Translated + dynamic stats
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
                  child: Text(student.name,
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
                      '${AmharicStringsAttendance.lateTimeLabel}: ${lateTime.format(context)}', // Translated
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
                  AmharicStringsAttendance.statusPresent, // Translated
                  successColor),
              _buildStatusButton(
                  student.id,
                  status,
                  AttendanceStatus.absent,
                  Iconsax.close_circle,
                  AmharicStringsAttendance.statusAbsent, // Translated
                  dangerColor),
              _buildStatusButton(
                  student.id,
                  status,
                  AttendanceStatus.late,
                  Iconsax.clock,
                  AmharicStringsAttendance.statusLate, // Translated
                  warningColor),
              _buildStatusButton(
                  student.id,
                  status,
                  AttendanceStatus.permission,
                  Iconsax.document,
                  AmharicStringsAttendance.statusPermission, // Translated
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
        Text(AmharicStringsAttendance.emptyStateTitle, // Translated
            style: GoogleFonts.notoSansEthiopic(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: subtleTextColor)),
        const SizedBox(height: 8),
        Text(AmharicStringsAttendance.emptyStateSubtitle, // Translated
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
      await UserAdminService.updateAttendanceAdminRole(
        userId: userId,
        shouldBeAdmin: !isCurrentlyAdmin,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AmharicStringsAttendance.rolesUpdateSuccess,
                style: GoogleFonts.notoSansEthiopic()), // Translated
            backgroundColor: successColor));
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${AmharicStringsAttendance.genericError} $e',
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
                    hintText:
                        AmharicStringsAttendance.searchUserHint, // Translated
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
                          '${AmharicStringsAttendance.genericError} ${snapshot.error}',
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
                                (user['full_name'] ?? '?').substring(0, 1),
                                style: GoogleFonts.notoSansEthiopic())),
                        title: Row(children: [
                          Text(
                              user['full_name'] ??
                                  AmharicStringsAttendance.noName,
                              style:
                                  GoogleFonts.notoSansEthiopic()), // Translated
                          const SizedBox(width: 8),
                          if (!isVerified)
                            Chip(
                                label: Text(
                                    AmharicStringsAttendance.userStatusPending,
                                    style: GoogleFonts.notoSansEthiopic(
                                        fontSize: 10,
                                        color: Colors.black87)), // Translated
                                backgroundColor: warningColor,
                                padding: EdgeInsets.zero)
                        ]),
                        subtitle: Text(
                            user['email'] ?? AmharicStringsAttendance.noEmail,
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
