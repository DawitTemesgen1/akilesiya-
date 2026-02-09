import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart'
    hide primaryColor;
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:provider/provider.dart';

// እነዚህ ፋይሎች በፕሮጀክትዎ መዋቅር ውስጥ እንዳሉ በማሰብ

import 'package:amde_haymanot_abalat_guday/providers/sync_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/batch_service.dart';
import 'package:amde_haymanot_abalat_guday/services/grade_service.dart';
import 'package:amde_haymanot_abalat_guday/services/sync_service.dart';
import 'package:amde_haymanot_abalat_guday/services/user_admin_service.dart';
import 'package:amde_haymanot_abalat_guday/widgets/sync_status_indicator.dart';

// --- የዩአይ ገጽታ ቋሚዎች ---
const Color kDefaultPrimaryColor = Color(0xFF050511); // Dark Background
const Color kDefaultAccentColor = Color(0xFFFFC107); // Gold
const Color kDefaultSurfaceColor = Color(0xFF151522); // Card Background
const Color kDefaultOnSurfaceColor = Colors.white;
const Color kDefaultSubtleTextColor = Colors.white54;
const Color successColor = Color(0xFF10B981);
const Color dangerColor = Color(0xFFEF4444);

const List<String> spiritualClassOptions = [
  '1ኛ ክፍል',
  '2ኛ ክፍል',
  '3ኛ ክፍል',
  '4ኛ ክፍል',
  '5ኛ ክፍል',
  '6ኛ ክፍል',
  '7ኛ ክፍል',
  '8ኛ ክፍል',
  '9ኛ ክፍል',
  '10ኛ ክፍል',
  '11ኛ ክፍል',
  '12ኛ ክፍል'
];

// ===============================================================
// ዋናው የማያ ገጽ መግብር
// ===============================================================

class GradeManagementScreen extends StatefulWidget {
  const GradeManagementScreen({super.key});
  @override
  State<GradeManagementScreen> createState() => _GradeManagementScreenState();
}

class _GradeManagementScreenState extends State<GradeManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _gradeEntryViewStateKey = GlobalKey<_GradeEntryViewState>();

  Color get primaryColor =>
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

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    final bool isSuperiorAdmin = userProvider.roles.contains('superior_admin');
    final bool isGradeAdmin = userProvider.roles.contains('grade_admin');

    int tabCount = 0;
    if (isSuperiorAdmin || isGradeAdmin) tabCount = 2;
    if (isSuperiorAdmin) tabCount = 3;

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

    final bool isSuperiorAdmin = userProvider.roles.contains('superior_admin');
    final bool isGradeAdmin = userProvider.roles.contains('grade_admin');
    // Removed local theme variable definitions as per instruction.
    // The theme variables are now accessed directly from the theme provider or defined as getters in the respective views.

    if (!isSuperiorAdmin && !isGradeAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('የትምህርት ውጤት አስተዳደር')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.lock, size: 48, color: dangerColor),
              SizedBox(height: 16),
              Text('መዳረሻ ተከልክሏል',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('ይህን ክፍል ለማየት ፍቃድ የለዎትም።'),
            ],
          ),
        ),
      );
    }

    List<Widget> tabs = [];
    List<Widget> tabViews = [];

    final bool isReadOnly = !isGradeAdmin;

    tabs.addAll([
      const Tab(icon: Icon(Iconsax.edit), text: 'ውጤት ያስገቡ'),
      const Tab(icon: Icon(Iconsax.people), text: 'ቡድኖችን ያቀናብሩ'),
    ]);
    tabViews.addAll([
      GradeEntryView(key: _gradeEntryViewStateKey, isReadOnly: isReadOnly),
      BatchManagementView(
          onBatchChanged: () =>
              _gradeEntryViewStateKey.currentState?.refreshData(),
          isReadOnly: isReadOnly),
    ]);

    if (isSuperiorAdmin) {
      tabs.add(const Tab(
          icon: Icon(Iconsax.security_user), text: 'አስተዳዳሪዎችን ያቀናብሩ'));
      tabViews.add(const AdminManagementView());
    }

    if (_tabController.length != tabs.length) {
      _tabController = TabController(length: tabs.length, vsync: this);
    }

    return Scaffold(
      backgroundColor: primaryColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text('የትምህርት ውጤት አስተዳደር',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: onSurfaceColor)),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(child: SyncStatusIndicator(compact: true)),
                ),
              ],
              backgroundColor: primaryColor,
              foregroundColor: onSurfaceColor,
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              bottom: TabBar(
                  controller: _tabController,
                  labelColor: accentColor,
                  unselectedLabelColor: subtleTextColor,
                  indicatorColor: accentColor,
                  isScrollable: true,
                  tabs: tabs),
            ),
          ];
        },
        body: TabBarView(controller: _tabController, children: tabViews),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          final isGradeTab = _tabController.index == 0;
          return isGradeTab && isGradeAdmin
              ? FloatingActionButton.extended(
                  onPressed: () => _gradeEntryViewStateKey.currentState
                      ?.showCourseManagementDialog(),
                  icon: const Icon(Iconsax.book_1),
                  label: const Text("ትምህርቶችን ያቀናብሩ"),
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}

// ===============================================================
// VIEW 1: ውጤት ማስገቢያ (አሁን በ isReadOnly ባህሪ)
// ===============================================================
class GradeEntryView extends StatefulWidget {
  final bool isReadOnly;
  const GradeEntryView({super.key, this.isReadOnly = false});
  @override
  State<GradeEntryView> createState() => _GradeEntryViewState();
}

class _GradeEntryViewState extends State<GradeEntryView> {
  // Theme Getters
  Color get primaryColor =>
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

