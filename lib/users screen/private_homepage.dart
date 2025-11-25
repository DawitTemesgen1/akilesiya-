import 'package:amde_haymanot_abalat_guday/services/refresh_ervice.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer';

import 'package:amde_haymanot_abalat_guday/services/private_feed_service.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';

// --- Re-usable UI Constants ---
const Color primaryColor = Color.fromARGB(255, 1, 37, 100);
const Color onSurfaceColor = Color(0xFF212529);

// ===============================================================
// MAIN CLASS: EthiopianDate (የኢትዮጵያ ቀን)
// ===============================================================
class EthiopianDate {
  final int year;
  final int month;
  final int day;

  const EthiopianDate(
      {required this.year, required this.month, required this.day});

  factory EthiopianDate.now() {
    return EthiopianDate.fromGregorian(DateTime.now());
  }

  factory EthiopianDate.parse(String formattedString) {
    try {
      final parts = formattedString.split('T')[0].split('-');
      if (parts.length != 3) {
        return EthiopianDate.now();
      }
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      return EthiopianDate(year: year, month: month, day: day);
    } catch (e) {
      return EthiopianDate.now();
    }
  }

  factory EthiopianDate.fromGregorian(DateTime gregorianDate) {
    final jdn = _gregorianToJDN(
        gregorianDate.year, gregorianDate.month, gregorianDate.day);
    return _jdnToEthiopian(jdn);
  }

  DateTime toGregorian() {
    final jdn = _ethiopianToJDN(year, month, day);
    return _jdnToGregorian(jdn);
  }

  String toDatabaseString() {
    return "${year.toString()}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
  }

  bool get isLeapYear => (year % 4) == 3;

  int get daysInMonth {
    if (month == 13) return isLeapYear ? 6 : 5;
    return 30;
  }

  String format(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (month < 1 || month > 13) return loc.dateInvalidDate;

    String monthName;
    switch (month) {
      case 1:
        monthName = loc.monthMeskerem;
        break;
      case 2:
        monthName = loc.monthTikimt;
        break;
      case 3:
        monthName = loc.monthHidar;
        break;
      case 4:
        monthName = loc.monthTahsas;
        break;
      case 5:
        monthName = loc.monthTir;
        break;
      case 6:
        monthName = loc.monthYekatit;
        break;
      case 7:
        monthName = loc.monthMegabit;
        break;
      case 8:
        monthName = loc.monthMiyazya;
        break;
      case 9:
        monthName = loc.monthGinbot;
        break;
      case 10:
        monthName = loc.monthSene;
        break;
      case 11:
        monthName = loc.monthHamle;
        break;
      case 12:
        monthName = loc.monthNehase;
        break;
      case 13:
        monthName = loc.monthPagume;
        break;
      default:
        monthName = '';
    }
    return '$monthName $day, $year';
  }

  static const int _jdnOffset = 1723856;

  static EthiopianDate _jdnToEthiopian(int jdn) {
    int r = (jdn - _jdnOffset) % 1461;
    int n = (r % 365) + 365 * (r ~/ 1460);
    int year = 4 * ((jdn - _jdnOffset) ~/ 1461) + (r ~/ 365) - (r ~/ 1460);
    int month = (n ~/ 30) + 1;
    int day = (n % 30) + 1;
    return EthiopianDate(year: year, month: month, day: day);
  }

  static int _ethiopianToJDN(int year, int month, int day) {
    return (_jdnOffset - 1) +
        365 * year +
        ((year + 3) ~/ 4) +
        30 * (month - 1) +
        day;
  }

  static int _gregorianToJDN(int year, int month, int day) {
    int a = (14 - month) ~/ 12;
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;
    return day +
        ((153 * m + 2) ~/ 5) +
        365 * y +
        (y ~/ 4) -
        (y ~/ 100) +
        (y ~/ 400) -
        32045;
  }

