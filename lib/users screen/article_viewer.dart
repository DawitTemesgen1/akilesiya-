import 'package:amde_haymanot_abalat_guday/services/app_theme.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/learning_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ArticleViewerScreen extends StatelessWidget {
  final LearningContent content;
  const ArticleViewerScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    // A unique tag for the Hero animation, ensuring no conflicts.
    final String heroTag = 'articleImage-${content.imageUrl}';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: AppTheme.textLight,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                content.title,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: Hero(
                tag: heroTag,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: content.imageUrl,
                      fit: BoxFit.cover,
                      // Recommendation: Add placeholder and error widgets
                      placeholder: (context, url) =>
                          Container(color: AppTheme.primaryLight),
                      errorWidget: (context, url, error) => const Icon(
                          Icons.image_not_supported,
                          color: AppTheme.textSecondary),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: <Color>[Colors.black54, Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "በ ${content.author} • ${DateFormat.yMMMd().format(content.publishDate)}", // "by" translated to "በ"
                    style: AppTheme.bodyText
                        .copyWith(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      Chip(
                        label: Text(content
                            .category), // Note: Dynamic data needs a translation strategy
                        labelStyle: AppTheme.chipText,
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                      ),
                      Chip(
                        label: Text(content
                            .difficulty), // Note: Dynamic data needs a translation strategy
                        labelStyle:
                            AppTheme.chipText.copyWith(color: AppTheme.info),
                        backgroundColor: AppTheme.info.withOpacity(0.1),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Markdown(
              data: content.content, // The article text in Markdown format
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                      p: AppTheme.bodyText,
                      h1: AppTheme.headline1,
                      h2: AppTheme.headline2,
                      listBullet: AppTheme.bodyText,
                      blockquoteDecoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.05),
                          border: const Border(
                              left: BorderSide(
                                  width: 4, color: AppTheme.primaryLight)))),
            ),
          ),
        ],
      ),
    );
  }
}