  bool _isLoading = false;
  String? _selectedSpiritualClass;
  int? _selectedYear;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _coursesForClass = [];
  final TextEditingController _searchController = TextEditingController();
  static final int currentEthiopianYear = EthiopianDate.now().year;
  final List<int> _yearOptions =
      List.generate(5, (index) => currentEthiopianYear - index);
  bool get canManageCourses =>
      !widget.isReadOnly &&
      _selectedSpiritualClass != null &&
      _selectedYear != null &&
      !_isLoading;
  List<Map<String, dynamic>> get _filteredStudents => _searchController
          .text.isEmpty
      ? _students
      : _students
          .where((s) => (s['full_name'] as String? ?? '')
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();

  @override
  void initState() {
    super.initState();
    _selectedYear = currentEthiopianYear;
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void refreshData() {
    if (_selectedSpiritualClass != null && _selectedYear != null) {
      _fetchDataForFilters();
    }
  }

  Future<void> _fetchDataForFilters() async {
    if (_selectedSpiritualClass == null || _selectedYear == null) {
      _showSnackbar('እባክዎ መጀመሪያ ክፍል እና ዓመት ይምረጡ።', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        GradeService.getStudentsWithGrades(
            spiritualClass: _selectedSpiritualClass!, year: _selectedYear!),
        GradeService.getCourses(_selectedSpiritualClass!, year: _selectedYear)
      ]);
      if (mounted) {
        setState(() {
          _students = (results[0]).cast<Map<String, dynamic>>();
          _coursesForClass = (results[1]).cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      _showSnackbar('መረጃ በማምጣት ላይ ስህተት ተፈጥሯል፦ ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message, style: GoogleFonts.poppins()),
          backgroundColor: isError ? dangerColor : successColor,
          behavior: SnackBarBehavior.floating));
    }
  }

  void showCourseManagementDialog() async {
    if (!canManageCourses) {
      _showSnackbar("እባክዎ መጀመሪያ የመንፈሳዊ ትምህርት ክፍል ይምረጡ።", isError: true);
      return;
    }
    final bool? didCoursesChange = await showDialog<bool>(
        context: context,
        builder: (context) => _CourseManagementDialog(
            spiritualClass: _selectedSpiritualClass!,
            year: _selectedYear!,
            initialCourses: _coursesForClass));
    if (didCoursesChange == true) {
      _showSnackbar("የትምህርት ዝርዝር ተዘምኗል። መረጃው እንደገና እየተጫነ ነው።");
      _fetchDataForFilters();
    }
  }

  void _showEditGradesDialog(Map<String, dynamic> student) async {
    final Map<String, dynamic>? updatedData =
        await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) => _EditGradesDialog(
                student: student,
                courses: _coursesForClass,
                year: _selectedYear!,
                isReadOnly: widget.isReadOnly));
    if (updatedData != null) {
      _showSnackbar("የ${student['full_name']} ውጤቶች በተሳካ ሁኔታ ተዘምነዋል!");
      setState(() {
        final index = _students
            .indexWhere((s) => s['student_id'] == student['student_id']);
        if (index != -1) {
          _students[index]['grades'] = updatedData['grades'];
          _students[index]['average_score'] = updatedData['average_score'];
          _students.sort((a, b) => (b['average_score'] as double)
              .compareTo(a['average_score'] as double));
          for (int i = 0; i < _students.length; i++) {
            _students[i]['rank'] = i + 1;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildFilterCard(),
      Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : _students.isEmpty
                  ? _buildEmptyState()
                  : _buildResultsTable())
    ]);
  }

  Widget _buildFilterCard() {
    return FadeIn(
        duration: const Duration(milliseconds: 400),
        child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2), blurRadius: 10)
                ]),
            child: Column(children: [
              Row(children: [
                Expanded(
                    child: DropdownButtonFormField<String>(
                        initialValue: _selectedSpiritualClass,
                        dropdownColor: surfaceColor,
                        style:
                            GoogleFonts.notoSansEthiopic(color: onSurfaceColor),
                        hint: Text("ክፍል ይምረጡ",
                            style: GoogleFonts.notoSansEthiopic(
                                color: subtleTextColor)),
                        items: spiritualClassOptions
                            .map((String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: GoogleFonts.notoSansEthiopic(
                                        color: onSurfaceColor))))
                            .toList(),
                        onChanged: (newValue) =>
                            setState(() => _selectedSpiritualClass = newValue),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: primaryColor,
                            prefixIcon:
                                Icon(Iconsax.teacher, color: accentColor),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white10)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white10)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16)))),
                const SizedBox(width: 16),
                Expanded(
                    child: DropdownButtonFormField<int>(
                        initialValue: _selectedYear,
                        dropdownColor: surfaceColor,
                        style:
                            GoogleFonts.notoSansEthiopic(color: onSurfaceColor),
                        hint: Text("ዓመት ይምረጡ",
                            style: GoogleFonts.notoSansEthiopic(
                                color: subtleTextColor)),
                        items: _yearOptions
                            .map((int value) => DropdownMenuItem<int>(
                                value: value,
                                child: Text("$value ዓ.ም.",
                                    style: GoogleFonts.notoSansEthiopic(
                                        color: onSurfaceColor))))
                            .toList(),
                        onChanged: (newValue) =>
                            setState(() => _selectedYear = newValue),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: primaryColor,
                            prefixIcon:
                                Icon(Iconsax.calendar, color: accentColor),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white10)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white10)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16))))
              ]),
              const SizedBox(height: 16),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _fetchDataForFilters,
                      icon: const Icon(Iconsax.search_normal),
                      label: const Text("የተማሪዎችን ውጤት ይጫኑ"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16)))),
              if (_students.isNotEmpty) ...[
                const SizedBox(height: 16),
                TextField(
                    controller: _searchController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: primaryColor,
                        hintText: "በተማሪ ስም ይፈልጉ...",
                        hintStyle: TextStyle(color: subtleTextColor),
                        prefixIcon:
                            Icon(Iconsax.user_search, color: accentColor),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white10)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white10)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10)))
              ]
            ])));
  }

  Widget _buildEmptyState() => Center(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Iconsax.folder_open, size: 64, color: subtleTextColor),
            const SizedBox(height: 16),
            Text(
                _selectedSpiritualClass == null
                    ? "ተማሪዎችን ለመጫን እባክዎ ማጣሪያዎችን ይምረጡ።"
                    : "ለዚህ ክፍል እና ዓመት ምንም ተማሪዎች አልተገኙም።",
                style:
                    GoogleFonts.poppins(color: subtleTextColor, fontSize: 16),
                textAlign: TextAlign.center)
          ])));

  Widget _buildResultsTable() => Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Card(
          color: surfaceColor,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white10)),
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                  headingRowColor:
                      WidgetStateProperty.all(primaryColor.withValues(alpha: 0.05)),
                  dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.selected)) {
                        return Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.08);
                      }
                      return null;
                    },
                  ),
                  columns: [
                    DataColumn(
                        label: Text('ደረጃ',
                            style: GoogleFonts.notoSansEthiopic(
                                fontWeight: FontWeight.bold,
                                color: subtleTextColor))),
                    DataColumn(
                        label: Text('ስም',
                            style: GoogleFonts.notoSansEthiopic(
                                fontWeight: FontWeight.bold,
                                color: subtleTextColor))),
                    DataColumn(
                        label: Text('አማካይ %',
                            style: GoogleFonts.notoSansEthiopic(
                                fontWeight: FontWeight.bold,
                                color: subtleTextColor)),
                        numeric: true),
                    DataColumn(
                        label: Text('ሁኔታ',
                            style: GoogleFonts.notoSansEthiopic(
                                fontWeight: FontWeight.bold,
                                color: subtleTextColor))),
                    DataColumn(
                        label: Text('ድርጊቶች',
                            style: GoogleFonts.notoSansEthiopic(
                                fontWeight: FontWeight.bold,
                                color: subtleTextColor)))
                  ],
                  rows: _filteredStudents.map((student) {
                    final double average =
                        (student['average_score'] as num?)?.toDouble() ?? 0.0;
                    final bool passed = average >= 50;
                    return DataRow(cells: [
                      DataCell(Text((student['rank'] ?? 0).toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(student['full_name'] ?? 'ስም የለም',
                          style: GoogleFonts.notoSansEthiopic())),
                      DataCell(Text(average.toStringAsFixed(1),
                          style: TextStyle(
                              color: passed ? successColor : dangerColor,
                              fontWeight: FontWeight.bold))),
                      DataCell(Chip(
                          label: Text(passed ? 'አልፏል' : 'ወድቋል'),
                          backgroundColor: (passed ? successColor : dangerColor)
                              .withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                              color: passed ? successColor : dangerColor,
                              fontWeight: FontWeight.bold))),
                      DataCell(
                        IconButton(
                          icon: Icon(
                              widget.isReadOnly ? Iconsax.eye : Iconsax.edit,
                              color: primaryColor),
                          tooltip:
                              widget.isReadOnly ? 'ውጤቶችን ይመልከቱ' : 'ውጤቶችን ያርትዑ',
                          onPressed: (_selectedSpiritualClass != null &&
                                  _selectedYear != null)
                              ? () => _showEditGradesDialog(student)
                              : null,
                        ),
                      ),
                    ]);
                  }).toList()))));
}

