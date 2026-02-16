import 'package:amde_haymanot_abalat_guday/services/refresh_ervice.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'dart:developer';

import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/private_feed_service.dart';

import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:animate_do/animate_do.dart';

const Color premiumDark = Color(0xFF0F0F1E);
const Color premiumGold = Color(0xFFFFD700);

// --- MODELS AND ENUMS ---

enum PostType { event, announcement, news, prayer }

class PrivateComment {
  final int id;
  final String userId;
  final String text;
  final DateTime timestamp;
  final String author;
  final String? authorAvatar;
  final int? parentId;
  final String? authorTenantId;

  PrivateComment({
    required this.id,
    required this.userId,
    required this.text,
    required this.timestamp,
    required this.author,
    this.authorAvatar,
    this.parentId,
    this.authorTenantId,
  });

  factory PrivateComment.fromJson(Map<String, dynamic> json) {
    return PrivateComment(
      id: json['id'],
      userId: json['userId']?.toString() ?? '',
      text: json['text'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      author: json['author'] ?? '',
      authorAvatar: ApiService.getImageUrl(json['authorAvatar']),
      parentId: json['parentId'],
      authorTenantId: json['authorTenantId']?.toString(),
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

    return PrivatePost(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: ApiService.getImageUrl(json['imageUrl']),
      author: json['author'] ?? '',
      authorAvatar: ApiService.getImageUrl(json['authorAvatar']),
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

class PrivateFeedView extends StatefulWidget {
  final String tenantId;
  final Function(SundaySchool?)? onDataLoaded;

  const PrivateFeedView({
    super.key,
    required this.tenantId,
    this.onDataLoaded,
  });

  @override
  State<PrivateFeedView> createState() => _PrivateFeedViewState();
}

class _PrivateFeedViewState extends State<PrivateFeedView> {
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
    log("Refresh signal received! Reloading data for PrivateFeedView.");
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

        final dynamic rawData = postsResult['data'];
        List<dynamic> postsList = [];

        if (rawData is List) {
          postsList = rawData;
        } else if (rawData is Map && rawData['posts'] is List) {
          postsList = rawData['posts'];
        }

        _privatePosts = postsList
            .map((postJson) => PrivatePost.fromJson(postJson))
            .toList();
        _isLoading = false;

        // Notify parent if callback provided
        if (widget.onDataLoaded != null) {
          widget.onDataLoaded!(_sundaySchool);
        }
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

  @override
  Widget build(BuildContext context) {
    // Scaffold removed to allow embedding in UnifiedHomePage
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode(context);
    final bgColor = themeProvider.getBackgroundColor(context);

    // Use a Container with gradient background as the root
    return Container(
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
                _sundaySchool?.name ??
                    AppLocalizations.of(context)!.privateHomepageSundaySchool,
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
    final cardColor =
        isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey.withValues(alpha: 0.2);

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
                      AppLocalizations.of(context)!.privateHomepageWelcomeHome,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _sundaySchool!.description ??
                          AppLocalizations.of(context)!
                              .privateHomepageCommunityUpdates,
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
    final cardColor =
        isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.grey.withValues(alpha: 0.2);

    final stats = [
      {
        'label': AppLocalizations.of(context)!.privateHomepageMembersText,
        'value': '${_sundaySchool!.memberCount}',
        'icon': Iconsax.people,
        'color': const Color(0xFF4ADE80)
      },
      {
        'label': AppLocalizations.of(context)!.privateHomepagePostsText,
        'value': '${_privatePosts.length}',
        'icon': Iconsax.document_text,
        'color': const Color(0xFF60A5FA)
      },
      {
        'label': AppLocalizations.of(context)!.privateHomepageYearsText,
        'value': _sundaySchool!.establishedDate != null
            ? '${DateTime.now().year - _sundaySchool!.establishedDate!.year}'
            : '0',
        'icon': Iconsax.calendar,
        'color': const Color(0xFFF472B6)
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
                          color:
                              (stat['color'] as Color).withValues(alpha: 0.2),
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
                  AppLocalizations.of(context)!.privateHomepageFeatured,
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
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.3),
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
                                AppLocalizations.of(context)!.homepageImportant,
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
                              "${EthiopianDate.fromGregorian(post.date)}",
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
    final cardColor =
        isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.grey.withValues(alpha: 0.2);

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
                        "${EthiopianDate.fromGregorian(post.date)} ${DateFormat.jm().format(post.date)}",
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
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
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

class EditTenantDialog extends StatefulWidget {
  final SundaySchool sundaySchool;
  final VoidCallback onSave;

  const EditTenantDialog({
    super.key,
    required this.sundaySchool,
    required this.onSave,
  });

  @override
  State<EditTenantDialog> createState() => _EditTenantDialogState();
}

class _EditTenantDialogState extends State<EditTenantDialog> {
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "${AppLocalizations.of(context)!.privateHomepageSaveError}: $e")));
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
                  Text(AppLocalizations.of(context)!.profileEditTitle,
                      style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 16),
                  _buildTextField(_nameController,
                      AppLocalizations.of(context)!.settingsName),
                  _buildTextField(_descriptionController,
                      AppLocalizations.of(context)!.labelDescription,
                      maxLines: 3),
                  _buildTextField(_serviceTimesController,
                      AppLocalizations.of(context)!.labelServiceTimes),
                  _buildTextField(_addressController,
                      AppLocalizations.of(context)!.labelAddress),
                  _buildTextField(_phoneController,
                      AppLocalizations.of(context)!.profilePhoneNumber),
                  _buildTextField(_emailController,
                      AppLocalizations.of(context)!.settingsName),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                              AppLocalizations.of(context)!.cancelButton,
                              style: const TextStyle(color: Colors.white70))),
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
                            : Text(AppLocalizations.of(context)!.saveButton),
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
  PrivateComment? _editingComment;
  PrivateComment? _replyingTo;

  final Set<int> _expandedComments = {};
  int _topLevelLimit = 10;

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
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    Map<String, dynamic> result;
    if (_editingComment != null) {
      result =
          await PrivateFeedService.updatePostComment(_editingComment!.id, text);
    } else {
      // Flatten replies: If replying to a reply, use its parentId. Otherwise use its id.
      final int? parentId = _replyingTo?.parentId ?? _replyingTo?.id;
      result = await PrivateFeedService.createPostComment(widget.post.id, text,
          parentId: parentId);
    }

    if (mounted) {
      if (result['success']) {
        _commentController.clear();
        if (_editingComment != null) {
          setState(() {
            _editingComment = null;
          });
        } else {
          setState(() {
            _replyingTo = null;
          });
        }
        _fetchComments(); // Refresh list
        widget.onCommentAdded(_comments.length + 1);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? 'Failed to post comment'),
          backgroundColor: Colors.redAccent,
        ));
      }
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _deleteComment(PrivateComment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: premiumDark,
        title: const Text("Delete Comment?",
            style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to delete this comment?",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.white54))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete",
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await PrivateFeedService.deletePostComment(comment.id);
      if (mounted) {
        if (result['success']) {
          _fetchComments();
          widget.onCommentAdded(_comments.length - 1);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['message'] ?? 'Failed to delete comment'),
            backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  void _cancelEditReply() {
    setState(() {
      _replyingTo = null;
      _editingComment = null;
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId =
        userProvider.userProfile?['user_id']?.toString() ?? '';
    final isSuperiorAdmin = userProvider.isSuperiorAdmin;
    final isSystemAdmin = userProvider.isSystemAdmin;
    final userTenantId = userProvider.tenantId;

    // Group comments: Map of parentId -> list of replies
    final Map<int, List<PrivateComment>> repliesMap = {};
    final List<PrivateComment> topLevelComments = [];

    for (var comment in _comments) {
      if (comment.parentId == null) {
        topLevelComments.add(comment);
      } else {
        repliesMap.putIfAbsent(comment.parentId!, () => []).add(comment);
      }
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // Tall sheet
      decoration: BoxDecoration(
        color: premiumDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
            top: BorderSide(
                color: premiumGold.withValues(alpha: 0.3), width: 1)),
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
                  AppLocalizations.of(context)!.homepageComments,
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
                                Text(
                                    AppLocalizations.of(context)!
                                        .homepageNoCommentsYet,
                                    style: GoogleFonts.notoSansEthiopic(
                                        color: Colors.white54)),
                                // Removing the second text as homepageNoCommentsYet combined them or matches the core intent better
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount:
                                (topLevelComments.length > _topLevelLimit)
                                    ? _topLevelLimit + 1
                                    : topLevelComments.length,
                            itemBuilder: (context, index) {
                              if (index == _topLevelLimit &&
                                  topLevelComments.length > _topLevelLimit) {
                                return Center(
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _topLevelLimit += 10;
                                      });
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!
                                            .commentsLoadMore,
                                        style: const TextStyle(
                                            color: premiumGold)),
                                  ),
                                );
                              }

                              final comment = topLevelComments[index];
                              final replies = repliesMap[comment.id] ?? [];
                              final bool isExpanded =
                                  _expandedComments.contains(comment.id);
                              final int repliesToShow =
                                  (replies.length >= 2 && !isExpanded)
                                      ? 0
                                      : replies.length;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCommentItem(
                                      comment,
                                      currentUserId,
                                      isSystemAdmin,
                                      isSuperiorAdmin,
                                      userTenantId),
                                  if (replies.isNotEmpty && repliesToShow == 0)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 48.0, bottom: 12),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _expandedComments.add(comment.id);
                                          });
                                        },
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .commentsViewAllReplies(
                                                  replies.length),
                                          style: const TextStyle(
                                              color: premiumGold,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  if (repliesToShow > 0)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 32.0),
                                      child: Column(
                                        children: [
                                          ...replies.map((reply) =>
                                              _buildCommentItem(
                                                  reply,
                                                  currentUserId,
                                                  isSystemAdmin,
                                                  isSuperiorAdmin,
                                                  userTenantId,
                                                  isReply: true)),
                                          if (isExpanded)
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _expandedComments
                                                        .remove(comment.id);
                                                  });
                                                },
                                                child: Text(
                                                    AppLocalizations.of(
                                                            context)!
                                                        .commentsHideReplies,
                                                    style: const TextStyle(
                                                        color: Colors.white54,
                                                        fontSize: 12)),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
          ),
          // Reply/Edit Indicator
          if (_replyingTo != null || _editingComment != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white.withValues(alpha: 0.1),
              child: Row(
                children: [
                  Icon(
                    _editingComment != null ? Iconsax.edit : Icons.reply,
                    size: 16,
                    color: premiumGold,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _editingComment != null
                          ? AppLocalizations.of(context)!.commentsEditing
                          : AppLocalizations.of(context)!
                              .commentsReplyingTo(_replyingTo!.author),
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close,
                        size: 16, color: Colors.white54),
                    onPressed: _cancelEditReply,
                  ),
                ],
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
                      hintText: AppLocalizations.of(context)!
                          .commentsWritePlaceholder,
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

  Widget _buildCommentItem(PrivateComment comment, dynamic currentUserId,
      bool isSystemAdmin, bool isSuperiorAdmin, String? userTenantId,
      {bool isReply = false}) {
    final bool isOwner = comment.userId.toString() == currentUserId.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isReply ? 0.03 : 0.05),
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: isReply ? 14 : 18,
                  backgroundColor: Colors.white10,
                  backgroundImage: comment.authorAvatar != null
                      ? CachedNetworkImageProvider(comment.authorAvatar!)
                      : null,
                  child: comment.authorAvatar == null
                      ? Text(
                          comment.author.isNotEmpty ? comment.author[0] : '?',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: premiumGold,
                              fontSize: isReply ? 12 : 14),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        )),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              comment.author,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: isReply ? 12 : 13),
                            ),
                            Text(
                              "${EthiopianDate.fromGregorian(comment.timestamp)}",
                              style: GoogleFonts.poppins(
                                  color: Colors.white24, fontSize: 10),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment.text,
                          style: GoogleFonts.notoSansEthiopic(
                              color: Colors.white70,
                              fontSize: isReply ? 13 : 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(
                  icon: Icons.reply,
                  label: AppLocalizations.of(context)!.commentsReplyAction,
                  onTap: () {
                    setState(() {
                      _replyingTo = comment;
                      _editingComment = null;
                      _commentController.text = "";
                    });
                  },
                ),
                if (isOwner) ...[
                  const SizedBox(width: 16),
                  _ActionButton(
                    icon: Iconsax.edit,
                    label: AppLocalizations.of(context)!.editButton,
                    onTap: () {
                      setState(() {
                        _editingComment = comment;
                        _replyingTo = null;
                        _commentController.text = comment.text;
                      });
                    },
                  ),
                  const SizedBox(width: 16),
                  _ActionButton(
                    icon: Iconsax.trash,
                    label: AppLocalizations.of(context)!.deleteButton,
                    color: Colors.redAccent.withValues(alpha: 0.7),
                    onTap: () => _deleteComment(comment),
                  ),
                ],
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 14, color: color ?? Colors.white54),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color ?? Colors.white54,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
