import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
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
                    // TODO: Implement share functionality
                    HapticFeedback.lightImpact();
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
          _buildStatItem(
            icon: Iconsax.message,
            count: widget.post.commentCount,
            label: 'አስተያየቶች',
            color: primaryColor,
            textColor: textColor,
            subtleText: subtleText,
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
                  // TODO: Open comments sheet
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
