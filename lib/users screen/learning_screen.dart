import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/role%20based/learning_admin.dart';

import 'package:amde_haymanot_abalat_guday/services/learning_service.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/article_viewer.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/video_player.dart';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:provider/provider.dart';

import 'package:animate_do/animate_do.dart';

// --- Premium Theme Constants ---
const Color premiumDark = Color(0xFF0F0F1E);
const Color premiumGold = Color(0xFFFFD700);

class Comment {
  final String id;
  final String author;
  final String avatarInitials;
  final String text;
  final DateTime timestamp;
  Comment(
      {required this.id,
      required this.author,
      required this.avatarInitials,
      required this.text,
      required this.timestamp});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'].toString(),
      author: json['author'] ?? '', // Empty default, handled in UI
      avatarInitials: json['avatarInitials'] ?? '?',
      text: json['text'] ?? '',
      timestamp: LearningContent._parseDate(json['timestamp']),
    );
  }
}

class LearningContent {
  final String id;
  final String title;
  final String author;
  final String? authorAvatar;
  final DateTime publishDate;
  final String description;
  final String type;
  final String imageUrl;
  final String content;
  final String duration;
  final String category;
  final String difficulty;
  int likes;
  bool isLiked;
  bool isBookmarked;
  int commentCount;

  LearningContent({
    required this.id,
    required this.title,
    required this.author,
    this.authorAvatar,
    required this.publishDate,
    required this.description,
    required this.type,
    required this.imageUrl,
    required this.content,
    required this.duration,
    required this.category,
    required this.difficulty,
    this.likes = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    this.commentCount = 0,
  });

  static DateTime _parseDate(dynamic dateString) {
    if (dateString == null || dateString is! String) {
      return DateTime.now();
    }
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      debugPrint('--- የቀን ανάλυση አልተሳካም ---');
      debugPrint('ዋጋ: $dateString, ስህተት: $e');
      debugPrint('-------------------------');
      return DateTime.now();
    }
  }

  factory LearningContent.fromJson(Map<String, dynamic> json) {
    return LearningContent(
      id: json['id']?.toString() ?? UniqueKey().toString(),
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      authorAvatar: json['authorAvatar'],
      publishDate: _parseDate(json['publishDate']),
      description: json['description'] ?? '',
      type: json['type'] ?? 'article',
      imageUrl: json['imageUrl'] ?? '',
      content: json['content'] ?? '',
      duration: json['duration'] ?? 'N/A',
      category: json['category'] ?? '',
      difficulty: json['difficulty'] ?? 'Beginner',
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] == 1 || json['isLiked'] == true,
      isBookmarked: json['isBookmarked'] == 1 || json['isBookmarked'] == true,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  List<LearningContent> _contentList = [];
  bool _isLoading = true;
  String? _error;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchLearningContent();
  }

  Future<void> _fetchLearningContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await LearningService.getLearningContent();
    if (mounted) {
      if (result['success']) {
        // Deduplicate items by ID
        final Map<String, LearningContent> uniqueContentMap = {};
        for (var item in (result['data'] as List)) {
          final content = LearningContent.fromJson(item);
          // If duplicate ID exists, keep the first one
          if (!uniqueContentMap.containsKey(content.id)) {
            uniqueContentMap[content.id] = content;
          }
        }

        setState(() {
          _contentList = uniqueContentMap.values.toList();
          _isLoading = false;
        });
      } else {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _error = result['message'] ?? l10n.learningFailedToLoad;
          _isLoading = false;
        });
      }
    }
  }

  void _onAdminAction() {
    _fetchLearningContent();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = context.watch<UserProvider>();
    final bool canManageContent =
        userProvider.roles.contains('superior_admin') ||
            userProvider.roles.contains('learning_admin');

    return Scaffold(
      backgroundColor: premiumDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.8),
                premiumDark,
                Colors.black,
              ],
              stops: const [
                0.0,
                0.4,
                1.0
              ]),
        ),
        child: RefreshIndicator(
          onRefresh: _fetchLearningContent,
          color: premiumGold,
          backgroundColor: premiumDark,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: true,
                backgroundColor: Colors.transparent,
                expandedHeight: 120,
                leading: IconButton(
                  icon: const Icon(Iconsax.menu_1, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
                  title: Text(l10n.learningCenter,
                      style: GoogleFonts.notoSansEthiopic(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 18)),
                  background: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent
                        ])),
                  ),
                ),
                actions: [
                  if (canManageContent)
                    IconButton(
                      icon: const Icon(Iconsax.edit, color: Colors.white),
                      tooltip: l10n.learningManageContent,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LearningAdminHubScreen(
                            onDataChanged: _onAdminAction,
                          ),
                        ),
                      ),
                    ),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Iconsax.search_normal,
                          color: Colors.white),
                      tooltip: l10n.learningSearch),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Iconsax.filter, color: Colors.white),
                      tooltip: l10n.learningFilter),
                ],
              ),
              _buildBody(),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: premiumGold)),
      );
    }
    if (_error != null) {
      return SliverFillRemaining(
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.warning_2, color: Colors.redAccent, size: 40),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansEthiopic(
                    color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        )),
      );
    }
    if (_contentList.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.document_text, color: Colors.white24, size: 60),
              const SizedBox(height: 16),
              Text(
                l10n.learningNoContent,
                style: GoogleFonts.notoSansEthiopic(
                    color: Colors.white60, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final content = _contentList[index];
            return FadeInUp(
              delay: Duration(milliseconds: 100 * index),
              child: _LearningContentCard(
                key: Key('learning_card_${content.id}'),
                content: content,
              ),
            );
          },
          childCount: _contentList.length,
        ),
      ),
    );
  }
}

