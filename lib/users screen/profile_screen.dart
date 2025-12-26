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

// --- Safe Luxury Theme ---
const Color kPrimaryColor = Color(0xFF0F0F1E);
const Color kDarkAccent = Color(0xFF1A1A2E);
const Color kGoldColor = Color(0xFFFFD700);
const Color kSurfaceColor = Color(0xFF252535);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();
  // Removed custom scroll controller for NestedScrollView to rely on default behavior which is often safer for Slivers

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
                delegate: _StickyTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: kGoldColor,
                    unselectedLabelColor: Colors.white60,
                    indicatorColor: kGoldColor,
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.notoSansEthiopic(
                        fontWeight: FontWeight.bold),
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
              _buildDynamicTab(profile, 'የግል', profileConfig),
              _buildDynamicTab(profile, 'መንፈሳዊ', profileConfig),
              _buildEducationTab(profile, profileConfig),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: kPrimaryColor,
      pinned: true,
      elevation: 0,
      centerTitle: true,
      title: Text("መገለጫ",
          style: GoogleFonts.notoSansEthiopic(
              color: kGoldColor, fontWeight: FontWeight.bold)),
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

  Widget _buildHeader(Map<String, dynamic> profile, String? avatarUrl) {
    return Container(
      color: kPrimaryColor, // Ensure opaque background behind scroll
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kGoldColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: kGoldColor.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2)
                    ]),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: kSurfaceColor,
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
              Positioned(
                right: 0,
                bottom: 0,
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
          Text(profile['full_name'] ?? 'User',
              style: GoogleFonts.notoSansEthiopic(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: kGoldColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kGoldColor.withOpacity(0.5))),
            child: Text(profile['spiritual_class'] ?? 'No Class',
                style: GoogleFonts.notoSansEthiopic(
                    color: kGoldColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // --- TABS ---

  Widget _buildStatusTab(Map<String, dynamic> profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildDetailCard(
                      "Status", "Active", Iconsax.verify, Colors.greenAccent)),
              const SizedBox(width: 15),
              Expanded(
                  child: _buildDetailCard(
                      "Sector",
                      profile['service_sector']?.toString() ?? "-",
                      Iconsax.briefcase,
                      kGoldColor)),
            ],
          ),
          const SizedBox(height: 20),
          FutureBuilder<dynamic>(
            future: _attendanceFuture,
            builder: (context, snapshot) {
              // Safe parsing logic
              double percent = 0.0;
              int present = 0;
              int total = 0;
              if (snapshot.hasData &&
                  snapshot.data is Map &&
                  snapshot.data['success'] == true) {
                final list = snapshot.data['data'];
                if (list is List && list.isNotEmpty) {
                  total = list.length;
                  present = list
                      .where((i) =>
                          i['status']?.toString().toLowerCase() == 'present')
                      .length;
                  percent = total > 0 ? present / total : 0.0;
                }
              }

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kSurfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    CircularPercentIndicator(
                      radius: 40,
                      lineWidth: 6,
                      percent: percent.clamp(0.0, 1.0),
                      center: Text("${(percent * 100).toStringAsFixed(0)}%",
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      progressColor: kGoldColor,
                      backgroundColor: Colors.white10,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Attendance Rate",
                            style: GoogleFonts.poppins(
                                color: kGoldColor,
                                fontWeight: FontWeight.bold)),
                        Text("$present out of $total sessions",
                            style: GoogleFonts.poppins(
                                color: Colors.white54, fontSize: 12)),
                      ],
                    )),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicTab(Map<String, dynamic> profile, String tabName,
      ProfileConfigProvider config) {
    final builtIn = _getBuiltInFields(tabName);
    final custom = config.customFields.where((f) {
      final t = f['profile_tab']?.toString().toUpperCase() ?? 'PERSONAL';
      if (tabName == 'የግል') return t == 'PERSONAL';
      if (tabName == 'መንፈሳዊ') return t == 'SPIRITUAL';
      return false;
    }).toList();

    List<Widget> items = [];
    for (var key in builtIn) {
      if (config.isWidgetVisible(key)) {
        items.add(_buildInfoRow(key, _formatValue(key, profile[key])));
      }
    }

    // Add custom fields
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
      items.add(_buildInfoRow(name, val, isCustom: true));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: kSurfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10)),
        child: Column(children: items),
      ),
    );
  }

  Widget _buildEducationTab(
      Map<String, dynamic> profile, ProfileConfigProvider config) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
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
                else if (d is List)
                  courses = List<Map<String, dynamic>>.from(d);
              } catch (e) {}

              if (courses.isEmpty) return const SizedBox.shrink();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: courses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, idx) {
                  final c = courses[idx];
                  double score = 0;
                  double max = 100;
                  try {
                    final sList = c['scores'];
                    if (sList is List && sList.isNotEmpty) {
                      for (var s in sList)
                        score +=
                            double.tryParse(s['score']?.toString() ?? '0') ?? 0;
                    } else {
                      score =
                          double.tryParse(c['score']?.toString() ?? '0') ?? 0;
                      max = double.tryParse(
                              c['total_marks']?.toString() ?? '100') ??
                          100;
                    }
                  } catch (e) {}
                  if (max <= 0) max = 100;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: kSurfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10)),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                                c['course_name']?.toString() ?? 'Subject',
                                style: GoogleFonts.notoSansEthiopic(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                        Text(
                            "${score.toStringAsFixed(1)} / ${max.toStringAsFixed(0)}",
                            style: GoogleFonts.poppins(
                                color: kGoldColor,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
                color: kSurfaceColor, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              _buildInfoRow("Academic Level",
                  profile['academic_level']?.toString() ?? '-',
                  isCustom: true),
              _buildInfoRow(
                  "Parent Name", profile['parent_name']?.toString() ?? '-',
                  isCustom: true),
              _buildInfoRow("Parent Phone",
                  profile['parent_phone_number']?.toString() ?? '-',
                  isCustom: true),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: kSurfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value,
              style: GoogleFonts.notoSansEthiopic(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          Text(title,
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, {bool isCustom = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isCustom ? title : _getTranslatedLabel(title),
              style: GoogleFonts.notoSansEthiopic(
                  color: Colors.white54, fontSize: 13)),
          Text(value,
              style: GoogleFonts.notoSansEthiopic(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ],
      ),
    );
  }

  // --- Helpers ---
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

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _StickyTabBarDelegate(this._tabBar);

  @override
  double get minExtent =>
      _tabBar.preferredSize.height + 20; // Exact match padded height
  @override
  double get maxExtent => _tabBar.preferredSize.height + 20;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        color: kPrimaryColor, // Solid bg to handle pinned state cleanly
        padding:
            const EdgeInsets.symmetric(vertical: 10), // Matches extent padding
        child: _tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