// ===============================================================
// VIEW 2: የቡድን አስተዳደር (አሁን በ isReadOnly ባህሪ)
// ===============================================================
class BatchManagementView extends StatefulWidget {
  final VoidCallback onBatchChanged;
  final bool isReadOnly;
  const BatchManagementView(
      {super.key, required this.onBatchChanged, this.isReadOnly = false});
  @override
  State<BatchManagementView> createState() => _BatchManagementViewState();
}

class _BatchManagementViewState extends State<BatchManagementView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  Color get primaryColor =>
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
    return Column(
      children: [
        TabBar(
            controller: _tabController,
            labelColor: primaryColor,
            unselectedLabelColor: subtleTextColor,
            indicatorColor: primaryColor,
            tabs: const [
              Tab(text: 'አዲስ ምዝገባ'),
              Tab(text: 'ቡድኖችን ያቀናብሩ'),
              Tab(text: 'ክፍል ያሳድጉ')
            ]),
        Expanded(
            child: TabBarView(controller: _tabController, children: [
          _NewStudentRegistrationTab(
              onBatchChanged: widget.onBatchChanged,
              isReadOnly: widget.isReadOnly),
          _ManageBatchesTab(
              onBatchChanged: widget.onBatchChanged,
              isReadOnly: widget.isReadOnly),
          _PromotionTab(
              onBatchChanged: widget.onBatchChanged,
              isReadOnly: widget.isReadOnly)
        ]))
      ],
    );
  }
}

// ===============================================================
// VIEW 3: የአስተዳዳሪ አስተዳደር (ለበላይ አስተዳዳሪዎች)
// ===============================================================
class AdminManagementView extends StatefulWidget {
  const AdminManagementView({super.key});
  @override
  State<AdminManagementView> createState() => _AdminManagementViewState();
}

class _AdminManagementViewState extends State<AdminManagementView> {
  // Theme Getters
  Color get primaryColor =>
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

  Future<void> _toggleGradeAdmin(String userId, bool isCurrentlyAdmin) async {
    try {
      await UserAdminService.updateUserRoles(
        userId: userId,
        shouldBeAdmin: !isCurrentlyAdmin,
        role: 'grade_admin',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('ሚናዎች በተሳካ ሁኔታ ተዘምነዋል።'),
            backgroundColor: successColor));
        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ስህተት፦ $e'), backgroundColor: dangerColor));
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
                decoration: const InputDecoration(
                    hintText: 'ተጠቃሚ ይፈልጉ...',
                    prefixIcon: Icon(Iconsax.search_normal),
                    border: OutlineInputBorder()),
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
                  return Center(child: Text('ስህተት፦ ${snapshot.error}'));
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
                    final bool isGradeAdmin =
                        roleString.contains('grade_admin');
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                            child: Text(
                                (user['full_name'] ?? '?').substring(0, 1))),
                        title: Text(user['full_name'] ?? 'ስም የለም'),
                        subtitle: Text(user['email'] ?? 'ኢሜይል የለም'),
                        trailing: Switch(
                            value: isGradeAdmin,
                            onChanged: (value) =>
                                _toggleGradeAdmin(user['id'], isGradeAdmin),
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

// ===============================================================
// የዲያሎግ መግብሮች (የውጤት አስተዳደር)
// ===============================================================
class _CourseManagementDialog extends StatefulWidget {
  final String spiritualClass;
  final int year;
  final List<Map<String, dynamic>> initialCourses;
  const _CourseManagementDialog(
      {required this.spiritualClass,
      required this.year,
      required this.initialCourses});
  @override
  State<_CourseManagementDialog> createState() =>
      _CourseManagementDialogState();
}

class _CourseManagementDialogState extends State<_CourseManagementDialog> {
  // Theme Getters
  Color get primaryColor =>
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

  late List<Map<String, dynamic>> _courses;
  final _courseController = TextEditingController();
  bool _isAdding = false;
  bool _hasChanges = false;
  @override
  void initState() {
    super.initState();
    _courses =
        widget.initialCourses.map((c) => Map<String, dynamic>.from(c)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("ትምህርቶችን ያቀናብሩ - ${widget.spiritualClass}",
          style: GoogleFonts.notoSansEthiopic(
              color: primaryColor, fontWeight: FontWeight.bold)),
      content: SizedBox(
          width: 500,
          height: 400,
          child: Column(children: [
            Expanded(
                child: _courses.isEmpty
                    ? Center(
                        child: Text("ምንም ትምህርት የለም። ከታች ያክሉ።",
                            style: GoogleFonts.poppins(color: onSurfaceColor)))
                    : ListView.builder(
                        itemCount: _courses.length,
                        itemBuilder: (context, index) {
                          final course = _courses[index];
                          return Card(
                              color: surfaceColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.white10)),
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                  leading:
                                      Icon(Iconsax.book_1, color: primaryColor),
                                  title: Text(
                                      course['course_name'] ?? 'ስም የሌለው',
                                      style: GoogleFonts.notoSansEthiopic(
                                          color: onSurfaceColor)),
                                  trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                            icon: Icon(Iconsax.edit,
                                                color: subtleTextColor),
                                            tooltip: 'ለዚህ ትምህርት ምዘናዎችን ያቀናብሩ',
                                            onPressed: () =>
                                                _manageAssessments(course)),
                                        IconButton(
                                            icon: Icon(Iconsax.trash,
                                                color: dangerColor),
                                            tooltip: 'ትምህርቱን ያጥፉ',
                                            onPressed: () => _deleteCourse(
                                                course['id'], index))
                                      ])));
                        })),
            const Divider(color: Colors.white10),
            Row(children: [
              Expanded(
                  child: TextField(
                controller: _courseController,
                style: TextStyle(color: onSurfaceColor),
                decoration: InputDecoration(
                    labelText: "የአዲስ ትምህርት ስም",
                    labelStyle: TextStyle(color: subtleTextColor),
                    fillColor: Colors.black12,
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.white10))),
              )),
              const SizedBox(width: 8),
              _isAdding
                  ? const CircularProgressIndicator()
                  : IconButton(
                      icon:
                          Icon(Icons.add_circle, color: successColor, size: 36),
                      onPressed: _addCourse)
            ])
          ])),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(_hasChanges),
            child: const Text("ዝጋ"))
      ],
    );
  }

  Future<void> _addCourse() async {
    if (_courseController.text.trim().isEmpty) return;
    final courseName = _courseController.text.trim();
    setState(() => _isAdding = true);
    try {
      final newCourse = await GradeService.addCourse(
          spiritualClass: widget.spiritualClass,
          courseName: courseName,
          year: widget.year);
      if (mounted) {
        setState(() {
          _courses.add(newCourse);
          _hasChanges = true;
        });
        _courseController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('ትምህርት ሲጨምሩ ስህተት ተፈጥሯል፦ $e'),
            backgroundColor: dangerColor));
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _deleteCourse(int courseId, int index) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text("ስረዛን ያረጋግጡ"),
                content: const Text(
                    "እርግጠኛ ነዎት? ይህን ትምህርት መሰረዝ ሁሉንም ተዛማጅ ምዘናዎች እና የተማሪ ውጤቶችን ያስወግዳል። ይህን ድርጊት መመለስ አይቻልም።"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("ይቅር")),
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: dangerColor),
                      child: const Text("አጥፋ"))
                ]));
    if (confirmed != true) return;
    try {
      await GradeService.deleteCourse(courseId);
      if (mounted) {
        setState(() {
          _courses.removeAt(index);
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('ትምህርት ሲሰርዙ ስህተት ተፈጥሯል፦ $e'),
            backgroundColor: dangerColor));
      }
    }
  }

  void _manageAssessments(Map<String, dynamic> course) async {
    await showDialog(
        context: context,
        builder: (context) => _AssessmentManagementDialog(course: course));
    setState(() => _hasChanges = true);
  }
}

