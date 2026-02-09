// lib/users screen/video_player_screen.dart (Refactored)

import 'package:amde_haymanot_abalat_guday/services/app_theme.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/learning_screen.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Amharic Localization Strings for Video Player ---
abstract class AmharicStringsVideoPlayer {
  static const String by = 'በ';
  static const String description = 'መግለጫ';
}

class VideoPlayerScreen extends StatefulWidget {
  final LearningContent content;
  const VideoPlayerScreen({super.key, required this.content});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId:
          widget.content.content, // The 'content' field holds the video ID
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        // Enabling hybrid composition can improve performance on some platforms (Windows/Linux/Web),
        // but it's often best left off unless explicitly required for a target platform.
        useHybridComposition: false,
      ),
    );
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive: YoutubePlayerBuilder handles the aspect ratio and screen rotation gracefully.
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        // Assuming AppTheme has `accent` and `primary` defined
        progressIndicatorColor: AppTheme.accent,
        progressColors: const ProgressBarColors(
          playedColor: AppTheme.accent,
          handleColor: AppTheme.accent,
        ),
      ),
      builder: (context, player) => Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.textLight,
          // Use NotoSansEthiopic for Amharic compatibility
          title: Text(
            widget.content.title,
            style: GoogleFonts.notoSansEthiopic(
                fontSize: 16, color: AppTheme.textLight),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: EdgeInsets.zero, // Remove default list padding
          children: [
            player, // The YouTube player widget (responsive via builder)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.content.title,
                    // Assuming AppTheme.headline1 uses a responsive font size
                    style: AppTheme.headline1,
                  ),
                  const SizedBox(height: 8),

                  // Author and Date (Translated and responsive font)
                  Text(
                    "${AmharicStringsVideoPlayer.by} ${widget.content.author} • ${DateFormat.yMMMd().format(widget.content.publishDate)}",
                    // Assuming AppTheme.bodyText uses a responsive font size
                    style: GoogleFonts.notoSansEthiopic()
                        .copyWith(fontSize: 14, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 4),

                  // Category Chip (Responsive)
                  Chip(
                    label: Text(widget.content.category,
                        style: GoogleFonts.notoSansEthiopic()),
                    labelStyle: AppTheme.chipText,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  const Divider(height: 32),

                  // Description Header (Translated)
                  Text(
                    AmharicStringsVideoPlayer.description,
                    // Assuming AppTheme.headline2 uses a responsive font size
                    style: GoogleFonts.notoSansEthiopic().copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),

                  // Description Content
                  Text(
                    widget.content.description,
                    // Assuming AppTheme.bodyText uses a responsive font size
                    style: GoogleFonts.notoSansEthiopic()
                        .copyWith(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
