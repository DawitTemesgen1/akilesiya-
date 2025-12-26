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

// --- AWARD WINNING THEME ---
const Color kBgDark = Color(0xFF121418); // Matte Black
const Color kBgCard = Color(0xFF1B1D23); // Gunmetal
const Color kAccentGold = Color(0xFFD4AF37); // Classic Gold
const Color kAccentBlue = Color(0xFF5E81AC); // Nordic Blue
const Color kTextWhite = Color(0xFFECEFF4);
const Color kTextGrey = Color(0xFFD8DEE9);

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
          backgroundColor: kBgDark,
          body: Center(child: CircularProgressIndicator(color: kAccentGold)));
    }

    return Scaffold(
      backgroundColor: kBgDark,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(context, profile, userProvider.avatarUrl),
            SliverPersistentHeader(
              delegate: _ModernTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: kBgDark,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: GoogleFonts.notoSansEthiopic(
                      fontWeight: FontWeight.w800, fontSize: 13),
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: kAccentGold,
                      boxShadow: [
                        BoxShadow(
                            color: kAccentGold.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ]),
                  indicatorSize: TabBarIndicatorSize.tab,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  dividerColor: Colors.transparent,
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
        body: Container(
          decoration: BoxDecoration(
            color: kBgDark,
            // subtle noise or patterns could go here
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildStatusTab(profile),
              _buildDynamicTab(profile, 'የግል', profileConfig),
              _buildDynamicTab(profile, 'መንፈሳዊ', profileConfig),
              _buildEducationTab(profile, profileConfig),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context, Map<String, dynamic> profile, String? avatarUrl) {
    return SliverAppBar(
      expandedHeight: 280.0,
      backgroundColor: kBgDark,
      pinned: true,
      stretch: true,
      leading: const SizedBox
          .shrink(), // Hides back button if any (or use leading automatically)
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Abstract Background Art
            Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [kBgDark, Color(0xFF2A2A35)],
              )),
            ),
            // Pattern
            Positioned(
              right: -50,
              top: -50,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Iconsax.star1, size: 300, color: kAccentGold),
              ),
            ),

            // Content
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Avatar with glowing ring
                    GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: kAccentGold, width: 3),
                            boxShadow: [
                              BoxShadow(
                                  color: kAccentGold.withOpacity(0.3),
                                  blurRadius: 20)
                            ],
                            image: (avatarUrl != null)
                                ? DecorationImage(
                                    image:
                                        CachedNetworkImageProvider(avatarUrl),
                                    fit: BoxFit.cover)
                                : null,
                            color: kBgCard),
                        child: (avatarUrl == null)
                            ? Center(
                                child: Text(
                                    (profile['full_name'] ?? 'U')[0]
                                        .toUpperCase(),
                                    style: GoogleFonts.poppins(
                                        fontSize: 40, color: kAccentGold)))
                            : null,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Name and Tag
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: Text(profile['full_name'] ?? 'Guest User',
                                style: GoogleFonts.notoSansEthiopic(
                                    color: kTextWhite,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(height: 8),
                          FadeInUp(
                            delay: const Duration(milliseconds: 400),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color: kAccentGold,
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                profile['spiritual_class'] ?? 'No Class',
                                style: GoogleFonts.notoSansEthiopic(
                                    color: kBgDark,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
          child: IconButton(
            icon: const Icon(Iconsax.edit, color: Colors.white, size: 20),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const UserEditProfileScreen(),
            ).then((_) => _refreshAllData()),
          ),
        )
      ],
    );
  }

  // --- TABS ---

  Widget _buildStatusTab(Map<String, dynamic> profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("DASHBOARD",
              style: GoogleFonts.poppins(
                  color: Colors.white24,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Stats Row
          Row(
            children: [
              Expanded(
                  child: _buildStatBox("MEMBERSHIP", "Active", Iconsax.verify5,
                      Colors.greenAccent)),
              const SizedBox(width: 15),
              Expanded(
                  child: _buildStatBox(
                      "SECTOR",
                      profile['service_sector']?.toString() ?? "-",
                      Iconsax.briefcase,
                      kAccentBlue)),
            ],
          ),

          const SizedBox(height: 24),

          // Attendance Graph / Card
          FutureBuilder<dynamic>(
            future: _attendanceFuture,
            builder: (context, snapshot) {
              // Robust Processing
              double percent = 0.0;
              int present = 0;
              int total = 0;
              if (snapshot.hasData &&
                  snapshot.data is Map &&
                  snapshot.data['success'] == true) {
                final raw = snapshot.data['data'];
                if (raw is List) {
                  total = raw.length;
                  present = raw
                      .where((i) =>
                          i['status'].toString().toLowerCase() == 'present')
                      .length;
                  percent = total > 0 ? present / total : 0;
                }
              }

              return FadeInUp(
                child: Container(
                  height: 180,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF2E323A), kBgCard]),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black45,
                            blurRadius: 20,
                            offset: Offset(0, 10))
                      ],
                      border:
                          Border.all(color: Colors.white.withOpacity(0.05))),
                  child: Row(
                    children: [
                      CircularPercentIndicator(
                        radius: 60,
                        lineWidth: 12,
                        percent: percent.clamp(0.0, 1.0),
                        progressColor: kAccentGold,
                        backgroundColor: Colors.black26,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("${(percent * 100).toStringAsFixed(0)}%",
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24)),
                            Text("Present",
                                style: GoogleFonts.poppins(
                                    color: Colors.white38, fontSize: 10)),
                          ],
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: true,
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("ATTENDANCE",
                                style: GoogleFonts.poppins(
                                    color: kAccentGold,
                                    fontSize: 12,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                                "You have attended $present out of $total sessions.",
                                style: GoogleFonts.notoSansEthiopic(
                                    color: kTextGrey,
                                    height: 1.5,
                                    fontSize: 13)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildDynamicTab(
      Map<String, dynamic> profile, String tab, ProfileConfigProvider config) {
    final widgets = <Widget>[];

    // Built-ins
    final builtIn = _getBuiltInFields(tab);
    for (var key in builtIn) {
      if (config.isWidgetVisible(key)) {
        widgets.add(_buildInfoTile(key, _formatValue(key, profile[key])));
      }
    }

    // Custom
    final custom = config.customFields.where((f) {
      final t = f['profile_tab']?.toString().toUpperCase() ?? 'PERSONAL';
      if (tab == 'የግል') return t == 'PERSONAL';
      if (tab == 'መንፈሳዊ') return t == 'SPIRITUAL';
      return false;
    }).toList();

    final savedValues = _getCustomFieldValuesMap(profile);
    for (var field in custom) {
      final name = field['name'].toString();
      String displayValue = '-';
      final optId = savedValues[field['id'].toString()];
      if (optId != null) {
        final options = field['options'] as List<dynamic>? ?? [];
        final opt = options.firstWhere(
            (o) => o['id'].toString() == optId.toString(),
            orElse: () => null);
        displayValue = opt?['option_value']?.toString() ?? '-';
      }
      widgets.add(_buildInfoTile(name, displayValue, isCustom: true));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  Widget _buildEducationTab(
      Map<String, dynamic> profile, ProfileConfigProvider config) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ACADEMIC RESULTS",
              style: GoogleFonts.poppins(
                  color: Colors.white24,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
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
                else if (d is List)
                  courses = List<Map<String, dynamic>>.from(d);
              } catch (e) {}

              if (courses.isEmpty)
                return const Text("No grades yet.",
                    style: TextStyle(color: Colors.white54));

              return SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: courses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, idx) => _buildGradeCard(courses[idx], idx),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Text("DETAILS",
              style: GoogleFonts.poppins(
                  color: Colors.white24,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildInfoTile(
              "Academic Level", profile['academic_level']?.toString() ?? '-',
              isCustom: true),
          _buildInfoTile(
              "Parent Name", profile['parent_name']?.toString() ?? '-',
              isCustom: true),
          _buildInfoTile(
              "Parent Phone", profile['parent_phone_number']?.toString() ?? '-',
              isCustom: true),
        ],
      ),
    );
  }

  // --- COMPONENT WIDGETS ---

  Widget _buildStatBox(
      String title, String value, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 28),
          const Spacer(),
          Text(value,
              style: GoogleFonts.notoSansEthiopic(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(title,
              style: GoogleFonts.poppins(
                  color: Colors.white30,
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold)),
        ],
      ),
      height: 140,
    );
  }

  Widget _buildInfoTile(String title, String value, {bool isCustom = false}) {
    final label = isCustom ? title : _getTranslatedLabel(title);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: kBgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.02))),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
                color: kAccentGold.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.notoSansEthiopic(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value,
                    style: GoogleFonts.notoSansEthiopic(
                        color: kTextWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGradeCard(Map<String, dynamic> course, int index) {
    final colors = [
      Color(0xFF88C0D0),
      Color(0xFFB48EAD),
      Color(0xFFA3BE8C),
      Color(0xFFEBCB8B)
    ];
    final color = colors[index % colors.length];

    double score = 0;
    double max = 100;
    try {
      final sList = course['scores'];
      if (sList is List && sList.isNotEmpty) {
        for (var s in sList)
          score += double.tryParse(s['score']?.toString() ?? '0') ?? 0;
      } else {
        score = double.tryParse(course['score']?.toString() ?? '0') ?? 0;
        max =
            double.tryParse(course['total_marks']?.toString() ?? '100') ?? 100;
      }
    } catch (e) {}
    if (max <= 0) max = 100;
    double percent = (score / max).clamp(0.0, 1.0);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: kBgCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
          ]),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: CircularPercentIndicator(
                radius: 40,
                lineWidth: 8,
                percent: percent,
                center: Text("${score.toInt()}",
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                progressColor: color,
                backgroundColor: Colors.white10,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(course['course_name']?.toString() ?? 'Course',
              style: GoogleFonts.notoSansEthiopic(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
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

class _ModernTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _ModernTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height + 24;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 24;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        color: kBgDark,
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        child: _tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