class _AssessmentManagementDialog extends StatefulWidget {
  final Map<String, dynamic> course;
  const _AssessmentManagementDialog({required this.course});
  @override
  State<_AssessmentManagementDialog> createState() =>
      _AssessmentManagementDialogState();
}

class _AssessmentManagementDialogState
    extends State<_AssessmentManagementDialog> {
  // Theme Getters
  Color get primaryColor =>
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

  late List<Map<String, dynamic>> _assessments;
  bool _isLoading = true;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _assessments = []; // Initialize here
    _fetchAssessments();
  }

  Future<void> _fetchAssessments() async {
    setState(() => _isLoading = true);
    try {
      final data =
          await GradeService.getAssessmentsForCourse(widget.course['id']);
      if (mounted) {
        setState(() => _assessments = data.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      _handleError("ምዘናዎችን መጫን አልተሳካም፦ $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addNewAssessment() => setState(() =>
      _assessments.add({'id': null, 'assessment_name': '', 'max_score': 0}));
  void _removeAssessment(int index) =>
      setState(() => _assessments.removeAt(index));
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final navigator = Navigator.of(context);
    setState(() => _isSaving = true);
    try {
      await GradeService.saveAssessmentsForCourse(
          courseId: widget.course['id'], assessments: _assessments);
      if (mounted) navigator.pop();
    } catch (e) {
      _handleError("ምዘናዎችን ማስቀመጥ አልተሳካም፦ $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _handleError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: dangerColor));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("ምዘናዎች ለ ${widget.course['course_name']}",
          style: GoogleFonts.notoSansEthiopic(
              color: primaryColor, fontWeight: FontWeight.bold)),
      content: Form(
          key: _formKey,
          child: SizedBox(
              width: 500,
              child: _isLoading || _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : Column(mainAxisSize: MainAxisSize.min, children: [
                      Flexible(
                          child: _assessments.isEmpty
                              ? const Center(
                                  child:
                                      Text("ምንም ምዘናዎች አልተገለጹም። ከታች አንዱን ያክሉ።"))
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _assessments.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12.0),
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  flex: 3,
                                                  child: TextFormField(
                                                      initialValue: _assessments[index]
                                                          ['assessment_name'],
                                                      style: TextStyle(
                                                          color:
                                                              onSurfaceColor),
                                                      decoration: InputDecoration(
                                                          labelText: 'ስም',
                                                          labelStyle: TextStyle(
                                                              color:
                                                                  subtleTextColor),
                                                          enabledBorder: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .white10)),
                                                          focusedBorder: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(12),
                                                              borderSide: BorderSide(color: primaryColor)),
                                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white10))),
                                                      validator: (v) => (v == null || v.isEmpty) ? 'ያስፈልጋል' : null,
                                                      onSaved: (v) => _assessments[index]['assessment_name'] = v)),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                  flex: 2,
                                                  child: TextFormField(
                                                      initialValue: _assessments[index]
                                                              ['max_score']
                                                          .toString(),
                                                      style: TextStyle(
                                                          color:
                                                              onSurfaceColor),
                                                      decoration: InputDecoration(
                                                          labelText: 'ከፍተኛ ውጤት',
                                                          labelStyle: TextStyle(
                                                              color:
                                                                  subtleTextColor),
                                                          enabledBorder: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      12),
                                                              borderSide: BorderSide(
                                                                  color: Colors
                                                                      .white10)),
                                                          focusedBorder: OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(12),
                                                              borderSide: BorderSide(color: primaryColor)),
                                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white10))),
                                                      keyboardType: TextInputType.number,
                                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                                      validator: (v) => (v == null || v.isEmpty || int.tryParse(v) == null) ? 'ያስ.' : null,
                                                      onSaved: (v) => _assessments[index]['max_score'] = int.tryParse(v!))),
                                              IconButton(
                                                  icon: Icon(Iconsax.trash,
                                                      color: dangerColor),
                                                  onPressed: () =>
                                                      _removeAssessment(index))
                                            ]));
                                  })),
                      const SizedBox(height: 16),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                              onPressed: _addNewAssessment,
                              icon: Icon(Icons.add_circle, color: successColor),
                              label: Text("አዲስ ምዘና ያክሉ",
                                  style: TextStyle(color: successColor))))
                    ]))),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("ይቅር")),
        ElevatedButton(
            onPressed: _isSaving ? null : _saveChanges,
            child: const Text("ለውጦችን ያስቀምጡ"))
      ],
    );
  }
}

