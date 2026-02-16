import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/appdrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

// Screens
import 'package:amde_haymanot_abalat_guday/users%20screen/homepage.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/learning_screen.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/profile_screen.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/chat_screen.dart';

// Providers
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/language_provider.dart';

// Constants
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';

// #########################################################################
// SCREEN: HomeScreen (Main Container)
// #########################################################################

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final userId = userProvider.userProfile?['id']?.toString() ?? 'anonymous';

    final List<Widget> pages = [
      const UnifiedHomePage(),
      const ChatScreen(),
      const LearningScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 700) {
            // Tablet/Desktop Layout
            return _TabletLayout(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              pages: pages,
              userId: userId,
              languageProvider: languageProvider,
            );
          } else {
            // Mobile Layout
            return _MobileLayout(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              pages: pages,
              userId: userId,
              languageProvider: languageProvider,
              scaffoldKey: _scaffoldKey,
            );
          }
        },
      ),
    );
  }
}

// #########################################################################
// RESPONSIVE LAYOUTS (Restored)
// #########################################################################

class _MobileLayout extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<Widget> pages;
  final String userId;
  final LanguageProvider languageProvider;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _MobileLayout({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.pages,
    required this.userId,
    required this.languageProvider,
    required this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: scaffoldKey,
      // =========== THE FIX IS HERE ===========
      // Assign the AppDrawer to the Scaffold's drawer property.
      drawer: AppDrawer(
        selectedIndex: selectedIndex,
        onItemTapped: onItemTapped,
      ),
      // =======================================
      // AppBar removed to allow child screens to control their own headers
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: selectedIndex,
        onItemTapped: onItemTapped,
        l10n: l10n,
      ),
    );
  }
}

