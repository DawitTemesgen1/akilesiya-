import 'package:animate_do/animate_do.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/language_provider.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Using the same premium dark theme colors as splash screen
    const premiumDark = Color(0xFF0F0F1E);
    const premiumGold = Color(0xFFFFD700);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
              premiumDark,
              Colors.black,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Language Toggle
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: _buildLanguageToggle(context, premiumGold),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Main Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    ZoomIn(
                      duration: const Duration(milliseconds: 1000),
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: premiumGold.withValues(alpha: 0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ]),
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Title
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        l10n.appName, // App Name
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: premiumGold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Welcome Text
                    FadeInUp(
                      delay: const Duration(milliseconds: 500),
                      child: Text(
                        l10n.startWelcome,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    FadeInUp(
                      delay: const Duration(milliseconds: 700),
                      child: Text(
                        l10n.startDescription,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.white70,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FadeInUp(
                      delay: const Duration(milliseconds: 900),
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: premiumGold,
                          foregroundColor:
                              const Color(0xFF0F0F1E), // Dark text on gold
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 8,
                          shadowColor: premiumGold.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        child: Text(l10n.loginButton),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeInUp(
                      delay: const Duration(milliseconds: 1100),
                      child: OutlinedButton(
                        onPressed: () {
                          context.push('/signup');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: premiumGold,
                          side: const BorderSide(color: premiumGold, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        child: Text(l10n.signupButton),
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

  Widget _buildLanguageToggle(BuildContext context, Color activeColor) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isAmharic = languageProvider.currentLocale.languageCode == 'am';
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white24),
          ),
          child: InkWell(
            onTap: () {
              languageProvider.toggleLocale();
            },
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language, size: 20, color: activeColor),
                  const SizedBox(width: 8),
                  Text(
                    isAmharic ? 'English' : 'አማርኛ',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
