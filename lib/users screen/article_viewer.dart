import 'package:amde_haymanot_abalat_guday/services/app_theme.dart';
import 'package:amde_haymanot_abalat_guday/users screen/learning_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:iconsax/iconsax.dart';

class ArticleViewerScreen extends StatelessWidget {
  final LearningContent content;
  const ArticleViewerScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // A unique tag for the Hero animation, ensuring no conflicts.
    final String heroTag = 'articleImage-${content.imageUrl}';

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Hero(
                tag: heroTag,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: content.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                          color: AppTheme.primary.withValues(alpha: 0.1)),
                      errorWidget: (context, url, error) => const Icon(
                          Icons.image_not_supported,
                          color: AppTheme.textSecondary),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: <Color>[
                            Colors.black87,
                            Colors.transparent,
                            Colors.black45,
                          ],
                          stops: [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Text(
                        content.title,
                        style: GoogleFonts.notoSansEthiopic(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Iconsax.bookmark, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.learningBookmarked,
                          style: GoogleFonts.notoSansEthiopic()),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Iconsax.share, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primary,
                          child: Text(
                            content.author[0].toUpperCase(),
                            style: GoogleFonts.notoSansEthiopic(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                content.author,
                                style: GoogleFonts.notoSansEthiopic(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Iconsax.calendar_1,
                                      size: 14, color: AppTheme.textSecondary),
                                  const SizedBox(width: 6),
                                  Text(
                                    EthiopianDate.fromGregorian(
                                            content.publishDate)
                                        .toString(),
                                    style: GoogleFonts.notoSansEthiopic(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildInfoChip(
                          content.category.isEmpty
                              ? l10n.learningCategoryGeneral
                              : content.category,
                          AppTheme.primary),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                          _getLocalizedDifficulty(content.difficulty, l10n),
                          AppTheme.info),
                    ],
                  ),
                  const SizedBox(height: 32),
                  MarkdownBody(
                    data: content.content,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(
                      p: GoogleFonts.notoSansEthiopic(
                          fontSize: 17,
                          height: 1.7,
                          color: AppTheme.textPrimary.withValues(alpha: 0.9)),
                      h1: GoogleFonts.notoSansEthiopic(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                          color: AppTheme.primary),
                      h2: GoogleFonts.notoSansEthiopic(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                          color: AppTheme.textPrimary),
                      h3: GoogleFonts.notoSansEthiopic(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          color: AppTheme.textPrimary),
                      listBullet:
                          GoogleFonts.notoSansEthiopic(color: AppTheme.primary),
                      blockquote: GoogleFonts.notoSansEthiopic(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textSecondary),
                      blockquoteDecoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: const Border(
                              left: BorderSide(
                                  width: 5, color: AppTheme.primary))),
                      code: GoogleFonts.firaCode(
                          backgroundColor:
                              AppTheme.primary.withValues(alpha: 0.05),
                          fontSize: 14,
                          color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.notoSansEthiopic(
            color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _getLocalizedDifficulty(String difficulty, AppLocalizations l10n) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return l10n.learningDifficultyBeginner;
      case 'intermediate':
        return l10n.learningDifficultyIntermediate;
      case 'advanced':
        return l10n.learningDifficultyAdvanced;
      default:
        return difficulty;
    }
  }
}
