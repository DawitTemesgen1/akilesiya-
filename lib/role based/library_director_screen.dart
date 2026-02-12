import 'package:amde_haymanot_abalat_guday/role%20based/librarian_admin_screen.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:amde_haymanot_abalat_guday/services/library_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';

// --- Models ---
class LibraryUser {
  final String id;
  final String fullName;
  final String? profileImageUrl;
  final String? spiritualClass;
  final int unfinishedBooksCount;
  final int overdueBooksCount;

  LibraryUser({
    required this.id,
    required this.fullName,
    this.profileImageUrl,
    this.spiritualClass,
    required this.unfinishedBooksCount,
    required this.overdueBooksCount,
  });

  factory LibraryUser.fromJson(Map<String, dynamic> json) {
    return LibraryUser(
      id: json['id'].toString(),
      fullName: json['full_name'] ?? 'ስም የለም',
      profileImageUrl: json['profile_image_url'],
      spiritualClass: json['spiritual_class'],
      unfinishedBooksCount:
          (json['unfinishedBooksCount'] as num?)?.toInt() ?? 0,
      overdueBooksCount: (json['overdueBooksCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class ReadingHistoryItem {
  final String bookTitle;
  final String status;
  final String? assignedBy;
  final DateTime? finishBy;

  ReadingHistoryItem(
      {required this.bookTitle,
      required this.status,
      this.assignedBy,
      this.finishBy});

  factory ReadingHistoryItem.fromJson(Map<String, dynamic> json) {
    return ReadingHistoryItem(
      bookTitle: json['bookTitle'] ?? 'ርዕስ አልባ',
      status: json['status'] ?? 'in_progress',
      assignedBy: json['assignedBy'],
      finishBy:
          json['finishBy'] != null ? DateTime.parse(json['finishBy']) : null,
    );
  }
}

// #########################################################################
// MAIN COMBINED SCREEN: LibraryManagementScreen
// #########################################################################

class LibraryManagementScreen extends StatefulWidget {
  const LibraryManagementScreen({super.key});

  @override
  State<LibraryManagementScreen> createState() =>
      _LibraryManagementScreenState();
}

class _LibraryManagementScreenState extends State<LibraryManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

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
  Color get kLibDangerColor => const Color(0xFFEF4444);
  Color get kLibSuccessColor => const Color(0xFF10B981);

  // --- State for Data ---
  late Future<void> _dataFuture;
  final _searchController = TextEditingController();
  List<LibraryUser> _allUsers = [];
  List<LibraryUser> _filteredUsers = [];
  bool _showOnlyUnfinished = false;
  Map<String, dynamic> _overviewStats = {};

  // --- State for Assignment ---
  LibraryUser? _selectedUserForAssignment;
  final _bookTitleController = TextEditingController();
  DateTime? _finishByDate;
  bool _isSavingAssignment = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _dataFuture = _fetchData();
    _searchController.addListener(_performFilter);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _bookTitleController.dispose();
    super.dispose();
  }

  // --- DATA FETCHING & FILTERING ---
  Future<void> _fetchData() async {
    final result = await LibraryService.getReaders();
    if (mounted && result['success']) {
      final users = (result['data'] as List)
          .map((userData) => LibraryUser.fromJson(userData))
          .toList();
      setState(() {
        _allUsers = users;
        _filteredUsers = users;
        _calculateOverviewStats();
      });
    } else if (mounted) {
      _showSnackbar(result['message'] ?? 'አንባቢዎችን ማምጣት አልተቻለም።', isError: true);
    }
  }

  void _calculateOverviewStats() {
    if (_allUsers.isEmpty) {
      setState(() {
        _overviewStats = {
          'totalReaders': '0',
          'booksInProgress': '0',
          'readersWithOverdue': '0',
          'completedThisMonth': 'N/A',
        };
      });
      return;
    }

    final totalReaders = _allUsers.length;
    final booksInProgress =
        _allUsers.map((u) => u.unfinishedBooksCount).reduce((a, b) => a + b);
    final readersWithOverdue =
        _allUsers.where((u) => u.overdueBooksCount > 0).length;

    setState(() {
      _overviewStats = {
        'totalReaders': totalReaders.toString(),
        'booksInProgress': booksInProgress.toString(),
        'readersWithOverdue': readersWithOverdue.toString(),
        'completedThisMonth': "N/A",
      };
    });
  }

  void _performFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((user) {
        final matchesSearch = user.fullName.toLowerCase().contains(query);
        final matchesUnfinished =
            !_showOnlyUnfinished || user.unfinishedBooksCount > 0;
        return matchesSearch && matchesUnfinished;
      }).toList();
    });
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? kLibDangerColor : kLibSuccessColor,
    ));
  }

  void _showReadingHistorySheet(LibraryUser user, String heroTag) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReadingHistorySheet(user: user, heroTag: heroTag),
    );
  }

  // --- BOOK ASSIGNMENT LOGIC ---
  Future<void> _selectUserForAssignment() async {
    final selected = await showModalBottomSheet<LibraryUser>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _UserSelectionSheet(users: _allUsers),
    );
    if (selected != null) {
      setState(() => _selectedUserForAssignment = selected);
    }
  }

  Future<void> _selectFinishDate() async {
    final initialDate = EthiopianDate.fromGregorian(
        DateTime.now().add(const Duration(days: 14)));
    final pickedEth = await showDialog<EthiopianDate>(
      context: context,
      builder: (context) => EthiopianDatePickerDialog(
        initialDate: initialDate,
      ),
    );
    if (pickedEth != null) {
      setState(() => _finishByDate = pickedEth.toGregorian());
    }
  }

  Future<void> _assignBook() async {
    if (_selectedUserForAssignment == null ||
        _bookTitleController.text.trim().isEmpty ||
        _finishByDate == null) {
      _showSnackbar("እባክዎ ሁሉንም πεδία ይሙሉ.", isError: true);
      return;
    }

    setState(() => _isSavingAssignment = true);

    final result = await LibraryService.assignBook(
      userId: _selectedUserForAssignment!.id,
      bookTitle: _bookTitleController.text.trim(),
      finishBy: _finishByDate!,
    );

    if (mounted) {
      _showSnackbar(result['message'] ?? 'ያልታወቀ ስህተት ተፈጥሯል።',
          isError: !result['success']);
      if (result['success']) {
        setState(() {
          _selectedUserForAssignment = null;
          _bookTitleController.clear();
          _finishByDate = null;
          _dataFuture = _fetchData();
        });
      }
    }
    setState(() => _isSavingAssignment = false);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final bool isSuperiorAdmin = userProvider.roles.contains('superior_admin');
    final bool isLibraryAdmin = userProvider.roles.contains('library_admin');
    final bool canAssignBooks = isLibraryAdmin;
    final bool canManageAdmins = isSuperiorAdmin;
    final bool isReadOnly = !isLibraryAdmin;

    List<Widget> tabs = [
      const Tab(text: 'አጠቃላይ እይታ'),
      const Tab(text: 'ሁሉም አንባቢዎች'),
    ];
    List<Widget> tabViews = [
      _buildOverviewTab(),
      _buildAllReadersTab(),
    ];

    if (canAssignBooks) {
      tabs.add(const Tab(text: 'ሥራ መድብ'));
      tabViews.add(_buildAssignTaskTab(isReadOnly: isReadOnly));
    }

    if (_tabController.length != tabs.length) {
      _tabController = TabController(length: tabs.length, vsync: this);
    }

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text('የቤተ-መጽሐፍት አስተዳደር',
            style: GoogleFonts.poppins(
                color: onSurfaceColor, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: accentColor),
        actions: [
          if (canManageAdmins)
            IconButton(
              icon: const Icon(Iconsax.security_user),
              tooltip: 'የቤተ-መጽሐፍት አስተዳዳሪዎችን ያቀናብሩ',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LibrarianAdminScreen(),
                  ),
                );
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: accentColor,
          unselectedLabelColor: subtleTextColor,
          indicatorColor: accentColor,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: tabs,
        ),
      ),
      body: FutureBuilder<void>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: accentColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text("ስህተት: ${snapshot.error}"));
          }
          return TabBarView(
            controller: _tabController,
            children: tabViews,
          );
        },
      ),
    );
  }

  // --- TAB 1: Overview ---
  Widget _buildOverviewTab() {
    if (_overviewStats.isEmpty) {
      return const Center(child: Text("ለአጠቃላይ እይታ ምንም መረጃ የለም።"));
    }
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatCard(
                title: "ጠቅላላ አንባቢዎች",
                value: _overviewStats['totalReaders'] ?? '0',
                icon: Iconsax.profile_2user,
                color: Colors.blue),
            _buildStatCard(
                title: "በሂደት ላይ ያሉ መጻሕፍት",
                value: _overviewStats['booksInProgress'] ?? '0',
                icon: Iconsax.book_1,
                color: Colors.orange),
            _buildStatCard(
                title: "ያልተመለሱ መጻሕፍት ያላቸው አንባቢዎች",
                value: _overviewStats['readersWithOverdue'] ?? '0',
                icon: Iconsax.warning_2,
                color: kLibDangerColor),
            _buildStatCard(
                title: "በዚህ ወር የተጠናቀቁ",
                value: _overviewStats['completedThisMonth'] ?? 'N/A',
                icon: Iconsax.task_square,
                color: kLibSuccessColor),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return FadeInUp(
      from: 20,
      child: Card(
        elevation: 0,
        color: surfaceColor,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white10)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              CircleAvatar(
                  radius: 24,
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(icon, color: color, size: 24)),
              const SizedBox(width: 16),
              Expanded(
                  child: Text(title,
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              subtleTextColor))), // Replaced kLibSubtleTextColor
              Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color:
                          accentColor)), // Replaced kLibPrimaryColor with accentColor
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 2: All Readers ---
  Widget _buildAllReadersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
                filled: true,
                fillColor: surfaceColor,
                hintText: 'አንባቢዎችን ይፈልጉ...',
                hintStyle: TextStyle(color: subtleTextColor),
                prefixIcon: Icon(Iconsax.search_normal, color: subtleTextColor),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white10)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white10))),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SwitchListTile(
            title: Text("ያልተጠናቀቁ መጻሕፍት ያላቸውን ብቻ አሳይ",
                style: TextStyle(color: onSurfaceColor)),
            value: _showOnlyUnfinished,
            onChanged: (val) {
              setState(() => _showOnlyUnfinished = val);
              _performFilter();
            },
            activeThumbColor: accentColor,
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchData,
            child: _filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.folder_open,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text("ለዚህ ማጣሪያ ምንም አንባቢዎች አልተገኙም።",
                            style: GoogleFonts.poppins(color: subtleTextColor)),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      final hasOverdue = user.overdueBooksCount > 0;
                      final heroTag = 'library-user-avatar-${user.id}';
                      return Card(
                        color: surfaceColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.white10)),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          onTap: () => _showReadingHistorySheet(user, heroTag),
                          leading: Hero(
                            tag: heroTag,
                            child: CircleAvatar(
                              child: ClipOval(
                                child: (user.profileImageUrl != null &&
                                        user.profileImageUrl!.isNotEmpty)
                                    ? Image.network(
                                        '${ApiService.baseUrl.replaceAll("/api", "")}/${user.profileImageUrl!}',
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) =>
                                            Text(
                                          user.fullName.isNotEmpty
                                              ? user.fullName[0]
                                              : '?',
                                        ),
                                      )
                                    : Text(user.fullName.isNotEmpty
                                        ? user.fullName[0]
                                        : '?'),
                              ),
                            ),
                          ),
                          title: Text(user.fullName,
                              style: GoogleFonts.notoSansEthiopic(
                                  fontWeight: FontWeight.w600,
                                  color: onSurfaceColor)),
                          subtitle: Text(
                            "${user.unfinishedBooksCount} መጽሐፍ(ቶች) በሂደት ላይ",
                            style: GoogleFonts.poppins(color: subtleTextColor),
                          ),
                          trailing: hasOverdue
                              ? Icon(Iconsax.warning_2, color: kLibDangerColor)
                              : const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.white54),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  // --- TAB 3: Assign Task ---
  Widget _buildAssignTaskTab({required bool isReadOnly}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: AbsorbPointer(
        absorbing: isReadOnly,
        child: Column(
          children: [
            if (isReadOnly)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.eye, color: Colors.amber.shade800),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'እርስዎ በማንበብ-ብቻ ሁነታ ላይ ነዎት። ለውጦችን ለማድረግ እራስዎን "የቤተ-መጽሐፍት አስተዳዳሪ" ሚና ይመድቡ።',
                        style:
                            GoogleFonts.poppins(color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            _buildStepCard(
              step: 1,
              title: "አንባቢ ይምረጡ",
              icon: Iconsax.user_search,
              content: _buildUserSelector(),
              isCompleted: _selectedUserForAssignment != null,
            ),
            _buildStepCard(
              step: 2,
              title: "የመጽሐፍ ዝርዝሮችን ያስገቡ",
              icon: Iconsax.book_1,
              content: _buildBookDetailsForm(),
              isCompleted:
                  _bookTitleController.text.isNotEmpty && _finishByDate != null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed:
                    _isSavingAssignment || isReadOnly ? null : _assignBook,
                style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                icon: _isSavingAssignment
                    ? const SizedBox.shrink()
                    : const Icon(Iconsax.send_1),
                label: _isSavingAssignment
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : Text("መጽሐፍ መድብ",
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets for Assign Task Tab ---
  Widget _buildStepCard(
      {required int step,
      required String title,
      required IconData icon,
      required Widget content,
      required bool isCompleted}) {
    return Card(
      elevation: 0,
      color: surfaceColor,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white10)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                backgroundColor: isCompleted ? kLibSuccessColor : accentColor,
                child: isCompleted
                    ? const Icon(Iconsax.tick_circle, color: Colors.white)
                    : Text("$step",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: accentColor)),
            ]),
            const Divider(height: 24),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildUserSelector() {
    return InkWell(
      onTap: _selectUserForAssignment,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10)),
        child: _selectedUserForAssignment == null
            ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Iconsax.user_add, color: Colors.grey),
                const SizedBox(width: 8),
                Text("ተጠቃሚ ለመምረጥ ይንኩ",
                    style: GoogleFonts.poppins(color: subtleTextColor)),
              ])
            : Row(children: [
                CircleAvatar(
                    backgroundImage: _selectedUserForAssignment!
                                    .profileImageUrl !=
                                null &&
                            _selectedUserForAssignment!
                                .profileImageUrl!.isNotEmpty
                        ? NetworkImage(
                            '${ApiService.baseUrl.replaceAll("/api", "")}/${_selectedUserForAssignment!.profileImageUrl!}')
                        : null,
                    child: _selectedUserForAssignment!.profileImageUrl ==
                                null ||
                            _selectedUserForAssignment!.profileImageUrl!.isEmpty
                        ? Text(_selectedUserForAssignment!.fullName.isNotEmpty
                            ? _selectedUserForAssignment!.fullName[0]
                            : '?')
                        : null),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(_selectedUserForAssignment!.fullName,
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w600))),
                const Icon(Iconsax.edit, color: Colors.amber),
              ]),
      ),
    );
  }

  Widget _buildBookDetailsForm() {
    return Column(children: [
      TextField(
        controller: _bookTitleController,
        decoration: InputDecoration(
            labelText: "የመጽሐፍ ርዕስ",
            labelStyle: TextStyle(color: subtleTextColor),
            filled: true,
            fillColor: surfaceColor,
            prefixIcon: const Icon(Iconsax.text, color: Colors.grey),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white10)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white10))),
        onChanged: (value) => setState(() {}),
      ),
      const SizedBox(height: 16),
      InkWell(
        onTap: _selectFinishDate,
        child: InputDecorator(
          decoration: InputDecoration(
              labelText: "የመጨረሻ ቀን",
              labelStyle: TextStyle(color: subtleTextColor),
              filled: true,
              fillColor: surfaceColor,
              prefixIcon: const Icon(Iconsax.calendar_1, color: Colors.grey),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white10)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white10))),
          child: Text(
            _finishByDate == null
                ? "ቀን ይምረጡ"
                : DateFormat.yMMMd().format(_finishByDate!),
            style: GoogleFonts.poppins(
                fontSize: 16,
                color: _finishByDate == null ? subtleTextColor : accentColor),
          ),
        ),
      ),
    ]);
  }
}

