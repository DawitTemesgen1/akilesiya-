import 'package:amde_haymanot_abalat_guday/admin%20only/post_general_home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/services/public_feed_service.dart';
import 'package:amde_haymanot_abalat_guday/services/private_feed_service.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/private_homepage.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/post_management.dart';
import 'package:amde_haymanot_abalat_guday/models/comment.dart';

// --- MODELS AND ENUMS ---

enum PostType { event, announcement, news, prayer }

class UnifiedPost {
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
  final String location;
  final DateTime? eventDate;
  final bool isImportant;

  // Fields specific to unified feed
  final bool isPrivate; // true if from private feed
  final String? tenantId; // Sunday School ID for private posts
  final String? tenantName; // Sunday School name for display
  final List<String> targetGroups; // For private posts

  UnifiedPost({
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
    this.location = '',
    this.eventDate,
    this.isImportant = false,
    this.isPrivate = false,
    this.tenantId,
    this.tenantName,
    this.targetGroups = const [],
  });

  factory UnifiedPost.fromPublicPost(Map<String, dynamic> json) {
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

    return UnifiedPost(
      id: json['id'].toString(),
      title: json['title'] ?? 'ርዕስ የለም',
      description: json['description'] ?? '',
      imageUrl: buildFullUrl(json['imageUrl']),
      author: json['author'] ?? 'ያልታወቀ ደራሲ',
      authorAvatar: buildFullUrl(json['authorAvatar']),
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      type: typeFromString(json['type']),
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] == true,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      location: json['location'] ?? '',
      eventDate: json['eventDate'] != null
          ? DateTime.tryParse(json['eventDate'])
          : null,
      isImportant: json['isImportant'] == 1 || json['isImportant'] == true,
      isPrivate: false, // Public post
      targetGroups: json['targetGroups'] != null
          ? List<String>.from(json['targetGroups'])
          : [],
    );
  }

  factory UnifiedPost.fromPrivatePost(Map<String, dynamic> json,
      {String? tenantName}) {
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

    return UnifiedPost(
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
      location: json['location'] ?? '',
      eventDate: json['eventDate'] != null
          ? DateTime.tryParse(json['eventDate'])
          : null,
      isImportant: json['isImportant'] == 1 || json['isImportant'] == true,
      isPrivate: true, // Private post
      tenantId: json['tenantId']?.toString(),
      tenantName: tenantName,
      targetGroups: json['targetGroups'] != null
          ? List<String>.from(json['targetGroups'])
          : [],
    );
  }
}

// --- CONSTANTS ---
const Color premiumDark = Color(0xFF0F0F1E);
const Color premiumGold = Color(0xFFFFD700);

// --- MAIN WIDGET ---

class UnifiedHomePage extends StatefulWidget {
  const UnifiedHomePage({super.key});

  @override
  State<UnifiedHomePage> createState() => _UnifiedHomePageState();
}

