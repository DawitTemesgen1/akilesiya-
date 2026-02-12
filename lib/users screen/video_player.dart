import 'package:amde_haymanot_abalat_guday/services/app_theme.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/learning_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// --- Amharic Localization Strings for Video Player ---
abstract class AmharicStringsVideoPlayer {
  static const String by = 'በ';
  static const String description = 'መግለጫ';
  static const String watchOnYoutube = 'በዩቲዩብ ይመልከቱ';
  static const String desktopNote =
      'በዴስክቶፕ ላይ ለተሻለ ተሞክሮ ቪዲዮውን በዩቲዩብ እንዲመለከቱ እንመክራለን።';
}

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
    if (_useFallback) {
      return _buildFallbackUI();
    }

    // Standard Embedded Player for Mobile/Web
    return YoutubePlayerScaffold(
      controller: _controller!,
      aspectRatio: 16 / 9,
      builder: (context, player) => Scaffold(
        appBar: _buildAppBar(),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            player,
            _buildContentDetails(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primary,
      foregroundColor: AppTheme.textLight,
      title: Text(
        widget.content.title,
        style: GoogleFonts.notoSansEthiopic(
            fontSize: 16, color: AppTheme.textLight),
      ),
      centerTitle: true,
    );
  }

  Widget _buildFallbackUI() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Thumbnail Preview with Play Button Overlay
          Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.content.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.play_circle_fill,
                    size: 80, color: AppTheme.accent),
                onPressed: _launchYoutubeUrl,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _launchYoutubeUrl,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text(AmharicStringsVideoPlayer.watchOnYoutube),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    backgroundColor: AppTheme.accent,
                    foregroundColor: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AmharicStringsVideoPlayer.desktopNote,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildContentDetails(),
        ],
      ),
    );
  }

  Widget _buildContentDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.content.title,
            style: AppTheme.headline1,
          ),
          const SizedBox(height: 8),
          Text(
            "${AmharicStringsVideoPlayer.by} ${widget.content.author} • ${DateFormat.yMMMd().format(widget.content.publishDate)}",
            style: GoogleFonts.notoSansEthiopic()
                .copyWith(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 4),
          Chip(
            label: Text(widget.content.category,
                style: GoogleFonts.notoSansEthiopic()),
            labelStyle: AppTheme.chipText,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          const Divider(height: 32),
          Text(
            AmharicStringsVideoPlayer.description,
            style: GoogleFonts.notoSansEthiopic().copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            widget.content.description,
            style: GoogleFonts.notoSansEthiopic()
                .copyWith(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
