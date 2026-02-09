import 'package:amde_haymanot_abalat_guday/admin%20only/post_general_home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/services/public_feed_service.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';

// --- MODELS AND ENUMS ---

enum PostType { event, announcement, news, prayer }

class Comment {
  final int id;
  final String author;
  final String? authorAvatar;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.author,
    this.authorAvatar,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
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

    return Comment(
      id: json['id'],
      author: json['author'] ?? 'User',
      authorAvatar: buildFullUrl(json['authorAvatar']),
      text: json['text'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

class Post {
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

  Post({
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
  });

  factory Post.fromJson(Map<String, dynamic> json) {
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

    return Post(
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
    );
  }
}

// --- CONSTANTS ---
const Color premiumDark = Color(0xFF0F0F1E);
const Color premiumGold = Color(0xFFFFD700);

// --- MAIN WIDGET ---

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> _posts = [];
  List<Post> _featuredPosts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    // Initial setState is redundant for first load as _isLoading is true,
    // and if called later (e.g. refresh), we want it.
    // However, to be safe and avoid "dirty build" if called rapidly:
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final result = await PublicFeedService.getPublicPosts();
      if (mounted) {
        if (result['success']) {
          final allPosts =
              (result['data'] as List).map((p) => Post.fromJson(p)).toList();
          setState(() {
            // Logic: Important posts or Events go to featured, rest to feed
            _featuredPosts = allPosts
                .where((p) => p.isImportant || p.type == PostType.event)
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date));

            // If no featured posts, take the top 3 latest
            if (_featuredPosts.isEmpty && allPosts.isNotEmpty) {
              _featuredPosts = allPosts.take(3).toList();
            }

            // The rest go to the main feed
            _posts = allPosts;
            _isLoading = false;
          });
        } else {
          throw Exception(result['message']);
        }
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

  void _showComments(Post post) {
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
    final bool canManagePosts =
        context.watch<UserProvider>().canManagePublicPosts;
    final userProfile = context.watch<UserProvider>().userProfile;
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
      // Drawer removed - already provided by parent HomeScreen
      body: Container(
        color: bgColor,
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: primaryColor,
          backgroundColor: surfaceColor,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, userName, primaryColor, surfaceColor,
                  textColor, subtleText, isDark, themeProvider.toggleTheme),
              if (_isLoading)
                SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(color: primaryColor)),
                )
              else if (_error != null)
                SliverFillRemaining(
                    child: _buildErrorWidget(primaryColor, subtleText))
              else ...[
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
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ]
            ],
          ),
        ),
      ),
      floatingActionButton: canManagePosts
          ? FloatingActionButton(
              heroTag: 'home_screen_fab', // Unique tag
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          const AdminPublicPostManagementScreen()),
                );
                if (result == true) {
                  _loadData();
                }
              },
              backgroundColor: premiumGold,
              foregroundColor: premiumDark,
              enableFeedback: true,
              child: const Icon(Iconsax.edit),
            )
          : null,
    );
  }

  Widget _buildSliverAppBar(
      BuildContext outerContext,
      String userName,
      Color primaryColor,
      Color surfaceColor,
      Color textColor,
      Color subtleText,
      bool isDark,
      VoidCallback onToggleTheme) {
    return SliverAppBar(
      expandedHeight: 140.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent, // Transparent to show gradient
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.sort, color: textColor, size: 28),
        onPressed: () => Scaffold.of(outerContext).openDrawer(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Iconsax.sun_1 : Iconsax.moon,
            color: textColor,
            size: 24,
          ),
          onPressed: onToggleTheme,
          tooltip: 'Toggle Theme',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "እንኳን ደህና መጡ፣",
              style: GoogleFonts.notoSansEthiopic(
                fontSize: 12,
                color: subtleText,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              userName,
              style: GoogleFonts.notoSansEthiopic(
                fontSize: 16, // Smaller font for collapsed state ideally
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 50, right: 16),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: surfaceColor,
                child: Icon(Iconsax.notification, color: primaryColor),
              ),
            ),
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
            onPressed: _loadData,
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
  final Post post;
  const _FeaturedPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: post.imageUrl != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(post.imageUrl!),
                fit: BoxFit.cover,
              )
            : null,
        color: post.imageUrl == null ? const Color(0xFF2A2A3D) : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.type == PostType.event)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                    color: premiumGold, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  "FEATURED EVENT",
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: premiumDark),
                ),
              ),
            Text(
              post.title,
              style: GoogleFonts.notoSansEthiopic(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat.yMMMd().format(post.date),
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
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
    final dividerColor = isDark ? Colors.white10 : Colors.black12;
    final primaryColor = themeProvider.getPrimaryColor(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dividerColor),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ]),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: dividerColor,
                  backgroundImage: post.authorAvatar != null
                      ? CachedNetworkImageProvider(post.authorAvatar!)
                      : null,
                  child: post.authorAvatar == null
                      ? Icon(Iconsax.user, color: subtleText)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.author,
                          style: GoogleFonts.notoSansEthiopic(
                              color: textColor, fontWeight: FontWeight.bold)),
                      Text(DateFormat.yMMMd().format(post.date),
                          style: GoogleFonts.poppins(
                              color: subtleText, fontSize: 12)),
                    ],
                  ),
                ),
                if (post.isImportant)
                  Icon(Iconsax.verify, color: primaryColor, size: 20),
              ],
            ),
          ),
          // Content
          if (post.imageUrl != null)
            PostImage(imageUrl: post.imageUrl!, postId: post.id),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title,
                    style: GoogleFonts.notoSansEthiopic(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor)),
                const SizedBox(height: 8),
                Text(post.description,
                    style: GoogleFonts.notoSansEthiopic(
                        color: subtleText, height: 1.5),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          // Interactions
          Divider(color: dividerColor),
          PostFooter(
              post: post, onInteraction: onInteraction, onComment: onComment),
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
  final Post post;
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
  final Post post;
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
    final result = await PublicFeedService.createPostComment(
        widget.post.id, _commentController.text.trim());
    if (mounted) {
      if (result['success']) {
        final newComment = Comment.fromJson(result['data']);
        setState(() {
          _comments.insert(0, newComment);
          _commentController.clear();
        });
        widget.onCommentCountChanged(_comments.length);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? 'አስተያየቱን መለጠፍ አልተቻለም።'),
          backgroundColor: Colors.red,
        ));
      }
      setState(() => _isPosting = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E), // Premium Dark
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                  color: premiumGold.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5))
            ]),
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 16),
                Text("አስተያየቶች (${_comments.length})",
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
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
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.white10,
                                    backgroundImage:
                                        (comment.authorAvatar != null)
                                            ? CachedNetworkImageProvider(
                                                comment.authorAvatar!)
                                            : null,
                                    child: (comment.authorAvatar == null)
                                        ? Text(
                                            comment.author.isNotEmpty
                                                ? comment.author[0]
                                                : 'U',
                                            style: const TextStyle(
                                                color: Colors.white))
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
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white)),
                                            Text(
                                                DateFormat.MMMd()
                                                    .format(comment.timestamp),
                                                style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    color: Colors.white54)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(comment.text,
                                            style: GoogleFonts.poppins(
                                                color: Colors.white70)),
                                      ]))
                                ],
                              ),
                            ),
                          );
                        }),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
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
}