class _UnifiedHomePageState extends State<UnifiedHomePage> {
  // Unified Feed State
  List<UnifiedPost> _posts = [];
  List<UnifiedPost> _featuredPosts = [];
  bool _isLoading = true;
  String? _error;
  SundaySchool? _userSundaySchool;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUnifiedFeed();
    });
  }

  Future<void> _loadUnifiedFeed() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final tenantId = userProvider.userProfile?['tenant_id'];

      List<UnifiedPost> allPosts = [];

      // Fetch public posts
      final publicResponse = await PublicFeedService.getPublicPosts();
      if (publicResponse['success']) {
        final publicData = publicResponse['data'] as List;
        allPosts.addAll(
          publicData.map((json) => UnifiedPost.fromPublicPost(json)),
        );
      }

      // Fetch private posts if user has Sunday School
      if (tenantId != null && tenantId.isNotEmpty) {
        final privateResponse =
            await PrivateFeedService.getPrivatePosts(tenantId);
        if (privateResponse['success']) {
          final responseData = privateResponse['data'];

          // Store Sunday School info
          if (responseData is Map && responseData['tenant'] != null) {
            _userSundaySchool = SundaySchool.fromJson(responseData['tenant']);
          }

          // Add private posts
          if (responseData is Map && responseData['posts'] != null) {
            final privateData = responseData['posts'] as List;
            allPosts.addAll(
              privateData.map((json) => UnifiedPost.fromPrivatePost(
                    json,
                    tenantName: _userSundaySchool?.name,
                  )),
            );
          } else if (responseData is List) {
            // Case where the response is a direct list of posts
            allPosts.addAll(
              responseData.map((json) => UnifiedPost.fromPrivatePost(
                    json,
                    tenantName: _userSundaySchool?.name,
                  )),
            );
          }
        }
      }

      // Sort by date (newest first)
      allPosts.sort((a, b) => b.date.compareTo(a.date));

      // Extract featured posts
      final featured = allPosts
          .where((p) => p.isImportant || p.type == PostType.event)
          .toList();

      if (mounted) {
        setState(() {
          _posts = allPosts;
          _featuredPosts = featured.isNotEmpty
              ? featured.take(5).toList()
              : allPosts.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll("Exception: ", "");
          _isLoading = false;
        });
      }
    }
  }

  void _showComments(UnifiedPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentsSheet(
        post: post,
        onCommentCountChanged: (newCount) {
          setState(() => post.commentCount = newCount);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final canManagePublicPosts = userProvider.canManagePublicPosts;
    final isSuperiorAdmin = userProvider.roles.contains('superior_admin');

    final userProfile = userProvider.userProfile;
    final userName = userProfile != null
        ? (userProfile['christian_name'] ?? userProfile['full_name'] ?? 'ምዕመን')
        : 'ምዕመን';

    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode(context);
    final bgColor = themeProvider.getBackgroundColor(context);
    final primaryColor = themeProvider.getPrimaryColor(context);
    final surfaceColor = themeProvider.getSurfaceColor(context);
    final textColor = themeProvider.getOnSurfaceColor(context);
    final subtleText = isDark ? Colors.white54 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        onRefresh: _loadUnifiedFeed,
        color: primaryColor,
        backgroundColor: surfaceColor,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(
                context,
                userName,
                primaryColor,
                surfaceColor,
                textColor,
                subtleText,
                isDark,
                bgColor,
                themeProvider.toggleTheme),
            if (_isLoading)
              SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: primaryColor)),
              )
            else if (_error != null)
              SliverFillRemaining(
                  child: _buildErrorWidget(primaryColor, subtleText))
            else ...[
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              if (_featuredPosts.isNotEmpty) ...[
                SliverToBoxAdapter(
                    child: _buildSectionHeader(
                        "ልዩ ትኩረት", Iconsax.star1, primaryColor, textColor)),
                SliverToBoxAdapter(child: _buildFeaturedCarousel()),
              ],
              SliverToBoxAdapter(
                  child: _buildSectionHeader(
                      "የቅርብ ጊዜ", Iconsax.activity, primaryColor, textColor)),
              if (_posts.isEmpty)
                SliverFillRemaining(
                    child: Center(
                        child: Text("ምንም መረጃ የለም",
                            style: TextStyle(color: subtleText))))
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        child: PostCard(
                          post: _posts[index],
                          onInteraction: () => setState(() {}),
                          onComment: () => _showComments(_posts[index]),
                        ),
                      );
                    },
                    childCount: _posts.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ]
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(
          canManagePublicPosts, isSuperiorAdmin, primaryColor),
    );
  }

  Widget _buildFloatingActionButton(
      bool canManagePublic, bool isSuperiorAdmin, Color primaryColor) {
    // Show public post management FAB for authorized users
    if (canManagePublic) {
      return FloatingActionButton(
        heroTag: 'home_screen_fab',
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => const AdminPublicPostManagementScreen()),
          );
          if (result == true) {
            _loadUnifiedFeed();
          }
        },
        backgroundColor: premiumGold,
        foregroundColor: premiumDark,
        enableFeedback: true,
        child: const Icon(Iconsax.edit),
      );
    }

    // Show private post management FABs for superior admins with Sunday School
    if (isSuperiorAdmin && _userSundaySchool != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'manage_private_posts_fab',
            onPressed: () async {
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AdminPostManagementScreen(
                            tenantId: _userSundaySchool?.id,
                          )));
              if (result == true) {
                _loadUnifiedFeed();
              }
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
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => EditTenantDialog(
                  sundaySchool: _userSundaySchool!,
                  onSave: () {
                    _loadUnifiedFeed();
                  },
                ),
              );
            },
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

    return const SizedBox.shrink();
  }

  Widget _buildSliverAppBar(
      BuildContext outerContext,
      String userName,
      Color primaryColor,
      Color surfaceColor,
      Color textColor,
      Color subtleText,
      bool isDark,
      Color bgColor,
      VoidCallback onToggleTheme) {
    return SliverAppBar(
      expandedHeight: 160.0,
      floating: false,
      pinned: true,
      backgroundColor: bgColor,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: surfaceColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(Iconsax.menu_1, color: textColor, size: 24),
          onPressed: () => Scaffold.of(outerContext).openDrawer(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: surfaceColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              isDark ? Iconsax.sun_1 : Iconsax.moon,
              color: textColor,
              size: 24,
            ),
            onPressed: onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20, bottom: 16, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "እንኳን ደህና መጡ፣",
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: 14,
                  color: subtleText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: 22,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withValues(alpha: 0.15),
                bgColor.withValues(alpha: 0.5),
                bgColor,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 100, right: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: bgColor,
                      child: Stack(
                        children: [
                          Icon(Iconsax.notification,
                              color: primaryColor, size: 24),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 220.0,
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: _featuredPosts.length > 1,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.85,
      ),
      items: _featuredPosts.map((post) {
        return Builder(
          builder: (BuildContext context) {
            return _FeaturedPostCard(post: post);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(
      String title, IconData icon, Color primaryColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 8),
          Text(title,
              style: GoogleFonts.notoSansEthiopic(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Color primaryColor, Color subtleText) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Iconsax.warning_2, color: subtleText, size: 50),
          const SizedBox(height: 16),
          Text(_error ?? "Unknown Error", style: TextStyle(color: subtleText)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUnifiedFeed,
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, foregroundColor: Colors.white),
            child: const Text("እንደገና ሞክር"),
          )
        ],
      ),
    );
  }
}

class _FeaturedPostCard extends StatelessWidget {
  final UnifiedPost post;
  const _FeaturedPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: post.imageUrl != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(post.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
        color: post.imageUrl == null ? const Color(0xFF2A2A3D) : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.2),
              Colors.black.withValues(alpha: 0.9),
            ],
            stops: const [0.5, 0.7, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.type == PostType.event)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: premiumGold,
                    borderRadius: BorderRadius.circular(30)),
                child: Text(
                  "FEATURED EVENT",
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: premiumDark),
                ),
              ),
            Text(
              post.title,
              style: GoogleFonts.notoSansEthiopic(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Iconsax.calendar_1, color: premiumGold, size: 16),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMMM d, y').format(post.date),
                  style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final UnifiedPost post;
  final VoidCallback onInteraction;
  final VoidCallback onComment;
  const PostCard(
      {super.key,
      required this.post,
      required this.onInteraction,
      required this.onComment});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode(context);
    final surfaceColor = themeProvider.getSurfaceColor(context);
    final textColor = themeProvider.getOnSurfaceColor(context);
    final subtleText = isDark ? Colors.white54 : const Color(0xFF64748B);
    final primaryColor = themeProvider.getPrimaryColor(context);

    final cardDecoration = BoxDecoration(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
          blurRadius: 15,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        )
      ],
      border: isDark
          ? Border.all(color: Colors.white.withValues(alpha: 0.05))
          : null,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: cardDecoration,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: isDark ? Colors.black38 : Colors.grey[200],
                    backgroundImage: post.authorAvatar != null
                        ? CachedNetworkImageProvider(post.authorAvatar!)
                        : null,
                    child: post.authorAvatar == null
                        ? Icon(Iconsax.user, color: subtleText)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author,
                          style: GoogleFonts.notoSansEthiopic(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Iconsax.clock, size: 12, color: subtleText),
                          const SizedBox(width: 4),
                          Text(DateFormat.yMMMd().format(post.date),
                              style: GoogleFonts.poppins(
                                  color: subtleText, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Iconsax.more, color: subtleText),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title,
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: textColor)),
                const SizedBox(height: 8),
                Text(post.description,
                    style: GoogleFonts.notoSansEthiopic(
                        color: subtleText, fontSize: 14, height: 1.6),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (post.imageUrl != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PostImage(imageUrl: post.imageUrl!, postId: post.id),
            ),

          // Interactions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: PostFooter(
                post: post, onInteraction: onInteraction, onComment: onComment),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class PostImage extends StatelessWidget {
  final String imageUrl;
  final String postId; // Unique ID for the Hero tag
  const PostImage({super.key, required this.imageUrl, required this.postId});

  @override
  Widget build(BuildContext context) {
    // Unique Hero tag for each post image
    final String heroTag = 'postImage-$postId';

    // Image viewer
    void openImageViewer() {
      // Simple implementation: push a full screen image viewer
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    iconTheme: const IconThemeData(color: Colors.white)),
                body: Center(
                  child: Hero(
                      tag: heroTag,
                      child: CachedNetworkImage(imageUrl: imageUrl)),
                ),
              )));
    }

    return GestureDetector(
      onTap: openImageViewer,
      child: Hero(
        tag: heroTag,
        child: Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.black12,
              image: DecorationImage(
                  image: CachedNetworkImageProvider(imageUrl),
                  fit: BoxFit.cover)),
        ),
      ),
    );
  }
}