  static DateTime _jdnToGregorian(int jdn) {
    int a = jdn + 32044;
    int b = (4 * a + 3) ~/ 146097;
    int c = a - (146097 * b) ~/ 4;
    int d = (4 * c + 3) ~/ 1461;
    int e = c - (1461 * d) ~/ 4;
    int m = (5 * e + 2) ~/ 153;
    int day = e - (153 * m + 2) ~/ 5 + 1;
    int month = m + 3 - 12 * (m ~/ 10);
    int year = 100 * b + d - 4800 + (m ~/ 10);
    return DateTime(year, month, day);
  }
}

// ===============================================================
// SHARED WIDGET: EthiopianDatePickerDialog (የኢትዮጵያ ቀን መምረጫ መገናኛ)
// ===============================================================
class EthiopianDatePickerDialog extends StatefulWidget {
  final EthiopianDate initialDate;
  const EthiopianDatePickerDialog({super.key, required this.initialDate});

  @override
  State<EthiopianDatePickerDialog> createState() =>
      _EthiopianDatePickerDialogState();
}

class _EthiopianDatePickerDialogState extends State<EthiopianDatePickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;
  }

  void _changeYear(int amount) {
    setState(() {
      _selectedYear += amount;
      final daysInMonth =
          EthiopianDate(year: _selectedYear, month: _selectedMonth, day: 1)
              .daysInMonth;
      if (_selectedDay > daysInMonth) {
        _selectedDay = daysInMonth;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tempDate =
        EthiopianDate(year: _selectedYear, month: _selectedMonth, day: 1);
    final daysInMonth = tempDate.daysInMonth;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.dateSelectDate,
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon:
                            const Icon(Icons.chevron_left, color: primaryColor),
                        onPressed: () => _changeYear(-1)),
                    Text(
                        '$_selectedYear ${AppLocalizations.of(context)!.dateEthiopianCalendar}',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: primaryColor)),
                    IconButton(
                        icon: const Icon(Icons.chevron_right,
                            color: primaryColor),
                        onPressed: () => _changeYear(1)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12)),
                child: DropdownButton<int>(
                  value: _selectedMonth,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: List.generate(13, (index) {
                    final loc = AppLocalizations.of(context)!;
                    final monthNames = [
                      loc.monthMeskerem,
                      loc.monthTikimt,
                      loc.monthHidar,
                      loc.monthTahsas,
                      loc.monthTir,
                      loc.monthYekatit,
                      loc.monthMegabit,
                      loc.monthMiyazya,
                      loc.monthGinbot,
                      loc.monthSene,
                      loc.monthHamle,
                      loc.monthNehase,
                      loc.monthPagume
                    ];
                    return DropdownMenuItem(
                        value: index + 1,
                        child: Text(monthNames[index],
                            style: GoogleFonts.poppins(fontSize: 14)));
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMonth = value;
                        final newDaysInMonth = EthiopianDate(
                                year: _selectedYear,
                                month: _selectedMonth,
                                day: 1)
                            .daysInMonth;
                        if (_selectedDay > newDaysInMonth) {
                          _selectedDay = newDaysInMonth;
                        }
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8),
                  itemCount: daysInMonth,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isSelected = day == _selectedDay;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = day),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : Colors.grey.shade300),
                        ),
                        child: Text('$day',
                            style: GoogleFonts.poppins(
                                color:
                                    isSelected ? Colors.white : onSurfaceColor,
                                fontWeight: FontWeight.w600)),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                              AppLocalizations.of(context)!.cancelButton,
                              style: GoogleFonts.poppins()))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      onPressed: () => Navigator.of(context).pop(EthiopianDate(
                          year: _selectedYear,
                          month: _selectedMonth,
                          day: _selectedDay)),
                      child: Text(AppLocalizations.of(context)!.okButton,
                          style: GoogleFonts.poppins()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- MODELS AND ENUMS ---

enum PostType { event, announcement, news, prayer }

class PrivateComment {
  final int id;
  final String text;
  final DateTime timestamp;
  final String author;
  final String? authorAvatar;

  PrivateComment({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.author,
    this.authorAvatar,
  });

  factory PrivateComment.fromJson(Map<String, dynamic> json) {
    String? buildFullUrl(String? pathOrUrl) {
      if (pathOrUrl == null || pathOrUrl.isEmpty) return null;
      if (pathOrUrl.startsWith('http')) return pathOrUrl;
      final baseUrl = ApiService.baseUrl.endsWith('/api')
          ? ApiService.baseUrl.substring(0, ApiService.baseUrl.length - 4)
          : ApiService.baseUrl;
      final cleanPath =
          pathOrUrl.startsWith('/') ? pathOrUrl.substring(1) : pathOrUrl;
      return '$baseUrl/$cleanPath';
    }

    return PrivateComment(
      id: json['id'],
      text: json['text'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      author: json['author'] ?? '',
      authorAvatar: buildFullUrl(json['authorAvatar']),
    );
  }
}

class PrivatePost {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String author;
  final String? authorAvatar;
  final DateTime date;
  final PostType type;
  int likes;
  bool isLiked;
  int commentCount;
  final List<String> tags;
  final String? location;
  final DateTime? eventDate;
  final bool isImportant;
  final List<String> targetGroups;

  PrivatePost({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.author,
    this.authorAvatar,
    required this.date,
    required this.type,
    this.likes = 0,
    this.isLiked = false,
    this.commentCount = 0,
    this.tags = const [],
    this.location,
    this.eventDate,
    this.isImportant = false,
    this.targetGroups = const [],
  });

  factory PrivatePost.fromJson(Map<String, dynamic> json) {
    PostType typeFromString(String? typeStr) {
      switch (typeStr?.toLowerCase()) {
        case 'event':
          return PostType.event;
        case 'announcement':
          return PostType.announcement;
        case 'news':
          return PostType.news;
        case 'prayer':
          return PostType.prayer;
        default:
          return PostType.news;
      }
    }

    String? buildFullUrl(String? pathOrUrl) {
      if (pathOrUrl == null || pathOrUrl.isEmpty) return null;
      if (pathOrUrl.startsWith('http')) return pathOrUrl;
      final baseUrl = ApiService.baseUrl.endsWith('/api')
          ? ApiService.baseUrl.substring(0, ApiService.baseUrl.length - 4)
          : ApiService.baseUrl;
      final cleanPath =
          pathOrUrl.startsWith('/') ? pathOrUrl.substring(1) : pathOrUrl;
      return '$baseUrl/$cleanPath';
    }

    return PrivatePost(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: buildFullUrl(json['imageUrl']),
      author: json['author'] ?? '',
      authorAvatar: buildFullUrl(json['authorAvatar']),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      type: typeFromString(json['type']),
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] == true,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      location: json['location'],
      eventDate: json['eventDate'] != null
          ? DateTime.tryParse(json['eventDate'])
          : null,
      isImportant: json['isImportant'] == 1 || json['isImportant'] == true,
      targetGroups: json['targetGroups'] != null
          ? List<String>.from(json['targetGroups'])
          : [],
    );
  }
}

class SundaySchool {
  final String id;
  final String name;
  final String? logoUrl;
  final String? primaryColor;
  final String? accentColor;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? pastorName;
  final String? serviceTimes;
  final int memberCount;
  final DateTime? establishedDate;

  SundaySchool(
      {required this.id,
      required this.name,
      this.logoUrl,
      this.primaryColor,
      this.accentColor,
      this.description,
      this.address,
      this.phone,
      this.email,
      this.pastorName,
      this.serviceTimes,
      this.memberCount = 0,
      this.establishedDate});

  factory SundaySchool.fromJson(Map<String, dynamic> json) {
    return SundaySchool(
      id: json['id'],
      name: json['name'] ?? 'Sunday School',
      logoUrl: json['logo_url'],
      primaryColor: json['primary_color'],
      accentColor: json['accent_color'],
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      pastorName: json['pastor_name'],
      serviceTimes: json['service_times'],
      memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
      establishedDate: json['established_date'] != null
          ? DateTime.parse(json['established_date'])
          : null,
    );
  }

  Color get primaryColorValue {
    if (primaryColor != null) {
      try {
        return Color(int.parse(primaryColor!.replaceFirst('#', '0xFF')));
      } catch (e) {
        return const Color(0xFF6366F1);
      }
    }
    return const Color(0xFF6366F1);
  }

  Color get accentColorValue {
    if (accentColor != null) {
      try {
        return Color(int.parse(accentColor!.replaceFirst('#', '0xFF')));
      } catch (e) {
        return const Color(0xFFF59E0B);
      }
    }
    return const Color(0xFFF59E0B);
  }
}

// --- MAIN WIDGET ---

class PrivateHomePage extends StatefulWidget {
  final String tenantId;
  const PrivateHomePage({super.key, required this.tenantId});

  @override
  State<PrivateHomePage> createState() => _PrivateHomePageState();
}

class _PrivateHomePageState extends State<PrivateHomePage> {
  SundaySchool? _sundaySchool;
  List<PrivatePost> _privatePosts = [];
  bool _isLoading = true;
  String? _error;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    privateFeedRefresher.addListener(_onRefreshSignal);
    _loadData();
  }

  void _onRefreshSignal() {
    log("Refresh signal received! Reloading data for PrivateHomePage.");
    _loadData();
  }

  void _onScroll() {
    if (mounted) {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    privateFeedRefresher.removeListener(_onRefreshSignal);
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final tenantResult =
          await PrivateFeedService.getTenantDetails(widget.tenantId);
      if (!mounted) return;
      if (!tenantResult['success']) throw Exception(tenantResult['message']);
      final postsResult =
          await PrivateFeedService.getPrivatePosts(widget.tenantId);
      if (!mounted) return;
      if (!postsResult['success']) throw Exception(postsResult['message']);
      setState(() {
        _sundaySchool = SundaySchool.fromJson(tenantResult['data']);
        _privatePosts = (postsResult['data'] as List)
            .map((postJson) => PrivatePost.fromJson(postJson))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted)
        setState(() {
          _error =
              "${AppLocalizations.of(context)!.privateHomepageFailedToLoad}: ${e.toString().replaceAll("Exception: ", "")}";
          _isLoading = false;
        });
    }
  }

  void _showEditTenantDialog() {
    showDialog(
      context: context,
      builder: (context) => _EditTenantDialog(
        sundaySchool: _sundaySchool!,
        onSave: () {
          _loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isSuperiorAdmin = userProvider.roles.contains('superior_admin');

    // ... inside the build method
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      body: _buildBody(),
      floatingActionButton:
          // Add a check to ensure data is loaded and sundaySchool is not null
          isSuperiorAdmin && !_isLoading && _sundaySchool != null
              ? _buildFloatingActionButton()
              : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildSpectacularLoadingScreen();
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.warning_2, color: Colors.red, size: 50),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.privateHomepageFailedToLoad,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_error!,
                  style: TextStyle(color: Colors.grey[700]),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                  icon: const Icon(Iconsax.refresh),
                  label: Text(AppLocalizations.of(context)!.homepageRetry),
                  onPressed: _loadData)
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildDynamicAppBar(),
          SliverToBoxAdapter(child: _buildWelcomeHero()),
          SliverToBoxAdapter(child: _buildAnimatedStats()),
          _buildFeaturedSection(),
          if (_privatePosts.isEmpty)
            SliverFillRemaining(
                child: Center(
                    child: Text(
                        AppLocalizations.of(context)!.privateHomepageNoPosts)))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildPrivatePostCard(_privatePosts[index], index);
                },
                childCount: _privatePosts.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildSpectacularLoadingScreen() {
    return Scaffold(
      backgroundColor:
          _sundaySchool?.primaryColorValue ?? const Color(0xFF6366F1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(IconsaxPlusBold.home_hashtag,
                color: Colors.white, size: 60),
            const SizedBox(height: 30),
            Text(
                _sundaySchool?.name ??
                    AppLocalizations.of(context)!
                        .privateHomepageLoadingCommunity,
                style: GoogleFonts.lato(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 20),
            const SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: Colors.white24)),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildDynamicAppBar() {
    final appBarHeight = 100.0;
    final scrollRatio = (_scrollOffset / appBarHeight).clamp(0.0, 1.0);
    return SliverAppBar(
      expandedHeight: appBarHeight,
      pinned: true,
      floating: true,
      backgroundColor: Colors.white,
      elevation: scrollRatio > 0.1 ? 4 : 0,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20 * (1 - scrollRatio)),
          bottomRight: Radius.circular(20 * (1 - scrollRatio)),
        ),
      ),
      title: AnimatedOpacity(
        opacity: scrollRatio > 0.5 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          _sundaySchool!.name,
          style: GoogleFonts.lato(
            color: _sundaySchool!.primaryColorValue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _sundaySchool!.primaryColorValue.withOpacity(0.9),
                _sundaySchool!.primaryColorValue.withOpacity(0.7),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 20),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_sundaySchool!.name,
                      style: GoogleFonts.lato(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                      AppLocalizations.of(context)!
                          .privateHomepageCommunityFeed,
                      style: GoogleFonts.lato(
                          color: Colors.white.withOpacity(0.9), fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(IconsaxPlusBold.notification,
                color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeHero() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _sundaySchool!.primaryColorValue.withOpacity(0.1),
            _sundaySchool!.accentColorValue.withOpacity(0.05),
            Colors.white.withOpacity(0.8)
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: _sundaySchool!.primaryColorValue.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.privateHomepageWelcomeHome,
                    style: GoogleFonts.lato(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _sundaySchool!.primaryColorValue,
                        height: 1.2)),
                const SizedBox(height: 8),
                Text(
                    AppLocalizations.of(context)!.privateHomepageWelcomeMessage,
                    style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4)),
                const SizedBox(height: 16),
                if (_privatePosts.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        color: _sundaySchool!.primaryColorValue,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                        "${_privatePosts.length} ${AppLocalizations.of(context)!.privateHomepageNewUpdates}",
                        style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _sundaySchool!.primaryColorValue,
                    _sundaySchool!.accentColorValue
                  ]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: _sundaySchool!.primaryColorValue.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5))
              ],
            ),
            child: const Icon(IconsaxPlusBold.home_hashtag,
                color: Colors.white, size: 35),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStats() {
    final isSuperiorAdmin =
        context.read<UserProvider>().roles.contains('superior_admin');
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildStatCard(
              IconsaxPlusBold.calendar_1,
              AppLocalizations.of(context)!.privateHomepageUpcomingEvents,
              _privatePosts
                  .where((p) => p.type == PostType.event)
                  .length
                  .toString(),
              const Color(0xFF6366F1),
              const Color(0xFF8B5CF6)),
          Stack(
            children: [
              _buildStatCard(
                  IconsaxPlusBold.people,
                  AppLocalizations.of(context)!.privateHomepageActiveMembers,
                  _sundaySchool!.memberCount.toString(),
                  const Color(0xFF10B981),
                  const Color(0xFF059669)),
              if (isSuperiorAdmin)
                Positioned(
                  top: 4,
                  right: 20,
                  child: Row(
                    children: [
                      _AdminControlButton(
                          icon: Iconsax.edit,
                          tooltip: AppLocalizations.of(context)!
                              .privateHomepageEditDetails,
                          onTap: _showEditTenantDialog),
                      const SizedBox(width: 4),
                      _AdminControlButton(
                          icon: Iconsax.user_search,
                          tooltip: AppLocalizations.of(context)!
                              .privateHomepageManageMembers,
                          onTap: () {}),
                    ],
                  ),
                ),
            ],
          ),
          _buildStatCard(
              IconsaxPlusBold.heart,
              AppLocalizations.of(context)!.privateHomepagePrayerRequests,
              _privatePosts
                  .where((p) => p.type == PostType.prayer)
                  .length
                  .toString(),
              const Color(0xFFEC4899),
              const Color(0xFFDB2777)),
          _buildStatCard(
              IconsaxPlusBold.volume_high,
              AppLocalizations.of(context)!.privateHomepageAnnouncements,
              _privatePosts
                  .where((p) => p.type == PostType.announcement)
                  .length
                  .toString(),
              const Color(0xFFF59E0B),
              const Color(0xFFD97706)),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      IconData icon, String title, String value, Color color1, Color color2) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color1, color2]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: color1.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
              right: -10,
              top: -10,
              child:
                  Icon(icon, size: 60, color: Colors.white.withOpacity(0.1))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(value,
                        style: GoogleFonts.lato(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text(title,
                        style: GoogleFonts.lato(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    final featuredPosts =
        _privatePosts.where((post) => post.isImportant).toList();
    if (featuredPosts.isEmpty)
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: Text(
                  AppLocalizations.of(context)!.privateHomepageFeaturedUpdates,
                  style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _sundaySchool!.primaryColorValue)),
            ),
            ...featuredPosts.map((post) => _buildFeaturedPostCard(post)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedPostCard(PrivatePost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            _sundaySchool!.accentColorValue.withOpacity(0.1),
            Colors.white
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: _sundaySchool!.accentColorValue.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: _sundaySchool!.accentColorValue.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(Icons.push_pin,
                  color: _sundaySchool!.accentColorValue, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title,
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(post.description,
                      style: GoogleFonts.lato(
                          fontSize: 12, color: Colors.grey.shade600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivatePostCard(PrivatePost post, int index) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, index == 0 ? 10 : 8, 20, 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        elevation: 4,
        shadowColor: _sundaySchool!.primaryColorValue.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.shade100, width: 1),
          ),
          child: Stack(
            children: [
              if (post.isImportant)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _sundaySchool!.accentColorValue,
                          _sundaySchool!.accentColorValue.withOpacity(0.5)
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomLeft: Radius.circular(25)),
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PostAuthorHeader(post: post, school: _sundaySchool!),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PostTypeTag(type: post.type),
                        const SizedBox(height: 16),
                        Text(post.title,
                            style: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                                color: Colors.black87)),
                        const SizedBox(height: 12),
                        Text(post.description,
                            style: GoogleFonts.lato(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.5)),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                    _PostImage(imageUrl: post.imageUrl!),
                  if (post.eventDate != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: _EventInfoChip(
                          eventDate: post.eventDate!,
                          location: post.location ?? ''),
                    ),
                  if (post.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: post.tags
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: _sundaySchool!.primaryColorValue
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Text('#$tag',
                                      style: GoogleFonts.lato(
                                          fontSize: 10,
                                          color:
                                              _sundaySchool!.primaryColorValue,
                                          fontWeight: FontWeight.w500)),
                                ))
                            .toList(),
                      ),
                    ),
                  _PostFooter(
                      post: post,
                      school: _sundaySchool!,
                      onInteraction: () => setState(() {})),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        context.push('/admin/posts');
      },
      backgroundColor: _sundaySchool!.primaryColorValue,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(IconsaxPlusBold.edit, size: 24),
      tooltip: AppLocalizations.of(context)!.privateHomepageManagePosts,
    );
  }
}