class _EditGradesDialog extends StatefulWidget {
  final Map<String, dynamic> student;
  final List<Map<String, dynamic>> courses;
  final int year;
  final bool isReadOnly;

  const _EditGradesDialog(
      {required this.student,
      required this.courses,
      required this.year,
      this.isReadOnly = false});
  @override
  State<_EditGradesDialog> createState() => _EditGradesDialogState();
}

class _EditGradesDialogState extends State<_EditGradesDialog> {
  // Theme Getters
  Color get primaryColor =>
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

  final Map<int, Map<int, TextEditingController>> _controllers = {};
  final Map<int, List<Map<String, dynamic>>> _assessmentsForCourses = {};
  bool _isLoading = true;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _fetchAssessmentsAndInitialize();
  }

  Future<void> _fetchAssessmentsAndInitialize() async {
    setState(() => _isLoading = true);
    try {
      final studentGrades = (widget.student['grades'] as List<dynamic>? ?? [])
          .map((g) => Map<String, dynamic>.from(g))
          .toList();
      for (var course in widget.courses) {
        final courseId = course['id'];
        if (courseId == null) continue;
        final assessmentData =
            await GradeService.getAssessmentsForCourse(courseId);
        _assessmentsForCourses[courseId] =
            assessmentData.cast<Map<String, dynamic>>();
        _controllers[courseId] = {};
        final studentScoresForCourse = studentGrades.firstWhere(
            (g) => g['course_name'] == course['course_name'],
            orElse: () => {'scores': []});
        final scoresList =
            (studentScoresForCourse['scores'] as List<dynamic>? ?? []);
        for (var assessment in _assessmentsForCourses[courseId]!) {
          final assessmentId = assessment['id'];
          final existingScore = scoresList.firstWhere(
              (s) => s['assessment_name'] == assessment['assessment_name'],
              orElse: () => {});
          _controllers[courseId]![assessmentId] = TextEditingController(
              text: (existingScore['score'] ?? '').toString());
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('ምዘናዎችን በመጫን ላይ ስህተት ተፈጥሯል፦ $e'),
            backgroundColor: dangerColor));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controllers.forEach(
        (_, map) => map.forEach((_, controller) => controller.dispose()));
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (widget.isReadOnly) {
      Navigator.of(context).pop(null);
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSaving = true);
    final navigator = Navigator.of(context);
    final List<Map<String, dynamic>> updatedScoresPayload = [];
    _controllers.forEach((courseId, assessmentMap) {
      assessmentMap.forEach((assessmentId, controller) {
        final score = double.tryParse(controller.text);
        if (score != null) {
          updatedScoresPayload.add({
            'course_id': courseId,
            'assessment_id': assessmentId,
            'score': score
          });
        }
      });
    });
    try {
      // Check connectivity before saving
      final syncService = SyncService();
      final isOnline = await syncService.isOnline();

      final result = await GradeService.saveStudentScores(
          studentId: widget.student['student_id'],
          year: widget.year,
          scores: updatedScoresPayload);

      // Update sync provider to refresh pending count
      if (mounted) {
        final syncProvider = context.read<SyncProvider>();
        await syncProvider.updatePendingCount();

        final responseData = result['data'];
        if (responseData != null && responseData is Map<String, dynamic>) {
          navigator.pop(responseData);
        } else {
          navigator.pop(null);
        }

        // Show appropriate message
        if (!isOnline ||
            result['message']?.toString().contains('offline') == true) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('ውጤቶች ኦፍላይን ተመዝግተዋል። ኢንተርኔት ሲገኝ በራስ-ሰር ይላካሉ።'),
              backgroundColor: Colors.amber.shade700));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('ውጤቶችን በማስቀመጥ ላይ ስህተት ተፈጥሯል፦ $e'),
            backgroundColor: dangerColor));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: surfaceColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
          widget.isReadOnly
              ? "ውጤቶችን ይመልከቱ: ${widget.student['full_name'] ?? 'ተማሪ'}"
              : "ውጤቶችን ያርትዑ: ${widget.student['full_name'] ?? 'ተማሪ'}",
          style: GoogleFonts.notoSansEthiopic(
              color: primaryColor, fontWeight: FontWeight.bold)),
      content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : (widget.courses.isEmpty)
                  ? Center(
                      child: Text("ምንም ትምህርቶች አልተገኙም። እባክዎ መጀመሪያ ትምህርቶችን ያክሉ።",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: subtleTextColor)))
                  : Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: widget.courses.map((course) {
                                final courseId = course['id'];
                                final assessments =
                                    _assessmentsForCourses[courseId] ?? [];
                                return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                            color: Colors.grey.shade200)),
                                    child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  course['course_name'] ??
                                                      'ስም የሌለው ትምህርት',
                                                  style: GoogleFonts
                                                      .notoSansEthiopic(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: onSurfaceColor,
                                                          fontSize: 16)),
                                              const Divider(height: 20),
                                              if (assessments.isEmpty)
                                                Center(
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                            "ለዚህ ትምህርት ምንም ምዘናዎች አልተገለጹም።",
                                                            style: TextStyle(
                                                                color:
                                                                    subtleTextColor))))
                                              else
                                                ...assessments
                                                    .map((assessment) {
                                                  final assessmentId =
                                                      assessment['id'];
                                                  if (courseId == null ||
                                                      assessmentId == null ||
                                                      _controllers[courseId] ==
                                                          null ||
                                                      _controllers[courseId]![
                                                              assessmentId] ==
                                                          null) {
                                                    return const SizedBox
                                                        .shrink();
                                                  }
                                                  return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 16.0),
                                                      child: _buildGradeField(
                                                          assessment[
                                                                  'assessment_name'] ??
                                                              'ስም የሌለው',
                                                          (assessment['max_score']
                                                                      as num?)
                                                                  ?.toInt() ??
                                                              100,
                                                          _controllers[
                                                                  courseId]![
                                                              assessmentId]!));
                                                })
                                            ])));
                              }).toList())))),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(widget.isReadOnly ? "ዝጋ" : "ይቅር")),
        if (!widget.isReadOnly)
          ElevatedButton(
              onPressed: _isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor, foregroundColor: accentColor),
              child: const Text("ለውጦችን ያስቀምጡ"))
      ],
    );
  }

  Widget _buildGradeField(
      String label, int maxScore, TextEditingController controller) {
    return TextFormField(
        controller: controller,
        readOnly: widget.isReadOnly,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(color: onSurfaceColor, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.poppins(color: subtleTextColor),
            suffixText: "/ $maxScore",
            suffixStyle: TextStyle(color: subtleTextColor),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white10)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white10)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryColor)),
            filled: true,
            fillColor: Colors.black12),
        validator: (value) {
          if (widget.isReadOnly || value == null || value.isEmpty) return null;
          final score = double.tryParse(value);
          if (score == null) return "ልክ ያልሆነ";
          if (score < 0 || score > maxScore) return "ከፍተኛ: $maxScore";
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction);
  }
}

