import 'dart:developer' as developer;
import 'package:amde_haymanot_abalat_guday/providers/profile_config_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/profile_service.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/edit_profile_sheet.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/uploadpp.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

// --- Constants ---
const Color primaryColor = Color.fromARGB(255, 1, 37, 100);
const Color accentColor = Color(0xFFFFD700);
const Color surfaceColor = Color(0xFFF4F7FC);
const Color onSurfaceColor = Color(0xFF212529);
const Color subtleTextColor = Color(0xFF6C757D);
const Color successColor = Color(0xFF198754);
const Color warningColor = Color(0xFFFFA500);
const Color dangerColor = Color(0xFFDC3545);

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

// --- Main Widget ---
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  // --- Controllers ---
  late TabController _mainTabController;
  late TabController _bookTabController;

  // --- State Variables ---
  Future<Map<String, dynamic>>? _attendanceFuture;
  Future<Map<String, dynamic>>? _gradesFuture;
  Future<List<RecommendedBook>>? _booksFuture;
  String? _selectedGradeYearKey;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 4, vsync: this);
    _bookTabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize futures only once
    if (_attendanceFuture == null) {
      _initializeFutures();
    }
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _bookTabController.dispose();
    super.dispose();
  }

  // --- Data Handling Methods ---
  void _initializeFutures() {
    setState(() {
      _attendanceFuture = ProfileService.getMyAttendance();
      _gradesFuture = ProfileService.getMyGrades();
      _booksFuture = _fetchBooks();
      _selectedGradeYearKey = null; // Reset on initialization
    });
  }

  Future<void> _refreshAllData() async {
    // Refresh user profile data from the provider first
    await context.read<UserProvider>().refreshProfile();
    // Re-initialize all futures to fetch fresh data
    _initializeFutures();
  }

  Future<List<RecommendedBook>> _fetchBooks() async {
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
  }

  // --- UI Interaction Methods ---
  Future<void> _pickAndUploadImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image == null || !mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('ምስል በመጫን ላይ...')));

    final result = await ProfileUploadService.uploadAvatar(image);

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'ስህተት ተፈጥሯል'),
        backgroundColor:
            (result['success'] ?? false) ? successColor : dangerColor,
      ));
      if (result['success'] == true) {
        context.read<UserProvider>().updateAvatar(result['data']['filename']);
      }
    }
  }

  Future<void> _handleBookStatusChange(
      RecommendedBook book, bool? isRead) async {
    if (isRead == null) return;
    final result = await ProfileService.updateBookStatus(book.id, isRead);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'ስህተት ተፈጥሯል'),
        backgroundColor:
            (result['success'] ?? false) ? successColor : dangerColor,
      ));
      if (result['success'] == true) {
        // Refresh data to show updated book status
        _initializeFutures();
      }
    }
  }

  // --- Translation Helper ---
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
    };
    return translations[key] ?? key.replaceAll('_', ' ').capitalize();
  }

  // --- Build Methods ---
  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final profileConfig = context.watch<ProfileConfigProvider>();
    final profile = userProvider.userProfile;

    if (userProvider.isLoading || profileConfig.isLoading || profile == null) {
      return const Scaffold(
        backgroundColor: surfaceColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: surfaceColor,
      body: RefreshIndicator(
        onRefresh: _refreshAllData,
        child: ListView(
          children: [
            _buildProfileHeader(profile, userProvider.avatarUrl),
            _buildTabBar(),
            SizedBox(
              // Adjust height to prevent overflow issues
              height: MediaQuery.of(context).size.height * 1.5,
              child: TabBarView(
                controller: _mainTabController,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  _buildStatusTab(profile),
                  _buildInfoTab('የግል', profile, profileConfig),
                  _buildInfoTab('መንፈሳዊ', profile, profileConfig),
                  _buildInfoTab('ትምህርት እና ቤተሰብ', profile, profileConfig),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final didUpdate = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const UserEditProfileScreen()),
          );
          if (didUpdate == true && mounted) {
            _refreshAllData();
          }
        },
        backgroundColor: primaryColor,
        tooltip: 'መገለጫዬን አስተካክል',
        child: const Icon(Iconsax.edit, color: accentColor),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> profile, String? avatarUrl) {
    // Unique tag for the Hero animation
    final String heroTag = 'profileAvatar-${profile['id']}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      color: surfaceColor,
      child: Column(
        children: [
          Hero(
            tag: heroTag,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: primaryColor,
                  child: ClipOval(
                    child: avatarUrl != null
                        ? CachedNetworkImage(
                            imageUrl: avatarUrl,
                            width: 112,
                            height: 112,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 112,
                              height: 112,
                              color: primaryColor.withOpacity(0.2),
                              child: const Icon(Iconsax.user,
                                  size: 50, color: accentColor),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Iconsax.user,
                              size: 50,
                              color: accentColor,
                            ),
                          )
                        : const Icon(Iconsax.user,
                            size: 50, color: accentColor),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: accentColor,
                      child:
                          Icon(Iconsax.camera, color: primaryColor, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile['full_name']?.toString() ?? 'በመጫን ላይ...',
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: onSurfaceColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile['email']?.toString() ?? '',
            style: GoogleFonts.poppins(fontSize: 16, color: subtleTextColor),
          ),
        ],
      ),
    );
  }

  TabBar _buildTabBar() => TabBar(
        controller: _mainTabController,
        isScrollable: true,
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: primaryColor,
        tabs: const [
          Tab(icon: Icon(Iconsax.chart_21), text: "ሁኔታ"),
          Tab(icon: Icon(Iconsax.user), text: "የግል"),
          Tab(icon: Icon(Iconsax.teacher), text: "መንፈሳዊ"),
          Tab(icon: Icon(Iconsax.book), text: "ትምህርት እና ቤተሰብ"),
        ],
      );

  // --- Tab Content Widgets ---
  Widget _buildStatusTab(Map<String, dynamic> profile) => ListView(
        key: const PageStorageKey('status'),
        padding: const EdgeInsets.all(16),
        children: [
          _buildServiceStatusCard(profile),
          const SizedBox(height: 16),
          _buildAttendanceCard(),
          const SizedBox(height: 16),
          _buildGradesCard(),
          const SizedBox(height: 16),
          _buildBookCard(),
        ],
      );

  Widget _buildInfoTab(String tabTitle, Map<String, dynamic> profile,
      ProfileConfigProvider config) {
    final widgetsForThisTab = _buildInfoWidgets(tabTitle, profile, config);
    if (widgetsForThisTab.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'ለዚህ ክፍል ምንም የመረጃ መስኮች አልተዋቀሩም።',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color.fromARGB(255, 253, 253, 253), fontSize: 16),
          ),
        ),
      );
    }
    return ListView(
      key: PageStorageKey(tabTitle),
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 4,
          shadowColor: primaryColor.withOpacity(0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              children: ListTile.divideTiles(
                      context: context, tiles: widgetsForThisTab)
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildInfoWidgets(String tabTitle, Map<String, dynamic> profile,
      ProfileConfigProvider config) {
    final List<Widget> widgets = [];
    final Map<String, List<String>> builtInFieldMap = {
      'የግል': [
        'christian_name',
        'mother_name',
        'gender',
        'age',
        'dob',
        'phone_number'
      ],
      'መንፈሳዊ': ['confession_father_name', 'spiritual_class', 'kifil'],
      'ትምህርት እና ቤተሰብ': ['academic_level', 'parent_name', 'parent_phone_number'],
    };
    final Map<String, IconData> iconMap = {
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
    };

    // --- Built-in Fields ---
    final List<String> builtInKeysForTab = builtInFieldMap[tabTitle] ?? [];
    for (var key in builtInKeysForTab) {
      if (config.isWidgetVisible(key)) {
        String? displayValue = profile[key]?.toString();
        // Special formatting for age and date of birth
        if (key == 'age' &&
            profile['dob'] != null &&
            profile['dob'].toString().isNotEmpty) {
          try {
            final birthDate = DateTime.parse(profile['dob'].toString());
            int age = DateTime.now().year - birthDate.year;
            if (DateTime.now().month < birthDate.month ||
                (DateTime.now().month == birthDate.month &&
                    DateTime.now().day < birthDate.day)) {
              age--;
            }
            displayValue = age.toString();
          } catch (e) {/* Fallback to stored value */}
        } else if (key == 'dob' &&
            displayValue != null &&
            displayValue.isNotEmpty) {
          try {
            displayValue =
                DateFormat.yMMMd().format(DateTime.parse(displayValue));
          } catch (e) {/* Fallback to raw string */}
        }
        widgets.add(_buildInfoTile(iconMap[key] ?? Iconsax.info_circle,
            _getTranslatedLabel(key), displayValue));
      }
    }

    // --- Custom Fields ---
    final customFieldsForThisTab = config.customFields.where((field) {
      final fieldMap = field as Map<String, dynamic>;
      final fieldTab = fieldMap['profile_tab']?.toString() ?? 'PERSONAL';
      if (tabTitle == 'ትምህርት እና ቤተሰብ') {
        return fieldTab == 'EDUCATION' || fieldTab == 'FAMILY';
      }
      return fieldTab == tabTitle.toUpperCase();
    }).toList();

    // This safely handles both map and list structures for custom field values.
    final savedValuesMap =
        (profile['custom_field_values'] is Map<String, dynamic>)
            ? profile['custom_field_values'] as Map<String, dynamic>
            : {
                for (var v
                    in (profile['custom_field_values'] as List<dynamic>? ?? []))
                  v['field_id'].toString(): v['option_id']
              };

    if (widgets.isNotEmpty && customFieldsForThisTab.isNotEmpty) {
      widgets.add(const Divider(height: 1, indent: 20, endIndent: 20));
    }

    for (var fieldTemplate in customFieldsForThisTab) {
      final fieldMap = fieldTemplate as Map<String, dynamic>;
      String displayValue = 'አልተገለጸም';
      final selectedOptionId = savedValuesMap[fieldMap['id'].toString()];

      if (selectedOptionId != null) {
        final options = fieldMap['options'] as List<dynamic>? ?? [];
        try {
          final selectedOption = options.firstWhere(
              (opt) => opt['id'].toString() == selectedOptionId.toString());
          displayValue =
              selectedOption['option_value']?.toString() ?? 'አልተገለጸም';
        } catch (e) {
          developer.log(
              'Error finding option for custom field ${fieldMap['id']}: $e');
        }
      }
      widgets.add(_buildInfoTile(
          Iconsax.document_filter, fieldMap['name'], displayValue));
    }

    // Remove last divider if it exists
    if (widgets.isNotEmpty && widgets.last is Divider) {
      widgets.removeLast();
    }

    return widgets;
  }

  // --- Card Widgets for Status Tab ---
  Widget _buildServiceStatusCard(Map<String, dynamic> profile) {
    final status = profile['service_status']?.toString() ?? 'Inactive';
    IconData icon;
    Color color;
    String statusText;

    switch (status) {
      case 'Active':
        icon = Iconsax.award;
        color = successColor;
        statusText = 'በአገልግሎት ላይ';
        break;
      case 'OnBreak':
        icon = Iconsax.timer_pause;
        color = warningColor;
        statusText = 'በእረፍት ላይ';
        break;
      default:
        icon = Iconsax.forbidden_2;
        color = dangerColor;
        statusText = 'አገልግሎት ላይ ያልሆነ';
    }
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(children: [
          Text('የአገልግሎት ሁኔታ',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor)),
          const SizedBox(height: 16),
          Icon(icon, size: 50, color: color),
          const SizedBox(height: 8),
          Text(statusText,
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          const Text('ይህ ሁኔታ የሚተዳደረው በአስተዳደሩ ነው።',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center)
        ]),
      ),
    );
  }

  Widget _buildAttendanceCard() => FutureBuilder<Map<String, dynamic>>(
      future: _attendanceFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!['success'] != true) {
          return const SizedBox.shrink();
        }
        final history = snapshot.data!['data'] as List<dynamic>? ?? [];
        if (history.isEmpty) return const SizedBox.shrink();

        final stats = _calculateAttendanceStats(history);
        final percentage = (stats['percentage'] ?? 0.0) / 100.0;
        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: onSurfaceColor,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("የመገኘት ማጠቃለያ",
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  flex: 2,
                  child: CircularPercentIndicator(
                    radius: 60.0,
                    lineWidth: 12.0,
                    animation: true,
                    percent: percentage,
                    center: Text("${(percentage * 100).toStringAsFixed(0)}%",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: accentColor)),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: accentColor,
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(children: [
                    _buildStatRow("ጠቅላላ", stats['totalSessions'],
                        Iconsax.activity, Colors.white),
                    _buildStatRow("የተገኘ", stats['present'], Iconsax.user_tick,
                        successColor),
                    _buildStatRow("ያልተገኘ", stats['absent'], Iconsax.user_minus,
                        dangerColor),
                    _buildStatRow(
                        "ያረፈደ", stats['late'], Iconsax.clock, warningColor),
                  ]),
                ),
              ]),
            ]),
          ),
        );
      });

  Widget _buildGradesCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _gradesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!['success'] != true) {
          return const SizedBox.shrink();
        }

        final gradeHistory = (snapshot.data!['data'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        if (gradeHistory.isEmpty) return const SizedBox.shrink();

        // Initialize the selected year key if it's null
        if (_selectedGradeYearKey == null && gradeHistory.isNotEmpty) {
          final firstEntry = gradeHistory.first;
          _selectedGradeYearKey =
              "${firstEntry['spiritualClass']} - ${firstEntry['academicYear']}";
        }

        final selectedYearData = gradeHistory.firstWhere(
          (g) =>
              "${g['spiritualClass']} - ${g['academicYear']}" ==
              _selectedGradeYearKey,
          orElse: () => gradeHistory.first, // Fallback
        );
        final gradesForTable =
            (selectedYearData['grades'] as List<dynamic>? ?? []);

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: onSurfaceColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("የትምህርት ውጤት መረጃ",
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    DropdownButton<String>(
                      value: _selectedGradeYearKey,
                      dropdownColor: onSurfaceColor,
                      style: GoogleFonts.notoSansEthiopic(color: Colors.white),
                      icon:
                          const Icon(Iconsax.arrow_down_1, color: accentColor),
                      underline: const SizedBox.shrink(),
                      items: gradeHistory.map((historyEntry) {
                        final key =
                            "${historyEntry['spiritualClass']} - ${historyEntry['academicYear']}";
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(key),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedGradeYearKey = newValue;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DataTable(
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white70),
                  dataRowMinHeight: 40,
                  dataRowMaxHeight: 48,
                  columns: const [
                    DataColumn(label: Text('የትምህርት ዓይነት')),
                    DataColumn(label: Text('ጠቅላላ'), numeric: true),
                  ],
                  rows: gradesForTable.map((grade) {
                    double total = (grade['total'] as num?)?.toDouble() ?? 0.0;
                    Color gradeColor = total >= 85
                        ? successColor
                        : (total >= 50 ? warningColor : dangerColor);
                    return DataRow(cells: [
                      DataCell(Text(grade['courseName']?.toString() ?? '',
                          style: const TextStyle(color: Colors.white))),
                      DataCell(Text("${total.toStringAsFixed(1)}%",
                          style: TextStyle(
                              color: gradeColor, fontWeight: FontWeight.bold))),
                    ]);
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookCard() => FutureBuilder<List<RecommendedBook>>(
      future: _booksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        final allBooks = snapshot.data!;
        final unreadBooks = allBooks.where((book) => !book.isRead).toList();
        final readBooks = allBooks.where((book) => book.isRead).toList();
        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: onSurfaceColor,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("የንባብ ጉዞ",
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 16),
              TabBar(
                  controller: _bookTabController,
                  labelColor: accentColor,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: accentColor,
                  tabs: [
                    Tab(text: 'ለማንበብ (${unreadBooks.length})'),
                    Tab(text: 'የተጠናቀቁ (${readBooks.length})'),
                  ]),
              const SizedBox(height: 12),
              SizedBox(
                height: 150, // Constrain height for the TabBarView
                child: TabBarView(
                  controller: _bookTabController,
                  children: [
                    _buildBookListView(unreadBooks),
                    _buildBookListView(readBooks),
                  ],
                ),
              ),
            ]),
          ),
        );
      });

  // --- Helper Widgets ---
  Widget _buildStatRow(String label, int value, IconData icon, Color color) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text("$label:", style: const TextStyle(color: Colors.white70)),
          const Spacer(),
          Text(value.toString(),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
      );

  Widget _buildBookListView(List<RecommendedBook> books) {
    if (books.isEmpty) {
      return const Center(
        child: Text("በዚህ ምድብ ውስጥ መጽሐፍት የሉም።",
            style: TextStyle(color: Colors.white70)),
      );
    }
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        final isOverdue =
            book.deadline.isBefore(DateTime.now()) && !book.isRead;
        return ListTile(
          leading: Checkbox(
            value: book.isRead,
            onChanged: (val) => _handleBookStatusChange(book, val),
            activeColor: accentColor,
            checkColor: primaryColor,
          ),
          title: Text(book.title,
              style: TextStyle(
                  color: Colors.white,
                  decoration: book.isRead ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.white54)),
          subtitle: Text("መመለሻ ቀን: ${DateFormat.yMMMd().format(book.deadline)}",
              style: TextStyle(
                  fontSize: 12, color: isOverdue ? dangerColor : warningColor)),
        );
      },
    );
  }

  Map<String, dynamic> _calculateAttendanceStats(List<dynamic> history) {
    int present =
        history.where((r) => r['status']?.toString() == 'present').length;
    int absent =
        history.where((r) => r['status']?.toString() == 'absent').length;
    int late = history.where((r) => r['status']?.toString() == 'late').length;
    int total = history.length;
    double percentage = total > 0 ? ((present + late) / total * 100) : 0.0;
    return {
      'totalSessions': total,
      'present': present,
      'absent': absent,
      'late': late,
      'percentage': percentage,
    };
  }

  Widget _buildInfoTile(IconData icon, String label, dynamic value) => ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        leading: Icon(icon, color: primaryColor, size: 28),
        title: Text(label,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 255, 255, 255),
                fontSize: 16)),
        trailing: Text(
          (value?.toString().isNotEmpty ?? false)
              ? value.toString()
              : 'አልተገለጸም',
          style: GoogleFonts.notoSansEthiopic(color: accentColor, fontSize: 16),
          textAlign: TextAlign.right,
        ),
      );
}

// --- Extensions ---
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
