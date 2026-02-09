import 'dart:async';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isMinTimePassed = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 1. Start the minimum display timer (e.g., 4 seconds)
    _timer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isMinTimePassed = true;
        });
        _attemptNavigation();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _attemptNavigation() {
    if (!mounted) return;

    final userProvider = context.read<UserProvider>();

    // 2. Wait until BOTH the timer is done AND the user data is loaded
    if (_isMinTimePassed && !userProvider.isLoading) {
      if (userProvider.isLoggedIn) {
        context.go('/home');
      } else {
        context.go('/start');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. Watch the provider to trigger rebuilds/checks when loading completes
    final userProvider = context.watch<UserProvider>();

    // Use addPostFrameCallback to safely trigger navigation after the build phase
    // if conditions are met during this build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptNavigation();
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              const Color(0xFF0F0F1E), // Deep dark accent
              Colors.black,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Animation - Elastic bounce for premium feel
                  ElasticIn(
                    duration: const Duration(seconds: 3),
                    child: Container(
                      width: 180,
                      height: 180,
                      padding: const EdgeInsets.all(
                          25), // Padding for the logo inside circle
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700)
                                .withValues(alpha: 0.5), // Beautiful Golden Glow
                            blurRadius: 50,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain, // perfect fit inside the circle
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // App Name Animation
                  FadeInUp(
                    delay: const Duration(milliseconds: 1200),
                    duration: const Duration(milliseconds: 1000),
                    child: Text(
                      'አቅሌስያ', // App Name
                      style: GoogleFonts.poppins(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700), // Gold
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Decoration Line
                  FadeInUp(
                    delay: const Duration(milliseconds: 1400),
                    child: Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Motto Animation
                  FadeInUp(
                    delay: const Duration(milliseconds: 1600),
                    duration: const Duration(milliseconds: 1000),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'የነገዋ ቤተ ክርስቲያን ዛሬ ትገነባለች',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.5,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Custom Loading Indicator
                  // Show this only if we are still waiting (for timer or auth)
                  if (!_isMinTimePassed || userProvider.isLoading)
                    FadeIn(
                      key: const ValueKey(
                          'loader'), // Ensure it animates correctly
                      delay: const Duration(milliseconds: 2500),
                      duration: const Duration(seconds: 1),
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFFFFD700).withValues(alpha: 0.8)),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Footer Version
            Positioned(
              bottom: 40,
              child: FadeInUp(
                delay: const Duration(seconds: 3),
                child: Text(
                  'v 1.0.0',
                  style: GoogleFonts.poppins(
                    color: Colors.white24,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