// ===============================================================
// የቡድን አስተዳደር ታቦች
// ===============================================================

class _NewStudentRegistrationTab extends StatefulWidget {
  final VoidCallback onBatchChanged;
  final bool isReadOnly;
  const _NewStudentRegistrationTab(
      {required this.onBatchChanged, required this.isReadOnly});
  @override
  State<_NewStudentRegistrationTab> createState() =>
      _NewStudentRegistrationTabState();
}

class _NewStudentRegistrationTabState
    extends State<_NewStudentRegistrationTab> {
  // Theme Getters
  Color get primaryColor =>
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

  bool _isLoading = false;
  static final int currentEthiopianYear = EthiopianDate.now().year;
  final List<int> _yearOptions =
      List.generate(12, (index) => currentEthiopianYear + 5 - index)
        ..sort((a, b) => b.compareTo(a));
  List<Map<String, dynamic>> _allUsers = [];
  bool _isLoadingUsers = true;
  String? _newStudentClass;
  int? _newStudentYear;
  final Set<String> _selectedStudentIds = {};
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchUserListForRegistration();
    _newStudentYear = currentEthiopianYear;
  }

  Future<void> _fetchUserListForRegistration() async {
    setState(() => _isLoadingUsers = true);
    try {
      // Changed to getAllUsers to allow re-registering existing students/users
      final response = await UserAdminService.getAllUsers();
      if (mounted) {
        setState(() {
          _allUsers = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      if (mounted) {
        _showResultDialog(isError: true, title: 'ስህተት', content: e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoadingUsers = false);
    }
  }

  Future<void> _registerNewStudents() async {
    if (_newStudentClass == null ||
        _newStudentYear == null ||
        _selectedStudentIds.isEmpty) {
      _showSnackbar('እባክዎ ክፍል፣ ዓመት እና ቢያንስ አንድ ተማሪ ይምረጡ።');
      return;
    }
    final confirmed = await _showConfirmationDialog(
        title: 'ምዝገባን ያረጋግጡ',
        content:
            '${_selectedStudentIds.length} ተማሪዎችን በ$_newStudentYear ዓ.ም. ወደ $_newStudentClass ለመመዝገብ እርግጠኛ ነዎት?');
    if (confirmed != true) return;
    setState(() => _isLoading = true);
    try {
      await BatchService.registerStudentsToBatch(
          studentIds: _selectedStudentIds.toList(),
          className: _newStudentClass!,
          academicYear: _newStudentYear!);
      widget.onBatchChanged();
      _showResultDialog(
          isError: false,
          title: 'ምዝገባው ተሳክቷል',
          content: '${_selectedStudentIds.length} ተማሪዎች በተሳካ ሁኔታ ተመዝግበዋል።');
      setState(() {
        _selectedStudentIds.clear();
      });
      // Refresh list to reflect changes if needed
      await _fetchUserListForRegistration();
    } catch (e) {
      _showResultDialog(
          isError: true, title: 'የምዝገባ ስህተት', content: e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message, style: GoogleFonts.poppins()),
          backgroundColor: isError ? dangerColor : successColor,
          behavior: SnackBarBehavior.floating));
    }
  }

  Future<bool?> _showConfirmationDialog(
      {required String title, required String content}) {
    return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(title, style: GoogleFonts.poppins()),
                content: Text(content, style: GoogleFonts.poppins()),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('ይቅር')),
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('አረጋግጥ'))
                ]));
  }

  void _showResultDialog(
      {required bool isError, required String title, required String content}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(title,
                    style: GoogleFonts.poppins(
                        color: isError ? dangerColor : successColor)),
                content: SelectableText(content, style: GoogleFonts.poppins()),
                actions: [
                  TextButton(
                      child: const Text('እሺ'),
                      onPressed: () => Navigator.of(context).pop())
                ]));
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _allUsers.where((user) {
      final name = (user['full_name'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();

    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(children: [
              Expanded(
                  child: DropdownButtonFormField<String>(
                      initialValue: _newStudentClass,
                      dropdownColor: surfaceColor,
                      hint: Text('ክፍል ይምረጡ',
                          style: GoogleFonts.notoSansEthiopic(
                              color: subtleTextColor)),
                      style:
                          GoogleFonts.notoSansEthiopic(color: onSurfaceColor),
                      items: spiritualClassOptions
                          .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c,
                                  style: GoogleFonts.notoSansEthiopic(
                                      color: onSurfaceColor))))
                          .toList(),
                      onChanged: widget.isReadOnly
                          ? null
                          : (val) => setState(() => _newStudentClass = val),
                      decoration: InputDecoration(
                          labelText: 'ክፍል',
                          labelStyle: TextStyle(color: subtleTextColor),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white10)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryColor)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white10))))),
              const SizedBox(width: 16),
              Expanded(
                  child: DropdownButtonFormField<int>(
                      initialValue: _newStudentYear,
                      dropdownColor: surfaceColor,
                      hint: Text('ዓመት ይምረጡ',
                          style: GoogleFonts.notoSansEthiopic(
                              color: subtleTextColor)),
                      style:
                          GoogleFonts.notoSansEthiopic(color: onSurfaceColor),
                      items: _yearOptions
                          .map((y) => DropdownMenuItem(
                              value: y,
                              child: Text('$y ዓ.ም.',
                                  style: TextStyle(color: onSurfaceColor))))
                          .toList(),
                      onChanged: widget.isReadOnly
                          ? null
                          : (val) => setState(() => _newStudentYear = val),
                      decoration: InputDecoration(
                          labelText: 'ዓመት',
                          labelStyle: TextStyle(color: subtleTextColor),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white10)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryColor)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white10))))),
            ])),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            style: TextStyle(color: onSurfaceColor),
            decoration: InputDecoration(
                labelText: "ተማሪ ይፈልጉ (Search User)",
                labelStyle: TextStyle(color: subtleTextColor),
                prefixIcon: Icon(Icons.search, color: subtleTextColor),
                filled: true,
                fillColor: surfaceColor,
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white10)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10)),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text('ለመመዝገብ ተማሪዎችን ይምረጡ',
                    style: GoogleFonts.poppins(
                        textStyle: Theme.of(context).textTheme.titleMedium,
                        color: onSurfaceColor)))),
        Expanded(
            child: _isLoadingUsers
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? Center(
                        child: Text("ምንም ተጠቃሚዎች አልተገኙም።",
                            style: GoogleFonts.poppins(color: subtleTextColor)))
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          final userId = user['id'];
                          return Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom:
                                          BorderSide(color: Colors.white10))),
                              child: CheckboxListTile(
                                title: Text(user['full_name'] ?? 'ስም የለም',
                                    style: GoogleFonts.poppins(
                                        color: onSurfaceColor)),
                                subtitle: Text(user['email'] ?? 'ኢሜይል የለም',
                                    style: GoogleFonts.poppins(
                                        color: subtleTextColor)),
                                value: _selectedStudentIds.contains(userId),
                                checkColor: Colors.black, // Check mark color
                                activeColor:
                                    accentColor, // Checkbox background when checked
                                side: BorderSide(
                                    color:
                                        subtleTextColor), // Unchecked border color
                                onChanged: widget.isReadOnly
                                    ? null
                                    : (bool? value) => setState(() {
                                          if (value == true) {
                                            _selectedStudentIds.add(userId);
                                          } else {
                                            _selectedStudentIds.remove(userId);
                                          }
                                        }),
                              ));
                        })),
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                    onPressed: widget.isReadOnly ||
                            _isLoading ||
                            _selectedStudentIds.isEmpty
                        ? null
                        : _registerNewStudents,
                    icon: const Icon(Icons.app_registration),
                    label: Text('${_selectedStudentIds.length} ተማሪዎችን ይመዝግቡ',
                        style: GoogleFonts.poppins()),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 16)))))
      ],
    );
  }
}

