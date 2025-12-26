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

// --- RESTORED ORIGINAL THEME (Dark Blue & Gold) ---
const Color kPrimaryColor = Color(0xFF050511); // Deep Navy/Black
const Color kCardColor = Color(0xFF151522); // Card Background
const Color kGoldColor = Color(0xFFFFC107); // Amber/Gold
const Color kTextWhite = Colors.white;
const Color kTextGrey = Colors.white54;
const Color kRedError = Color(0xFFE53935);

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
      body: RefreshIndicator(
        onRefresh: _refreshAllData,
        color: kGoldColor,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildAppBar(context),
              SliverToBoxAdapter(
                  child: _buildHeader(profile, userProvider.avatarUrl)),
              SliverPersistentHeader(
                delegate: _RestoredTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: kGoldColor,
                    unselectedLabelColor: Colors.white60,
                    indicatorColor: kGoldColor,
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.notoSansEthiopic(
                        fontWeight: FontWeight.bold, fontSize: 12),
                    tabs: const [
                      Tab(text: "ሁኔታ", icon: Icon(Iconsax.status)),
                      Tab(text: "የግል", icon: Icon(Iconsax.user)),
                      Tab(text: "መንፈሳዊ", icon: Icon(Iconsax.teacher)),
                      Tab(text: "ትምህርት", icon: Icon(Iconsax.book)),
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
              _buildDynamicTabContent(profile, 'የግል', profileConfig),
              _buildDynamicTabContent(profile, 'መንፈሳዊ', profileConfig),
              _buildEducationTab(profile, profileConfig),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => const UserEditProfileScreen(),
        ).then((_) => _refreshAllData()),
        backgroundColor: kGoldColor,
        child: const Icon(Iconsax.edit, color: Colors.black),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: kPrimaryColor,
      floating: false,
      pinned: true,
      elevation: 0,
      centerTitle: true,
      // Hamburger menu is likely handled by Scaffold drawer, leading is Auto.
    );
  }

  Widget _buildHeader(Map<String, dynamic> profile, String? avatarUrl) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Stack(
            children: [
              // Glow
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                  BoxShadow(
                      color: kGoldColor.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 5)
                ]),
              ),
              // Avatar
              Container(
                width: 110,
                height: 110,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kGoldColor, width: 2)),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF222233),
                  backgroundImage: (avatarUrl != null)
                      ? CachedNetworkImageProvider(avatarUrl)
                      : null,
                  child: (avatarUrl == null)
                      ? Text((profile['full_name'] ?? 'U')[0].toUpperCase(),
                          style: GoogleFonts.poppins(
                              fontSize: 40, color: kGoldColor))
                      : null,
                ),
              ),
              // Camera Icon
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                        color: kGoldColor, shape: BoxShape.circle),
                    child: const Icon(Iconsax.camera,
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
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(profile['email'] ?? '',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  // --- TAB CONTENT ---

  Widget _buildStatusTab(Map<String, dynamic> profile) {
    final serviceStatus =
        profile['service_sector']?.toString() ?? "አገልግሎት ላይ ያልሆነ";
    final isActive = serviceStatus != "አገልግሎት ላይ ያልሆነ";

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Service Status Card
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
              const SizedBox(height: 16),
              isActive
                  ? const Icon(Iconsax.verify5,
                      color: Colors.greenAccent, size: 50)
                  : const Icon(Icons.cancel_outlined,
                      color: kRedError, size: 50),
              const SizedBox(height: 16),
              Text(serviceStatus,
                  style: GoogleFonts.notoSansEthiopic(
                      color: isActive ? Colors.greenAccent : kRedError,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("ይህ ሁኔታ የሚተዳደረው በስተዳደር ነው::",
                  style: GoogleFonts.notoSansEthiopic(
                      color: Colors.white38, fontSize: 12)),
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
              final list = snapshot.data['data'];
              if (list is List) {
                present = list
                    .where((x) =>
                        x['status'].toString().toLowerCase() == 'present')
                    .length;
                absent = list
                    .where(
                        (x) => x['status'].toString().toLowerCase() == 'absent')
                    .length;
                if (list.isNotEmpty) percent = present / list.length;
              }
            }

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          color: Colors.white54, size: 16),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CircularPercentIndicator(
                        radius: 50,
                        lineWidth: 10,
                        percent: percent.clamp(0.0, 1.0),
                        progressColor: kGoldColor,
                        backgroundColor: const Color(0xFF2A2A3A),
                        center: Text("${(percent * 100).toStringAsFixed(1)}%",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                      const SizedBox(width: 30),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem(Icons.person, "ተገኝቷል: $present",
                              Colors.greenAccent),
                          const SizedBox(height: 10),
                          _buildLegendItem(
                              Icons.person_off, "ቀርቷል: $absent", kRedError),
                          // const SizedBox(height: 10),
                          // _buildLegendItem(Icons.calendar_today, "አስፈቅዷል: 0", Colors.orange),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                      child: Text("ዝርዝር ታሪክን ለማየት ይጫኑ",
                          style: GoogleFonts.notoSansEthiopic(
                              color: kGoldColor, fontSize: 12))),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLegendItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(text,
            style: GoogleFonts.notoSansEthiopic(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDynamicTabContent(
      Map<String, dynamic> profile, String tab, ProfileConfigProvider config) {
    final widgets = <Widget>[];

    void add(String l, String v, IconData i) =>
        widgets.add(_buildProfileRow(i, l, v));

    // Simple manual mapping based on screenshots for "Original" look
    if (tab == 'መንፈሳዊ') {
      add("የንስሐ አባት ስም", profile['confession_father_name']?.toString() ?? "-",
          Iconsax.user);
      add("የመንፈሳዊ ትምህርት ክፍል", profile['spiritual_class']?.toString() ?? "-",
          Iconsax.teacher);
      add("ክፍል", profile['kifil']?.toString() ?? "Not set", Iconsax.people);
    } else {
      // Personal
      add("የክርስትና ስም", profile['christian_name']?.toString() ?? "-",
          Iconsax.heart);
      add("የእናት ስም", profile['mother_name']?.toString() ?? "-",
          Iconsax.user_square);
      add("ስልክ ቁጥር", profile['phone_number']?.toString() ?? "-", Iconsax.call);
    }

    // Custom Fields appended
    final custom = config.customFields.where((f) {
      final t = f['profile_tab']?.toString().toUpperCase() ?? 'PERSONAL';
      if (tab == 'የግል') return t == 'PERSONAL';
      if (tab == 'መንፈሳዊ') return t == 'SPIRITUAL';
      return false;
    }).toList();
    final saved = _getCustomFieldValuesMap(profile);

    for (var f in custom) {
      String val = '-';
      final optId = saved[f['id'].toString()];
      if (optId != null) {
        final opts = f['options'] as List<dynamic>? ?? [];
        final op = opts.firstWhere(
            (o) => o['id'].toString() == optId.toString(),
            orElse: () => null);
        val = op?['option_value']?.toString() ?? '-';
      }
      add(f['name'].toString(), val, Iconsax.info_circle);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10)),
          child: Column(children: widgets),
        )
      ],
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFF222233),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGoldColor.withOpacity(0.2))),
            child: Icon(icon, color: kGoldColor, size: 20),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.notoSansEthiopic(
                        color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value,
                    style: GoogleFonts.notoSansEthiopic(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
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
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text("የትምህርት ውጤት",
                        style: GoogleFonts.notoSansEthiopic(
                            color: kGoldColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ),
                  ...courses.map((c) => _buildGradeItem(c)).toList(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGradeItem(Map<String, dynamic> course) {
    double score = 0;
    double max = 100;
    try {
      final s = course['scores'];
      if (s is List && s.isNotEmpty)
        for (var i in s) score += double.tryParse(i['score'].toString()) ?? 0;
      else {
        score = double.tryParse(course['score'].toString()) ?? 0;
        max = double.tryParse(course['total_marks'].toString()) ?? 100;
      }
    } catch (e) {}
    if (max <= 0) max = 100;

    final courseName =
        course['course_name']?.toString() ?? course['subject_name'] ?? '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white10))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(courseName,
                  style: GoogleFonts.notoSansEthiopic(color: Colors.white))),
          Text("${score.toStringAsFixed(1)} / $max",
              style: const TextStyle(
                  color: kGoldColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- Helpers ---
  Map<String, dynamic> _getCustomFieldValuesMap(Map<String, dynamic> profile) {
    if (profile['custom_field_values'] is Map)
      return profile['custom_field_values'];
    if (profile['custom_field_values'] is List) {
      return {
        for (var v in profile['custom_field_values'])
          v['field_id'].toString(): v['option_id']
      };
    }
    return {};
  }
}

class _RestoredTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _RestoredTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height + 20;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 20;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        color: kPrimaryColor,
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: _tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
