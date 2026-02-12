import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:amde_haymanot_abalat_guday/services/public_feed_service.dart';
import 'package:amde_haymanot_abalat_guday/services/private_feed_service.dart';
import 'package:amde_haymanot_abalat_guday/models/comment.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';

import 'package:amde_haymanot_abalat_guday/users%20screen/homepage.dart';

class PostDetailPage extends StatefulWidget {
  final UnifiedPost post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  bool _isLiked = false;
  int _likes = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _isLiked = widget.post.isLiked;
    _likes = widget.post.likes;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLiked = !_isLiked;
      _likes += _isLiked ? 1 : -1;
    });
    _animationController.forward().then((_) => _animationController.reverse());
  }

  void _showCommentsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentsSheet(
        post: widget.post,
        onCommentCountChanged: (count) {
          // You might want to update local state here if you display comment count elsewhere
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode(context);
    final bgColor = themeProvider.getBackgroundColor(context);
    final surfaceColor = themeProvider.getSurfaceColor(context);
    final textColor = themeProvider.getOnSurfaceColor(context);
    final subtleText = isDark ? Colors.white54 : const Color(0xFF64748B);
    final primaryColor = themeProvider.getPrimaryColor(context);
    final premiumGold = const Color(0xFFFFD700);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Image Header
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: bgColor,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: surfaceColor.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Iconsax.arrow_left, color: textColor),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: surfaceColor.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Iconsax.share, color: textColor),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Share.share(
                      'Check out this post: ${widget.post.title}\n\n${widget.post.description}\n\nShared via Akilesiya App',
                      subject: widget.post.title,
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero Image
                  if (widget.post.imageUrl != null)
                    Hero(
                      tag: 'post_image_${widget.post.id}',
                      child: CachedNetworkImage(
                        imageUrl: widget.post.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: surfaceColor,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: surfaceColor,
                          child: Icon(
                            Iconsax.gallery,
                            size: 64,
                            color: subtleText,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            primaryColor.withValues(alpha: 0.3),
                            bgColor,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _getPostTypeIcon(widget.post.type),
                          size: 80,
                          color: primaryColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  // Gradient Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            bgColor.withValues(alpha: 0.8),
                            bgColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Type Badge & Private Indicator
                  Row(
                    children: [
                      _buildPostTypeBadge(isDark, primaryColor, premiumGold),
                      if (widget.post.isPrivate) ...[
                        const SizedBox(width: 8),
                        _buildPrivateBadge(isDark, premiumGold, subtleText),
                      ],
                      if (widget.post.isImportant) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.warning_2,
                                size: 14,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'አስፈላጊ',
                                style: GoogleFonts.notoSansEthiopic(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    widget.post.title,
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Author Info
                  Row(
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
                          radius: 24,
                          backgroundColor: surfaceColor,
                          backgroundImage: widget.post.authorAvatar != null
                              ? CachedNetworkImageProvider(
                                  widget.post.authorAvatar!)
                              : null,
                          child: widget.post.authorAvatar == null
                              ? Icon(Iconsax.user, color: subtleText)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.author,
                              style: GoogleFonts.notoSansEthiopic(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('MMM dd, yyyy • h:mm a')
                                  .format(widget.post.date),
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: subtleText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Event Details (if applicable)
                  if (widget.post.type == PostType.event &&
                      widget.post.eventDate != null) ...[
                    _buildEventDetails(
                      isDark,
                      surfaceColor,
                      primaryColor,
                      textColor,
                      subtleText,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Description
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: isDark
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.05))
                          : null,
                    ),
                    child: Text(
                      widget.post.description,
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 16,
                        height: 1.8,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Interaction Stats
                  _buildInteractionStats(
                    isDark,
                    surfaceColor,
                    textColor,
                    subtleText,
                    primaryColor,
                    premiumGold,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Action Buttons
      floatingActionButton: _buildFloatingActions(
        isDark,
        surfaceColor,
        textColor,
        primaryColor,
        premiumGold,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildPostTypeBadge(bool isDark, Color primaryColor, Color gold) {
    final typeData = _getPostTypeData(widget.post.type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: typeData['color'].withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: typeData['color'].withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            typeData['icon'],
            size: 14,
            color: typeData['color'],
          ),
          const SizedBox(width: 4),
          Text(
            typeData['label'],
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: typeData['color'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivateBadge(bool isDark, Color gold, Color subtleText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.lock,
            size: 14,
            color: gold,
          ),
          const SizedBox(width: 4),
          Text(
            widget.post.tenantName ?? 'የእኔ ቤተክርስቲያን',
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: gold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetails(
    bool isDark,
    Color surfaceColor,
    Color primaryColor,
    Color textColor,
    Color subtleText,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.1),
            primaryColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Iconsax.calendar_1,
              size: 32,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'የዝግጅት ቀን',
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 13,
                    color: subtleText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM dd, yyyy')
                      .format(widget.post.eventDate!),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                if (widget.post.location.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Iconsax.location,
                        size: 14,
                        color: subtleText,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.post.location,
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 14,
                            color: subtleText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionStats(
    bool isDark,
    Color surfaceColor,
    Color textColor,
    Color subtleText,
    Color primaryColor,
    Color gold,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.05))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Iconsax.heart5,
            count: _likes,
            label: 'ወደዱ',
            color: Colors.red,
            textColor: textColor,
            subtleText: subtleText,
          ),
          Container(
            width: 1,
            height: 40,
            color: subtleText.withValues(alpha: 0.2),
          ),
          Expanded(
            child: InkWell(
              onTap: _showCommentsSheet,
              child: Column(
                children: [
                  Icon(
                    Iconsax.message,
                    color: const Color(0xFFFFD700), // Changed color to gold
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.post.commentCount}', // Use widget.post.commentCount
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'አስተያየቶች', // Changed label to plural
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 14,
                      color: subtleText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
    required Color textColor,
    required Color subtleText,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 13,
            color: subtleText,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActions(
    bool isDark,
    Color surfaceColor,
    Color textColor,
    Color primaryColor,
    Color gold,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: surfaceColor.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark
              ? gold.withValues(alpha: 0.2)
              : primaryColor.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.1),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Like Button
          Expanded(
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOut,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleLike,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _isLiked
                          ? Colors.red.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isLiked ? Iconsax.heart5 : Iconsax.heart,
                          color: _isLiked ? Colors.red : textColor,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isLiked ? 'ወድጃለሁ' : 'አውደው',
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isLiked ? Colors.red : textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Comment Button
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showCommentsSheet(); // Wired up to _showCommentsSheet
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.message_text,
                        color: primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'አስተያየት',
                        style: GoogleFonts.notoSansEthiopic(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
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
    );
  }

  IconData _getPostTypeIcon(PostType type) {
    switch (type) {
      case PostType.event:
        return Iconsax.calendar_1;
      case PostType.announcement:
        return Iconsax.notification;
      case PostType.prayer:
        return Iconsax.heart;
      case PostType.news:
        return Iconsax.document_text;
    }
  }

  Map<String, dynamic> _getPostTypeData(PostType type) {
    switch (type) {
      case PostType.event:
        return {
          'icon': Iconsax.calendar_1,
          'label': 'ዝግጅት',
          'color': const Color(0xFF3B82F6),
        };
      case PostType.announcement:
        return {
          'icon': Iconsax.notification,
          'label': 'ማስታወቂያ',
          'color': const Color(0xFFF59E0B),
        };
      case PostType.prayer:
        return {
          'icon': Iconsax.heart,
          'label': 'ጸሎት',
          'color': const Color(0xFFEC4899),
        };
      case PostType.news:
        return {
          'icon': Iconsax.document_text,
          'label': 'ዜና',
          'color': const Color(0xFF10B981),
        };
    }
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
    final result = widget.post.isPrivate
        ? await PrivateFeedService.getPostComments(widget.post.id)
        : await PublicFeedService.getPostComments(widget.post.id);

    if (mounted) {
      if (result['success']) {
        setState(() {
          _comments =
              (result['data'] as List).map((c) => Comment.fromJson(c)).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty || _isPosting) return;
    setState(() => _isPosting = true);

    Map<String, dynamic> result;
    final text = _commentController.text.trim();

    if (_editingComment != null) {
      result = widget.post.isPrivate
          ? await PrivateFeedService.updatePostComment(
              _editingComment!.id, text)
          : await PublicFeedService.updatePostComment(
              _editingComment!.id, text);
    } else {
      final int? parentId = _replyingTo?.parentId ?? _replyingTo?.id;
      result = widget.post.isPrivate
          ? await PrivateFeedService.createPostComment(widget.post.id, text,
              parentId: parentId)
          : await PublicFeedService.createPostComment(widget.post.id, text,
              parentId: parentId);
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
                text: text,
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
          content: Text(result['message'] ?? 'Failed to post comment'),
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
        backgroundColor: const Color(0xFF1E1E2E), // Premium Dark
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
      final result = widget.post.isPrivate
          ? await PrivateFeedService.deletePostComment(comment.id)
          : await PublicFeedService.deletePostComment(comment.id);

      if (mounted) {
        if (result['success']) {
          setState(() {
            _comments.removeWhere((c) => c.id == comment.id);
          });
          widget.onCommentCountChanged(_comments.length);
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
                    Text("Comments",
                        style: GoogleFonts.notoSansEthiopic(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700), // Premium Gold
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${_comments.length}",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F0F1E), // Premium Dark
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white70))
                  ],
                ),
              ])),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFFFD700))) // Premium Gold
                : _comments.isEmpty
                    ? const Center(
                        child: Text("No comments yet. Be the first!",
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
                                child: const Text("View more comments",
                                    style: TextStyle(
                                        color:
                                            Color(0xFFFFD700))), // Premium Gold
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
                                      "View all ${replies.length} replies",
                                      style: const TextStyle(
                                          color:
                                              Color(0xFFFFD700), // Premium Gold
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
                                            child: const Text("Hide replies",
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
                    color: const Color(0xFFFFD700), // Premium Gold
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _editingComment != null
                          ? "Editing comment..."
                          : "Replying to ${_replyingTo!.author}...",
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
                      hintText: "Write a comment...",
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
                backgroundColor: const Color(0xFFFFD700), // Premium Gold
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
    // For public feed, tenantId might be null/irrelevant, but logic holds.
    // If post is private, widget.post.isPrivate, we check tenant match.
    // If public, SystemAdmin can delete.
    final bool isAuthorFromMySchool = comment.authorTenantId == userTenantId;
    final bool canDelete = isOwner ||
        isSystemAdmin ||
        (widget.post.isPrivate && isSuperiorAdmin && isAuthorFromMySchool) ||
        (!widget.post.isPrivate && isSystemAdmin); // Simplified

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
                _ActionButton(
                  icon: Icons.reply,
                  label: "Reply",
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
                    label: "Edit",
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
                    label: "Delete",
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
