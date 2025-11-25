import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/role%20based/learning_admin.dart';
import 'package:amde_haymanot_abalat_guday/services/app_theme.dart';
import 'package:amde_haymanot_abalat_guday/services/learning_service.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/article_viewer.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
      author: json['author'] ?? 'ስም አልባ',
      avatarInitials: json['avatarInitials'] ?? 'ስ',
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
      title: json['title'] ?? 'ርዕስ የለም',
      author: json['author'] ?? 'ያልታወቀ ደራሲ',
      authorAvatar: json['authorAvatar'],
      publishDate: _parseDate(json['publishDate']),
      description: json['description'] ?? '',
      type: json['type'] ?? 'article',
      imageUrl: json['imageUrl'] ?? '',
      content: json['content'] ?? '',
      duration: json['duration'] ?? 'N/A',
      category: json['category'] ?? 'አጠቃላይ',
      difficulty: json['difficulty'] ?? 'ጀማሪ',
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
        final List<LearningContent> fetchedContent = (result['data'] as List)
            .map((item) => LearningContent.fromJson(item))
            .toList();
        setState(() {
          _contentList = fetchedContent;
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
      body: RefreshIndicator(
        onRefresh: _fetchLearningContent,
        color: AppTheme.primary,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(l10n.learningCenter,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                  ),
                ),
              ),
              actions: [
                if (canManageContent)
                  IconButton(
                    icon: const Icon(Iconsax.edit),
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
                    icon: const Icon(Iconsax.search_normal),
                    tooltip: l10n.learningSearch),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Iconsax.filter),
                    tooltip: l10n.learningFilter),
              ],
            ),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const SliverFillRemaining(
        child:
            Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }
    if (_error != null) {
      return SliverFillRemaining(
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: AppTheme.bodyText.copyWith(color: AppTheme.danger),
          ),
        )),
      );
    }
    if (_contentList.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            l10n.learningNoContent,
            style: AppTheme.bodyText,
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final content = _contentList[index];
            return _LearningContentCard(
              key: Key('learning_card_${content.id}'),
              content: content,
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
        backgroundColor: AppTheme.danger,
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
      backgroundColor: widget.content.isBookmarked
          ? AppTheme.success
          : AppTheme.textSecondary,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
    ));
    final result = await LearningService.toggleBookmark(widget.content.id);
    if (!result['success'] && mounted) {
      setState(() => widget.content.isBookmarked = originalBookmarkState);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.learningBookmarkUpdateFailed),
        backgroundColor: AppTheme.danger,
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
        return AppTheme.success;
      case 'intermediate':
      case 'መካከለኛ':
        return AppTheme.warning;
      case 'advanced':
      case 'ከፍተኛ':
        return AppTheme.danger;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 6,
      shadowColor: AppTheme.primary.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageHeader(),
          _buildAuthorInfoBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                        label: Text(widget.content.category.toUpperCase()),
                        labelStyle: AppTheme.chipText,
                        backgroundColor: AppTheme.primary.withOpacity(0.1)),
                    Chip(
                        label: Text(widget.content.difficulty),
                        labelStyle: AppTheme.chipText.copyWith(
                            color:
                                _getDifficultyColor(widget.content.difficulty)),
                        backgroundColor:
                            _getDifficultyColor(widget.content.difficulty)
                                .withOpacity(0.1)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(widget.content.title, style: AppTheme.headline2),
                const SizedBox(height: 12),
                Text(widget.content.description,
                    style: AppTheme.bodyText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          _buildActionBar(),
        ],
      ),
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            IconButton(
                icon: Icon(
                    widget.content.isLiked ? Iconsax.heart5 : Iconsax.heart,
                    color: widget.content.isLiked
                        ? AppTheme.danger
                        : AppTheme.textSecondary),
                onPressed: _handleLike),
            if (widget.content.likes > 0)
              Text(widget.content.likes.toString(),
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
            const SizedBox(width: 12),
            IconButton(
                icon:
                    const Icon(Iconsax.message, color: AppTheme.textSecondary),
                onPressed: _showComments),
            if (widget.content.commentCount > 0)
              Text(widget.content.commentCount.toString(),
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
          ]),
          IconButton(
            icon: Icon(
                widget.content.isBookmarked
                    ? Iconsax.bookmark5
                    : Iconsax.bookmark,
                color: widget.content.isBookmarked
                    ? AppTheme.primary
                    : AppTheme.textSecondary),
            onPressed: _handleBookmark,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorInfoBar() {
    final ethiopianDate =
        EthiopianDate.fromGregorian(widget.content.publishDate);
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.background,
              backgroundImage: widget.content.authorAvatar != null &&
                      widget.content.authorAvatar!.isNotEmpty
                  ? CachedNetworkImageProvider(widget.content.authorAvatar!)
                  : null,
              child: (widget.content.authorAvatar == null ||
                      widget.content.authorAvatar!.isEmpty)
                  ? Text(
                      widget.content.author.isNotEmpty
                          ? widget.content.author[0]
                          : 'ደ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.content.author,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    ethiopianDate.toString(),
                    style: AppTheme.bodyText.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageHeader() {
    return GestureDetector(
      onTap: _handleContentTap,
      child: Hero(
        tag: 'learning_image_${widget.content.id}',
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CachedNetworkImage(
                imageUrl: widget.content.imageUrl,
                fit: BoxFit.cover,
                height: 180,
                width: double.infinity,
                placeholder: (context, url) =>
                    Container(height: 180, color: Colors.grey[200]),
                errorWidget: (context, url, error) => Container(
                    height: 180,
                    color: Colors.grey[200],
                    child: const Icon(Iconsax.gallery_slash,
                        color: AppTheme.textSecondary)),
              ),
              Container(
                  height: 180,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent
                  ], begin: Alignment.bottomCenter, end: Alignment.center))),
              if (widget.content.type == 'video')
                Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle),
                    child: const Icon(Iconsax.play,
                        color: Colors.white, size: 24)),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    Icon(
                        widget.content.type == 'video'
                            ? Iconsax.video
                            : Iconsax.document_text,
                        color: Colors.white,
                        size: 14),
                    const SizedBox(width: 6),
                    Text(widget.content.duration,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),
            ],
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
    final result = await LearningService.getComments(widget.content.id);
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
    final result = await LearningService.addComment(
        widget.content.id, _commentController.text.trim());
    if (mounted) {
      if (result['success']) {
        final newComment = Comment.fromJson(result['data']);
        setState(() {
          _comments.insert(0, newComment);
          _commentController.clear();
        });
        widget.onCommentAdded(_comments.length);
      } else {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? l10n.learningCommentPostFailed),
          backgroundColor: AppTheme.danger,
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
    final l10n = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
            color: AppTheme.background,
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
                        borderRadius: BorderRadius.circular(2.5))),
                const SizedBox(height: 12),
                Text(l10n.commonComments, style: AppTheme.headline2),
              ])),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary))
                : _comments.isEmpty
                    ? Center(
                        child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(l10n.learningNoComments,
                            style: AppTheme.bodyText,
                            textAlign: TextAlign.center),
                      ))
                    : ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor:
                                      AppTheme.primary.withOpacity(0.1),
                                  child: Text(comment.avatarInitials,
                                      style: GoogleFonts.poppins(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(comment.author,
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.textPrimary)),
                                          const Spacer(),
                                          Text(
                                              DateFormat('MMM d, h:mm a')
                                                  .format(comment.timestamp),
                                              style: AppTheme.bodyText.copyWith(
                                                  fontSize: 12,
                                                  color:
                                                      AppTheme.textSecondary)),
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
                          );
                        },
                      ),
          ),
          _buildCommentInputField(),
        ]),
      ),
    );
  }

  Widget _buildCommentInputField() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
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
            style: AppTheme.bodyText.copyWith(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: l10n.learningAddComment,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _isPosting
            ? const Padding(
                padding: EdgeInsets.all(12.0),
                child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2)))
            : IconButton(
                icon: const Icon(Iconsax.send_1, color: AppTheme.primary),
                onPressed: _addComment,
              ),
      ]),
    );
  }
}
