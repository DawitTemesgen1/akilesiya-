import 'package:amde_haymanot_abalat_guday/admin%20only/post_general_home.dart';
import 'package:amde_haymanot_abalat_guday/services/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/services/public_feed_service.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';

// --- MODELS AND ENUMS (No Changes Here) ---

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

// --- MAIN WIDGET ---

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> _posts = [];
  List<Post> _events = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await PublicFeedService.getPublicPosts();
      if (mounted) {
        if (result['success']) {
          final allPosts =
              (result['data'] as List).map((p) => Post.fromJson(p)).toList();
          setState(() {
            _events = allPosts.where((p) => p.type == PostType.event).toList()
              ..sort((a, b) => a.eventDate!.compareTo(b.eventDate!));
            _posts = allPosts.where((p) => p.type != PostType.event).toList();
            _isLoading = false;
          });
        } else {
          throw Exception(result['message']);
        }
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _error = e.toString().replaceAll("Exception: ", "");
          _isLoading = false;
        });
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

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _buildBody(),
      ),
      floatingActionButton: canManagePosts
          ? FloatingActionButton(
              heroTag: 'public_homepage',
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
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.accent,
              child: const Icon(Iconsax.edit),
              tooltip: 'ይፋዊ ልጥፎችን ያስተዳድሩ',
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.warning_2, color: Colors.red, size: 50),
              const SizedBox(height: 16),
              const Text("ዝርዝሩን መጫን አልተቻለም",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_error!,
                  style: TextStyle(color: Colors.grey[700]),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                  icon: const Icon(Iconsax.refresh),
                  label: const Text("እንደገና ሞክር"),
                  onPressed: _loadData)
            ],
          ),
        ),
      );
    }
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.textLight,
          pinned: true,
          floating: true,
          expandedHeight: 120,
          flexibleSpace: FlexibleSpaceBar(
            title: Text("ሰንበት ትምህርት ቤት ህብረት",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              ),
            ),
          ),
        ),
        if (_events.isNotEmpty) ...[
          _buildSectionHeader("መጪ ዝግጅቶች", Iconsax.calendar_1),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _events.length,
                itemBuilder: (context, index) =>
                    _EventCard(event: _events[index]),
              ),
            ),
          ),
        ],
        _buildSectionHeader("አዳዲስ መረጃዎች", Iconsax.activity),
        if (_posts.isEmpty && _events.isEmpty)
          const SliverFillRemaining(
              child: Center(child: Text("እስካሁን ምንም አዲስ መረጃ የለም።")))
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PostCard(
                  post: _posts[index],
                  onInteraction: () => setState(() {}),
                  onComment: () => _showComments(_posts[index]),
                );
              },
              childCount: _posts.length,
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.onSurface)),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Post event;
  const _EventCard({required this.event});
  @override
  Widget build(BuildContext context) {
    final shadowTextStyle = GoogleFonts.poppins(
      color: Colors.white,
      shadows: [
        Shadow(
            blurRadius: 4.0,
            color: Colors.black.withOpacity(0.7),
            offset: const Offset(1.0, 1.0))
      ],
    );
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: event.imageUrl != null
            ? DecorationImage(
                image: CachedNetworkImageProvider(event.imageUrl!),
                fit: BoxFit.cover)
            : null,
        color: event.imageUrl == null ? AppTheme.primaryLight : null,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.9),
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.0)
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: const [0.0, 0.6, 1.0]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (event.eventDate != null)
              Text(
                DateFormat('E, MMM d \'በ\' h:mm a').format(event.eventDate!),
                style: shadowTextStyle.copyWith(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            const SizedBox(height: 4),
            Text(event.title,
                style: shadowTextStyle.copyWith(
                    fontWeight: FontWeight.bold, fontSize: 16, height: 1.2),
                maxLines: 2),
            const SizedBox(height: 8),
            if (event.location.isNotEmpty)
              Row(
                children: [
                  const Icon(Iconsax.location, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(event.location,
                        style: shadowTextStyle.copyWith(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1),
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 4,
      shadowColor: const Color.fromARGB(255, 233, 237, 240).withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostHeader(post: post),
          if (post.type == PostType.event) EventInfoRow(post: post),
          if (post.imageUrl != null)
            PostImage(imageUrl: post.imageUrl!, postId: post.id),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title,
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 239, 242, 245))),
                const SizedBox(height: 8),
                Text(post.description,
                    style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                        height: 1.5),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          PostFooter(
              post: post, onInteraction: onInteraction, onComment: onComment),
        ],
      ),
    );
  }
}