class _ManageBatchesTab extends StatefulWidget {
  final VoidCallback onBatchChanged;
  final bool isReadOnly;
  const _ManageBatchesTab(
      {required this.onBatchChanged, required this.isReadOnly});
  @override
  State<_ManageBatchesTab> createState() => _ManageBatchesTabState();
}

class _ManageBatchesTabState extends State<_ManageBatchesTab> {
  // Theme Getters
  Color get primaryColor =>
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

  Future<List<dynamic>>? _batchesFuture;
  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  void _loadBatches() {
    setState(() {
      _batchesFuture = BatchService.getBatchSummary();
    });
  }

  void _showStudentsInBatchDialog(Map<String, dynamic> batch) async {
    final bool? changed = await showDialog<bool>(
        context: context,
        builder: (context) => _StudentsInBatchDialog(
            batch: batch, isReadOnly: widget.isReadOnly));
    if (changed == true) {
      _loadBatches();
      widget.onBatchChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async => _loadBatches(),
        child: FutureBuilder<List<dynamic>>(
            future: _batchesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("ስህተት፦ ${snapshot.error}"));
              }
              final batches = snapshot.data ?? [];
              if (batches.isEmpty) {
                return Center(
                    child: Text("ምንም ንቁ ቡድኖች አልተገኙም።",
                        style: GoogleFonts.poppins(color: subtleTextColor)));
              }
              return ListView.builder(
                  itemCount: batches.length,
                  itemBuilder: (context, index) {
                    final batch = batches[index];
                    return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.2))),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child:
                                    Icon(Iconsax.folder, color: primaryColor)),
                            title: Text(
                                "${batch['spiritual_class']} - ${batch['academic_year']} ዓ.ም.",
                                style: GoogleFonts.notoSansEthiopic(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                  "${batch['student_count']} ተማሪዎች ተመዝግበዋል",
                                  style: GoogleFonts.notoSansEthiopic(
                                      color: subtleTextColor)),
                            ),
                            trailing: Icon(Iconsax.arrow_right_3,
                                color: subtleTextColor),
                            onTap: () => _showStudentsInBatchDialog(batch)));
                  });
            }));
  }
}

class _PromotionTab extends StatefulWidget {
  final VoidCallback onBatchChanged;
  final bool isReadOnly;
  const _PromotionTab({required this.onBatchChanged, required this.isReadOnly});
  @override
  State<_PromotionTab> createState() => _PromotionTabState();
}

class _PromotionTabState extends State<_PromotionTab> {
  // Theme Getters
  Color get primaryColor =>
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

  bool _isLoading = false;
  static final int currentEthiopianYear = EthiopianDate.now().year;
  final List<int> _yearOptions =
      List.generate(12, (index) => currentEthiopianYear + 5 - index)
        ..sort((a, b) => b.compareTo(a));
  final _promotionFormKey = GlobalKey<FormState>();
  String? _promotionFromClass;
  int? _promotionFromYear;
  final _passingScoreController = TextEditingController(text: '50.0');
  @override
  void initState() {
    super.initState();
    _promotionFromYear = currentEthiopianYear;
  }

  @override
  void dispose() {
    _passingScoreController.dispose();
    super.dispose();
  }

