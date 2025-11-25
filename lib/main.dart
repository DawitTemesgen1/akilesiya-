import 'dart:async';
import 'dart:ui'; // Required for ImageFilter

import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:amde_haymanot_abalat_guday/role%20based/private.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:amde_haymanot_abalat_guday/admin%20only/post_management.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/student_list.dart';
import 'package:amde_haymanot_abalat_guday/app_restart_wrapper.dart';
import 'package:amde_haymanot_abalat_guday/auth_gate.dart';
import 'package:amde_haymanot_abalat_guday/providers/activity_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/language_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/profile_config_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/sync_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/tenant_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/role%20based/admin_notes.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/dashboard.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/platform_analytics.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/system_settings.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/user_detail.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/content_manager.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/home_screen.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/login.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/settings_screen.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/signup.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/start_screen.dart';

// Your existing colors, now primarily for the Light Theme
const Color primaryColor = Color.fromARGB(255, 1, 37, 100);
const Color accentColor = Color(0xFFFFD700);

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");

    final apiBaseUrl = _getApiBaseUrl();
    ApiService.initialize(baseUrl: apiBaseUrl);

    await initializeDateFormatting('am', null);

    print('✅ Application Initialized Successfully');
  } catch (e, stackTrace) {
    print('💥 App initialization failed: $e \n$stackTrace');
    runApp(MaterialApp(home: _InitializationErrorScreen(error: e)));
    return;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => TenantProvider()),
        ChangeNotifierProvider(create: (context) => ActivityProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => SyncProvider()),
        ChangeNotifierProvider(create: (context) => ContentManager()),
        ChangeNotifierProvider(create: (context) => ProfileConfigProvider()),
      ],
      child: const AppRestartWrapper(
        child: MyApp(),
      ),
    ),
  );
}