class PostHeader extends StatelessWidget {
  final Post post;
  const PostHeader({super.key, required this.post});
  @override
  Widget build(BuildContext context) {
    final bool isEvent = post.type == PostType.event && post.eventDate != null;
    final DateTime displayDate = isEvent ? post.eventDate! : post.date;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: (post.authorAvatar != null)
                ? CachedNetworkImageProvider(post.authorAvatar!)
                : null,
            child:
                (post.authorAvatar == null) ? const Icon(Iconsax.shop) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.author,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 246, 248, 250))),
                Text(
                    (isEvent ? 'ዝግጅቱ በ: ' : '') +
                        DateFormat.yMMMd().format(displayDate),
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventInfoRow extends StatelessWidget {
  final Post post;
  const EventInfoRow({super.key, required this.post});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.primary.withOpacity(0.05),
      child: Column(
        children: [
          if (post.eventDate != null)
            Row(
              children: [
                Icon(Iconsax.calendar_1, size: 16, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        DateFormat('EEEE, MMMM d, yyyy \'በ\' h:mm a')
                            .format(post.eventDate!),
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.onSurface))),
              ],
            ),
          if (post.location.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Iconsax.location, size: 16, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(post.location,
                        style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary))),
              ],
            ),
          ]
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

    return Hero(
      tag: heroTag,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        height: 220,
        width: double.infinity,
        placeholder: (context, url) =>
            Container(height: 220, color: Colors.grey[200]),
        errorWidget: (context, url, error) => Container(
            height: 220,
            color: Colors.grey[200],
            child: const Icon(Iconsax.gallery_slash,
                color: AppTheme.textSecondary)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          IconButton(
              icon: Icon(widget.post.isLiked ? Iconsax.heart5 : Iconsax.heart,
                  color: widget.post.isLiked
                      ? AppTheme.danger
                      : AppTheme.textSecondary),
              onPressed: _handleLike),
          if (widget.post.likes > 0)
            Text(widget.post.likes.toString(),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ]),
        Row(children: [
          IconButton(
              icon: const Icon(Iconsax.message_text_1,
                  color: AppTheme.textSecondary),
              onPressed: widget.onComment),
          if (widget.post.commentCount > 0)
            Text(widget.post.commentCount.toString(),
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ]),
        IconButton(
            icon: const Icon(Iconsax.share, color: AppTheme.textSecondary),
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
        decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 16),
                Text("አስተያየቶች (${_comments.length})",
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ])),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? const Center(
                        child: Text("እስካሁን ምንም አስተያየት የለም። የመጀመሪያው ይሁኑ!"))
                    : ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        (comment.authorAvatar != null)
                                            ? CachedNetworkImageProvider(
                                                comment.authorAvatar!)
                                            : null,
                                    child: (comment.authorAvatar == null)
                                        ? Text(comment.author.isNotEmpty
                                            ? comment.author[0]
                                            : 'U')
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
                                                DateFormat.jm()
                                                    .format(comment.timestamp),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppTheme
                                                        .textSecondary)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(comment.text,
                                            style: const TextStyle(
                                                color: AppTheme.onSurface)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                .copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 8),
            decoration: BoxDecoration(color: AppTheme.surface, boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5))
            ]),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: const TextStyle(color: AppTheme.onSurface),
                  decoration: InputDecoration(
                    hintText: "አስተያየትዎን ያስገቡ...",
                    fillColor: AppTheme.background,
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
                      icon: const Icon(Iconsax.send_1, color: AppTheme.primary),
                      onPressed: _addComment),
            ]),
          ),
        ]),
      ),
    );
  }
}
