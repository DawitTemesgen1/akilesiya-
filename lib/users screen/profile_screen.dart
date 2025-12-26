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

// --- ROYAL ELEGANCE THEME ---
const Color kDeepBlue = Color(0xFF0F172A);
const Color kPaperBlack = Color(0xFF000000);
const Color kGoldPrimary = Color(0xFFFFD700);
const Color kGoldMuted = Color(0xFFC5A000);
const Color kCleanWhite = Color(0xFFFFFFFF);
const Color kGlassWhite = Color(0x1AFFFFFF);

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
          backgroundColor: kPaperBlack,
          body: Center(child: CircularProgressIndicator(color: kGoldPrimary)));
    }

    return Scaffold(
      backgroundColor: kPaperBlack,
      body: Stack(
        children: [
          // Background Gradient (Subtle)
          Container(
            decoration: BoxDecoration(
                gradient: RadialGradient(
              center: const Alignment(0, -0.6),
              radius: 1.2,
              colors: [Color(0xFF1E2838), kPaperBlack],
            )),
          ),

          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildSliverAppBar(context),
                SliverToBoxAdapter(
                  child: _buildHeroProfile(profile, userProvider.avatarUrl),
                ),
                SliverPersistentHeader(
                  delegate: _ElegantTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: kPaperBlack,
                      unselectedLabelColor: Colors.white54,
                      labelStyle: GoogleFonts.notoSansEthiopic(
                          fontWeight: FontWeight.bold, fontSize: 13),
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: kGoldPrimary,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      labelPadding: EdgeInsets.zero,
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
                _buildStatusTab(profile),
                _buildDetailsList(profile, 'የግል', profileConfig),
                _buildDetailsList(profile, 'መንፈሳዊ', profileConfig),
                _buildEducationTab(profile, profileConfig),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text("MY PROFILE",
          style: GoogleFonts.cinzel(
              color: kGoldPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2)),
      actions: [
        IconButton(
          icon: const Icon(Iconsax.edit, color: kCleanWhite),
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

  Widget _buildHeroProfile(Map<String, dynamic> profile, String? avatarUrl) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Avatar Ring
        GestureDetector(
          onTap: _pickAndUploadImage,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: kGoldMuted.withOpacity(0.3), width: 1),
                ),
              ),
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: (avatarUrl != null)
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(avatarUrl),
                            fit: BoxFit.cover)
                        : null,
                    color: kDeepBlue,
                    border: Border.all(color: kGoldPrimary, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: kGoldPrimary.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5)
                    ]),
                child: (avatarUrl == null)
                    ? Center(
                        child: Text(
                            (profile['full_name'] ?? 'U')[0].toUpperCase(),
                            style: GoogleFonts.cinzel(
                                fontSize: 40, color: kGoldPrimary)))
                    : null,
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                      color: kGoldPrimary, shape: BoxShape.circle),
                  child:
                      const Icon(Iconsax.camera, size: 14, color: kPaperBlack),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(profile['full_name'] ?? 'Nom de l\'utilisateur',
            style: GoogleFonts.notoSansEthiopic(
                fontSize: 26, color: kCleanWhite, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
              border: Border.all(color: kGoldPrimary.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(20)),
          child: Text(profile['spiritual_class'] ?? 'No Class',
              style: GoogleFonts.notoSansEthiopic(
                  color: kGoldPrimary, fontSize: 12, letterSpacing: 1.2)),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // --- TABS CONTENT ---

  Widget _buildStatusTab(Map<String, dynamic> profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildEleganceCard(
                      "Status", "Active", Iconsax.verify5, Colors.greenAccent)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildEleganceCard(
                      "Sector",
                      profile['service_sector']?.toString() ?? "-",
                      Iconsax.briefcase,
                      kGoldPrimary)),
            ],
          ),
          const SizedBox(height: 24),
          FutureBuilder<dynamic>(
            future: _attendanceFuture,
            builder: (context, snapshot) {
              double percent = 0;
              int present = 0;
              int total = 0;
              if (snapshot.hasData &&
                  snapshot.data is Map &&
                  snapshot.data['success'] == true) {
                final l = snapshot.data['data'];
                if (l is List) {
                  total = l.length;
                  present = l
                      .where((i) =>
                          i['status'].toString().toLowerCase() == 'present')
                      .length;
                  percent = total > 0 ? present / total : 0.0;
                }
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: kGlassWhite),
                  color: kGlassWhite,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ATTENDANCE",
                            style: GoogleFonts.cinzel(
                                color: kGoldPrimary,
                                fontWeight: FontWeight.bold)),
                        Text("${(percent * 100).toInt()}%",
                            style: GoogleFonts.cinzel(
                                color: kCleanWhite,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearPercentIndicator(
                      lineHeight: 8,
                      percent: percent.clamp(0.0, 1.0),
                      backgroundColor: Colors.white10,
                      progressColor: kGoldPrimary,
                      barRadius: const Radius.circular(4),
                      animation: true,
                    ),
                    const SizedBox(height: 16),
                    Text("$present sessions attended out of $total total.",
                        style: GoogleFonts.notoSansEthiopic(
                            color: Colors.white54, fontSize: 13)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsList(
      Map<String, dynamic> profile, String tab, ProfileConfigProvider config) {
    final widgets = <Widget>[];

    // Built-ins
    final builtIn = _getBuiltInFields(tab);
    for (var key in builtIn) {
      if (config.isWidgetVisible(key)) {
        widgets.add(_buildRowItem(key, _formatValue(key, profile[key])));
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
      String val = '-';
      final optId = savedValues[field['id'].toString()];
      if (optId != null) {
        final options = field['options'] as List<dynamic>? ?? [];
        final opt = options.firstWhere(
            (o) => o['id'].toString() == optId.toString(),
            orElse: () => null);
        val = opt?['option_value']?.toString() ?? '-';
      }
      widgets.add(_buildRowItem(name, val, isCustom: true));
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              color: kGlassWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Column(children: widgets),
        )
      ],
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
              children: courses.map((c) => _buildGradeRow(c)).toList(),
            );
          },
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
              color: kGlassWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Column(children: [
            _buildRowItem(
                "Academic Level", profile['academic_level']?.toString() ?? '-',
                isCustom: true),
            _buildRowItem(
                "Parent Name", profile['parent_name']?.toString() ?? '-',
                isCustom: true),
            _buildRowItem("Parent Phone",
                profile['parent_phone_number']?.toString() ?? '-',
                isCustom: true),
          ]),
        )
      ],
    );
  }

  // --- WIDGETS ---

  Widget _buildEleganceCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 120,
      decoration: BoxDecoration(
          color: kGlassWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(value,
              style: GoogleFonts.notoSansEthiopic(
                  color: kCleanWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          Text(title,
              style: GoogleFonts.cinzel(
                  color: kGoldMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRowItem(String title, String value, {bool isCustom = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isCustom ? title : _getTranslatedLabel(title),
              style: GoogleFonts.notoSansEthiopic(
                  color: Colors.white54, fontSize: 13)),
          Text(value,
              style: GoogleFonts.notoSansEthiopic(
                  color: kCleanWhite,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildGradeRow(Map<String, dynamic> course) {
    double score = 0;
    double max = 100;
    try {
      final s = course['scores'];
      if (s is List && s.isNotEmpty) {
        for (var i in s) score += double.tryParse(i['score'].toString()) ?? 0;
      } else {
        score = double.tryParse(course['score'].toString()) ?? 0;
        max = double.tryParse(course['total_marks'].toString()) ?? 100;
      }
    } catch (e) {}
    if (max <= 0) max = 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
          color: kGlassWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.02))),
      child: Row(
        children: [
          Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                  color: (score / max > 0.5) ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 16),
          Expanded(
              child: Text(course['course_name']?.toString() ?? 'Course',
                  style: GoogleFonts.notoSansEthiopic(
                      color: kCleanWhite, fontWeight: FontWeight.bold))),
          Text(score.toStringAsFixed(1),
              style: GoogleFonts.cinzel(
                  color: kGoldPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          Text("/${max.toInt()}",
              style: GoogleFonts.cinzel(color: Colors.white30, fontSize: 12)),
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

class _ElegantTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _ElegantTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height + 30;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 30;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        color: kPaperBlack,
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        child: _tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