// =================================================================
// --- ALL HELPER WIDGETS AND FUNCTIONS ARE NOW DEFINED HERE, OUTSIDE THE STATE CLASS ---
// =================================================================

class _AdminControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _AdminControlButton(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.25),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
        ),
      ),
    );
  }
}

class _EditTenantDialog extends StatefulWidget {
  final SundaySchool sundaySchool;
  final VoidCallback onSave;

  const _EditTenantDialog({required this.sundaySchool, required this.onSave});

  @override
  State<_EditTenantDialog> createState() => _EditTenantDialogState();
}

class _EditTenantDialogState extends State<_EditTenantDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _memberCountController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.sundaySchool.name);
    _memberCountController =
        TextEditingController(text: widget.sundaySchool.memberCount.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _memberCountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    final data = {
      'name': _nameController.text,
      'member_count': int.tryParse(_memberCountController.text) ?? 0,
    };
    final result = await PrivateFeedService.updateTenantDetails(
        widget.sundaySchool.id, data);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ??
            AppLocalizations.of(context)!.commonFailedToPostComment),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ));
      if (result['success']) {
        widget.onSave();
        Navigator.of(context).pop();
      } else {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.privateHomepageEditSSDetails),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.privateHomepageSSName),
              validator: (value) => value!.isEmpty
                  ? AppLocalizations.of(context)!.validationNameCannotBeEmpty
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _memberCountController,
              decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.privateHomepageMemberCount),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isEmpty)
                  return AppLocalizations.of(context)!.validationCannotBeEmpty;
                if (int.tryParse(value) == null)
                  return AppLocalizations.of(context)!
                      .validationMustBeValidNumber;
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancelButton)),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(AppLocalizations.of(context)!.saveButton),
        ),
      ],
    );
  }
}

