import 'package:amde_haymanot_abalat_guday/services/grade_service.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/uploadpp.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:amde_haymanot_abalat_guday/providers/profile_config_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:amde_haymanot_abalat_guday/services/auth_service.dart';
import 'package:amde_haymanot_abalat_guday/services/profile_service.dart';
import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/edit_profile_sheet.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/homepage.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/user_attendance_history.dart';

// --- EXACT COLOR PALETTE FROM ORIGINAL SCREENSHOTS ---
const Color kPrimaryColor = Color(0xFF050511); // The "Blueish" Dark Black
const Color kCardColor = Color(0xFF151522); // The matching card color
const Color kGoldColor = Color(0xFFFFC107); // Amber/Gold
const Color kRedError = Color(0xFFE53935);
const Color kTextGrey = Colors.white54;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  Future<dynamic>? _attendanceFuture;
  Future<dynamic>? _gradesFuture;
  Future<dynamic>? _booksFuture;

  int _readingTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_attendanceFuture == null) {
      _initializeFutures();
    }
  }

  void _initializeFutures() {
    setState(() {
      _attendanceFuture = ProfileService.getMyAttendance();
      _gradesFuture = ProfileService.getMyGrades();
      _booksFuture = ProfileService.getMyBooks();
    });
  }

  Future<void> _refreshAllData() async {
    final userProvider = context.read<UserProvider>();
    final profileConfig = context.read<ProfileConfigProvider>();

    await userProvider.refreshProfile();
    await profileConfig.fetchConfig();
    _initializeFutures();
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null || !mounted) return;
    final result = await ProfileUploadService.uploadAvatar(image);
    if (mounted && result['success'] == true) {
      context.read<UserProvider>().updateAvatar(result['data']['filename']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profileConfig = context.watch<ProfileConfigProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final profile = userProvider.userProfile;

    // Theme colors
    final bgColor = themeProvider.getBackgroundColor(context);
    final surfaceColor = themeProvider.getSurfaceColor(context);
    final primaryColor = themeProvider.getPrimaryColor(context);
    final textColor = themeProvider.getOnSurfaceColor(context);
    final subtleText = themeProvider.getSubtleTextColor(context);
    final isDark = themeProvider.isDarkMode(context);

    if (userProvider.isLoading || profile == null) {
      return Scaffold(
          backgroundColor: bgColor,
          body: Center(child: CircularProgressIndicator(color: primaryColor)));
    }

    developer.log("DEBUG ProfileScreen: Profile Keys: ${profile.keys.toList()}",
        name: 'ProfileScreen');
    // Custom field debugging
    for (var f in profileConfig.customFields) {
      if (f is Map) {
        final name = f['name'];
        developer.log(
            "DEBUG ProfileScreen: Checking custom field '$name' -> ${profile[name]}",
            name: 'ProfileScreen');
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      // Drawer removed - already provided by parent HomeScreen
      appBar: AppBar(
        title: const Text(""), // Empty title
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.sort,
              color: primaryColor, size: 28), // Hamburger style
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Iconsax.sun_1 : Iconsax.moon,
              color: primaryColor,
              size: 24,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAllData,
        color: primaryColor,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // 1. The Header (Avatar, Name) - Scrolled freely
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildHeader(profile, userProvider.avatarUrl,
                      primaryColor, surfaceColor, textColor, subtleText),
                ),
              ),
              // 2. The Pins (TabBar) - Correctly Pinned
              SliverAppBar(
                backgroundColor: bgColor,
                automaticallyImplyLeading: false,
                pinned: true,
                primary: false,
                toolbarHeight: 0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(75),
                  child: Container(
                    color: bgColor,
                    width: double.infinity,
                    alignment: Alignment
                        .centerLeft, // Align tabs to left like screenshot? Or center? Screenshot shows centered.
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: primaryColor,
                      unselectedLabelColor: subtleText,
                      indicatorColor: primaryColor,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize
                          .label, // Matches screenshot small underline
                      labelStyle: GoogleFonts.notoSansEthiopic(
                          fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: const [
                        Tab(
                            text: "ሁኔታ",
                            icon: Icon(Iconsax.chart_2,
                                size: 20)), // Matches 'Status' bar chart
                        Tab(text: "የግል", icon: Icon(Iconsax.user, size: 20)),
                        Tab(
                            text: "መንፈሳዊ",
                            icon: Icon(Iconsax.teacher, size: 20)),
                        Tab(
                            text: "ትምህርት እና ቤተሰብ",
                            icon: Icon(Iconsax.book, size: 20)),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildStatusTab(profile, primaryColor, surfaceColor, textColor,
                  subtleText, isDark),
              _buildPersonalTab(profile, profileConfig, primaryColor,
                  surfaceColor, textColor, subtleText, isDark),
              _buildSpiritualTab(profile, profileConfig, primaryColor,
                  surfaceColor, textColor, subtleText, isDark),
              _buildEducationTab(profile, profileConfig, primaryColor,
                  surfaceColor, textColor, subtleText, isDark),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (c) => const UserEditProfileScreen())
            .then((_) => _refreshAllData()),
        backgroundColor: primaryColor,
        child: Icon(Icons.edit, color: isDark ? Colors.black : Colors.white),
      ),
    );
  }

  Widget _buildHeader(
      Map<String, dynamic> profile,
      String? avatarUrl,
      Color primaryColor,
      Color surfaceColor,
      Color textColor,
      Color subtleText) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer Ring
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: primaryColor.withValues(alpha: 0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                      color: primaryColor.withValues(alpha: 0.1),
                      blurRadius: 20)
                ],
              ),
            ),
            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: surfaceColor,
              backgroundImage: (avatarUrl != null)
                  ? CachedNetworkImageProvider(avatarUrl)
                  : null,
              child: (avatarUrl == null)
                  ? Text((profile['full_name'] ?? 'U')[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                          fontSize: 36, color: primaryColor))
                  : null,
            ),
            // Camera
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickAndUploadImage,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: primaryColor, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.black, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(profile['full_name'] ?? 'ስም የለም',
            style: GoogleFonts.notoSansEthiopic(
                color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(profile['email'] ?? '',
            style: GoogleFonts.poppins(color: subtleText, fontSize: 13)),
      ],
    );
  }

  // --- TAB CONTENT ---

  Widget _buildStatusTab(Map<String, dynamic> profile, Color primaryColor,
      Color surfaceColor, Color textColor, Color subtleText, bool isDark) {
    bool inService = profile['service_sector'] != null;
    return ListView(
      primary: false, // Fix ScrollController conflict
      key: const PageStorageKey('status_tab'),
      padding: const EdgeInsets.all(16),
      children: [
        // Status Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: isDark ? Colors.white10 : Colors.black12)),
          child: Column(
            children: [
              Text("የአገልግሎት ሁኔታ",
                  style: GoogleFonts.notoSansEthiopic(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              inService
                  ? const Icon(Icons.check_circle,
                      color: Colors.green, size: 40)
                  : Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: kRedError, width: 2)),
                      child:
                          const Icon(Icons.close, color: kRedError, size: 30),
                    ),
              const SizedBox(height: 16),
              Text(
                  inService
                      ? (profile['service_sector']?.toString() ?? "Active")
                      : "አገልግሎት ላይ ያልሆነ",
                  style: GoogleFonts.notoSansEthiopic(
                      color: inService ? Colors.green : kRedError,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("ይህ ሁኔታ የሚተዳደረው በስተዳደር ነው::",
                  style: GoogleFonts.notoSansEthiopic(
                      color: subtleText, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Attendance Card
        FutureBuilder<dynamic>(
          future: _attendanceFuture,
          builder: (context, snapshot) {
            int present = 0;
            int absent = 0;
            double percent = 0;
            if (snapshot.hasData &&
                snapshot.data is Map &&
                snapshot.data['success'] == true) {
              final l = snapshot.data['data'];
              if (l is List) {
                present = l
                    .where((i) =>
                        i['status']?.toString().toLowerCase() == 'present')
                    .length;
                absent = l
                    .where((i) =>
                        i['status']?.toString().toLowerCase() == 'absent')
                    .length;
                if (l.isNotEmpty) percent = present / l.length;
              }
            }

            return GestureDetector(
              onTap: () {
                // Navigate to user attendance history screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserAttendanceHistoryScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("የመገኘት ማጠቃለያ",
                            style: GoogleFonts.notoSansEthiopic(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Icon(Icons.arrow_forward_ios,
                            color: subtleText, size: 14)
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularPercentIndicator(
                          radius: 45,
                          lineWidth: 8,
                          percent: percent.clamp(0.0, 1.0),
                          center: Text("${(percent * 100).toInt()}%",
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold)),
                          progressColor: primaryColor,
                          backgroundColor: const Color(0xFF252535),
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        const SizedBox(width: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _legendRow(Icons.person, "ተገኝቷል: $present",
                                Colors.green, subtleText),
                            const SizedBox(height: 10),
                            _legendRow(Icons.person_off, "ቀርቷል: $absent",
                                kRedError, subtleText),
                            const SizedBox(height: 10),
                            _legendRow(Icons.calendar_today, "አስፈቅዷል: 0",
                                kGoldColor, subtleText),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text("ዝርዝር ታሪክን ለማየት ይጫኑ",
                        style: GoogleFonts.notoSansEthiopic(
                            color: primaryColor, fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildReadingHistoryCard(
            primaryColor, surfaceColor, textColor, subtleText),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _legendRow(IconData icon, String text, Color color, Color textColor) {
    return Row(children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 8),
      Text(text,
          style: GoogleFonts.notoSansEthiopic(color: textColor, fontSize: 13))
    ]);
  }

  // --- LIST TABS ---

  Widget _buildPersonalTab(
      Map<String, dynamic> profile,
      ProfileConfigProvider profileConfig,
      Color primaryColor,
      Color surfaceColor,
      Color textColor,
      Color subtleText,
      bool isDark) {
    // Build list of rows dynamically
    final List<Widget> rows = [];

    // Standard fields
    final standardFields = [
      {'icon': Iconsax.heart, 'label': 'የክርስትና ስም', 'key': 'christian_name'},
      {'icon': Iconsax.user_square, 'label': 'የእናት ስም', 'key': 'mother_name'},
      {'icon': Iconsax.call, 'label': 'ስልክ ቁጥር', 'key': 'phone_number'},
      {'icon': Icons.cake_outlined, 'label': 'ዕድሜ', 'key': 'age'},
      {'icon': Icons.date_range_outlined, 'label': 'የትውልድ ቀን', 'key': 'dob'},
      {'icon': Icons.male, 'label': 'ጾታ', 'key': 'gender'},
    ];

    for (var field in standardFields) {
      if (rows.isNotEmpty) rows.add(_buildDivider());
      dynamic val = profile[field['key']];

      // Special handling for Birthday (DOB)
      if (field['key'] == 'dob' && val != null) {
        val = _formatBirthday(val.toString());
      }

      rows.add(_buildDetailRow(field['icon'] as IconData,
          field['label'] as String, val, primaryColor, subtleText, textColor));
    }

    // Add custom fields from config
    final personalFields = profileConfig.customFields
        .where((f) =>
            f is Map &&
            f['profile_tab']?.toString().toUpperCase() == 'PERSONAL')
        .toList();

    for (var field in personalFields) {
      if (rows.isNotEmpty) rows.add(_buildDivider());
      final fieldMap = field as Map<String, dynamic>;
      final val = _getCustomFieldValue(profile, fieldMap);
      rows.add(_buildDetailRow(
          Icons.info_outline,
          fieldMap['name']?.toString() ?? 'Custom Field',
          val,
          primaryColor,
          subtleText,
          textColor));
    }

    return ListView(
      primary: false, // Fix ScrollController conflict
      key: const PageStorageKey('personal_tab'),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: isDark ? Colors.white10 : Colors.black12)),
          child: Column(children: rows),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSpiritualTab(
      Map<String, dynamic> profile,
      ProfileConfigProvider profileConfig,
      Color primaryColor,
      Color surfaceColor,
      Color textColor,
      Color subtleText,
      bool isDark) {
    List<Widget> rows = [];

    if (profileConfig.isWidgetVisible('confession_father_name')) {
      rows.add(_buildDetailRow(
          Iconsax.user_square,
          "የንስሃ አባት ስም",
          profile['confession_father_name'],
          primaryColor,
          subtleText,
          textColor));
      rows.add(_buildDivider());
    }

    if (profileConfig.isWidgetVisible('spiritual_class')) {
      rows.add(_buildDetailRow(Iconsax.teacher, "የመንፈሳዊ ትምህርት ክፍል",
          profile['spiritual_class'], primaryColor, subtleText, textColor));
    }

    if (profileConfig.isWidgetVisible('kifil')) {
      if (rows.isNotEmpty) rows.add(_buildDivider());
      rows.add(_buildDetailRow(Iconsax.people, "ክፍል", profile['kifil'],
          primaryColor, subtleText, textColor));
    }

    // Add custom fields from config
    final spiritualFields = profileConfig.customFields
        .where((f) =>
            f is Map &&
            f['profile_tab']?.toString().toUpperCase() == 'SPIRITUAL')
        .toList();
    for (var field in spiritualFields) {
      if (rows.isNotEmpty) rows.add(_buildDivider());
      final fieldMap = field as Map<String, dynamic>;
      final val = _getCustomFieldValue(profile, fieldMap);
      rows.add(_buildDetailRow(
          Icons.info_outline,
          fieldMap['name']?.toString() ?? 'Custom Field',
          val,
          primaryColor,
          subtleText,
          textColor));
    }

    return ListView(
      primary: false, // Fix ScrollController conflict
      key: const PageStorageKey('spiritual_tab'),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: isDark ? Colors.white10 : Colors.black12)),
          child: Column(children: rows),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  String? _getCustomFieldValue(
      Map<String, dynamic> profile, Map<String, dynamic> fieldMap) {
    final name = fieldMap['name']?.toString();
    if (name == null) return null;

    // 1. Try direct lookup (if merged)
    if (profile.containsKey(name) && profile[name] != null) {
      return profile[name]?.toString();
    }

    // 2. Try looking in custom_fields_detail list (fallback)
    if (profile['custom_fields_detail'] is List) {
      final details = profile['custom_fields_detail'] as List;
      final match = details.firstWhere(
          (d) => d is Map && d['field_name'] == name,
          orElse: () => null);
      if (match != null) {
        return match['field_value']?.toString();
      }
    }

    return null;
  }

  // State for filtering
  String? _selectedSpiritualClass;
  int? _selectedYear;
  bool _initialFilterSet = false;

  final List<String> _spiritualClasses = [
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

  List<int> _getYearOptions() {
    // Current Ethiopian Year approximation (based on logs seeing 2018)
    final current = 2018;
    return List.generate(10, (i) => current - i);
  }

  void _updateGradesFilter() {
    setState(() {
      _gradesFuture = GradeService.getMyGrades(
          spiritualClassOverride: _selectedSpiritualClass,
          yearOverride: _selectedYear);
    });
  }

  Widget _buildEducationTab(
      Map<String, dynamic> profile,
      ProfileConfigProvider config,
      Color primaryColor,
      Color surfaceColor,
      Color textColor,
      Color subtleText,
      bool isDark) {
    // Initialize filters once from profile data
    if (!_initialFilterSet) {
      if (profile['spiritual_class'] != null) {
        _selectedSpiritualClass = profile['spiritual_class'];
      }
      _selectedYear = 2018; // Default
      _initialFilterSet = true;
    }

    return ListView(
      primary: false, // Fix ScrollController conflict
      key: const PageStorageKey('education_tab'),
      padding: const EdgeInsets.all(16),
      children: [
        // Filter Section
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: isDark ? Colors.white10 : Colors.black12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("ማጣሪያ (Filter)",
                  style: GoogleFonts.notoSansEthiopic(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      initialValue:
                          _spiritualClasses.contains(_selectedSpiritualClass)
                              ? _selectedSpiritualClass
                              : null,
                      dropdownColor: surfaceColor,
                      style: GoogleFonts.notoSansEthiopic(
                          color: textColor, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: "ክፍል",
                        labelStyle: TextStyle(color: subtleText, fontSize: 12),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    isDark ? Colors.white24 : Colors.black12),
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      items: _spiritualClasses
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        _selectedSpiritualClass = val;
                        _updateGradesFilter();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<int>(
                      initialValue: _selectedYear,
                      dropdownColor: surfaceColor,
                      style: GoogleFonts.notoSansEthiopic(
                          color: textColor, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: "ዓመት",
                        labelStyle: TextStyle(color: subtleText, fontSize: 12),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    isDark ? Colors.white24 : Colors.black12),
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      items: _getYearOptions()
                          .map((y) => DropdownMenuItem(
                              value: y, child: Text(y.toString())))
                          .toList(),
                      onChanged: (val) {
                        _selectedYear = val;
                        _updateGradesFilter();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        FutureBuilder<dynamic>(
          future: _gradesFuture,
          builder: (context, snapshot) {
            // Handle Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(color: primaryColor));
            }

            List<Map<String, dynamic>> courses = [];
            bool hasError = false;

            if (snapshot.hasData) {
              final data = snapshot.data;
              if (data['success'] == false) {
                hasError = true;
              } else {
                try {
                  final d = data['data'];
                  if (d is Map) {
                    d.forEach((k, v) {
                      if (v is List) {
                        courses.addAll(List<Map<String, dynamic>>.from(v));
                      }
                    });
                  } else if (d is List) {
                    courses = List<Map<String, dynamic>>.from(d);
                  }
                } catch (e) {
                  developer.log("Error parsing grades: $e",
                      name: 'ProfileScreen', error: e);
                }
              }
            }

            if (courses.isNotEmpty) {
              developer.log(
                  "DEBUG ProfileScreen: First Course Structure: ${courses[0]}",
                  name: 'ProfileScreen');
            }

            if (courses.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10)),
                child: Column(
                  children: [
                    Icon(Iconsax.book, size: 40, color: subtleText),
                    const SizedBox(height: 10),
                    Text(
                      hasError
                          ? "ውጤት አልተገኘም ወይም ይህ ተጠቃሚ ተማሪ አይደለም"
                          : "ምንም ውጤት የለም",
                      style: GoogleFonts.notoSansEthiopic(color: subtleText),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10)),
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("የውጤት ዝርዝር",
                              style: GoogleFonts.notoSansEthiopic(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)))),
                  ...courses.map((c) => _buildCourseItem(
                      c, primaryColor, textColor, subtleText, isDark))
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10)),
          child: Column(
            children: [
              _buildDetailRow(
                  Iconsax.ruler,
                  "የትምህርት ደረጃ",
                  profile['academic_level'],
                  primaryColor,
                  subtleText,
                  textColor),
              _buildDivider(),
              _buildDetailRow(Iconsax.user_tick, "የወላጅ ስም",
                  profile['parent_name'], primaryColor, subtleText, textColor),
              _buildDivider(),
              _buildDetailRow(
                  Iconsax.call,
                  "የወላጅ ስልክ",
                  profile['parent_phone_number'],
                  primaryColor,
                  subtleText,
                  textColor),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildCourseItem(Map<String, dynamic> c, Color primaryColor,
      Color textColor, Color subtleText, bool isDark) {
    double score = 0;
    try {
      if (c['total'] != null) {
        score = double.parse(c['total'].toString());
      } else if (c['score'] != null) {
        score = double.parse(c['score'].toString());
      }
    } catch (e) {
      developer.log("Error parsing course score: $e",
          name: 'ProfileScreen', error: e);
    }

    // Backend returns 'scores' list for assessments, but we support 'assessments' too just in case
    final assessments = (c['scores'] ?? c['assessments']) is List
        ? (c['scores'] ?? c['assessments']) as List
        : [];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey('course_${c['course_id'] ?? c['course_name']}'),
          initiallyExpanded: false,
          iconColor: primaryColor,
          collapsedIconColor: subtleText,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(Iconsax.book_1, color: primaryColor, size: 20),
          ),
          title: Text(
            c['course_name']?.toString() ?? '-',
            style: GoogleFonts.notoSansEthiopic(
                color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          subtitle: assessments.isEmpty
              ? Text("No grades yet",
                  style: TextStyle(color: subtleText, fontSize: 11))
              : Text("${assessments.length} assessments",
                  style: TextStyle(color: subtleText, fontSize: 11)),
          children: [
            if (assessments.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text("ምንም የፈተና ውጤት አልገባም",
                    style: TextStyle(
                        color: subtleText, fontStyle: FontStyle.italic)),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("የፈተና ዓይነት (Assessment)",
                            style: TextStyle(
                                color: subtleText,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                        Text("ውጤት (Score)",
                            style: TextStyle(
                                color: subtleText,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Divider(
                        color: isDark ? Colors.white12 : Colors.black12,
                        height: 20),
                    // List
                    ...assessments.map((a) {
                      final aName = a['assessment_name'] ?? a['name'] ?? '-';
                      final aScore = a['score'] ?? 0;
                      final aMax = a['max_score'] ?? a['total'] ?? 100;

                      // Decide how to show score
                      final scoreText =
                          (a['max_score'] != null || a['total'] != null)
                              ? "$aScore / $aMax"
                              : "$aScore";

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(aName,
                                  style: GoogleFonts.notoSansEthiopic(
                                      color: textColor.withValues(alpha: 0.9),
                                      fontSize: 13)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(scoreText,
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 13,
                                      fontFamily: 'Courier')),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(color: Colors.white24, height: 32),
                    // Summary Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("ጠቅላላ ውጤት",
                                style: GoogleFonts.notoSansEthiopic(
                                    color: Colors.white70, fontSize: 12)),
                            Text("Total Score",
                                style: GoogleFonts.poppins(
                                    color: subtleText, fontSize: 10)),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              score.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                  color: primaryColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text("%",
                                style: GoogleFonts.poppins(
                                    color: primaryColor.withValues(alpha: 0.7),
                                    fontSize: 14)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildDetailRow(IconData icon, String label, dynamic value,
      Color primaryColor, Color subtleText, Color textColor,
      {bool isGold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3))),
            child: Icon(icon, color: primaryColor, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Text(label,
                  style: GoogleFonts.notoSansEthiopic(
                      color: subtleText, fontSize: 13))),
          Text(value?.toString() ?? '-',
              style: GoogleFonts.notoSansEthiopic(
                  color: isGold ? primaryColor : textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
        height: 1,
        thickness: 1,
        color: Colors.white.withValues(alpha: 0.05),
        indent: 16,
        endIndent: 16);
  }

  Widget _buildReadingHistoryCard(Color primaryColor, Color surfaceColor,
      Color textColor, Color subtleText) {
    return FutureBuilder<dynamic>(
      future: _booksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 100, child: Center(child: CircularProgressIndicator()));
        }

        final data = snapshot.data;
        List<dynamic> allBooks = [];
        if (data is Map && data['success'] == true) {
          allBooks = data['data'] ?? [];
        } else if (data is List) {
          allBooks = data;
        }

        final toRead = allBooks.where((b) {
          final r = b['is_read'];
          return r != true && r != 1 && r != '1';
        }).toList();
        final read = allBooks.where((b) {
          final r = b['is_read'];
          return r == true || r == 1 || r == '1';
        }).toList();

        final currentList = _readingTab == 0 ? toRead : read;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10)),
          child: Column(
            children: [
              // Header & Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("ቤተ-መጽሐፍት",
                      style: GoogleFonts.notoSansEthiopic(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        _buildTabButton("የሚነበብ", 0, toRead.length, primaryColor,
                            textColor, subtleText),
                        _buildTabButton("የተነበበ", 1, read.length, primaryColor,
                            textColor, subtleText),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),

              if (currentList.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    _readingTab == 0
                        ? "ምንም የሚነበብ መጽሐፍ የለም"
                        : "እስካሁን ያነበቡት መጽሐፍ የለም",
                    style: GoogleFonts.notoSansEthiopic(color: subtleText),
                  ),
                )
              else
                ...currentList.map((book) {
                  final title =
                      book['title'] ?? book['bookTitle'] ?? 'Unknown Title';
                  final deadlineRaw = book['deadline'] ?? book['finishBy'];
                  final id = book['id']?.toString() ??
                      book['assignedBookId']?.toString();
                  String deadlineStr = "";

                  if (deadlineRaw != null) {
                    try {
                      final dt = DateTime.parse(deadlineRaw.toString());
                      final now = DateTime.now();
                      final diff = dt.difference(now).inDays;
                      deadlineStr =
                          "${dt.day}/${dt.month}/${dt.year} (${diff > 0 ? '$diff ቀናት ቀርተዋል' : 'ጊዜው አልፏል'})";
                    } catch (e) {
                      deadlineStr = deadlineRaw.toString();
                    }
                  }

                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: _readingTab ==
                                    1, // Checked if in 'Read' tab
                                activeColor: Colors.green,
                                side: BorderSide(color: primaryColor, width: 2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) async {
                                  if (id == null) return;
                                  // Optimistic toggle? Or just strict 'mark as read'
                                  // If in "To Read" (0), val becomes true -> Move to Read
                                  // If in "Read" (1), val becomes false -> Move back to To Read
                                  bool newStatus = val == true;
                                  if (_readingTab == 1 && val == false) {
                                    newStatus = false;
                                  } else if (_readingTab == 0 && val == true) {
                                    newStatus = true;
                                  } else {
                                    return; // No change logic needed
                                  }

                                  // Disable UI or show loader? Simple async update.
                                  await ProfileService.updateBookStatus(
                                      id, newStatus);
                                  _initializeFutures(); // Refresh data
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title,
                                      style: GoogleFonts.notoSansEthiopic(
                                          color: textColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  const SizedBox(height: 4),
                                  if (_readingTab == 0 &&
                                      deadlineStr.isNotEmpty)
                                    Text("የማጠናቀቂያ ጊዜ: $deadlineStr",
                                        style: GoogleFonts.notoSansEthiopic(
                                            color: primaryColor, fontSize: 12)),
                                  if (_readingTab == 1)
                                    Text("ተነብቦ ተረጋግጧል",
                                        style: GoogleFonts.notoSansEthiopic(
                                            color: Colors.green, fontSize: 12))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      if (book != currentList.last)
                        Divider(
                            color: Colors.white.withValues(alpha: 0.05),
                            height: 1),
                    ],
                  );
                })
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabButton(String text, int index, int count, Color primaryColor,
      Color textColor, Color subtleText) {
    final bool isSelected = _readingTab == index;
    return GestureDetector(
      onTap: () => setState(() => _readingTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          "$text ($count)",
          style: GoogleFonts.notoSansEthiopic(
            color: isSelected ? Colors.black : subtleText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  String _formatBirthday(String dobStr) {
    if (dobStr.isEmpty) return '-';
    try {
      final dt = DateTime.tryParse(dobStr);
      if (dt == null) return dobStr;

      // If it's the \"1899\" default or something clearly invalid, hide it
      if (dt.year < 1920) return '-';

      final etDate = EthiopianDate.fromGregorian(dt);
      return etDate.toString();
    } catch (e) {
      return dobStr;
    }
  }
}
