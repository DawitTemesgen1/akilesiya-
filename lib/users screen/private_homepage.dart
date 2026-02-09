import 'package:amde_haymanot_abalat_guday/services/refresh_ervice.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:provider/provider.dart';

import 'dart:developer';

import 'package:amde_haymanot_abalat_guday/services/private_feed_service.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:animate_do/animate_do.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/post_management.dart';

// --- Re-usable UI Constants ---
// Note: We use local constants for the premium theme to ensure consistency.
const Color premiumDark = Color(0xFF0F0F1E);
const Color premiumGold = Color(0xFFFFD700);

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
            color: premiumDark,
            border: Border.all(color: premiumGold.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.dateSelectDate,
                  style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: premiumGold)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon:
                            const Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: () => _changeYear(-1)),
                    Text(
                        '$_selectedYear ${AppLocalizations.of(context)!.dateEthiopianCalendar}',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white)),
                    IconButton(
                        icon: const Icon(Icons.chevron_right,
                            color: Colors.white),
                        onPressed: () => _changeYear(1)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(12)),
                child: DropdownButton<int>(
                  value: _selectedMonth,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: premiumDark,
                  style: GoogleFonts.poppins(color: Colors.white),
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
                          color: isSelected ? premiumGold : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: isSelected ? premiumGold : Colors.white24),
                        ),
                        child: Text('$day',
                            style: GoogleFonts.poppins(
                                color: isSelected ? Colors.black : Colors.white,
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
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white24),
                              foregroundColor: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                              AppLocalizations.of(context)!.cancelButton,
                              style: GoogleFonts.poppins()))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: premiumGold,
                          foregroundColor: premiumDark,
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
        // Scroll listener kept for potential future animations
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
      if (mounted) {
        setState(() {
          _error =
              "${AppLocalizations.of(context)!.privateHomepageFailedToLoad}: ${e.toString().replaceAll("Exception: ", "")}";
          _isLoading = false;
        });
      }
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode(context);
    final bgColor = themeProvider.getBackgroundColor(context);

    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    Theme.of(context).primaryColor.withValues(alpha: 0.8),
                    premiumDark,
                    Colors.black,
                  ]
                : [
                    Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    bgColor,
                    bgColor,
                  ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: _buildBody(context),
      ),
      floatingActionButton:
          // Add a check to ensure data is loaded and sundaySchool is not null
          isSuperiorAdmin && !_isLoading && _sundaySchool != null
              ? _buildFloatingActionButton()
              : null,
    );
  }

  Widget _buildBody(BuildContext outerContext) {
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
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Provider.of<ThemeProvider>(context)
                          .getOnSurfaceColor(context))),
              const SizedBox(height: 8),
              Text(_error!,
                  style: TextStyle(
                      color: Provider.of<ThemeProvider>(context)
                          .getOnSurfaceColor(context)
                          .withValues(alpha: 0.7)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: premiumGold,
                      foregroundColor: premiumDark),
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
      color: Theme.of(context).primaryColor,
      backgroundColor:
          Provider.of<ThemeProvider>(context).getSurfaceColor(context),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildDynamicAppBar(outerContext),
          SliverToBoxAdapter(child: FadeInDown(child: _buildWelcomeHero())),
          SliverToBoxAdapter(
              child: FadeIn(
                  delay: const Duration(milliseconds: 200),
                  child: _buildAnimatedStats())),
          _buildFeaturedSection(),
          if (_privatePosts.isEmpty)
            SliverFillRemaining(
                child: Center(
                    child: Text(
                        AppLocalizations.of(context)!.privateHomepageNoPosts,
                        style: TextStyle(
                            color: Provider.of<ThemeProvider>(context)
                                .getOnSurfaceColor(context)
                                .withValues(alpha: 0.6)))))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return FadeInUp(
                      delay: Duration(milliseconds: 100 * index),
                      child:
                          _buildPrivatePostCard(_privatePosts[index], index));
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
          Provider.of<ThemeProvider>(context).getBackgroundColor(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(IconsaxPlusBold.home_hashtag,
                color: Theme.of(context).primaryColor, size: 60),
            const SizedBox(height: 30),
            Text(
                _sundaySchool?.name ??
                    AppLocalizations.of(context)!
                        .privateHomepageLoadingCommunity,
                style: GoogleFonts.lato(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Provider.of<ThemeProvider>(context)
                        .getOnSurfaceColor(context))),
            const SizedBox(height: 20),
            SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                    backgroundColor:
                        Provider.of<ThemeProvider>(context).isDarkMode(context)
                            ? Colors.white24
                            : Colors.black12)),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildDynamicAppBar(BuildContext outerContext) {
    final appBarHeight = 100.0;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final gradientColor = Theme.of(context).primaryColor;
    final titleColor = isDark ? Colors.black87 : Colors.white;
    // final scrollRatio = (_scrollOffset / appBarHeight).clamp(0.0, 1.0); // Not used currently
    return SliverAppBar(
      expandedHeight: appBarHeight,
      pinned: true,
      floating: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.sort, color: titleColor),
        onPressed: () {
          Scaffold.of(outerContext).openDrawer();
        },
      ),
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () =>
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
          icon: Icon(
            Provider.of<ThemeProvider>(context).isDarkMode(context)
                ? Iconsax.sun_1
                : Iconsax.moon,
            color: titleColor,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                gradientColor.withValues(alpha: 0.9),
                Colors.transparent
              ])),
        ),
        title: Row(
          children: [
            if (_sundaySchool?.logoUrl != null)
              CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(_sundaySchool!.logoUrl!),
                radius: 16,
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _sundaySchool?.name ?? "ሰንበት ትምህርት ቤት",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: titleColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHero() {
    if (_sundaySchool == null) return const SizedBox();
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtleText = isDark ? Colors.white70 : Colors.black54;
    final cardColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "እንኳን ደህና መጡ",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _sundaySchool!.description ?? "የማህበረሰብ ዝመናዎች",
                      style: GoogleFonts.poppins(
                        color: subtleText,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedStats() {
    if (_sundaySchool == null) return const SizedBox();
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtleText = isDark ? Colors.white60 : Colors.black54;
    final cardColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.2);

    final stats = [
      {
        'label': "አባላት",
        'value': '${_sundaySchool!.memberCount}',
        'icon': Iconsax.people,
        'color': const Color(0xFF4ADE80)
      },
      {
        'label': "ልጥፎች",
        'value': '${_privatePosts.length}',
        'icon': Iconsax.document_text,
        'color': const Color(0xFF60A5FA)
      },
      {
        'label': "ዓመታት",
        'value': _sundaySchool!.establishedDate != null
            ? '${DateTime.now().year - _sundaySchool!.establishedDate!.year}'
            : '0',
        'icon': Iconsax.calendar,
        'color': Color(0xFFF472B6)
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: stats
            .map((stat) => Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (stat['color'] as Color).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(stat['icon'] as IconData,
                            color: stat['color'] as Color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat['value'] as String,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: textColor,
                            ),
                          ),
                          Text(
                            stat['label'] as String,
                            style: GoogleFonts.poppins(
                              color: subtleText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    final importantPosts = _privatePosts.where((p) => p.isImportant).toList();
    if (importantPosts.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Iconsax.star1,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? premiumGold
                        : Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  "ተለይቶ የቀረበ",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        Provider.of<ThemeProvider>(context).isDarkMode(context)
                            ? Colors.white
                            : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: importantPosts.length,
              itemBuilder: (context, index) {
                final post = importantPosts[index];
                return Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        const Color(0xFF1E1E2E), // Premium Dark
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      if (post.imageUrl != null)
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              key: ValueKey(post.imageUrl),
                              child: CachedNetworkImage(
                                imageUrl: post.imageUrl!,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[900],
                                  child: const Icon(Icons.broken_image,
                                      color: Colors.white54),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "አስፈላጊ",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              post.title,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat.yMMMd().format(post.date),
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPrivatePostCard(PrivatePost post, int index) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtleText = isDark ? Colors.white54 : Colors.black54;
    final cardColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.2);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  child: ClipOval(
                      child: post.authorAvatar != null
                          ? CachedNetworkImage(
                              imageUrl: post.authorAvatar!,
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                              errorWidget: (context, url, error) =>
                                  _buildInitialsAvatar(post),
                            )
                          : _buildInitialsAvatar(post)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        DateFormat.yMMMd().add_jm().format(post.date),
                        style: GoogleFonts.poppins(
                          color: subtleText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Tag chip
                if (post.tags.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      post.tags.first,
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (post.imageUrl != null)
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => Scaffold(
                              backgroundColor: Colors.black,
                              appBar: AppBar(
                                backgroundColor: Colors.transparent,
                                iconTheme:
                                    const IconThemeData(color: Colors.white),
                              ),
                              body: Center(
                                  child: CachedNetworkImage(
                                      imageUrl: post.imageUrl!)),
                            )));
              },
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(post.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.description,
                  style: GoogleFonts.poppins(
                    color: subtleText,
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Location & Event Date
                if (post.location != null || post.eventDate != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        if (post.eventDate != null)
                          Row(children: [
                            Icon(Iconsax.calendar_1,
                                color: premiumGold, size: 16),
                            const SizedBox(width: 8),
                            Text(
                                DateFormat('MMM d, yyyy @ h:mm a')
                                    .format(post.eventDate!),
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 13))
                          ]),
                        if (post.location != null) ...[
                          const SizedBox(height: 8),
                          Row(children: [
                            Icon(Iconsax.location,
                                color: premiumGold, size: 16),
                            const SizedBox(width: 8),
                            Text(post.location!,
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 13))
                          ]),
                        ]
                      ],
                    ),
                  )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _InteractionButton(
                  icon: post.isLiked ? Iconsax.heart5 : Iconsax.heart,
                  label: '${post.likes}',
                  isActive: post.isLiked,
                  activeColor: Colors.redAccent,
                  onTap: () {
                    // Optimistic update
                    setState(() {
                      post.isLiked = !post.isLiked;
                      post.likes += post.isLiked ? 1 : -1;
                    });
                    PrivateFeedService.togglePostLike(post.id);
                  },
                ),
                const SizedBox(width: 24),
                _InteractionButton(
                  icon: Iconsax.message_text_1,
                  label: '${post.commentCount}',
                  onTap: () {
                    // Show comments
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => _PrivateCommentsSheet(
                            post: post,
                            onCommentAdded: (count) {
                              setState(() {
                                post.commentCount = count;
                              });
                            }));
                  },
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Iconsax.share, color: subtleText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          heroTag: 'manage_posts_fab',
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AdminPostManagementScreen(
                          tenantId: _sundaySchool?.id,
                        )));
          },
          backgroundColor: premiumGold,
          foregroundColor: premiumDark,
          elevation: 4,
          icon: const Icon(Iconsax.document_text),
          label: Text(
            "ልጥፎችን ያስተዳድሩ",
            style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        FloatingActionButton.extended(
          heroTag: 'edit_tenant_fab',
          onPressed: _showEditTenantDialog,
          backgroundColor: Colors.white,
          foregroundColor: premiumDark,
          elevation: 4,
          icon: const Icon(Iconsax.edit),
          label: Text(
            "መገለጫ አርትዕ",
            style: GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialsAvatar(PrivatePost post) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Text(
        post.author.isNotEmpty ? post.author[0] : 'U',
        style: TextStyle(
            fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
      ),
    );
  }
}

class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _InteractionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode(context);
    final subtleText = isDark ? Colors.white54 : Colors.black54;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : subtleText,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isActive ? activeColor : subtleText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
  // ... (Keep existing logic, just styling update if needed, but Dialogs usually inherit theme)
  // For brevity, skipping full rewrite of dialog logic unless specifically asked, but I will include it to prevent errors.
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _pastorNameController;
  late TextEditingController _serviceTimesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.sundaySchool.name);
    _descriptionController =
        TextEditingController(text: widget.sundaySchool.description);
    _addressController =
        TextEditingController(text: widget.sundaySchool.address);
    _phoneController = TextEditingController(text: widget.sundaySchool.phone);
    _emailController = TextEditingController(text: widget.sundaySchool.email);
    _pastorNameController =
        TextEditingController(text: widget.sundaySchool.pastorName);
    _serviceTimesController =
        TextEditingController(text: widget.sundaySchool.serviceTimes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _pastorNameController.dispose();
    _serviceTimesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final updates = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'address': _addressController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'pastor_name': _pastorNameController.text,
      'service_times': _serviceTimesController.text,
    };

    try {
      final result = await PrivateFeedService.updateTenantDetails(
          widget.sundaySchool.id, updates);
      if (result['success']) {
        if (mounted) Navigator.pop(context);
        widget.onSave();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(result['message'])));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("ዝመና አልተሳካም: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: premiumDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("መገለጫ አርትዕ",
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 16),
                  _buildTextField(_nameController, "Name"),
                  _buildTextField(_descriptionController, "Description",
                      maxLines: 3),
                  _buildTextField(_serviceTimesController, "Service Times"),
                  _buildTextField(_addressController, "Address"),
                  _buildTextField(_phoneController, "Phone"),
                  _buildTextField(_emailController, "Email"),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel",
                              style: TextStyle(color: Colors.white70))),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: premiumGold,
                            foregroundColor: premiumDark),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator())
                            : const Text("Save"),
                      )
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: maxLines,
        decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none)),
      ),
    );
  }
}

