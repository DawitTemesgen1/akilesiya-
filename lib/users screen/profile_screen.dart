import 'dart:ui';
import 'package:amde_haymanot_abalat_guday/providers/profile_config_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/profile_service.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/edit_profile_sheet.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/uploadpp.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

// --- PIXEL-PERFECT SCREENSHOT MATCH (CRASH FIXED & SCROLL FIXED) ---
const Color kNavyBg = Color(0xFF030712); // Deepest Navy
const Color kCardNavy = Color(0xFF111827); // Dark Blue-Grey Card
const Color kGold = Color(0xFFFFCC00); // Bright Yellow-Gold
const Color kRed = Color(0xFFEF4444);
const Color kTextWhite = Colors.white;
const Color kTextGrey = Color(0xFF9CA3AF);

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
          backgroundColor: kNavyBg,
          body: Center(child: CircularProgressIndicator(color: kGold)));
    }

    return Scaffold(
      backgroundColor: kNavyBg,
      appBar: AppBar(
        leading: const Icon(Icons.menu, color: kGold),
        backgroundColor: kNavyBg,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.notifications_none, color: Colors.white),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAllData,
        color: kGold,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Header as a generic Sliver
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildHeader(profile, userProvider.avatarUrl),
                ),
              ),
              // Pinned Tab Bar using SliverAppBar (Crash Fix)
              SliverAppBar(
                backgroundColor: kNavyBg,
                pinned: true,
                primary: false, // Don't try to account for status bar again
                toolbarHeight: 0, // Hide the toolbar part
                automaticallyImplyLeading: false,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Container(
                    color: kNavyBg,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: kGold,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: kGold,
                      indicatorSize: TabBarIndicatorSize.tab,
                      isScrollable: true,
                      labelStyle: GoogleFonts.notoSansEthiopic(
                          fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: const [
                        Tab(text: "ሁኔታ", icon: Icon(Icons.bar_chart_outlined)),
                        Tab(text: "የግል", icon: Icon(Icons.person_outline)),
                        Tab(text: "መንፈሳዊ", icon: Icon(Icons.school_outlined)),
                        Tab(
                            text: "ትምህርት እና ቤተሰብ",
                            icon: Icon(Icons.menu_book_outlined)),
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
      // PILL FLOATING BUTTON
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
            color: kGold, borderRadius: BorderRadius.circular(30)),
        child: InkWell(
          onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (c) => const UserEditProfileScreen())
              .then((_) => _refreshAllData()),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit_outlined, color: Colors.black, size: 20),
              const SizedBox(width: 8),
              Text("የግል መረጃ",
                  style: GoogleFonts.notoSansEthiopic(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> profile, String? avatarUrl) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            // Standard avatar without huge glow
            CircleAvatar(
              radius: 52,
              backgroundColor: kGold.withOpacity(0.8),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: kCardNavy,
                backgroundImage: (avatarUrl != null)
                    ? CachedNetworkImageProvider(avatarUrl)
                    : null,
                child: (avatarUrl == null)
                    ? Text((profile['full_name'] ?? 'U')[0].toUpperCase(),
                        style: GoogleFonts.poppins(fontSize: 36, color: kGold))
                    : null,
              ),
            ),
            // Camera floating
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickAndUploadImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration:
                      const BoxDecoration(color: kGold, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt,
                      size: 16, color: Colors.black),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        Text(profile['full_name'] ?? 'Guest User',
            style: GoogleFonts.notoSansEthiopic(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(profile['email'] ?? 'w@d.com',
            style: GoogleFonts.poppins(color: kTextGrey, fontSize: 12)),
        const SizedBox(height: 20),
      ],
    );
  }

  // --- TABS (NOW WITH PageStorageKey) ---

  Widget _buildStatusTab(Map<String, dynamic> profile) {
    bool inService = profile['service_sector'] != null;
    return ListView(
      key: const PageStorageKey('status_tab'), // Unique Key
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: kCardNavy, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Text("የአገልግሎት ሁኔታ",
                  style: GoogleFonts.notoSansEthiopic(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              // Red Octagon X
              inService
                  ? const Icon(Icons.check_circle,
                      color: Colors.green, size: 40)
                  : Icon(Icons.dangerous_outlined, color: kRed, size: 50),
              const SizedBox(height: 12),
              Text(
                  inService
                      ? (profile['service_sector']?.toString() ?? "Active")
                      : "አገልግሎት ላይ ያልሆነ",
                  style: GoogleFonts.notoSansEthiopic(
                      color: inService ? Colors.green : kRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const SizedBox(height: 8),
              Text("ይህ ሁኔታ የሚተዳደረው በስተዳደር ነው::",
                  style: GoogleFonts.notoSansEthiopic(
                      color: kTextGrey, fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FutureBuilder<dynamic>(
          future: _attendanceFuture,
          builder: (context, snapshot) {
            double percent = 0;
            int present = 0;
            int absent = 0;
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
                  color: kCardNavy, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("የመገኘት ማጠቃለያ",
                          style: GoogleFonts.notoSansEthiopic(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const Icon(Icons.chevron_right, color: Colors.grey)
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircularPercentIndicator(
                        radius: 50,
                        lineWidth: 8,
                        percent: percent.clamp(0.0, 1.0),
                        center: Text("${(percent * 100).toInt()}%",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        progressColor: kGold,
                        backgroundColor: Colors.white10,
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _legend(
                              Icons.person, "ተገኝቷል: $present", Colors.green),
                          const SizedBox(height: 8),
                          _legend(Icons.person_off, "ቀርቷል: $absent", kRed),
                          const SizedBox(height: 8),
                          _legend(Icons.event_busy, "አስፈቅዷል: 0",
                              kGold), // Permitted is usually gold/orange
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("ዝርዝር ታሪክን ለማየት ይጫኑ",
                      style: GoogleFonts.notoSansEthiopic(
                          color: kGold, fontSize: 12)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _legend(IconData icon, String text, Color color) {
    return Row(children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 8),
      Text(text,
          style: GoogleFonts.notoSansEthiopic(color: kTextGrey, fontSize: 13))
    ]);
  }

  // --- IDENTITY & SPIRITUAL TABS ---

  Widget _buildPersonalTab(
      Map<String, dynamic> profile, ProfileConfigProvider config) {
    return ListView(
      key: const PageStorageKey('personal_tab'), // Unique Key
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          decoration: BoxDecoration(
              color: kCardNavy, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              _buildRow(
                  Icons.badge_outlined, "የክርስትና ስም", profile['christian_name']),
              Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.05),
                  indent: 16,
                  endIndent: 16),
              _buildRow(Icons.face_retouching_natural, "የእናት ስም",
                  profile['mother_name']),
              Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.05),
                  indent: 16,
                  endIndent: 16),
              _buildRow(Icons.call, "ስልክ ቁጥር", profile['phone_number']),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSpiritualTab(
      Map<String, dynamic> profile, ProfileConfigProvider config) {
    return ListView(
      key: const PageStorageKey('spiritual_tab'), // Unique Key
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          decoration: BoxDecoration(
              color: kCardNavy, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              _buildRow(Icons.person_outline, "የንስሐ አባት ስም",
                  profile['confession_father_name']),
              Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.05),
                  indent: 16,
                  endIndent: 16),
              _buildRow(Icons.school_outlined, "የመንፈሳዊ ትምህርት ክፍል",
                  profile['spiritual_class']),
              Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.05),
                  indent: 16,
                  endIndent: 16),
              _buildRow(Icons.groups_outlined, "ክፍል",
                  profile['kifil']), // 'kifil' field
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildEducationTab(
      Map<String, dynamic> profile, ProfileConfigProvider config) {
    return ListView(
      key: const PageStorageKey('education_tab'), // Unique Key
      padding: const EdgeInsets.all(20),
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
                  color: kCardNavy, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(16),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("የውጤት ዝርዝር",
                              style: GoogleFonts.notoSansEthiopic(
                                  color: kGold, fontWeight: FontWeight.bold)))),
                  ...courses.map((c) {
                    double grade = 0;
                    try {
                      grade = double.parse(c['score'].toString());
                    } catch (e) {}
                    return _buildRow(
                        Icons.menu_book,
                        c['course_name']?.toString() ?? '-',
                        grade.toStringAsFixed(1),
                        isGoldValue: true);
                  }).toList()
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // --- ROW BUILDER ---
  Widget _buildRow(IconData icon, String label, dynamic value,
      {bool isGoldValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kGold.withOpacity(0.3))),
            child: Icon(icon, color: kGold, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
              child: Text(label,
                  style: GoogleFonts.notoSansEthiopic(
                      color: kTextGrey, fontSize: 13))),
          Text(value?.toString() ?? '-',
              style: GoogleFonts.notoSansEthiopic(
                  color: isGoldValue ? kGold : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }
}
