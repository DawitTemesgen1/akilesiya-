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

// --- Ultra Modern Theme Constants ---
const Color kDarkBg = Color(0xFF05050A);
const Color kSurfaceColor = Color(0xFF1E1E2C);
const Color kAccentGold = Color(0xFFFFD700);
const Color kAccentBlue = Color(0xFF2E86DE);
const Color kAccentPurple = Color(0xFF6C5CE7);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

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
          backgroundColor: kDarkBg,
          body: Center(child: CircularProgressIndicator(color: kAccentGold)));
    }

    return Scaffold(
      backgroundColor: kDarkBg,
      body: Stack(
        children: [
          // 1. Ambient Background (Mesh Gradient effect)
          Positioned(
              top: -100,
              right: -100,
              child: _buildBlurOrb(kAccentPurple.withOpacity(0.2))),
          Positioned(
              top: 200,
              left: -50,
              child: _buildBlurOrb(kAccentBlue.withOpacity(0.15))),
          Positioned(
              bottom: -50,
              right: 0,
              child: _buildBlurOrb(kAccentGold.withOpacity(0.1))),

          NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildModernAppBar(context),
                SliverToBoxAdapter(
                    child:
                        _buildImmersiveHeader(profile, userProvider.avatarUrl)),
                SliverPersistentHeader(
                  delegate: _GlassTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                      labelColor: kDarkBg,
                      unselectedLabelColor: Colors.white60,
                      labelStyle: GoogleFonts.notoSansEthiopic(
                          fontWeight: FontWeight.bold, fontSize: 13),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: kAccentGold,
                      ),
                      dividerColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 0),
                      tabs: const [
                        Tab(text: "ሁኔታ"),
                        Tab(text: "የግል"),
                        Tab(text: "መንፈሳዊ"),
                        Tab(text: "ትምህርት"),
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
                _buildStatusDashboard(profile),
                _buildGridContent('የግል', profile, profileConfig),
                _buildGridContent('መንፈሳዊ', profile, profileConfig),
                _buildEducationDashboard(profile, profileConfig),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurOrb(Color color) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(color: Colors.transparent)),
    );
  }

  Widget _buildModernAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: kDarkBg.withOpacity(0.8),
      title: Text("MY PROFILE",
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 16)),
      centerTitle: true,
      pinned: true,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Iconsax.edit, color: Colors.white),
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => const UserEditProfileScreen(),
          ).then((_) => _refreshAllData()),
        ),
      ],
    );
  }

  Widget _buildImmersiveHeader(
      Map<String, dynamic> profile, String? avatarUrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Row(
              children: [
                _buildAvatarRing(profile, avatarUrl),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile['full_name'] ?? 'User Name',
                          style: GoogleFonts.notoSansEthiopic(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.2)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              kAccentGold,
                              kAccentGold.withOpacity(0.7)
                            ]),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          profile['spiritual_class'] ?? 'No Class',
                          style: GoogleFonts.notoSansEthiopic(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarRing(Map<String, dynamic> profile, String? avatarUrl) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1)),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kAccentGold, width: 2)),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: kSurfaceColor,
              backgroundImage: (avatarUrl != null)
                  ? CachedNetworkImageProvider(avatarUrl)
                  : null,
              child: (avatarUrl == null)
                  ? Text((profile['full_name'] ?? 'U')[0].toUpperCase(),
                      style:
                          GoogleFonts.poppins(fontSize: 30, color: kAccentGold))
                  : null,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickAndUploadImage,
            child: CircleAvatar(
                radius: 14,
                backgroundColor: kAccentGold,
                child:
                    const Icon(Iconsax.camera, size: 14, color: Colors.black)),
          ),
        )
      ],
    );
  }

  // --- TAB CONTENT: STATUS DASHBOARD ---
  Widget _buildStatusDashboard(Map<String, dynamic> profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Status Overview"),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                  child: _buildModernStatCard(
                      "Status", "Active", Iconsax.verify5, Colors.greenAccent)),
              const SizedBox(width: 15),
              Expanded(
                  child: _buildModernStatCard(
                      "Members",
                      profile['service_sector']?.toString() ?? "-",
                      Iconsax.people,
                      kAccentBlue)),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle("Attendance"),
          const SizedBox(height: 15),
          FutureBuilder<dynamic>(
            future: _attendanceFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: kAccentGold));
              }

              // Calculate Attendance (Robust)
              double percentage = 0.0;
              String message = "No records";
              String subMessage = "Attendance data unavailable";
              int total = 0;
              int present = 0;

              if (snapshot.hasData &&
                  snapshot.data is Map &&
                  snapshot.data['success'] == true) {
                final data = snapshot.data['data'];
                if (data is List && data.isNotEmpty) {
                  total = data.length;
                  present = data
                      .where((item) =>
                          item['status'].toString().toLowerCase() == 'present')
                      .length;
                  percentage = total > 0 ? present / total : 0.0;

                  if (percentage >= 0.8) {
                    message = "Excellent!";
                    subMessage = "You are regular in your service.";
                  } else if (percentage >= 0.5) {
                    message = "Good";
                    subMessage = "Keep up the good work.";
                  } else {
                    message = "Attention";
                    subMessage = "Try to attend more frequently.";
                  }
                } else if (data is List && data.isEmpty) {
                  subMessage = "No attendance records yet.";
                }
              }

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kSurfaceColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 45,
                      lineWidth: 8,
                      percent: percentage.clamp(0.0, 1.0),
                      center: Text("${(percentage * 100).toStringAsFixed(0)}%",
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      progressColor:
                          percentage > 0.5 ? kAccentGold : Colors.redAccent,
                      backgroundColor: Colors.white10,
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(message,
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(subMessage,
                            style: GoogleFonts.poppins(
                                color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text("$present / $total Sessions",
                            style: GoogleFonts.notoSansEthiopic(
                                color: kAccentBlue,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ],
                    ))
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- TAB CONTENT: GRIDS (Personal / Spiritual) ---
  Widget _buildGridContent(String tabName, Map<String, dynamic> profile,
      ProfileConfigProvider config) {
    // Collect Fields
    final builtIn = _getBuiltInFields(tabName);
    final custom = config.customFields.where((f) {
      final t = f['profile_tab']?.toString().toUpperCase() ?? 'PERSONAL';
      if (tabName == 'የግል') return t == 'PERSONAL';
      if (tabName == 'መንፈሳዊ') return t == 'SPIRITUAL';
      return false;
    }).toList();

    final allWidgets = <Widget>[];

    // Built-in
    for (var key in builtIn) {
      if (config.isWidgetVisible(key)) {
        allWidgets.add(_buildDetailItem(key, _formatValue(key, profile[key])));
      }
    }

    // Custom
    final savedValues = _getCustomFieldValuesMap(profile);
    for (var field in custom) {
      final fieldId = field['id'].toString();
      final fieldName = field['name'].toString();
      String displayValue = '-';
      final optionId = savedValues[fieldId];
      if (optionId != null) {
        final options = field['options'] as List<dynamic>? ?? [];
        final option = options.firstWhere(
            (opt) => opt['id'].toString() == optionId.toString(),
            orElse: () => null);
        displayValue = option?['option_value']?.toString() ?? '-';
      }
      allWidgets.add(_buildDetailItem(fieldName, displayValue, isCustom: true));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: FadeInUp(
        child: Wrap(
          spacing: 15,
          runSpacing: 15,
          children: allWidgets
              .map((w) => SizedBox(
                  width: (MediaQuery.of(context).size.width - 55) /
                      2, // 2 items per row
                  child: w))
              .toList(),
        ),
      ),
    );
  }

  // --- TAB CONTENT: EDUCATION (Grades) ---
  Widget _buildEducationDashboard(
      Map<String, dynamic> profile, ProfileConfigProvider config) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Academic Performance"),
          const SizedBox(height: 15),
          FutureBuilder<dynamic>(
            future: _gradesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData)
                return const Text("No grades available",
                    style: TextStyle(color: Colors.white54));

              final rawData =
                  snapshot.data is Map ? snapshot.data['data'] : null;
              List<Map<String, dynamic>> courses = [];
              if (rawData is Map) {
                rawData.forEach((k, v) {
                  if (v is List)
                    courses.addAll(List<Map<String, dynamic>>.from(v));
                });
              } else if (rawData is List) {
                courses = List<Map<String, dynamic>>.from(rawData);
              }

              if (courses.isEmpty)
                return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(16)),
                    child: const Text("No Grade Data",
                        style: TextStyle(color: Colors.white)));

              return SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: courses.length,
                  itemBuilder: (context, index) =>
                      _buildGradeCard(courses[index], index),
                ),
              );
            },
          ),
          const SizedBox(height: 25),
          _buildSectionTitle("Additional Info"),
          const SizedBox(height: 15),
          // Reusing Grid Logic for Education details
          ..._buildGridContentWidgets('ትምህርት/ቤተሰብ', profile, config),
        ],
      ),
    );
  }

  List<Widget> _buildGridContentWidgets(String tabName,
      Map<String, dynamic> profile, ProfileConfigProvider config) {
    // Manual fallback for education
    return [
      Wrap(
        spacing: 15,
        runSpacing: 15,
        children: [
          _buildDetailGridItem(
              'Academic Level', profile['academic_level']?.toString() ?? '-'),
          _buildDetailGridItem(
              'Guardian Name', profile['parent_name']?.toString() ?? '-'),
          _buildDetailGridItem('Guardian Phone',
              profile['parent_phone_number']?.toString() ?? '-'),
        ],
      )
    ];
  }

  // --- WIDGETS ---

  Widget _buildGradeCard(Map<String, dynamic> course, int index) {
    final colors = [
      kAccentBlue,
      kAccentPurple,
      Colors.orangeAccent,
      Colors.tealAccent
    ];
    final color = colors[index % colors.length];
    final courseName = course['course_name']?.toString() ?? 'Course';

    // Calculate total
    final scores = course['scores'] as List<dynamic>? ?? [];
    double total = 0;
    if (scores.isNotEmpty) {
      for (var s in scores)
        total += double.tryParse(s['score']?.toString() ?? '0') ?? 0;
    } else {
      total = double.tryParse(course['score']?.toString() ?? '0') ?? 0;
    }

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.2), color.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(courseName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.notoSansEthiopic(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const Spacer(),
          CircularPercentIndicator(
            radius: 40,
            lineWidth: 8,
            percent: (total / 100).clamp(0.0, 1.0),
            center: Text(total.toStringAsFixed(0),
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            progressColor: color,
            backgroundColor: Colors.white10,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const Spacer(),
          Text("Score",
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: kSurfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: GoogleFonts.notoSansEthiopic(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          Text(title,
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String key, String value, {bool isCustom = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: kSurfaceColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(isCustom ? key : _getTranslatedLabel(key),
              style: GoogleFonts.notoSansEthiopic(
                  color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.notoSansEthiopic(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDetailGridItem(String title, String value) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 55) / 2,
      child: _buildDetailItem(title, value, isCustom: true),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5));
  }

  // Helpers
  List<String> _getBuiltInFields(String tab) {
    if (tab == 'የግል')
      return [
        'christian_name',
        'mother_name',
        'gender',
        'age',
        'dob',
        'phone_number'
      ];
    if (tab == 'መንፈሳዊ')
      return ['confession_father_name', 'spiritual_class', 'kifil'];
    return [];
  }

  String _formatValue(String key, dynamic value) {
    if (value == null || value.toString().isEmpty) return '-';
    if (key == 'dob') {
      try {
        return DateFormat.yMMMd().format(DateTime.parse(value.toString()));
      } catch (e) {}
    }
    return value.toString();
  }

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

  String _getTranslatedLabel(String key) {
    const Map<String, String> translations = {
      'christian_name': 'የክርስትና ስም',
      'mother_name': 'የእናት ስም',
      'gender': 'ጾታ',
      'age': 'ዕድሜ',
      'dob': 'የትውልድ ቀን',
      'phone_number': 'ስልክ ቁጥር',
      'confession_father_name': 'የንስሐ አባት ስም',
      'spiritual_class': 'የመንፈሳዊ ትምህርት ክፍል',
      'kifil': 'ክፍል',
      'academic_level': 'የትምህርት ደረጃ',
      'parent_name': 'የወላጅ ስም',
      'parent_phone_number': 'የወላጅ ስልክ ቁጥር',
      'grade_points': 'ውጤት',
    };
    return translations[key] ?? key.replaceAll('_', ' ').toUpperCase();
  }
}

class _GlassTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _GlassTabBarDelegate(this._tabBar);
  @override
  double get minExtent => 70;
  @override
  double get maxExtent => 70;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.white.withOpacity(0.05),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: _tabBar,
            ),
          ),
        ));
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