class PostFooter extends StatefulWidget {
  final UnifiedPost post;
  final VoidCallback onInteraction;
  final VoidCallback onComment;
  const PostFooter(
      {super.key,
      required this.post,
      required this.onInteraction,
      required this.onComment});
  @override
  State<PostFooter> createState() => _PostFooterState();
}

class _PostFooterState extends State<PostFooter> {
  Future<void> _handleLike() async {
    final originalLikedState = widget.post.isLiked;
    final originalLikes = widget.post.likes;
    setState(() {
      widget.post.isLiked = !widget.post.isLiked;
      widget.post.likes += widget.post.isLiked ? 1 : -1;
    });
    final result = await PublicFeedService.togglePostLike(widget.post.id);
    if (!result['success'] && mounted) {
      setState(() {
        widget.post.isLiked = originalLikedState;
        widget.post.likes = originalLikes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode(context);
    final subtleText = isDark ? Colors.white70 : Colors.black54;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        InkWell(
          onTap: _handleLike,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              Icon(widget.post.isLiked ? Iconsax.heart5 : Iconsax.heart,
                  color: widget.post.isLiked ? Colors.redAccent : subtleText,
                  size: 22),
              if (widget.post.likes > 0) ...[
                const SizedBox(width: 6),
                Text(widget.post.likes.toString(),
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, color: subtleText)),
              ]
            ]),
          ),
        ),
        InkWell(
          onTap: widget.onComment,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              Icon(Iconsax.message_text_1, color: subtleText, size: 22),
              if (widget.post.commentCount > 0) ...[
                const SizedBox(width: 6),
                Text(widget.post.commentCount.toString(),
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, color: subtleText)),
              ]
            ]),
          ),
        ),
        IconButton(
            icon: Icon(Iconsax.share, color: subtleText, size: 22),
            onPressed: () {}),
      ]),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final UnifiedPost post;
  final ValueChanged<int> onCommentCountChanged;
  const _CommentsSheet(
      {required this.post, required this.onCommentCountChanged});
  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isPosting = false;
  Comment? _replyingTo;
  Comment? _editingComment;

  final Set<int> _expandedComments = {};
  int _topLevelLimit = 10;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() => _isLoading = true);
    final result = await PublicFeedService.getPostComments(widget.post.id);
    if (mounted && result['success']) {
      setState(() {
        _comments =
            (result['data'] as List).map((c) => Comment.fromJson(c)).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty || _isPosting) return;
    setState(() => _isPosting = true);

    Map<String, dynamic> result;
    if (_editingComment != null) {
      result = await PublicFeedService.updatePostComment(
          _editingComment!.id, _commentController.text.trim());
    } else {
      result = await PublicFeedService.createPostComment(
          widget.post.id, _commentController.text.trim(),
          parentId: _replyingTo?.id);
    }

    if (mounted) {
      if (result['success']) {
        if (_editingComment != null) {
          setState(() {
            final index =
                _comments.indexWhere((c) => c.id == _editingComment!.id);
            if (index != -1) {
              _comments[index] = Comment(
                id: _editingComment!.id,
                userId: _editingComment!.userId,
                author: _editingComment!.author,
                authorAvatar: _editingComment!.authorAvatar,
                text: _commentController.text.trim(),
                timestamp: _editingComment!.timestamp,
                parentId: _editingComment!.parentId,
              );
            }
            _editingComment = null;
            _commentController.clear();
          });
        } else {
          final newComment = Comment.fromJson(result['data']);
          setState(() {
            _comments.insert(0, newComment);
            _commentController.clear();
            _replyingTo = null;
          });
          widget.onCommentCountChanged(_comments.length);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? 'አስተያየቱን መለጠፍ አልተቻለም።'),
          backgroundColor: Colors.red,
        ));
      }
      setState(() => _isPosting = false);
    }
  }

  Future<void> _deleteComment(Comment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: const Text("አስተያየት ይጥፉ?", style: TextStyle(color: Colors.white)),
        content: const Text("ይህንን አስተያየት ማጥፋት እንደሚፈልጉ እርግጠኛ ነዎት?",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child:
                  const Text("ይቅር", style: TextStyle(color: Colors.white54))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child:
                  const Text("አጥፋ", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await PublicFeedService.deletePostComment(comment.id);
      if (mounted) {
        if (result['success']) {
          setState(() {
            _comments.removeWhere((c) => c.id == comment.id);
          });
          widget.onCommentCountChanged(_comments.length);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['message'] ?? 'አስተያየቱን ማጥፋት አልተቻለም።'),
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
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
    final Map<int, List<Comment>> repliesMap = {};
    final List<Comment> topLevelComments = [];

    for (var comment in _comments) {
      if (comment.parentId == null) {
        topLevelComments.add(comment);
      } else {
        repliesMap.putIfAbsent(comment.parentId!, () => []).add(comment);
      }
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E), // Premium Dark
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, -10))
            ]),
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Container(
                    width: 50,
                    height: 6,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("አስተያየቶች",
                        style: GoogleFonts.notoSansEthiopic(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: premiumGold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${_comments.length}",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: premiumDark,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ])),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: premiumGold))
                : _comments.isEmpty
                    ? const Center(
                        child: Text("እስካሁን ምንም አስተያየት የለም። የመጀመሪያው ይሁኑ!",
                            style: TextStyle(color: Colors.white60)))
                    : ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: (topLevelComments.length > _topLevelLimit)
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
                                child: const Text("ተጨማሪ አስተያየቶችን ይመልከቱ",
                                    style: TextStyle(color: premiumGold)),
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
                              _buildCommentItem(comment, currentUserId,
                                  isSystemAdmin, isSuperiorAdmin, userTenantId),
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
                                      "ሁሉንም ${replies.length} ምላሾች ይመልከቱ",
                                      style: const TextStyle(
                                          color: premiumGold,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              if (repliesToShow > 0)
                                Padding(
                                  padding: const EdgeInsets.only(left: 32.0),
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
                                            child: const Text("ምላሾችን ሰብስብ",
                                                style: TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12)),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        }),
          ),
          // Reply/Edit Indicator
          if (_replyingTo != null || _editingComment != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white.withValues(alpha: 0.05),
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
                          ? "አስተያየትን በማስተካከል ላይ..."
                          : "${_replyingTo!.author} በመመለስ ላይ...",
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
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      hintText: "አስተያየት ይፃፉ...",
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12)),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: premiumGold,
                child: IconButton(
                    icon: _isPosting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.black))
                        : const Icon(Iconsax.send_1,
                            color: Colors.black, size: 20),
                    onPressed: _addComment),
              )
            ]),
          )
        ]),
      ),
    );
  }

  Widget _buildCommentItem(Comment comment, dynamic currentUserId,
      bool isSystemAdmin, bool isSuperiorAdmin, String? userTenantId,
      {bool isReply = false}) {
    final bool isOwner = comment.userId.toString() == currentUserId.toString();

    // Deletion Logic: Owner OR System Admin OR School-Specific Superior Admin
    final bool isAuthorFromMySchool = comment.authorTenantId == userTenantId;
    final bool canDelete =
        isOwner || isSystemAdmin || (isSuperiorAdmin && isAuthorFromMySchool);

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
                  backgroundImage: (comment.authorAvatar != null)
                      ? CachedNetworkImageProvider(comment.authorAvatar!)
                      : null,
                  child: (comment.authorAvatar == null)
                      ? Text(
                          comment.author.isNotEmpty ? comment.author[0] : 'U',
                          style: TextStyle(
                              color: Colors.white, fontSize: isReply ? 12 : 14))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(comment.author,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isReply ? 13 : 14,
                                    color: Colors.white)),
                          ),
                          Text(DateFormat.MMMd().format(comment.timestamp),
                              style: GoogleFonts.poppins(
                                  fontSize: 10, color: Colors.white54)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(comment.text,
                          style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: isReply ? 13 : 14)),
                    ])),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isReply)
                  _ActionButton(
                    icon: Icons.reply,
                    label: "መልስ",
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
                    label: "አስተካክል",
                    onTap: () {
                      setState(() {
                        _editingComment = comment;
                        _replyingTo = null;
                        _commentController.text = comment.text;
                      });
                    },
                  ),
                ],
                if (canDelete) ...[
                  const SizedBox(width: 16),
                  _ActionButton(
                    icon: Iconsax.trash,
                    label: "አጥፋ",
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

// --- HELPER CLASSES ---
