import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/main.dart'; // Provides colors

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // The SplashPage no longer needs any redirect logic.
  // The main GoRouter redirect handles everything.

  @override
  Widget build(BuildContext context) {
    // It's possible for this widget to build before localizations are fully ready.
    // A null check provides a safe fallback.
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/am-11.png', width: 150, height: 150),
            const SizedBox(height: 24),
            if (l10n != null)
              Text(l10n.appTitle,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white)),
            const SizedBox(height: 40),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              ),
            ),
            const SizedBox(height: 16),
            if (l10n != null)
              Text(l10n.splashLoading,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