  Future<void> _promoteStudents() async {
    if (!_promotionFormKey.currentState!.validate()) return;
    final passingScore = double.tryParse(_passingScoreController.text);
    if (passingScore == null) {
      _showResultDialog(
          isError: true,
          title: 'ልክ ያልሆነ ውጤት',
          content: 'የማለፊያ ውጤቱ ትክክለኛ ቁጥር መሆን አለበት።');
      return;
    }

    final confirmed = await _showConfirmationDialog(
        title: 'ማሳደግን ያረጋግጡ',
        content:
            'ከ$_promotionFromClass - $_promotionFromYear ዓ.ም. ያሉ ተማሪዎችን $passingScore% ወይም ከዚያ በላይ ውጤት ያላቸውን ማሳደግ ይፈልጋሉ?');
    if (confirmed != true) return;
    setState(() => _isLoading = true);
    try {
      final result = await BatchService.promoteStudents(
          fromClass: _promotionFromClass!,
          fromYear: _promotionFromYear!,
          passingScore: passingScore);
      widget.onBatchChanged();
      _showResultDialog(
          isError: false,
          title: 'የማሳደግ ሂደት ተጠናቋል',
          content: result['message'] ?? 'ማሳደጉ በተሳካ ሁኔታ ተጠናቋል።');
    } catch (e) {
      _showResultDialog(
          isError: true, title: 'የማሳደግ ስህተት', content: e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showConfirmationDialog(
      {required String title, required String content}) {
    return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(title, style: GoogleFonts.poppins()),
                content: Text(content, style: GoogleFonts.poppins()),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('ይቅር')),
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('አረጋግጥ'))
                ]));
  }

  void _showResultDialog(
      {required bool isError, required String title, required String content}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(title,
                    style: GoogleFonts.poppins(
                        color: isError ? dangerColor : successColor)),
                content: SelectableText(content, style: GoogleFonts.poppins()),
                actions: [
                  TextButton(
                      child: const Text('እሺ'),
                      onPressed: () => Navigator.of(context).pop())
                ]));
  }

  @override
  Widget build(BuildContext context) {
    final promotableClasses =
        spiritualClassOptions.take(spiritualClassOptions.length - 1).toList();
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
              key: _promotionFormKey,
              child: ListView(children: [
                Text('ለማሳደግ የሚፈልጉትን ክፍል ይምረጡ',
                    style: GoogleFonts.poppins(
                        textStyle: Theme.of(context).textTheme.titleLarge,
                        color: onSurfaceColor,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                    initialValue: _promotionFromClass,
                    hint:
                        Text('ክፍል ይምረጡ', style: GoogleFonts.notoSansEthiopic()),
                    items: promotableClasses
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child:
                                Text(c, style: GoogleFonts.notoSansEthiopic())))
                        .toList(),
                    onChanged: widget.isReadOnly
                        ? null
                        : (val) => setState(() => _promotionFromClass = val),
                    decoration: InputDecoration(
                        labelText: 'ከክፍል',
                        labelStyle: GoogleFonts.poppins(),
                        border: const OutlineInputBorder()),
                    validator: (v) => v == null ? 'እባክዎ ክፍል ይምረጡ' : null),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                    initialValue: _promotionFromYear,
                    hint:
                        Text('ዓመት ይምረጡ', style: GoogleFonts.notoSansEthiopic()),
                    items: _yearOptions
                        .map((y) =>
                            DropdownMenuItem(value: y, child: Text('$y ዓ.ም.')))
                        .toList(),
                    onChanged: widget.isReadOnly
                        ? null
                        : (val) => setState(() => _promotionFromYear = val),
                    decoration: InputDecoration(
                        labelText: 'ከዓመት',
                        labelStyle: GoogleFonts.poppins(),
                        border: const OutlineInputBorder()),
                    validator: (v) => v == null ? 'እባክዎ ዓመት ይምረጡ' : null),
                const SizedBox(height: 24),
                Text('የማሳደጊያ መስፈርት',
                    style: GoogleFonts.poppins(
                        textStyle: Theme.of(context).textTheme.titleLarge,
                        color: onSurfaceColor,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _passingScoreController,
                    readOnly: widget.isReadOnly,
                    decoration: InputDecoration(
                        labelText: 'የማለፊያ ውጤት (%)',
                        labelStyle: GoogleFonts.poppins(),
                        border: const OutlineInputBorder(),
                        suffixText: '%'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'እባክዎ ውጤት ያስገቡ';
                      }
                      final score = double.tryParse(value);
                      if (score == null || score < 0 || score > 100) {
                        return 'ከ 0-100 መካከል የሆነ ቁጥር ያስገቡ';
                      }
                      return null;
                    }),
                const SizedBox(height: 32),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                        onPressed: widget.isReadOnly || _isLoading
                            ? null
                            : _promoteStudents,
                        icon: Icon(Iconsax.scroll),
                        label:
                            Text('ተማሪዎችን ያሳድጉ', style: GoogleFonts.poppins()),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: accentColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16))))
              ])),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(child: CircularProgressIndicator(color: accentColor)),
          ),
      ],
    );
  }
}

class _StudentsInBatchDialog extends StatefulWidget {
  final Map<String, dynamic> batch;
  final bool isReadOnly;
  const _StudentsInBatchDialog({required this.batch, required this.isReadOnly});
  @override
  State<_StudentsInBatchDialog> createState() => _StudentsInBatchDialogState();
}

class _StudentsInBatchDialogState extends State<_StudentsInBatchDialog> {
  // Theme Getters
  Color get primaryColor =>
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

  Future<List<dynamic>>? _studentsFuture;
  final Set<String> _selectedStudentIds = {};
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  void _loadStudents() {
    setState(() {
      _studentsFuture = BatchService.getStudentsInBatch(
          spiritualClass: widget.batch['spiritual_class'],
          academicYear: widget.batch['academic_year']);
    });
  }

  Future<void> _removeSelectedStudents() async {
    if (_selectedStudentIds.isEmpty) return;
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: const Text('ማስወገድን ያረጋግጡ'),
                content: Text(
                    '${_selectedStudentIds.length} ተማሪዎችን ከዚህ ቡድን ለማስወገድ እርግጠኛ ነዎት? "ያልተመዘገቡ" ይሆናሉ እና ወደ አዲስ ቡድን ሊጨመሩ ይችላሉ።'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('ይቅር')),
                  TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: TextButton.styleFrom(foregroundColor: dangerColor),
                      child: const Text('አስወግድ'))
                ]));
    if (confirmed != true) return;
    setState(() => _isLoading = true);
    try {
      await BatchService.removeStudentsFromBatch(
          studentIds: _selectedStudentIds.toList());
      if (mounted) {
        _selectedStudentIds.clear();
        _loadStudents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ስህተት፦ $e'), backgroundColor: dangerColor));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          "${widget.batch['spiritual_class']} - ${widget.batch['academic_year']}",
          style: GoogleFonts.notoSansEthiopic()),
      content: SizedBox(
          width: 400,
          height: 500,
          child: FutureBuilder<List<dynamic>>(
              future: _studentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    _isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("ስህተት፦ ${snapshot.error}"));
                }
                final students = snapshot.data ?? [];
                if (students.isEmpty) {
                  return const Center(
                      child: Text("በዚህ ቡድን ውስጥ ምንም ተማሪዎች አልተገኙም።"));
                }
                return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return CheckboxListTile(
                          title: Text(student['full_name'] ?? 'ስም የለም'),
                          value: _selectedStudentIds.contains(student['id']),
                          onChanged: widget.isReadOnly
                              ? null
                              : (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedStudentIds.add(student['id']);
                                    } else {
                                      _selectedStudentIds.remove(student['id']);
                                    }
                                  });
                                });
                    });
              })),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ዝጋ')),
        if (!widget.isReadOnly)
          ElevatedButton.icon(
              onPressed:
                  _selectedStudentIds.isEmpty ? null : _removeSelectedStudents,
              icon: const Icon(Iconsax.user_minus),
              label: Text('${_selectedStudentIds.length} አስወግድ'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: dangerColor, foregroundColor: Colors.white))
      ],
    );
  }
}