class _LearningContentCard extends StatefulWidget {
  final LearningContent content;
  const _LearningContentCard({super.key, required this.content});

  @override
  State<_LearningContentCard> createState() => _LearningContentCardState();
}

class _LearningContentCardState extends State<_LearningContentCard> {
  void _handleLike() async {
    final originalLikedState = widget.content.isLiked;
    final originalLikes = widget.content.likes;
    setState(() {
      widget.content.isLiked = !widget.content.isLiked;
      widget.content.likes += widget.content.isLiked ? 1 : -1;
    });
    final result = await LearningService.toggleLike(widget.content.id);
    if (!result['success'] && mounted) {
      setState(() {
        widget.content.isLiked = originalLikedState;
        widget.content.likes = originalLikes;
      });
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.learningLikeUpdateFailed),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  void _handleBookmark() async {
    final l10n = AppLocalizations.of(context)!;
    final originalBookmarkState = widget.content.isBookmarked;
    setState(() => widget.content.isBookmarked = !widget.content.isBookmarked);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(widget.content.isBookmarked
          ? l10n.learningBookmarkAdded
          : l10n.learningBookmarkRemoved),
      backgroundColor:
          widget.content.isBookmarked ? premiumGold : Colors.grey[800],
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
    ));
    final result = await LearningService.toggleBookmark(widget.content.id);
    if (!result['success'] && mounted) {
      setState(() => widget.content.isBookmarked = originalBookmarkState);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.learningBookmarkUpdateFailed),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentsSheet(
          content: widget.content,
          onCommentAdded: (newCommentCount) {
            setState(() {
              widget.content.commentCount = newCommentCount;
            });
          }),
    );
  }

  void _handleContentTap() {
    if (widget.content.type == 'video') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(content: widget.content),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArticleViewerScreen(content: widget.content),
        ),
      );
    }
  }

  Color _getDifficultyColor(String d) {
    switch (d.toLowerCase()) {
      case 'beginner':
      case 'ጀማሪ':
        return Colors.greenAccent;
      case 'intermediate':
      case 'መካከለኛ':
        return Colors.orangeAccent;
      case 'advanced':
      case 'ከፍተኛ':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  String _getLocalizedDifficulty(BuildContext context, String difficulty) {
    final l10n = AppLocalizations.of(context)!;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
      case 'ጀማሪ':
        return l10n.learningDifficultyBeginner;
      case 'intermediate':
      case 'መካከለኛ':
        return l10n.learningDifficultyIntermediate;
      case 'advanced':
      case 'ከፍተኛ':
        return l10n.learningDifficultyAdvanced;
      default:
        return difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ]),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageHeader(),
          Transform.translate(
              offset: const Offset(0, -25), child: _buildAuthorInfoBar()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.5))),
                      child: Text(
                          widget.content.category.isEmpty
                              ? AppLocalizations.of(context)!
                                  .learningCategoryGeneral
                                  .toUpperCase()
                              : widget.content.category.toUpperCase(),
                          style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color:
                                _getDifficultyColor(widget.content.difficulty)
                                    .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color:
                                    _getDifficultyColor(widget.content.difficulty)
                                        .withOpacity(0.3))),
                        child: Text(
                            _getLocalizedDifficulty(
                                context, widget.content.difficulty),
                            style: GoogleFonts.poppins(
                                fontSize: 10,
                                color:
                                    _getDifficultyColor(widget.content.difficulty),
                                fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                    widget.content.title.isEmpty
                        ? AppLocalizations.of(context)!.learningNoTitle
                        : widget.content.title,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
                const SizedBox(height: 8),
                Text(widget.content.description,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.1), height: 1),
          _buildActionBar(),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            InkWell(
              onTap: _handleLike,
              child: Row(
                children: [
                  Icon(widget.content.isLiked ? Iconsax.heart5 : Iconsax.heart,
                      color: widget.content.isLiked
                          ? Colors.redAccent
                          : Colors.white60,
                      size: 22),
                  if (widget.content.likes > 0) ...[
                    const SizedBox(width: 8),
                    Text(widget.content.likes.toString(),
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.white60)),
                  ]
                ],
              ),
            ),
            const SizedBox(width: 24),
            InkWell(
              onTap: _showComments,
              child: Row(
                children: [
                  Icon(Iconsax.message, color: Colors.white60, size: 22),
                  if (widget.content.commentCount > 0) ...[
                    const SizedBox(width: 8),
                    Text(widget.content.commentCount.toString(),
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.white60)),
                  ]
                ],
              ),
            )
          ]),
          InkWell(
            onTap: _handleBookmark,
            child: Icon(
                widget.content.isBookmarked
                    ? Iconsax.bookmark5
                    : Iconsax.bookmark,
                color:
                    widget.content.isBookmarked ? premiumGold : Colors.white60,
                size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorInfoBar() {
    final ethiopianDate =
        EthiopianDate.fromGregorian(widget.content.publishDate);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E), // Darker card background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: premiumGold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: premiumGold, width: 1.5),
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey[800],
              backgroundImage: widget.content.authorAvatar != null &&
                      widget.content.authorAvatar!.isNotEmpty
                  ? CachedNetworkImageProvider(widget.content.authorAvatar!)
                  : null,
              child: (widget.content.authorAvatar == null ||
                      widget.content.authorAvatar!.isEmpty)
                  ? Text(
                      widget.content.author.isNotEmpty
                          ? widget.content.author[0]
                          : '?',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.content.author.isEmpty
                      ? AppLocalizations.of(context)!.learningUnknownAuthor
                      : widget.content.author,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  ethiopianDate.toString(),
                  style:
                      GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageHeader() {
    return GestureDetector(
      onTap: _handleContentTap,
      child: Hero(
        tag: 'content_image_${widget.content.id}',
        child: Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black26,
            image: widget.content.imageUrl.isNotEmpty
                ? DecorationImage(
                    image: CachedNetworkImageProvider(widget.content.imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: widget.content.imageUrl.isEmpty
              ? Center(
                  child: Icon(
                    widget.content.type == 'video'
                        ? Iconsax.video_play
                        : Iconsax.document_text,
                    size: 48,
                    color: Colors.white24,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent
                  ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
                  child: Center(
                    child: widget.content.type == 'video'
                        ? Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white54)),
                            child: const Icon(Iconsax.play,
                                color: Colors.white, size: 30),
                          )
                        : null,
                  ),
                ),
        ),
      ),
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final LearningContent content;
  final Function(int) onCommentAdded;

  const _CommentsSheet({required this.content, required this.onCommentAdded});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
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

    final result = await LearningService.getComments(widget.content.id);

    if (mounted) {
      if (result['success']) {
        final List<dynamic> data = result['data'] as List<dynamic>? ?? [];
        setState(() {
          _comments = data.map((e) => Comment.fromJson(e)).toList();
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

    final result = await LearningService.addComment(widget.content.id, text);

    if (mounted) {
      setState(() {
        _isSending = false;
      });

      if (result['success']) {
        _commentController.clear();
        _fetchComments(); // Refresh list
        widget.onCommentAdded(_comments.length + 1);
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
          color: premiumDark,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
              top: BorderSide(color: premiumGold.withOpacity(0.3), width: 1))),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10))),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text("Comments",
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
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
          const Divider(color: Colors.white10),
          // List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: premiumGold))
                : _error != null
                    ? Center(
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.redAccent)))
                    : _comments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Iconsax.message,
                                    size: 48, color: Colors.white24),
                                const SizedBox(height: 16),
                                Text("No comments yet",
                                    style: GoogleFonts.notoSansEthiopic(
                                        color: Colors.white54)),
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
                                      child: Text(
                                        comment.avatarInitials.isNotEmpty
                                            ? comment.avatarInitials
                                            : '?',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            color: premiumGold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.05),
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
                                                  comment.author.isNotEmpty
                                                      ? comment.author
                                                      : l10n
                                                          .learningUnknownAuthor,
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      fontSize: 13),
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
                      fillColor: Colors.white.withOpacity(0.05),
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
