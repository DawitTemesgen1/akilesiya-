import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/appdrawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

// Screens
import 'package:amde_haymanot_abalat_guday/users%20screen/homepage.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/private_homepage.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/learning_screen.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/profile_screen.dart';

// Providers
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/language_provider.dart';

// Constants
import 'package:amde_haymanot_abalat_guday/constants/hero_tags.dart';
import 'package:amde_haymanot_abalat_guday/constants/app_colors.dart';

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
      const HomePage(),
      PrivateHomePage(tenantId: userProvider.tenantId ?? 'default-tenant'),
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

  const _MobileLayout({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.pages,
    required this.userId,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pageTitles = [
      l10n.homePageTitle,
      l10n.managementPageTitle,
      l10n.learningPageTitle,
      l10n.profilePageTitle,
    ];

    return Scaffold(
      // =========== THE FIX IS HERE ===========
      // Assign the AppDrawer to the Scaffold's drawer property.
      drawer: AppDrawer(
        selectedIndex: selectedIndex,
        onItemTapped: onItemTapped,
      ),
      // =======================================
      appBar: ModernAppBar(
        title: pageTitles[selectedIndex],
        onProfileTap: () {},
        currentLocale: languageProvider.currentLocale,
        languageProvider: languageProvider,
      ),
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
      backgroundColor: AppColors.surfaceColor,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Iconsax.menu, color: AppColors.primaryColor),
          onPressed: () => Scaffold.of(context).openDrawer(),
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        ),
      ),
      title: Text(
        title,
        style: currentLocale.languageCode == 'am'
            ? GoogleFonts.notoSansEthiopic(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              )
            : GoogleFonts.roboto(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.language, color: AppColors.primaryColor),
          tooltip: 'Switch Language',
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
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            icon: Iconsax.home_2,
            label: l10n.homePageTitle,
            isSelected: selectedIndex == 0,
            onTap: () => onItemTapped(0),
          ),
          _NavBarItem(
            icon: Iconsax.shield_tick,
            label: l10n.managementPageTitle,
            isSelected: selectedIndex == 1,
            onTap: () => onItemTapped(1),
          ),
          _NavBarItem(
            icon: Iconsax.teacher,
            label: l10n.learningPageTitle,
            isSelected: selectedIndex == 2,
            onTap: () => onItemTapped(2),
          ),
          _NavBarItem(
            icon: Iconsax.user,
            label: l10n.profilePageTitle,
            isSelected: selectedIndex == 3,
            onTap: () => onItemTapped(3),
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.accentColor
                  : Colors.white.withOpacity(0.7),
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
                              color: AppColors.accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            )
                          : GoogleFonts.roboto(
                              color: AppColors.accentColor,
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

    return Hero(
      tag: HeroTags.navRail(userId),
      child: Material(
        child: NavigationRail(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          backgroundColor: AppColors.surfaceColor,
          selectedIconTheme:
              const IconThemeData(color: AppColors.primaryColor, size: 28),
          unselectedIconTheme: IconThemeData(color: Colors.grey[600], size: 26),
          labelType: NavigationRailLabelType.all,
          useIndicator: true,
          indicatorColor: AppColors.primaryColor.withOpacity(0.1),
          leading: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Hero(
              tag: 'app_logo',
              child: Material(
                color: Colors.transparent,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryColor,
                  child:
                      const Icon(Iconsax.home_2, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),
          destinations: [
            _buildNavRailDestination(
              icon: Iconsax.home_2,
              label: l10n.homePageTitle,
              isSelected: selectedIndex == 0,
              locale: currentLocale,
            ),
            _buildNavRailDestination(
              icon: Iconsax.category,
              label: l10n.managementPageTitle,
              isSelected: selectedIndex == 1,
              locale: currentLocale,
            ),
            _buildNavRailDestination(
              icon: Iconsax.book_1,
              label: l10n.learningPageTitle,
              isSelected: selectedIndex == 2,
              locale: currentLocale,
            ),
            _buildNavRailDestination(
              icon: Iconsax.profile_circle,
              label: l10n.profilePageTitle,
              isSelected: selectedIndex == 3,
              locale: currentLocale,
            ),
          ],
        ),
      ),
    );
  }
}

NavigationRailDestination _buildNavRailDestination({
  required IconData icon,
  required String label,
  required bool isSelected,
  required Locale? locale,
}) {
  return NavigationRailDestination(
    icon: Icon(icon, size: 24, color: Colors.grey[600]),
    selectedIcon: Icon(icon, size: 26, color: AppColors.primaryColor),
    label: Text(
      label,
      style: TextStyle(
        color: isSelected ? AppColors.primaryColor : Colors.grey[600],
        fontSize: 12,
        fontFamily:
            locale?.languageCode == 'am' ? 'NotoSansEthiopic' : 'Roboto',
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    ),
  );
}
