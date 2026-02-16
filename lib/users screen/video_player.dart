import 'package:amde_haymanot_abalat_guday/services/app_theme.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/learning_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:iconsax/iconsax.dart';

class VideoPlayerScreen extends StatefulWidget {
  final LearningContent content;
  const VideoPlayerScreen({super.key, required this.content});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _controller;
  bool _useFallback = false;

  @override
  void initState() {
    super.initState();

    // On Linux desktop, webview implementation is often missing or unstable.
    // We use a fallback UI to prevent crashes and provide a better experience.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.linux) {
      _useFallback = true;
      return;
    }

    _initializeController();
  }

  void _initializeController() {
    String contentId = widget.content.content;
    String? videoId;

    try {
      if (contentId.contains('youtube.com') || contentId.contains('youtu.be')) {
        final uri = Uri.tryParse(contentId);
        if (uri != null) {
          if (uri.host == 'youtu.be') {
            videoId = uri.pathSegments.first;
          } else if (uri.host.contains('youtube.com')) {
            videoId = uri.queryParameters['v'] ?? uri.pathSegments.last;
          }
        }
      }
    } catch (_) {}

    videoId ??= contentId;

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  Future<void> _launchYoutubeUrl() async {
    String contentId = widget.content.content;
    String url = contentId;

    // If it's just an ID, construct the URL
    if (!contentId.contains('http')) {
      url = 'https://www.youtube.com/watch?v=$contentId';
    }

    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_useFallback) {
      return _buildFallbackUI(l10n);
    }

    // Standard Embedded Player for Mobile/Web
    return YoutubePlayerScaffold(
      controller: _controller!,
      aspectRatio: 16 / 9,
      builder: (context, player) => Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: _buildAppBar(),
        body: ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          children: [
            player,
            _buildContentDetails(l10n),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        widget.content.title,
        style: GoogleFonts.notoSansEthiopic(
            fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildFallbackUI(AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: _buildAppBar(),
      body: ListView(
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        children: [
          // Thumbnail Preview with Play Button Overlay
          Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Hero(
                  tag: 'videoImage-${widget.content.imageUrl}',
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(widget.content.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black87, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _launchYoutubeUrl,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_circle_fill,
                      size: 90, color: AppTheme.accent),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _launchYoutubeUrl,
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: Text(
                    l10n.videoWatchOnYoutube,
                    style: GoogleFonts.notoSansEthiopic(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 64),
                    backgroundColor: AppTheme.accent,
                    foregroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    shadowColor: AppTheme.accent.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppTheme.info.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppTheme.info, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.videoDesktopNote,
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 12,
                            color: AppTheme.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildContentDetails(l10n),
        ],
      ),
    );
  }

  Widget _buildContentDetails(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.content.title,
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primary,
                child: Text(
                  widget.content.author[0].toUpperCase(),
                  style: GoogleFonts.notoSansEthiopic(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.content.author,
                      style: GoogleFonts.notoSansEthiopic(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      EthiopianDate.fromGregorian(widget.content.publishDate)
                          .toString(),
                      style: GoogleFonts.notoSansEthiopic(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _buildCategoryChip(widget.content.category.isEmpty
                  ? l10n.learningCategoryGeneral
                  : widget.content.category),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            l10n.videoDescription,
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border:
                  Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
            ),
            child: Text(
              widget.content.description,
              style: GoogleFonts.notoSansEthiopic(
                fontSize: 16,
                height: 1.7,
                color: AppTheme.textPrimary.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(height: 40),
          _buildActionButtons(l10n),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: GoogleFonts.notoSansEthiopic(
          color: AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Iconsax.share, size: 20),
            label:
                Text(l10n.shareButton, style: GoogleFonts.notoSansEthiopic()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: AppTheme.surface,
              foregroundColor: AppTheme.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side:
                    BorderSide(color: AppTheme.primary.withValues(alpha: 0.2)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Iconsax.bookmark, size: 20),
            label: Text(l10n.saveButton, style: GoogleFonts.notoSansEthiopic()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: AppTheme.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
