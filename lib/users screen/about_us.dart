import 'package:amde_haymanot_abalat_guday/users%20screen/social_media_url.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/app_theme.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _Responsive(
      mobile: _AboutUsMobile(),
      tablet: _AboutUsTablet(),
    );
  }
}

class _AboutUsMobile extends StatelessWidget {
  const _AboutUsMobile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Provider.of<ThemeProvider>(context).getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, 300),
          _buildSliverBody(context, 2),
        ],
      ),
    );
  }
}

class _AboutUsTablet extends StatelessWidget {
  const _AboutUsTablet();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Provider.of<ThemeProvider>(context).getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, 400),
          _buildSliverBody(context, 4),
        ],
      ),
    );
  }
}

class _Responsive extends StatelessWidget {
  const _Responsive({
    required this.mobile,
    required this.tablet,
  });

  final Widget mobile;
  final Widget tablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return mobile;
        } else {
          return tablet;
        }
      },
    );
  }
}

SliverAppBar _buildSliverAppBar(BuildContext context, double expandedHeight) {
  return SliverAppBar(
    expandedHeight: expandedHeight,
    pinned: true,
    backgroundColor: AppTheme.primary,
    elevation: 0,
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 1.5),
                    ),
                    child: Hero(
                      tag: 'app_logo',
                      child: Icon(
                        Iconsax.activity, // Using a more "dynamic" icon
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!
                        .appName, // Updated to Akilesiya
                    style: GoogleFonts.notoSansEthiopic(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.aboutUsAppSubTitle,
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

SliverToBoxAdapter _buildSliverBody(
  BuildContext context,
  int crossAxisCount,
) {
  return SliverToBoxAdapter(
    child: Container(
      decoration: BoxDecoration(
        color: Provider.of<ThemeProvider>(context).getBackgroundColor(context),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildVisionSection(context),
          const SizedBox(height: 60),
          _buildStorySection(context),
          const SizedBox(height: 60),
          _buildValuesSection(context, crossAxisCount),
          const SizedBox(height: 60),
          _buildDeveloperSection(context),
          const SizedBox(height: 60),
          _buildConnectSection(context),
          const SizedBox(height: 40),
        ],
      ),
    ),
  );
}

Widget _buildVisionSection(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.2)),
          ),
          child: Text(
            AppLocalizations.of(context)!.aboutUsVisionTitle,
            style: GoogleFonts.notoSansEthiopic(
              color: const Color(0xFF10B981),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)!.aboutUsVisionSubTitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context)!.aboutUsVisionDescription,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 16,
            height: 1.8,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    ),
  );
}

Widget _buildStorySection(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 24),
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: Colors.white, // Using a clean white card
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.05)),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primary.withValues(alpha: 0.08),
          blurRadius: 30,
          offset: const Offset(0, 15),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Iconsax.book, color: Color(0xFFF59E0B), size: 28),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.aboutUsStoryTitle,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context)!.aboutUsStoryDescription,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 16,
            height: 1.8,
            color: AppTheme.textPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    ),
  );
}

Widget _buildValuesSection(BuildContext context, int crossAxisCount) {
  final values = [
    {
      'icon': Iconsax.heart,
      'title': AppLocalizations.of(context)!.aboutUsValueFaithTitle,
      'description': AppLocalizations.of(context)!.aboutUsValueFaithDesc,
      'color': const Color(0xFFEF4444),
    },
    {
      'icon': Iconsax.people,
      'title': AppLocalizations.of(context)!.aboutUsValueLoveTitle,
      'description': AppLocalizations.of(context)!.aboutUsValueLoveDesc,
      'color': const Color(0xFF10B981),
    },
    {
      'icon': Iconsax.book_1,
      'title': AppLocalizations.of(context)!.aboutUsValueEducationTitle,
      'description': AppLocalizations.of(context)!.aboutUsValueEducationDesc,
      'color': const Color(0xFFF59E0B),
    },
    {
      'icon': Iconsax.gift,
      'title': AppLocalizations.of(context)!.aboutUsValueServiceTitle,
      'description': AppLocalizations.of(context)!.aboutUsValueServiceDesc,
      'color': const Color(0xFF8B5CF6),
    },
  ];

  return Column(
    children: [
      Text(
        AppLocalizations.of(context)!.aboutUsValuesTitle,
        style: GoogleFonts.notoSansEthiopic(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
      const SizedBox(height: 40),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.85,
          ),
          itemCount: values.length,
          itemBuilder: (context, index) {
            final value = values[index];
            return Container(
              decoration: BoxDecoration(
                color: (value['color'] as Color).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: (value['color'] as Color).withValues(alpha: 0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: (value['color'] as Color).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        value['icon'] as IconData,
                        color: value['color'] as Color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      value['title'] as String,
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value['description'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 13,
                        height: 1.4,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildDeveloperSection(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 24),
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      children: [
        const Icon(Iconsax.code, size: 40, color: Colors.white),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.aboutUsBuiltByTitle,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.aboutUsBuiltByDesc,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.8),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            AppLocalizations.of(context)!.aboutUsDigitalName,
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildConnectSection(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      children: [
        Text(
          AppLocalizations.of(context)!.aboutUsJoinCommunity,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.aboutUsStayConnected,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        const SocialMediaUrl(),
        const SizedBox(height: 32),
        Text(
          AppLocalizations.of(context)!.aboutUsLocation,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSansEthiopic(
            fontSize: 14,
            color: AppTheme.textSecondary.withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ),
  );
}