class _PostAuthorHeader extends StatelessWidget {
  const _PostAuthorHeader({required this.post, required this.school});
  final PrivatePost post;
  final SundaySchool school;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [school.primaryColorValue, school.accentColorValue]),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade200,
              backgroundImage:
                  post.authorAvatar != null && post.authorAvatar!.isNotEmpty
                      ? CachedNetworkImageProvider(post.authorAvatar!)
                      : null,
              child: (post.authorAvatar == null || post.authorAvatar!.isEmpty)
                  ? Icon(IconsaxPlusBold.user,
                      size: 16, color: Colors.grey.shade400)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.author,
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87)),
                Text(_formatDate(context, post.date),
                    style: GoogleFonts.lato(
                        fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostImage extends StatelessWidget {
  const _PostImage({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          height: 200,
          width: double.infinity,
          placeholder: (context, url) => Container(
            height: 200,
            color: Colors.grey.shade200,
            child: Center(
                child: CircularProgressIndicator(color: Colors.grey.shade400)),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: Colors.grey.shade200,
            child: Center(
                child: Icon(IconsaxPlusBold.gallery_slash,
                    color: Colors.grey.shade400, size: 50)),
          ),
        ),
      ),
    );
  }
}

class _PostFooter extends StatefulWidget {
  final PrivatePost post;
  final SundaySchool school;
  final VoidCallback onInteraction;

