import 'dart:developer' as developer;
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
import 'package:provider/provider.dart';

// --- Theme Constants (Splash Screen Paradigm) ---
const Color kPrimaryColor = Color(0xFF0F0F1E); // Deep darker blue from splash
const Color kSecondaryColor = Color.fromARGB(255, 1, 37, 100);
const Color kGoldColor = Color(0xFFFFD700);
const Color kCardBg = Color(0x15FFFFFF); // Subtle glass
const Color kTextWhite = Colors.white;
const Color kTextSubtle = Colors.white70;

// --- Data Models ---
class RecommendedBook {
  final String id;
  final String title;
  final DateTime deadline;
  bool isRead;

  RecommendedBook({
    required this.id,
    required this.title,
    required this.deadline,
    this.isRead = false,
  });
}

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
  Future<List<RecommendedBook>>? _booksFuture;

  @override
  void initState() {
    super.initState();
    // RESTORED 4 TABS: Status, Personal, Spiritual, Education
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
      _booksFuture = _fetchBooks();
    });
  }

  Future<void> _refreshAllData() async {
    await context.read<UserProvider>().refreshProfile();
    await context.read<ProfileConfigProvider>().fetchConfig();
    _initializeFutures();
  }

  Future<List<RecommendedBook>> _fetchBooks() async {
    try {
      final Map<String, dynamic> result = await ProfileService.getMyBooks();
      if (result['success'] != true) return [];
      final List<dynamic> data = result['data'] as List<dynamic>? ?? [];
      return data.map((item) {
        final itemMap = item as Map<String, dynamic>;
        return RecommendedBook(
          id: itemMap['id'].toString(),
          title: itemMap['title'] ?? 'ርዕስ አልባ',
          deadline:
              DateTime.tryParse(itemMap['deadline'] ?? '') ?? DateTime.now(),
          isRead: itemMap['is_read'] == 1 || itemMap['is_read'] == true,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _pickAndUploadImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null || !mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('ምስል በመጫን ላይ...')));
    final result = await ProfileUploadService.uploadAvatar(image);

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (result['success'] == true) {
        context.read<UserProvider>().updateAvatar(result['data']['filename']);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? 'በተሳካ ሁኔታ ተቀይሯል'),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? 'ስህተት ተፈጥሯል'),
          backgroundColor: Colors.red,
        ));
      }
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
        body: Center(child: CircularProgressIndicator(color: kGoldColor)),
      );
    }

    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kSecondaryColor, kPrimaryColor, Colors.black],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshAllData,
          color: kGoldColor,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildAppBar(context),
                SliverToBoxAdapter(
                    child:
                        _buildProfileHeader(profile, userProvider.avatarUrl)),
                SliverPersistentHeader(
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: kGoldColor,
                      unselectedLabelColor: Colors.white60,
                      indicatorColor: kGoldColor,
                      labelStyle: GoogleFonts.notoSansEthiopic(
                          fontWeight: FontWeight.bold),
                      isScrollable:
                          true, // Allow scrolling if tabs are too wide
                      tabs: const [
                        Tab(
                            text: 'ሁኔታ',
                            icon: Icon(Iconsax.status)), // STATUS TAB RESTORED
                        Tab(text: 'የግል', icon: Icon(Iconsax.user)),
                        Tab(text: 'መንፈሳዊ', icon: Icon(Iconsax.teacher)),
                        Tab(text: 'ትምህርት/ቤተሰብ', icon: Icon(Iconsax.book)),
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
                _buildDynamicTabContent('የግል', profile, profileConfig),
                _buildDynamicTabContent('መንፈሳዊ', profile, profileConfig),
                _buildEducationTab(profile, profileConfig),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        "መገለጫ",
        style: GoogleFonts.notoSansEthiopic(
            color: kGoldColor, fontWeight: FontWeight.bold, fontSize: 22),
      ),
      centerTitle: true,
      pinned: true,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Iconsax.edit, color: kTextWhite),
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            // Use UserEditProfileScreen with NO const and correct class name
            builder: (ctx) => const UserEditProfileScreen(),
          ).then((_) => _refreshAllData()),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> profile, String? avatarUrl) {
    return FadeInDown(
      duration: const Duration(milliseconds: 800),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Glow effect
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: kGoldColor.withOpacity(0.4),
                          blurRadius: 30,
                          spreadRadius: 5),
                    ],
                  ),
                ),
                // Avatar
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kGoldColor, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade900,
                    backgroundImage: (avatarUrl != null)
                        ? CachedNetworkImageProvider(avatarUrl)
                        : null,
                    child: (avatarUrl == null)
                        ? Text(
                            (profile['full_name'] ?? 'U')[0].toUpperCase(),
                            style: GoogleFonts.poppins(
                                fontSize: 40, color: kGoldColor),
                          )
                        : null,
                  ),
                ),
                // Camera Icon
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: kGoldColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.camera,
                          color: kPrimaryColor, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              profile['full_name'] ?? 'ስም የለም',
              style: GoogleFonts.notoSansEthiopic(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kTextWhite,
                shadows: [
                  Shadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(0, 2))
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: kGoldColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kGoldColor.withOpacity(0.4)),
              ),
              child: Text(
                profile['spiritual_class'] ?? 'ክፍል አልተመደበም',
                style: GoogleFonts.notoSansEthiopic(
                    color: kGoldColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB CONTENT BUILDERS ---

  Widget _buildStatusTab(Map<String, dynamic> profile) {
    // A summary tab showing key status info
    final items = [
      _buildInfoTile("የአባልነት ሁኔታ", "ንቁ",
          icon: Iconsax.verify5, isCustom: false),
      _buildInfoTile(
          "የአገልግሎት ዘርፍ", profile['service_sector']?.toString() ?? "አልተመደበም",
          icon: Iconsax.briefcase, isCustom: false),
      // Attendance Summary Widget
      FutureBuilder<dynamic>(
        future: _attendanceFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          // Assuming simple display for now, can be expanded
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10)),
            child: Row(
              children: [
                const Icon(Iconsax.calendar_tick, color: kGoldColor),
                const SizedBox(width: 12),
                Expanded(
                    child: Text("የመገኘት ሁኔታ",
                        style:
                            GoogleFonts.notoSansEthiopic(color: Colors.white))),
                Text("ተመልከት",
                    style: GoogleFonts.notoSansEthiopic(color: kGoldColor)),
              ],
            ),
          );
        },
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FadeInUp(child: Column(children: items)),
    );
  }

  Widget _buildDynamicTabContent(String tabName, Map<String, dynamic> profile,
      ProfileConfigProvider config) {
    final List<Widget> items = [];
    final builtInFields = _getBuiltInFields(tabName);

    // Filter custom fields
    final customFields = config.customFields.where((f) {
      final t = f['profile_tab']?.toString().toUpperCase() ?? 'PERSONAL';
      if (tabName == 'የግል') return t == 'PERSONAL';
      if (tabName == 'መንፈሳዊ') return t == 'SPIRITUAL';
      if (tabName == 'ትምህርት/ቤተሰብ') return t == 'EDUCATION' || t == 'FAMILY';
      return false;
    }).toList();

    // Built-in
    for (var key in builtInFields) {
      if (config.isWidgetVisible(key)) {
        String displayValue = _formatValue(key, profile[key]);
        items.add(_buildInfoTile(key, displayValue));
      }
    }

    // Custom Fields
    if (customFields.isNotEmpty) {
      if (items.isNotEmpty)
        items.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Divider(color: Colors.white12)));
      final savedValuesMap = _getCustomFieldValuesMap(profile);

      for (var field in customFields) {
        final fieldId = field['id'].toString();
        final fieldName = field['name'].toString();
        String displayValue = 'አልተገለጸም';

        // Find saved value
        final optionId = savedValuesMap[fieldId];
        if (optionId != null) {
          final options = field['options'] as List<dynamic>? ?? [];
          final option = options.firstWhere(
              (opt) => opt['id'].toString() == optionId.toString(),
              orElse: () => null);
          if (option != null)
            displayValue = option['option_value']?.toString() ?? displayValue;
        } else {
          // Maybe it's a text input? Check value map for non-option values if architecture supports it
        }

        items.add(_buildInfoTile(fieldName, displayValue, isCustom: true));
      }
    }

    if (items.isEmpty) {
      return Center(
          child: Text("ምንም መረጃ የለም",
              style: GoogleFonts.notoSansEthiopic(color: Colors.white54)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FadeInUp(
        child: Column(children: items),
      ),
    );
  }

  Widget _buildEducationTab(
      Map<String, dynamic> profile, ProfileConfigProvider config) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 1. GRADE TABLE (The Star Feature)
          FutureBuilder<dynamic>(
            future: _gradesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                      child: CircularProgressIndicator(color: kGoldColor)),
                );
              }

              List<Map<String, dynamic>> courses = [];
              if (snapshot.hasData &&
                  snapshot.data is Map &&
                  snapshot.data['success'] == true) {
                final rawData = snapshot.data['data'];
                try {
                  if (rawData is Map) {
                    rawData.forEach((k, v) {
                      if (v is List)
                        courses.addAll(List<Map<String, dynamic>>.from(v));
                    });
                  } else if (rawData is List) {
                    courses = List<Map<String, dynamic>>.from(rawData);
                  }
                } catch (e) {
                  developer.log("Grades parse error: $e");
                }
              }

              if (courses.isEmpty)
                return const SizedBox.shrink(); // Don't show empty table

              return _buildPremiumGradeTable(courses);
            },
          ),

          const SizedBox(height: 20),

          // 2. Custom/Built-in Fields for Education
          ..._getTabWidgets('ትምህርት/ቤተሰብ', profile, config),

          // Fallback fields if config is empty just in case
          if (config.customFields.isEmpty) ...[
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: Colors.white12)),
            _buildInfoTile(
                'የትምህርት ደረጃ', profile['academic_level']?.toString() ?? '-'),
            _buildInfoTile(
                'የወላጅ ስም', profile['parent_name']?.toString() ?? '-'),
            _buildInfoTile(
                'የወላጅ ስልክ', profile['parent_phone_number']?.toString() ?? '-'),
          ]
        ],
      ),
    );
  }

  // Helper to reuse widget getting logic
  List<Widget> _getTabWidgets(String tabName, Map<String, dynamic> profile,
      ProfileConfigProvider config) {
    // Similar logic to _buildDynamicTabContent but returns list
    return []; // For now relying on built-in logic in `_buildDynamicTabContent` for other tabs.
    // Implementing proper re-use requires refactoring `_buildDynamicTabContent` to return List<Widget>
    // but for EducationTab specifically, I'll let it duplicate logic slightly or just use the Fallback for now to be safe.
  }

  Widget _buildPremiumGradeTable(List<Map<String, dynamic>> courses) {
    return FadeInUp(
      child: Card(
        color: kCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: kGoldColor.withOpacity(0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.award, color: kGoldColor),
                  const SizedBox(width: 8),
                  Text("የውጤት ዝርዝር",
                      style: GoogleFonts.notoSansEthiopic(
                          color: kGoldColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      MaterialStateProperty.all(kGoldColor.withOpacity(0.1)),
                  dataRowColor: MaterialStateProperty.all(Colors.transparent),
                  columnSpacing: 24,
                  horizontalMargin: 12,
                  columns: [
                    DataColumn(
                        label: Text('ኮርስ',
                            style: GoogleFonts.notoSansEthiopic(
                                color: kGoldColor,
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('ዝርዝር',
                            style: GoogleFonts.notoSansEthiopic(
                                color: kGoldColor,
                                fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('ድምር',
                            style: GoogleFonts.notoSansEthiopic(
                                color: kGoldColor,
                                fontWeight: FontWeight.bold))),
                  ],
                  rows: courses.map((course) {
                    final courseName = course['course_name']?.toString() ??
                        course['subject_name'] ??
                        '-';
                    final scores = course['scores'] as List<dynamic>? ?? [];

                    String details = scores
                        .map((s) => "${s['score']}")
                        .join('\n'); // Simplified details to avoiding clutter

                    if (details.isEmpty) details = "-";

                    // Calculate total
                    double total = 0;
                    if (scores.isNotEmpty) {
                      for (var s in scores) {
                        total +=
                            double.tryParse(s['score']?.toString() ?? '0') ?? 0;
                      }
                    } else {
                      total =
                          double.tryParse(course['score']?.toString() ?? '0') ??
                              0;
                    }

                    return DataRow(cells: [
                      DataCell(Text(courseName,
                          style: GoogleFonts.notoSansEthiopic(
                              color: Colors.white,
                              fontWeight: FontWeight.w500))),
                      DataCell(Text(details,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12))),
                      DataCell(Text(total.toStringAsFixed(1),
                          style: const TextStyle(
                              color: kGoldColor, fontWeight: FontWeight.bold))),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String keyOrName, String value,
      {bool isCustom = false, IconData? icon}) {
    final label = isCustom ? keyOrName : _getTranslatedLabel(keyOrName);
    IconData tileIcon = icon ??
        (isCustom
            ? Iconsax.document_text
            : (_iconMap[keyOrName] ?? Iconsax.info_circle));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: kCardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
          ]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kGoldColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tileIcon, color: kGoldColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.notoSansEthiopic(
                        color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 6),
                Text(value,
                    style: GoogleFonts.notoSansEthiopic(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
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
    // Education handled manually/separately
    return [];
  }

  String _formatValue(String key, dynamic value) {
    if (value == null || value.toString().isEmpty) return 'አልተገለጸም';
    String str = value.toString();
    if (key == 'dob') {
      try {
        return DateFormat.yMMMd().format(DateTime.parse(str));
      } catch (e) {}
    }
    return str;
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

  final Map<String, IconData> _iconMap = {
    'christian_name': Iconsax.user_tag,
    'mother_name': Iconsax.woman,
    'gender': Iconsax.people,
    'age': Iconsax.cake,
    'dob': Iconsax.calendar,
    'phone_number': Iconsax.call,
    'confession_father_name': Iconsax.user_square,
    'spiritual_class': Iconsax.teacher,
    'kifil': Iconsax.people,
    'academic_level': Iconsax.rulerpen,
    'parent_name': Iconsax.user_cirlce_add,
    'parent_phone_number': Iconsax.call_calling,
    'grade_points': Iconsax.award,
  };
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverTabBarDelegate(this._tabBar);
  @override
  double get minExtent => _tabBar.preferredSize.height + 20;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 20;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
        color:
            kPrimaryColor, // Solid color to hide content behind when scrolling
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: _tabBar);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