class _TabletLayout extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<Widget> pages;
  final String userId;
  final LanguageProvider languageProvider;

  const _TabletLayout({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.pages,
    required this.userId,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppNavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onItemTapped,
            userId: userId,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}

// #########################################################################
// WIDGET 2: ModernAppBar (Restored and Fixed)
// #########################################################################

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onProfileTap;
  final Locale currentLocale;
  final LanguageProvider languageProvider;
  final bool showBackButton;

  const ModernAppBar({
    super.key,
    required this.title,
    required this.onProfileTap,
    required this.currentLocale,
    required this.languageProvider,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Iconsax.arrow_left,
                  color: Theme.of(context).appBarTheme.foregroundColor),
              onPressed: () => Navigator.of(context).pop(),
            )
          : Builder(
              builder: (context) => IconButton(
                icon: Icon(Iconsax.menu,
                    color: Theme.of(context).appBarTheme.foregroundColor),
                onPressed: () => Scaffold.of(context).openDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
      title: Text(
        title,
        style: currentLocale.languageCode == 'am'
            ? GoogleFonts.notoSansEthiopic(
                color: Theme.of(context).appBarTheme.foregroundColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              )
            : GoogleFonts.roboto(
                color: Theme.of(context).appBarTheme.foregroundColor,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
      ),
      actions: [
        IconButton(
          icon: Icon(
              context.watch<ThemeProvider>().isDarkMode(context)
                  ? Iconsax.sun_1
                  : Iconsax.moon,
              color: Theme.of(context).appBarTheme.foregroundColor),
          tooltip: AppLocalizations.of(context)!.settingsTheme,
          onPressed: () => context.read<ThemeProvider>().toggleTheme(),
        ),
        IconButton(
          icon: Icon(Icons.language,
              color: Theme.of(context).appBarTheme.foregroundColor),
          tooltip: AppLocalizations.of(context)!.settingsLanguageToggleTooltip,
          onPressed: () {
            languageProvider.toggleLocale();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// #########################################################################
// WIDGET 3: AppBottomNavBar (Restored and Fixed)
// #########################################################################

// --- Constants ---
const Color premiumDark = Color(0xFF0F0F1E);
const Color premiumGold = Color(0xFFFFD700);

class AppBottomNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final AppLocalizations l10n;

  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.l10n,
  });

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late AnimationController _rippleController;
  late Animation<double> _morphAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _morphAnimation = CurvedAnimation(
      parent: _morphController,
      curve: Curves.elasticOut,
    );
    _previousIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(AppBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      _morphController.forward(from: 0);
      _rippleController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode(context);
    final bgColor = isDark ? const Color(0xFF0F0F1E) : Colors.white;
    final selectedBg =
        isDark ? const Color(0xFFFFD700) : const Color(0xFF1E3A8A);
    final selectedText = isDark ? const Color(0xFF0F0F1E) : Colors.white;
    final unselectedIcon = isDark ? Colors.white54 : const Color(0xFF64748B);

    return AnimatedBuilder(
      animation: _morphAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          height: 75,
          child: Stack(
            children: [
              // Morphing island background
              Positioned.fill(
                child: CustomPaint(
                  painter: MorphingIslandPainter(
                    selectedIndex: widget.selectedIndex,
                    previousIndex: _previousIndex,
                    progress: _morphAnimation.value,
                    isDark: isDark,
                    primaryColor: selectedBg,
                  ),
                ),
              ),
              // Glassmorphism overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            bgColor.withValues(alpha: 0.7),
                            bgColor.withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Navigation items
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _FloatingNavItem(
                      icon: Iconsax.home_2,
                      activeIcon: Iconsax.home_25,
                      label: widget.l10n.homePageTitle,
                      isSelected: widget.selectedIndex == 0,
                      onTap: () => widget.onItemTapped(0),
                      selectedBg: selectedBg,
                      selectedText: selectedText,
                      unselectedIcon: unselectedIcon,
                      animationProgress:
                          widget.selectedIndex == 0 ? _morphAnimation.value : 0,
                    ),
                    _FloatingNavItem(
                      icon: Iconsax.messages_1,
                      activeIcon: Iconsax.messages_15,
                      label: widget.l10n.chatPageTitle,
                      isSelected: widget.selectedIndex == 1,
                      onTap: () => widget.onItemTapped(1),
                      selectedBg: selectedBg,
                      selectedText: selectedText,
                      unselectedIcon: unselectedIcon,
                      animationProgress:
                          widget.selectedIndex == 1 ? _morphAnimation.value : 0,
                    ),
                    _FloatingNavItem(
                      icon: Iconsax.teacher,
                      activeIcon: Iconsax.teacher5,
                      label: widget.l10n.learningPageTitle,
                      isSelected: widget.selectedIndex == 2,
                      onTap: () => widget.onItemTapped(2),
                      selectedBg: selectedBg,
                      selectedText: selectedText,
                      unselectedIcon: unselectedIcon,
                      animationProgress:
                          widget.selectedIndex == 2 ? _morphAnimation.value : 0,
                    ),
                    _FloatingNavItem(
                      icon: Iconsax.user,
                      activeIcon: Iconsax.user5,
                      label: widget.l10n.profilePageTitle,
                      isSelected: widget.selectedIndex == 3,
                      onTap: () => widget.onItemTapped(3),
                      selectedBg: selectedBg,
                      selectedText: selectedText,
                      unselectedIcon: unselectedIcon,
                      animationProgress:
                          widget.selectedIndex == 3 ? _morphAnimation.value : 0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedBg;
  final Color selectedText;
  final Color unselectedIcon;
  final double animationProgress;

  const _FloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.selectedBg,
    required this.selectedText,
    required this.unselectedIcon,
    required this.animationProgress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(0,
                isSelected ? -Interpolation.lerp(0, 4, animationProgress) : 0),
            child: Transform.scale(
              scale: isSelected
                  ? Interpolation.lerp(1.0, 1.2, animationProgress)
                  : 1.0,
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected
                    ? Color.lerp(unselectedIcon, selectedBg, animationProgress)
                    : unselectedIcon,
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedOpacity(
            opacity: isSelected ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              label,
              style: l10n.localeName == 'am'
                  ? GoogleFonts.notoSansEthiopic(
                      color: isDark(context) ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    )
                  : GoogleFonts.poppins(
                      color: isDark(context) ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}

/// Helper for simple interpolation
class Interpolation {
  static double lerp(double start, double end, double t) =>
      start + (end - start) * t;
}

class MorphingIslandPainter extends CustomPainter {
  final int selectedIndex;
  final int previousIndex;
  final double progress;
  final bool isDark;
  final Color primaryColor;

  MorphingIslandPainter({
    required this.selectedIndex,
    required this.previousIndex,
    required this.progress,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate item width
    final itemWidth = size.width / 4;

    // Calculate positions
    final double prevX = (previousIndex * itemWidth) + (itemWidth / 2);
    final double targetX = (selectedIndex * itemWidth) + (itemWidth / 2);

    // Interpolate current X
    final double currentX = prevX + (targetX - prevX) * progress;

    // Draw the active indicator blob
    final blobPaint = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.8 : 1.0)
      ..maskFilter =
          MaskFilter.blur(BlurStyle.normal, 10 * (1 - progress).abs());

    // Morphing factor (stretching while moving)
    final distance = (targetX - prevX).abs();
    final stretch =
        (progress < 0.5 ? progress : 1 - progress) * (distance / 40);

    final Rect blobRect = Rect.fromCenter(
      center: Offset(currentX, size.height / 2),
      width: 50 + stretch * 20,
      height: 45 - stretch * 5,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(blobRect, Radius.circular(22)),
      blobPaint,
    );

    // Draw subtle glow
    final glowPaint = Paint()
      ..color = primaryColor.withValues(alpha: isDark ? 0.3 : 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(
      Offset(currentX, size.height / 2),
      25 + stretch * 10,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant MorphingIslandPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}

// #########################################################################
// WIDGET 4: AppNavigationRail (Restored and Fixed)
// #########################################################################

class AppNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final String userId;

  const AppNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale =
        l10n.localeName == 'am' ? const Locale('am') : const Locale('en');

    return Material(
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedIconTheme:
            IconThemeData(color: Theme.of(context).primaryColor, size: 28),
        unselectedIconTheme:
            IconThemeData(color: Theme.of(context).disabledColor, size: 26),
        labelType: NavigationRailLabelType.all,
        useIndicator: true,
        indicatorColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        leading: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Hero(
            tag: 'app_logo',
            child: Material(
              color: Colors.transparent,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).primaryColor,
                child: Icon(Iconsax.home_2,
                    color: Theme.of(context).colorScheme.onPrimary, size: 28),
              ),
            ),
          ),
        ),
        destinations: [
          _buildNavRailDestination(
            context: context,
            icon: Iconsax.home_2,
            label: l10n.homePageTitle,
            isSelected: selectedIndex == 0,
            locale: currentLocale,
          ),
          _buildNavRailDestination(
            context: context,
            icon: Iconsax.messages_1,
            label: l10n.chatPageTitle,
            isSelected: selectedIndex == 1,
            locale: currentLocale,
          ),
          _buildNavRailDestination(
            context: context,
            icon: Iconsax.book_1,
            label: l10n.learningPageTitle,
            isSelected: selectedIndex == 2,
            locale: currentLocale,
          ),
          _buildNavRailDestination(
            context: context,
            icon: Iconsax.profile_circle,
            label: l10n.profilePageTitle,
            isSelected: selectedIndex == 3,
            locale: currentLocale,
          ),
        ],
      ),
    );
  }
}

NavigationRailDestination _buildNavRailDestination({
  required IconData icon,
  required String label,
  required bool isSelected,
  required Locale? locale,
  required BuildContext context,
}) {
  return NavigationRailDestination(
    icon: Icon(icon, size: 24, color: Theme.of(context).disabledColor),
    selectedIcon: Icon(icon, size: 26, color: Theme.of(context).primaryColor),
    label: Text(
      label,
      style: TextStyle(
        color: isSelected
            ? Theme.of(context).primaryColor
            : Theme.of(context).disabledColor,
        fontSize: 12,
        fontFamily:
            locale?.languageCode == 'am' ? 'NotoSansEthiopic' : 'Roboto',
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    ),
  );
}