  const _PostFooter(
      {required this.post, required this.school, required this.onInteraction});

  @override
  State<_PostFooter> createState() => _PostFooterState();
}

class _PostFooterState extends State<_PostFooter> {
  Future<void> _handleLike() async {
    setState(() {
      widget.post.isLiked = !widget.post.isLiked;
      widget.post.likes += widget.post.isLiked ? 1 : -1;
    });
    await PrivateFeedService.togglePostLike(widget.post.id);
  }

  void _showCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(
        post: widget.post,
        onCommentCountChanged: (newCount) {
          setState(() {
            widget.post.commentCount = newCount;
          });
          widget.onInteraction();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildReactionButton(
                widget.post.isLiked ? Iconsax.heart5 : Iconsax.heart,
                '${widget.post.likes}',
                widget.post.isLiked ? Colors.pink : Colors.grey.shade600,
                onTap: _handleLike,
              ),
              const SizedBox(width: 16),
              _buildReactionButton(
                Iconsax.message_text_1,
                '${widget.post.commentCount}',
                Colors.grey.shade600,
                onTap: _showCommentsSheet,
              ),
            ],
          ),
          _buildReactionButton(Iconsax.share,
              AppLocalizations.of(context)!.commonShare, Colors.grey.shade600,
              onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildReactionButton(IconData icon, String text, Color color,
      {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            if (text.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(text,
                  style: GoogleFonts.lato(
                      fontSize: 12, fontWeight: FontWeight.w600, color: color)),
            ]
          ],
        ),
      ),
    );
  }
}

