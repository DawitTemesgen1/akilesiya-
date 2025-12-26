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

// --- ULTIMATE PREMIUM THEME (Diamond & Gold) ---
const Color kRichBlack = Color(0xFF000000);
const Color kDeepOnyx = Color(0xFF101010);
const Color kGoldGradientStart = Color(0xFFFFD700);
const Color kGoldGradientEnd = Color(0xFFDAA520);
const Color kPlatinum = Color(0xFFE5E4E2);

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

  // --- GOLD TEXT SHADER HELPER ---
  Widget _goldText(String text,
      {double fontSize = 16,
      FontWeight fontWeight = FontWeight.bold,
      String? fontFamily}) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [kGoldGradientStart, kGoldGradientEnd, kGoldGradientStart],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style: fontFamily == 'cinzel'
            ? GoogleFonts.cinzel(
                fontSize: fontSize, fontWeight: fontWeight, color: Colors.white)
            : GoogleFonts.notoSansEthiopic(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profileConfig = context.watch<ProfileConfigProvider>();
    final profile = userProvider.userProfile;

    if (userProvider.isLoading || profile == null) {
      return const Scaffold(
          backgroundColor: kRichBlack,
          body: Center(
              child: CircularProgressIndicator(color: kGoldGradientStart)));
    }

    return Scaffold(
      backgroundColor: kRichBlack,
      body: Stack(
        children: [
          // LUXURY BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F0F1A), kRichBlack, kRichBlack],
                  stops: [0.0, 0.4, 1.0]),
            ),
          ),
          // Ambient Glow
          Positioned(
              top: -100,
              right: -100,
              child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kGoldGradientStart.withOpacity(0.05),
                      boxShadow: [
                        BoxShadow(
                            color: kGoldGradientStart.withOpacity(0.1),
                            blurRadius: 100)
                      ]))),

          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildSliverAppBar(context, profile, userProvider.avatarUrl),
                SliverPersistentHeader(
                  delegate: _PremiumTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: kGoldGradientStart,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: GoogleFonts.cinzel(
                          fontWeight: FontWeight.w900,
                          fontSize: 13), // Premium Font
                      indicatorColor: kGoldGradientStart,
                      indicatorWeight: 3,
                      padding: EdgeInsets.zero,
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: "STATUS"),
                        Tab(text: "PERSONAL"),
                        Tab(text: "SPIRITUAL"),
                        Tab(text: "ACADEMIC"),
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
                _buildDetailsList(profile, 'የግል',
                    profileConfig), // Keeping content logic but wrapped
                _buildDetailsList(profile, 'መንፈሳዊ', profileConfig),
                _buildEducationTab(profile, profileConfig),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context, Map<String, dynamic> profile, String? avatarUrl) {
    return SliverAppBar(
      backgroundColor: kRichBlack,
      expandedHeight: 300,
      pinned: true,
      centerTitle: true,
      title: _goldText("PROFILE", fontSize: 18, fontFamily: 'cinzel'),
      actions: [
        IconButton(
            icon: const Icon(Iconsax.edit, color: kPlatinum),
            onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (c) => const UserEditProfileScreen())
                .then((_) => _refreshAllData())),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.center,
          children: [
            // Diamond Pattern or similar
            Opacity(
                opacity: 0.05,
                child: Image.network(
                    "https://www.transparenttextures.com/patterns/cubes.png",
                    repeat: ImageRepeat.repeat,
                    errorBuilder: (c, o, s) =>
                        const SizedBox())), // Fallback safe

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                            colors: [kGoldGradientStart, kGoldGradientEnd]),
                        boxShadow: [
                          BoxShadow(
                              color: kGoldGradientStart.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 2)
                        ]),
                    child: CircleAvatar(
                      radius: 65,
                      backgroundColor: kDeepOnyx,
                      backgroundImage: (avatarUrl != null)
                          ? CachedNetworkImageProvider(avatarUrl)
                          : null,
                      child: (avatarUrl == null)
                          ? Text((profile['full_name'] ?? 'U')[0].toUpperCase(),
                              style: GoogleFonts.cinzel(
                                  fontSize: 50, color: kGoldGradientStart))
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(profile['full_name'] ?? 'User',
                    style: GoogleFonts.notoSansEthiopic(
                        color: kPlatinum,
                        fontSize: 28,
                        fontWeight: FontWeight.normal)),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white10),
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white.withOpacity(0.05)),
                  child: Text(profile['spiritual_class'] ?? 'No Class',
                      style: GoogleFonts.notoSansEthiopic(
                          color: kGoldGradientEnd,
                          fontSize: 12,
                          letterSpacing: 1.5)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- PREMIUM CONTENT ---

  Widget _buildStatusTab(Map<String, dynamic> profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildDiamondCard(
                      "STATUS", "Active", Iconsax.verify5, Colors.greenAccent)),
              const SizedBox(width: 20),
              Expanded(
                  child: _buildDiamondCard(
                      "SECTOR",
                      profile['service_sector']?.toString() ?? "-",
                      Iconsax.briefcase,
                      kGoldGradientStart)),
            ],
          ),
          const SizedBox(height: 30),
          FutureBuilder<dynamic>(
            future: _attendanceFuture,
            builder: (context, snapshot) {
              double percent = 0;
              int present = 0;
              int total = 0;
              if (snapshot.hasData &&
                  snapshot.data is Map &&
                  snapshot.data['success'] == true) {
                final data = snapshot.data['data'];
                if (data is List) {
                  total = data.length;
                  present = data
                      .where((x) =>
                          x['status'].toString().toLowerCase() == 'present')
                      .length;
                  percent = total > 0 ? present / total : 0.0;
                }
              }
              return _buildGlassContainer(
                  child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _goldText("ATTENDANCE",
                              fontFamily: 'cinzel', fontSize: 14),
                          const SizedBox(height: 4),
                          Text("Yearly Overview",
                              style: GoogleFonts.poppins(
                                  color: Colors.white38, fontSize: 10)),
                        ],
                      ),
                      Text("$present / $total",
                          style: GoogleFonts.cinzel(
                              color: kPlatinum, fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LinearPercentIndicator(
                    lineHeight: 20,
                    percent: percent.clamp(0.0, 1.0),
                    animation: true,
                    barRadius: const Radius.circular(10),
                    backgroundColor: Colors.white10,
                    progressColor: kGoldGradientStart,
                    center: Text("${(percent * 100).toInt()}%",
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black)),
                  )
                ],
              ));
            },
          )
        ],
      ),
    );
  }

  Widget _buildDetailsList(
      Map<String, dynamic> profile, String tab, ProfileConfigProvider config) {
    final widgets = <Widget>[];

    void add(String l, String v) => widgets.add(_buildDetailRow(l, v));

    // Built-in
    final builtIn = _getBuiltInFields(tab);
    for (var key in builtIn) {
      if (config.isWidgetVisible(key))
        add(_getTranslatedLabel(key), _formatValue(key, profile[key]));
    }

    // Custom
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
      add(f['name'].toString(), val);
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [_buildGlassContainer(child: Column(children: widgets))],
    );
  }

  Widget _buildEducationTab(
      Map<String, dynamic> profile, ProfileConfigProvider config) {
    return ListView(
      padding: const EdgeInsets.all(24),
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

            return Column(
              children: courses.map((c) => _buildGradeItem(c)).toList(),
            );
          },
        ),
        const SizedBox(height: 30),
        _buildGlassContainer(
            child: Column(children: [
          _buildDetailRow(
              "Academic Level", profile['academic_level']?.toString() ?? '-'),
          _buildDetailRow(
              "Parent Name", profile['parent_name']?.toString() ?? '-'),
          _buildDetailRow("Parent Phone",
              profile['parent_phone_number']?.toString() ?? '-'),
        ]))
      ],
    );
  }

  // --- WIDGETS ---

  Widget _buildGlassContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1A24), // Subtle dark purple-grey
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ]),
      child: child,
    );
  }

  Widget _buildDiamondCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF20202C), kDeepOnyx]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: color.withOpacity(0.1)),
            child: Icon(icon, size: 20, color: color),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.notoSansEthiopic(
                      color: kPlatinum,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(title,
                  style: GoogleFonts.cinzel(
                      color: Colors.white30, fontSize: 10, letterSpacing: 2)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.notoSansEthiopic(
                  color: Colors.white38, fontSize: 13)),
          Text(value,
              style: GoogleFonts.notoSansEthiopic(
                  color: kPlatinum, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: kDeepOnyx,
          borderRadius: BorderRadius.circular(16),
          border: Border(
              left: BorderSide(
                  color: (score / max > 0.5) ? kGoldGradientStart : Colors.red,
                  width: 4))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(course['course_name']?.toString() ?? 'Course',
                  style: GoogleFonts.notoSansEthiopic(
                      color: kPlatinum, fontWeight: FontWeight.bold))),
          _goldText("${score.toStringAsFixed(1)}", fontSize: 18),
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

class _PremiumTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _PremiumTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height + 24;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 24;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        color: kRichBlack,
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        child: _tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
