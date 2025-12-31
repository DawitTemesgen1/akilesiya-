import 'dart:async';
import 'dart:ui'; // Required for ImageFilter

import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:amde_haymanot_abalat_guday/role%20based/private.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/otp_verification_screen.dart';
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
import 'package:amde_haymanot_abalat_guday/users%20screen/forgot_password_screen.dart';

import 'package:amde_haymanot_abalat_guday/users%20screen/start_screen.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/splash_screen.dart';

// Your existing colors, now primarily for the Light Theme
const Color primaryColor = Color.fromARGB(255, 1, 37, 100);
const Color accentColor = Color(0xFFFFD700);

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");

    final apiBaseUrl = _getApiBaseUrl();
    // DEBUG LOG
    print('----------------------------------------------------');
    print('🔌 API URL Configured: $apiBaseUrl');
    print('----------------------------------------------------');

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
  // ---------------------------------------------------------------------------
  // 🔗 API CONNECTION SETTINGS
  // ---------------------------------------------------------------------------
  // Currently pointing to: PRODUCTION SERVER
  return 'https://akilesiya.amdehaymanot.com/api';

  // --- Local Development Fallbacks (Uncomment to use Localhost) ---
  /*
  if (kIsWeb) {
    return 'http://localhost:3000/api';
  }

  // 10.0.2.2 is required for Android Emulator to access host machine
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000/api';
  }
  
  return 'http://localhost:3000/api';
  */
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Initialize the router once.
    // We access the UserProvider here to set up refreshListenable and redirects
    final userProvider = context.read<UserProvider>();

    _router = GoRouter(
      navigatorKey: navigatorKey,
      refreshListenable: userProvider,
      initialLocation: '/splash',
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) =>
              const AuthGate(),
        ),
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/start',
          builder: (context, state) => const StartScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Login(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/otp-verify',
          builder: (context, state) {
            // Handle both String (forgot password) and Map (signup with password)
            final extra = state.extra;
            if (extra is Map<String, dynamic>) {
              // From signup with password
              return OtpVerificationScreen(
                email: extra['email'] as String,
                password: extra['password'] as String?,
              );
            } else if (extra is String) {
              // From forgot password (legacy)
              return OtpVerificationScreen(email: extra);
            } else {
              // Fallback - shouldn't happen
              return const OtpVerificationScreen(email: '');
            }
          },
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => HomeScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/admin/development-hub',
          builder: (context, state) => const MemberDevelopmentHubScreen(),
        ),
        GoRoute(
          path: '/admin/member-development/notes',
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
          path: '/system-admin',
          builder: (context, state) => const SystemAdminDashboard(),
        ),
        GoRoute(
          path: '/system-admin/user-management',
          builder: (context, state) => const UserManagementScreen(),
        ),
        GoRoute(
          path: '/system-admin/user-details/:userId',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return UserDetailsScreen(userId: userId);
          },
        ),
        GoRoute(
          path: '/system-admin/analytics',
          builder: (context, state) => const PlatformAnalyticsScreen(),
        ),
        GoRoute(
          path: '/system-admin/settings',
          builder: (context, state) => const SystemSettingsScreen(),
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final isLoggedIn = userProvider.isLoggedIn;
        final isLoading = userProvider.isLoading;

        if (isLoading) return null;
        if (state.uri.path == '/splash') return null;

        final isAuthPath = state.uri.path == '/login' ||
            state.uri.path == '/signup' ||
            state.uri.path == '/start' ||
            state.uri.path == '/otp-verify' ||
            state.uri.path == '/forgot-password';

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
  }

  @override
  Widget build(BuildContext context) {
    // Only these will trigger rebuilds, but Router won't reset
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      themeMode: themeProvider.themeMode,
      theme: _buildThemeData(false),
      darkTheme: _buildThemeData(true),
      routerConfig: _router,
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
    );
  }

  ThemeData _buildThemeData(bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final primaryColor =
        isDark ? ThemeProvider.darkPrimary : ThemeProvider.lightPrimary;
    final accentColor =
        isDark ? ThemeProvider.darkPrimary : ThemeProvider.lightAccent;

    final scaffoldBg =
        isDark ? ThemeProvider.darkBackground : ThemeProvider.lightBackground;
    final surfaceColor =
        isDark ? ThemeProvider.darkSurface : ThemeProvider.lightSurface;
    final textColor =
        isDark ? ThemeProvider.darkOnSurface : ThemeProvider.lightOnSurface;
    final secondaryTextColor =
        isDark ? ThemeProvider.darkSubtle : ThemeProvider.lightSubtle;
    final inputFillColor =
        isDark ? const Color(0xFF232936) : const Color(0xFFF1F3F5);
    final appBarColor = isDark ? ThemeProvider.darkBackground : primaryColor;
    final appBarTextColor = isDark ? accentColor : Colors.white;

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