class _PrivateCommentsSheet extends StatefulWidget {
  final PrivatePost post;
  final Function(int) onCommentAdded;

  const _PrivateCommentsSheet(
      {required this.post, required this.onCommentAdded});

  @override
  State<_PrivateCommentsSheet> createState() => _PrivateCommentsSheetState();
}

class _PrivateCommentsSheetState extends State<_PrivateCommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  List<PrivateComment> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await PrivateFeedService.getPostComments(widget.post.id);

    if (mounted) {
      if (result['success']) {
        final List<dynamic> data = result['data'] as List<dynamic>? ?? [];
        setState(() {
          _comments = data.map((e) => PrivateComment.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result['message'] ?? 'Failed to load comments';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    final result =
        await PrivateFeedService.createPostComment(widget.post.id, text);

    if (mounted) {
      setState(() {
        _isSending = false;
      });

      if (result['success']) {
        _commentController.clear();
        _fetchComments(); // Refresh list
        widget.onCommentAdded(_comments.length + 1); // Optimistic update
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? 'Failed to post comment'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // Tall sheet
      decoration: BoxDecoration(
        color: premiumDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
            top: BorderSide(color: premiumGold.withValues(alpha: 0.3), width: 1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  "Comments",
                  style: GoogleFonts.notoSansEthiopic(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(width: 8),
                if (!_isLoading)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: premiumGold,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      "${_comments.length}",
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: premiumDark),
                    ),
                  ),
                const Spacer(),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70))
              ],
            ),
          ),
          Divider(color: Colors.white10),
          // List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: premiumGold))
                : _error != null
                    ? Center(
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.redAccent)))
                    : _comments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Iconsax.message,
                                    size: 48, color: Colors.white24),
                                const SizedBox(height: 16),
                                Text("No comments yet",
                                    style: GoogleFonts.notoSansEthiopic(
                                        color: Colors.white54)),
                                Text("Be the first to share your thoughts",
                                    style: GoogleFonts.notoSansEthiopic(
                                        color: Colors.white24, fontSize: 12)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.white10,
                                      backgroundImage:
                                          comment.authorAvatar != null
                                              ? CachedNetworkImageProvider(
                                                  comment.authorAvatar!)
                                              : null,
                                      child: comment.authorAvatar == null
                                          ? Text(
                                              comment.author.isNotEmpty
                                                  ? comment.author[0]
                                                  : '?',
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  color: premiumGold),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withValues(alpha: 0.05),
                                            borderRadius:
                                                const BorderRadius.only(
                                              topRight: Radius.circular(16),
                                              bottomLeft: Radius.circular(16),
                                              bottomRight: Radius.circular(16),
                                            )),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  comment.author,
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 13),
                                                ),
                                                Text(
                                                  DateFormat.yMMMd().format(
                                                      comment.timestamp),
                                                  style: GoogleFonts.poppins(
                                                      color: Colors.white24,
                                                      fontSize: 10),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              comment.text,
                                              style:
                                                  GoogleFonts.notoSansEthiopic(
                                                      color: Colors.white70,
                                                      fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
          // Input
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            decoration: const BoxDecoration(
                color: premiumDark,
                border: Border(top: BorderSide(color: Colors.white10))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Write a comment...",
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _isSending ? null : _submitComment,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: _isSending ? Colors.white10 : premiumGold,
                        shape: BoxShape.circle),
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Iconsax.send_1,
                            color: premiumDark, size: 20),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
