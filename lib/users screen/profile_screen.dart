import 'dart:ui';
import 'package:amde_haymanot_abalat_guday/providers/profile_config_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/profile_service.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/edit_profile_sheet.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/uploadpp.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

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
    });
  }

  Future<void> _refreshAllData() async {
    await context.read<UserProvider>().refreshProfile();
    await context.read<ProfileConfigProvider>().fetchConfig();
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
    final profile = userProvider.userProfile;

    if (userProvider.isLoading || profile == null) {
      return const Scaffold(
          backgroundColor: kPrimaryColor,
          body: Center(child: CircularProgressIndicator(color: kGoldColor)));
    }

    return Scaffold(
      backgroundColor: kPrimaryColor,
      appBar: AppBar(
        title: const Text(""), // Empty title
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.sort,
                color: kGoldColor, size: 28), // Hamburger style
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.transparent, // Or transparent
              child: const Icon(Iconsax.notification,
                  color: Colors.white, size: 24),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAllData,
        color: kGoldColor,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // 1. The Header (Avatar, Name) - Scrolled freely
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildHeader(profile, userProvider.avatarUrl),
                ),
              ),
              // 2. The Pins (TabBar) - Correctly Pinned
              SliverAppBar(
                backgroundColor: kPrimaryColor,
                automaticallyImplyLeading: false,
                pinned: true,
                primary: false,
                toolbarHeight: 0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(75),
                  child: Container(
                    color: kPrimaryColor,
                    width: double.infinity,
                    alignment: Alignment
                        .centerLeft, // Align tabs to left like screenshot? Or center? Screenshot shows centered.
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: kGoldColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: kGoldColor,
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
              _buildStatusTab(profile),
              _buildPersonalTab(profile, profileConfig),
              _buildSpiritualTab(profile, profileConfig),
              _buildEducationTab(profile, profileConfig),
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
        backgroundColor: kGoldColor,
        child: const Icon(Icons.edit, color: Colors.black),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> profile, String? avatarUrl) {
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
                border:
                    Border.all(color: kGoldColor.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(color: kGoldColor.withOpacity(0.1), blurRadius: 20)
                ],
              ),
            ),
            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: kCardColor,
              backgroundImage: (avatarUrl != null)
                  ? CachedNetworkImageProvider(avatarUrl)
                  : null,
              child: (avatarUrl == null)
                  ? Text((profile['full_name'] ?? 'U')[0].toUpperCase(),
                      style:
                          GoogleFonts.poppins(fontSize: 36, color: kGoldColor))
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
                  decoration: const BoxDecoration(
                      color: kGoldColor, shape: BoxShape.circle),
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
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(profile['email'] ?? '',
            style: GoogleFonts.poppins(color: kTextGrey, fontSize: 13)),
      ],
    );
  }

  // --- TAB CONTENT ---

  Widget _buildStatusTab(Map<String, dynamic> profile) {
    bool inService = profile['service_sector'] != null;
    return ListView(
      key: const PageStorageKey('status_tab'),
      padding: const EdgeInsets.all(16),
      children: [
        // Status Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10)),
          child: Column(
            children: [
              Text("የአገልግሎት ሁኔታ",
                  style: GoogleFonts.notoSansEthiopic(
                      color: Colors.white,
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
                      color: kTextGrey, fontSize: 12)),
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

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("የመገኘት ማጠቃለያ",
                          style: GoogleFonts.notoSansEthiopic(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white54, size: 14)
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
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        progressColor: kGoldColor,
                        backgroundColor: const Color(0xFF252535),
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                      const SizedBox(width: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _legendRow(
                              Icons.person, "ተገኝቷል: $present", Colors.green),
                          const SizedBox(height: 10),
                          _legendRow(
                              Icons.person_off, "ቀርቷል: $absent", kRedError),
                          const SizedBox(height: 10),
                          _legendRow(
                              Icons.calendar_today, "አስፈቅዷል: 0", kGoldColor),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text("ዝርዝር ታሪክን ለማየት ይጫኑ",
                      style: GoogleFonts.notoSansEthiopic(
                          color: kGoldColor, fontSize: 12)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _legendRow(IconData icon, String text, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 8),
      Text(text,
          style:
              GoogleFonts.notoSansEthiopic(color: Colors.white70, fontSize: 13))
    ]);
  }

  // --- LIST TABS ---

  Widget _buildPersonalTab(
      Map<String, dynamic> profile, ProfileConfigProvider config) {
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
      rows.add(_buildDetailRow(field['icon'] as IconData,
          field['label'] as String, profile[field['key']]));
    }

    // Add custom fields from config
    final personalFields = config.customFields
        .where((f) => f is Map && f['category'] == 'personal')
        .toList();
    for (var field in personalFields) {
      if (rows.isNotEmpty) rows.add(_buildDivider());
      final fieldMap = field as Map<String, dynamic>;
      rows.add(_buildDetailRow(
          Icons.info_outline,
          fieldMap['label']?.toString() ??
              fieldMap['field_name']?.toString() ??
              'Custom Field',
          profile[fieldMap['field_name']]));
    }

    return ListView(
      key: const PageStorageKey('personal_tab'),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10)),
          child: Column(children: rows),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSpiritualTab(
      Map<String, dynamic> profile, ProfileConfigProvider config) {
    // Build list of rows dynamically
    final List<Widget> rows = [];

    // Standard fields
    final standardFields = [
      {
        'icon': Iconsax.user,
        'label': 'የንስሐ አባት ስም',
        'key': 'confession_father_name'
      },
      {
        'icon': Iconsax.teacher,
        'label': 'የመንፈሳዊ ትምህርት ክፍል',
        'key': 'spiritual_class'
      },
      {'icon': Iconsax.people, 'label': 'ክፍል', 'key': 'kifil'},
    ];

    for (var field in standardFields) {
      if (rows.isNotEmpty) rows.add(_buildDivider());
      rows.add(_buildDetailRow(field['icon'] as IconData,
          field['label'] as String, profile[field['key']]));
    }

    // Add custom fields from config
    final spiritualFields = config.customFields
        .where((f) => f is Map && f['category'] == 'spiritual')
        .toList();
    for (var field in spiritualFields) {
      if (rows.isNotEmpty) rows.add(_buildDivider());
      final fieldMap = field as Map<String, dynamic>;
      rows.add(_buildDetailRow(
          Icons.info_outline,
          fieldMap['label']?.toString() ??
              fieldMap['field_name']?.toString() ??
              'Custom Field',
          profile[fieldMap['field_name']]));
    }

    return ListView(
      key: const PageStorageKey('spiritual_tab'),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10)),
          child: Column(children: rows),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildEducationTab(
      Map<String, dynamic> profile, ProfileConfigProvider config) {
    return ListView(
      key: const PageStorageKey('education_tab'),
      padding: const EdgeInsets.all(16),
      children: [
        FutureBuilder<dynamic>(
          future: _gradesFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            List<Map<String, dynamic>> courses = [];
            try {
              final d = snapshot.data['data'];
              if (d is Map)
                d.forEach((k, v) {
                  if (v is List)
                    courses.addAll(List<Map<String, dynamic>>.from(v));
                });
              else if (d is List) courses = List<Map<String, dynamic>>.from(d);
            } catch (e) {}

            if (courses.isEmpty) return const SizedBox.shrink();

            return Container(
              decoration: BoxDecoration(
                  color: kCardColor,
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
                                  color: kGoldColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)))),
                  ...courses.map((c) {
                    double val = 0;
                    try {
                      val = double.parse(c['score'].toString());
                    } catch (e) {}
                    return _buildDetailRow(
                        Iconsax.book_1,
                        c['course_name']?.toString() ?? '-',
                        val.toStringAsFixed(1),
                        isGold: true);
                  }).toList()
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10)),
          child: Column(
            children: [
              _buildDetailRow(
                  Iconsax.ruler, "የትምህርት ደረጃ", profile['academic_level']),
              _buildDivider(),
              _buildDetailRow(
                  Iconsax.user_tick, "የወላጅ ስም", profile['parent_name']),
              _buildDivider(),
              _buildDetailRow(
                  Iconsax.call, "የወላጅ ስልክ", profile['parent_phone_number']),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // --- HELPERS ---

  Widget _buildDetailRow(IconData icon, String label, dynamic value,
      {bool isGold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kGoldColor.withOpacity(0.3))),
            child: Icon(icon, color: kGoldColor, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Text(label,
                  style: GoogleFonts.notoSansEthiopic(
                      color: kTextGrey, fontSize: 13))),
          Text(value?.toString() ?? '-',
              style: GoogleFonts.notoSansEthiopic(
                  color: isGold ? kGoldColor : Colors.white,
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
        color: Colors.white.withOpacity(0.05),
        indent: 16,
        endIndent: 16);
  }
}