// #########################################################################
// HELPER WIDGETS (Bottom Sheets, etc.)
// #########################################################################

class _UserSelectionSheet extends StatefulWidget {
  final List<LibraryUser> users;
  const _UserSelectionSheet({required this.users});

  @override
  State<_UserSelectionSheet> createState() => _UserSelectionSheetState();
}

class _UserSelectionSheetState extends State<_UserSelectionSheet> {
  List<LibraryUser> _filteredUsers = [];
  final _searchController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _filteredUsers = widget.users;
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredUsers = widget.users
            .where((u) => u.fullName.toLowerCase().contains(query))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 16),
                Text("አንባቢ ይምረጡ",
                    style: GoogleFonts.poppins(
                        color: onSurfaceColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                        hintText: "በስም ይፈልጉ...",
                        hintStyle: TextStyle(color: subtleTextColor),
                        filled: true,
                        fillColor: surfaceColor,
                        prefixIcon:
                            Icon(Iconsax.search_normal, color: subtleTextColor),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white10)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white10)))),
              ])),
          Expanded(
              child: ListView.builder(
            controller: controller,
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              return ListTile(
                leading: CircleAvatar(
                    backgroundImage: user.profileImageUrl != null &&
                            user.profileImageUrl!.isNotEmpty
                        ? NetworkImage(
                            '${ApiService.baseUrl.replaceAll("/api", "")}/${user.profileImageUrl!}')
                        : null,
                    child: user.profileImageUrl == null ||
                            user.profileImageUrl!.isEmpty
                        ? Text(
                            user.fullName.isNotEmpty ? user.fullName[0] : '?')
                        : null),
                title: Text(user.fullName,
                    style: GoogleFonts.notoSansEthiopic(
                        fontWeight: FontWeight.w600, color: onSurfaceColor)),
                subtitle: Text(user.spiritualClass ?? 'ክፍል የለውም',
                    style: GoogleFonts.notoSansEthiopic(color: onSurfaceColor)),
                onTap: () => Navigator.of(context).pop(user),
              );
            },
          )),
        ]),
      ),
    );
  }
}

