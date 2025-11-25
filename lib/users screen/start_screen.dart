import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/language_provider.dart';

// Your Brand Colors for this screen
const Color primaryStartColor = Color.fromARGB(255, 1, 37, 100);
const Color accentStartColor = Color(0xFFFFD700);

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: primaryStartColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Language Switcher Button
            Positioned(
              top: 16,
              right: 16,
              child: _buildLanguageToggle(context),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: _buildContent(context, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isAmharic = languageProvider.currentLocale.languageCode == 'am';
        return OutlinedButton.icon(
          onPressed: () {
            languageProvider.toggleLocale();
          },
          icon: const Icon(Icons.translate, size: 20),
          label: Text(isAmharic ? 'English' : 'አማርኛ'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            side: const BorderSide(color: Colors.white30),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(
          'assets/images/login_person.png',
          height: 250,
          errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.church_rounded,
              size: 150,
              color: accentStartColor),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.startWelcome,
          textAlign: TextAlign.center,
          style: GoogleFonts.notoSerif(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            l10n.startDescription,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansEthiopic(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: () {
            context.push('/login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: accentStartColor,
            foregroundColor: primaryStartColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Text(l10n.loginButton),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {
            context.push('/signup');
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: accentStartColor,
            side: const BorderSide(color: accentStartColor, width: 2),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Text(l10n.signupButton),
        ),
      ],
    );
  }
}