class _PostTypeTag extends StatelessWidget {
  const _PostTypeTag({required this.type});
  final PostType type;

  Color _getTypeColor(PostType type) {
    switch (type) {
      case PostType.event:
        return const Color(0xFFEC4899);
      case PostType.announcement:
        return const Color(0xFF10B981);
      case PostType.news:
        return const Color(0xFFF59E0B);
      case PostType.prayer:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData _getTypeIcon(PostType type) {
    switch (type) {
      case PostType.event:
        return IconsaxPlusBold.calendar_1;
      case PostType.announcement:
        return IconsaxPlusBold.volume_high;
      case PostType.news:
        return IconsaxPlusBold.document_text_1;
      case PostType.prayer:
        return IconsaxPlusBold.heart;
    }
  }

  // Helper to map PostType to translated string
  String _getTypeText(BuildContext context, PostType type) {
    switch (type) {
      case PostType.event:
        return AppLocalizations.of(context)!.postTypeEvent;
      case PostType.announcement:
        return AppLocalizations.of(context)!.postTypeAnnouncement;
      case PostType.news:
        return AppLocalizations.of(context)!.postTypeNews;
      case PostType.prayer:
        return AppLocalizations.of(context)!.postTypePrayer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor(type);
    final typeText = _getTypeText(context, type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getTypeIcon(type), size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            typeText.toUpperCase(),
            style: GoogleFonts.lato(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _EventInfoChip extends StatelessWidget {
  const _EventInfoChip({required this.eventDate, required this.location});
  final DateTime eventDate;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          const Color(0xFF6366F1).withOpacity(0.05),
          const Color(0xFF8B5CF6).withOpacity(0.02)
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                shape: BoxShape.circle),
            child: const Icon(IconsaxPlusBold.clock,
                size: 18, color: Color(0xFF6366F1)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDateTime(context, eventDate),
                    style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6366F1))),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(location,
                      style: GoogleFonts.lato(
                          fontSize: 12,
                          color: const Color(0xFF6366F1).withOpacity(0.8))),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final PrivatePost post;
  final ValueChanged<int> onCommentCountChanged;

  const _CommentsSheet(
      {required this.post, required this.onCommentCountChanged});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _commentController = TextEditingController();
  List<PrivateComment> _comments = [];
  bool _isLoading = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final result = await PrivateFeedService.getPostComments(widget.post.id);
    if (mounted && result['success']) {
      setState(() {
        _comments = (result['data'] as List)
            .map((c) => PrivateComment.fromJson(c))
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty || _isPosting) return;
    setState(() => _isPosting = true);
    final result = await PrivateFeedService.createPostComment(
        widget.post.id, _commentController.text.trim());
    if (mounted) {
      if (result['success']) {
        final newComment = PrivateComment.fromJson(result['data']);
        setState(() {
          _comments.insert(0, newComment);
          _commentController.clear();
        });
        widget.onCommentCountChanged(_comments.length);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ??
              AppLocalizations.of(context)!.commonFailedToPostComment),
          backgroundColor: Colors.red,
        ));
      }
      setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFAFBFF),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 16),
                  Text(
                      "${AppLocalizations.of(context)!.commonComments} (${_comments.length})",
                      style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _comments.isEmpty
                      ? Center(
                          child: Text(
                              AppLocalizations.of(context)!.commonNoComments))
                      : ListView.builder(
                          controller: controller,
                          itemCount: _comments.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 1,
                              shadowColor: Colors.black12,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          comment.authorAvatar != null
                                              ? CachedNetworkImageProvider(
                                                  comment.authorAvatar!)
                                              : null,
                                      child: comment.authorAvatar == null
                                          ? Text(comment.author.isNotEmpty
                                              ? comment.author[0]
                                              : '?')
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(comment.author,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              Text(
                                                  DateFormat.jm().format(
                                                      comment.timestamp),
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(comment.text),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            _buildCommentInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInputField() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 8),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5))
      ]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.commonWriteComment,
                fillColor: const Color.fromARGB(255, 1, 6, 24),
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _isPosting
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2)))
              : IconButton(
                  icon: const Icon(Iconsax.send_1),
                  color: Theme.of(context).primaryColor,
                  onPressed: _addComment),
        ],
      ),
    );
  }
}

String _formatDate(BuildContext context, DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);
  final loc = AppLocalizations.of(context)!;
  if (difference.inHours < 1) return loc.dateJustNow;
  if (difference.inHours < 24)
    return '${difference.inHours} ${loc.dateHoursAgoSuffix}';
  if (difference.inDays == 1) return loc.dateYesterday;
  final format = DateFormat.yMMMd();
  return format.format(date);
}

String _formatDateTime(BuildContext context, DateTime date) {
  final format = DateFormat.yMMMd().add_jm();
  return format.format(date);
}
