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

// --- PIXEL-PERFECT ORIGINAL THEME MATCH ---
const Color kPrimaryColor =
    Color(0xFF060D25); // Exact Deep Navy from screenshot
const Color kCardColor = Color(0xFF151725); // Darker Blue-Grey Card
const Color kGoldColor =
    Color(0xFFFFC107); // Standard Amber (Matches Screenshot)
const Color kRedError = Color(0xFFF44336);
const Color kTextWhite = Colors.white;

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
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: const Icon(Icons.menu, color: kGoldColor), // Hamburger match
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              // Match the secondary avatar/logo in screenshot if dynamic
              radius: 18,
              backgroundColor: Colors.transparent,
              child: const Icon(Iconsax.notification, color: Colors.white),
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildHeader(profile, userProvider.avatarUrl),
                ),
              ),
              SliverPersistentHeader(
                delegate: _IdenticalTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: kGoldColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: kGoldColor,
                    indicatorWeight: 3,
                    indicatorSize:
                        TabBarIndicatorSize.label, // Matches small underline
                    labelStyle: GoogleFonts.notoSansEthiopic(
                        fontWeight: FontWeight.bold, fontSize: 13),
                    isScrollable:
                        true, // IMPORTANT: Matches spacing in screenshot
                    tabs: const [
                      Tab(
                          text: "ሁኔታ",
                          icon: Icon(Icons.bar_chart)), // Matches "Status" icon
                      Tab(text: "የግል", icon: Icon(Icons.person_outline)),
                      Tab(
                          text: "መንፈሳዊ",
                          icon: Icon(Icons.school_outlined)), // Closest match
                      Tab(
                          text: "ትምህርት እና ቤተሰብ",
                          icon: Icon(Icons.book_outlined)), // Full text match
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
              _buildStatusTab(profile),
              _buildPersonalTab(
                  profile, profileConfig), // Specific "Personal" structure
              _buildSpiritualTab(
                  profile, profileConfig), // Specific "Spiritual" structure
              _buildEducationTab(profile, profileConfig),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 140, // Wide button 'Private Info'
        height: 48,
        decoration: BoxDecoration(
            color: kGoldColor, borderRadius: BorderRadius.circular(24)),
        child: InkWell(
          onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (c) => const UserEditProfileScreen())
              .then((_) => _refreshAllData()),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit, color: Colors.black, size: 18),
              const SizedBox(width: 8),
              Text("የግል መረጃ",
                  style: GoogleFonts.notoSansEthiopic(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerFloat, // Match screenshot bottom center
    );
  }

  Widget _buildHeader(Map<String, dynamic> profile, String? avatarUrl) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer Glow Ring (Yellowish)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: kGoldColor.withOpacity(0.5), width: 1),
                  boxShadow: [
                    BoxShadow(
                        color: kGoldColor.withOpacity(0.2), blurRadius: 20)
                  ]),
            ),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: kPrimaryColor,
              backgroundImage: (avatarUrl != null)
                  ? CachedNetworkImageProvider(avatarUrl)
                  : null,
              child: (avatarUrl == null)
                  ? Text((profile['full_name'] ?? 'U')[0].toUpperCase(),
                      style: GoogleFonts.poppins(
                          fontSize: 40, color: Colors.white))
                  : null,
            ),
            // Camera Button (Yellow circle bottom right)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickAndUploadImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                      color: kGoldColor, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.black, size: 18),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        Text(profile['full_name'] ?? 'ስም የለም',
            style: GoogleFonts.notoSansEthiopic(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(profile['email'] ?? 'w@d.com',
            style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 13)), // Matches screenshot subtext
      ],
    );
  }

  // --- EXACT SCREENSHOT MATCHING TABS ---

  Widget _buildStatusTab(Map<String, dynamic> profile) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. Service Status (Often Red 'X' or Green check)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10)),
          child: Column(
            children: [
              Text("የአገልግሎት ሁኔታ",
                  style: GoogleFonts.notoSansEthiopic(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              // Default to Red X icon match
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kRedError, width: 2)),
                child: const Icon(Icons.close, color: kRedError, size: 30),
              ),
              const SizedBox(height: 16),
              Text("አገልግሎት ላይ ያልሆነ",
                  style: GoogleFonts.notoSansEthiopic(
                      color: kRedError,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)), // "Not in service"
              const SizedBox(height: 8),
              Text("ይህ ሁኔታ የሚተዳደረው በስተዳደር ነው::",
                  style: GoogleFonts.notoSansEthiopic(
                      color: Colors.white38, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Attendance Summary
        FutureBuilder<dynamic>(
          future: _attendanceFuture,
          builder: (context, snapshot) {
            int present = 0;
            int absent = 0;
            // int permitted = 0;
            double percent = 0;
            if (snapshot.hasData &&
                snapshot.data is Map &&
                snapshot.data['success'] == true) {
              final l = snapshot.data['data'];
              if (l is List) {
                present = l
                    .where((x) =>
                        x['status'].toString().toLowerCase() == 'present')
                    .length;
                absent = l
                    .where(
                        (x) => x['status'].toString().toLowerCase() == 'absent')
                    .length;
                if (l.isNotEmpty) percent = present / l.length;
              }
            }

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("የመገኘት ማጠቃለያ",
                          style: GoogleFonts.notoSansEthiopic(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const Icon(Icons.arrow_forward_ios,
                          color: Colors.white38, size: 14)
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
                        progressColor: kGoldColor,
                        backgroundColor: const Color(0xFF252535),
                        center: Text("${(percent * 100).toStringAsFixed(1)}%",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                      const SizedBox(width: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _legendRow(Icons.person_outline, "ተገኝቷል: $present",
                              Colors.green),
                          const SizedBox(height: 8),
                          _legendRow(Icons.person_off_outlined, "ቀርቷል: $absent",
                              kRedError),
                          const SizedBox(height: 8),
                          _legendRow(Icons.calendar_today_outlined, "አስፈቅዷል: 0",
                              kGoldColor),
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
        // Spacer for FAB
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

  // Matches Screenshot 3: Spiritual Tab (Yellow underline active)
  Widget _buildSpiritualTab(
      Map<String, dynamic> profile, ProfileConfigProvider config) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
              color: kCardColor, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              _buildScreenshotRow(Icons.person_outline, "የንስሐ አባት ስም",
                  profile['confession_father_name']?.toString() ?? "sdfghj"),
              _buildDivider(),
              _buildScreenshotRow(Icons.school_outlined, "የመንፈሳዊ ትምህርት ክፍል",
                  profile['spiritual_class']?.toString() ?? "6ኛ ክፍል"),
              _buildDivider(),
              _buildScreenshotRow(Icons.people_outline, "ክፍል",
                  profile['kifil']?.toString() ?? "Not set"),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // Matches "Personal" Tab structure
  Widget _buildPersonalTab(
      Map<String, dynamic> profile, ProfileConfigProvider config) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
              color: kCardColor, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              _buildScreenshotRow(Icons.badge_outlined, "የክርስትና ስም",
                  profile['christian_name']?.toString() ?? "-"),
              _buildDivider(),
              _buildScreenshotRow(Icons.face, "የእናት ስም",
                  profile['mother_name']?.toString() ?? "-"),
              _buildDivider(),
              _buildScreenshotRow(Icons.call, "ስልክ ቁጥር",
                  profile['phone_number']?.toString() ?? "-"),
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
                  color: kCardColor, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text("የውጤት ዝርዝር",
                          style: GoogleFonts.notoSansEthiopic(
                              color: kGoldColor, fontWeight: FontWeight.bold))),
                  ...courses.map((c) {
                    final name = c['course_name']?.toString() ?? '-';
                    double s = 0;
                    try {
                      s = double.parse(c['score'].toString());
                    } catch (e) {}
                    return _buildScreenshotRow(
                        Icons.book, name, s.toStringAsFixed(1),
                        isValueGold: true);
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

  Widget _buildScreenshotRow(IconData icon, String label, String value,
      {bool isValueGold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kGoldColor.withOpacity(0.3))),
            child: Icon(icon, color: kGoldColor, size: 20),
          ),
          const SizedBox(width: 20),
          Expanded(
              child: Text(label,
                  style: GoogleFonts.notoSansEthiopic(
                      color: Colors.grey, fontSize: 13))), // Grey label
          Text(value,
              style: GoogleFonts.notoSansEthiopic(
                  color: isValueGold ? kGoldColor : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
        color: Colors.white.withOpacity(0.05),
        height: 1,
        indent: 20,
        endIndent: 20);
  }
}

class _IdenticalTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _IdenticalTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        color: kPrimaryColor, // Matches background exactly
        child: _tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