String _getApiBaseUrl() {
  return 'http://akilesiya.amdehaymanot.com/api';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final tenantProvider = context.watch<TenantProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final router = GoRouter(
      navigatorKey: navigatorKey,
      refreshListenable: userProvider,
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const AuthGate(),
          routes: [
            GoRoute(
              path: 'start',
              builder: (context, state) => const StartScreen(),
            ),
            GoRoute(
              path: 'login',
              builder: (context, state) => const Login(),
            ),
            GoRoute(
              path: 'signup',
              builder: (context, state) => const SignUpScreen(),
            ),
            GoRoute(
              path: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: 'admin/development-hub',
              builder: (context, state) => const MemberDevelopmentHubScreen(),
            ),
            GoRoute(
              path: 'admin/member-development/notes',
              builder: (context, state) {
                final user = state.extra as Map<String, dynamic>;
                return AdminMemberDevelopmentScreen(user: user);
              },
            ),
            GoRoute(
              path: '/admin/posts',
              builder: (context, state) => const AdminPostManagementScreen(),
            ),
            GoRoute(
              path: 'system-admin',
              builder: (context, state) => const SystemAdminDashboard(),
            ),
            GoRoute(
              path: 'system-admin/user-management',
              builder: (context, state) => const UserManagementScreen(),
            ),
            GoRoute(
              path: 'system-admin/user-details/:userId',
              builder: (context, state) {
                final userId = state.pathParameters['userId']!;
                return UserDetailsScreen(userId: userId);
              },
            ),
            GoRoute(
              path: 'system-admin/analytics',
              builder: (context, state) => const PlatformAnalyticsScreen(),
            ),
            GoRoute(
              path: 'system-admin/settings',
              builder: (context, state) => const SystemSettingsScreen(),
            ),
          ],
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final isLoggedIn = userProvider.isLoggedIn;
        final isLoading = userProvider.isLoading;

        if (isLoading) return null;

        final isAuthPath = state.uri.path == '/login' ||
            state.uri.path == '/signup' ||
            state.uri.path == '/start';

        if (isLoggedIn && isAuthPath) return '/home';
        if (!isLoggedIn && !isAuthPath && state.uri.path != '/')
          return '/login';

        return null;
      },
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text("Page Not Found")),
        body: Center(child: Text('Error: ${state.error}')),
      ),
      debugLogDiagnostics: kDebugMode,
    );

    final primary = tenantProvider.currentTenant?.primaryColor ?? primaryColor;
    final accent = tenantProvider.currentTenant?.accentColor ?? accentColor;

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: languageProvider.currentLocale,
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'Amde Haymanot',
      theme: _buildThemeData(primary, accent, Brightness.light),
      darkTheme: _buildThemeData(primary, accent, Brightness.dark),
      themeMode: themeProvider.themeMode,
    );
  }

  // =========== THEME REDESIGN: COMPLETE OVERHAUL OF THIS METHOD ===========
  ThemeData _buildThemeData(
      Color primaryColor, Color accentColor, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    // --- Define Color Palettes ---
    final Color scaffoldBg;
    final Color surfaceColor; // For cards, dialogs
    final Color textColor;
    final Color secondaryTextColor;
    final Color inputFillColor;
    final Color appBarColor;
    final Color appBarTextColor;

    if (isDark) {
      // --- ENHANCED "MIDNIGHT GOLD" DARK THEME ---
      scaffoldBg = const Color(0xFF0F0F1E); // Deeper dark blue-black
      surfaceColor = const Color(0xFF1E1E2E); // Elevated surface for cards
      textColor = accentColor; // GOLDEN TEXT for dark theme!
      secondaryTextColor =
          const Color(0xFFD4D4D8); // Light grey for secondary text
      inputFillColor = const Color(0xFF2A2A3E);
      appBarColor = const Color(0xFF1A1A2E);
      appBarTextColor = accentColor; // Golden app bar text
    } else {
      // --- ENHANCED LIGHT THEME WITH PROPER CONTRAST ---
      scaffoldBg = const Color(0xFFF8F9FA); // Very light grey
      surfaceColor = Colors.white; // Pure white cards
      textColor =
          const Color(0xFF1A1A2E); // Deep navy blue for excellent contrast
      secondaryTextColor = const Color(0xFF6C757D); // Medium grey
      inputFillColor = const Color(0xFFF1F3F5);
      appBarColor = primaryColor; // Your brand's main blue color
      appBarTextColor = accentColor; // Golden text on dark blue appbar
    }

    final baseTextTheme =
        isDark ? Typography.whiteHelsinki : Typography.blackHelsinki;

    return ThemeData(
        useMaterial3: true,
        brightness: brightness,
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: accentColor,
          brightness: brightness,
          background: scaffoldBg,
          surface: surfaceColor,
          onSurface: textColor,
          onPrimary: Colors.white,
          onSecondary: primaryColor,
        ),
        scaffoldBackgroundColor: scaffoldBg,
        appBarTheme: AppBarTheme(
          backgroundColor: appBarColor,
          foregroundColor: appBarTextColor,
          elevation: 0,
          scrolledUnderElevation: isDark ? 0 : 2,
          systemOverlayStyle:
              isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          titleTextStyle: GoogleFonts.poppins(
              color: appBarTextColor,
              fontSize: 20,
              fontWeight: FontWeight.w600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: primaryColor,
            minimumSize: const Size(88, 52),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: inputFillColor,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentColor, width: 2)),
          labelStyle: TextStyle(color: secondaryTextColor),
          floatingLabelStyle: TextStyle(color: accentColor),
          hintStyle: TextStyle(color: secondaryTextColor),
        ),
        textTheme: baseTextTheme
            .copyWith(
              bodyLarge: GoogleFonts.poppins(color: textColor, height: 1.5),
              bodyMedium: GoogleFonts.poppins(color: textColor, height: 1.5),
              titleLarge: GoogleFonts.poppins(
                  color: textColor, fontWeight: FontWeight.bold),
              titleMedium: GoogleFonts.poppins(
                  color: textColor, fontWeight: FontWeight.w600),
              headlineSmall: GoogleFonts.poppins(
                  color: textColor, fontWeight: FontWeight.bold),
            )
            .apply(
              bodyColor: textColor,
              displayColor: textColor,
            ),
        cardTheme: CardThemeData(
          color: surfaceColor,
          elevation: isDark ? 6 : 2,
          shadowColor: Colors.black.withOpacity(isDark ? 0.7 : 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isDark
                ? BorderSide(color: accentColor.withOpacity(0.15), width: 1)
                : BorderSide.none,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: isDark ? surfaceColor : Colors.white,
          selectedItemColor: isDark ? accentColor : primaryColor,
          unselectedItemColor: secondaryTextColor,
        ),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: isDark ? surfaceColor : Colors.white,
          selectedIconTheme:
              IconThemeData(color: isDark ? accentColor : primaryColor),
          unselectedIconTheme: IconThemeData(color: secondaryTextColor),
          selectedLabelTextStyle:
              TextStyle(color: isDark ? accentColor : primaryColor),
          unselectedLabelTextStyle: TextStyle(color: secondaryTextColor),
        ));
  }
}

class _InitializationErrorScreen extends StatelessWidget {
  final Object error;
  const _InitializationErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              const Text('App Initialization Failed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('Error: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
