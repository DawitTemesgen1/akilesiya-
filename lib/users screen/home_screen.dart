import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/appdrawer.dart';
import 'package:flutter/material.dart';
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

  const ModernAppBar({
    super.key,
    required this.title,
    required this.onProfileTap,
    required this.currentLocale,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      leading: Builder(
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

class AppBottomNavBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode(context);
    final bgColor = isDark ? const Color(0xFF0F0F1E) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFFFFD700).withValues(alpha: 0.2)
        : const Color(0xFF1E3A8A).withValues(alpha: 0.1);
    final selectedBg =
        isDark ? const Color(0xFFFFD700) : const Color(0xFF1E3A8A);
    final selectedText = isDark ? const Color(0xFF0F0F1E) : Colors.white;
    final unselectedIcon = isDark ? Colors.white54 : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavBarItem(
            icon: Iconsax.home_2,
            activeIcon: Iconsax.home_25,
            label: l10n.homePageTitle,
            isSelected: selectedIndex == 0,
            onTap: () => onItemTapped(0),
            selectedBg: selectedBg,
            selectedText: selectedText,
            unselectedIcon: unselectedIcon,
          ),
          _NavBarItem(
            icon: Iconsax.messages_1,
            activeIcon: Iconsax.messages_15,
            label: l10n.chatPageTitle,
            isSelected: selectedIndex == 1,
            onTap: () => onItemTapped(1),
            selectedBg: selectedBg,
            selectedText: selectedText,
            unselectedIcon: unselectedIcon,
          ),
          _NavBarItem(
            icon: Iconsax.teacher,
            activeIcon: Iconsax.teacher5,
            label: l10n.learningPageTitle,
            isSelected: selectedIndex == 2,
            onTap: () => onItemTapped(2),
            selectedBg: selectedBg,
            selectedText: selectedText,
            unselectedIcon: unselectedIcon,
          ),
          _NavBarItem(
            icon: Iconsax.user,
            activeIcon: Iconsax.user5,
            label: l10n.profilePageTitle,
            isSelected: selectedIndex == 3,
            onTap: () => onItemTapped(3),
            selectedBg: selectedBg,
            selectedText: selectedText,
            unselectedIcon: unselectedIcon,
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedBg;
  final Color selectedText;
  final Color unselectedIcon;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.selectedBg,
    required this.selectedText,
    required this.unselectedIcon,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutQuart,
        padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 20 : 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? selectedText : unselectedIcon,
              size: 24,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: SizedBox(width: isSelected ? 8 : 0),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: isSelected
                  ? Text(
                      label,
                      style: l10n.localeName == 'am'
                          ? GoogleFonts.notoSansEthiopic(
                              color: selectedText,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            )
                          : GoogleFonts.poppins(
                              color: selectedText,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
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