class _ReadingHistorySheet extends StatefulWidget {
  final LibraryUser user;
  final String heroTag;
  const _ReadingHistorySheet({required this.user, required this.heroTag});

  @override
  State<_ReadingHistorySheet> createState() => _ReadingHistorySheetState();
}

class _ReadingHistorySheetState extends State<_ReadingHistorySheet>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Future<List<ReadingHistoryItem>>? _historyFuture;

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
  Color get kLibDangerColor => const Color(0xFFEF4444);
  Color get kLibSuccessColor => const Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _historyFuture = _fetchHistory();
  }

  Future<List<ReadingHistoryItem>> _fetchHistory() async {
    final result = await LibraryService.getReadingHistory(widget.user.id);
    if (mounted && result['success']) {
      return (result['data'] as List)
          .map((item) => ReadingHistoryItem.fromJson(item))
          .toList();
    } else {
      throw Exception(result['message'] ?? 'ታሪክን መጫን አልተቻለም');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 16),
                Hero(
                  tag: widget.heroTag,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                          backgroundImage: widget.user.profileImageUrl !=
                                      null &&
                                  widget.user.profileImageUrl!.isNotEmpty
                              ? NetworkImage(
                                  '${ApiService.baseUrl.replaceAll("/api", "")}/${widget.user.profileImageUrl!}')
                              : null,
                          child: widget.user.profileImageUrl == null ||
                                  widget.user.profileImageUrl!.isEmpty
                              ? Text(widget.user.fullName.isNotEmpty
                                  ? widget.user.fullName[0]
                                  : '?')
                              : null),
                      const SizedBox(width: 12),
                      Material(
                        color: Colors.transparent,
                        child: Text(widget.user.fullName,
                            style: GoogleFonts.notoSansEthiopic(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabController,
                  labelColor: accentColor,
                  unselectedLabelColor: subtleTextColor,
                  indicatorColor: accentColor,
                  tabs: const [
                    Tab(text: 'በሂደት ላይ'),
                    Tab(text: 'የተጠናቀቁ'),
                    Tab(text: 'ያለፉ')
                  ],
                ),
              ])),
          Expanded(
            child: FutureBuilder<List<ReadingHistoryItem>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: accentColor));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("ስህተት: ${snapshot.error}"));
                }
                final history = snapshot.data ?? [];
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHistoryList(
                        history
                            .where((h) =>
                                h.status == 'in_progress' ||
                                h.status == 'overdue')
                            .toList(),
                        controller),
                    _buildHistoryList(
                        history.where((h) => h.status == 'completed').toList(),
                        controller),
                    _buildHistoryList(
                        history.where((h) => h.status == 'overdue').toList(),
                        controller),
                  ],
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildHistoryList(
      List<ReadingHistoryItem> items, ScrollController controller) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.book_1, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text("በዚህ ምድብ ውስጥ ምንም መጽሐፍት የሉም።",
                style: GoogleFonts.poppins(color: subtleTextColor)),
          ],
        ),
      );
    }
    return ListView.builder(
      controller: controller,
      itemCount: items.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final item = items[index];
        IconData icon;
        Color color;
        switch (item.status) {
          case 'in_progress':
            icon = Iconsax.book_1;
            color = accentColor;
            break;
          case 'completed':
            icon = Iconsax.task_square;
            color = kLibSuccessColor;
            break;
          case 'overdue':
            icon = Iconsax.warning_2;
            color = kLibDangerColor;
            break;
          default:
            icon = Iconsax.book;
            color = subtleTextColor;
        }
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(icon, color: color),
            title: Text(item.bookTitle,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: item.finishBy != null
                ? Text("መመለሻ ቀን: ${DateFormat.yMMMd().format(item.finishBy!)}",
                    style: TextStyle(
                        color: item.status == 'overdue'
                            ? kLibDangerColor
                            : subtleTextColor))
                : null,
          ),
        );
      },
    );
  }
}
