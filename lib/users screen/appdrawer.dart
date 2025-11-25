import 'package:amde_haymanot_abalat_guday/admin%20only/admin_edit%20user.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/create_school_screen.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/grade_attendance_audit.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/manage_family.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/student_list.dart';
import 'package:amde_haymanot_abalat_guday/app_restart_wrapper.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/tenant_provider.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/permission_management.dart';
import 'package:amde_haymanot_abalat_guday/role%20based/attendance_manager.dart';
import 'package:amde_haymanot_abalat_guday/role%20based/attendance_summary_screen.dart';
import 'package:amde_haymanot_abalat_guday/role%20based/family_view_screen.dart';
import 'package:amde_haymanot_abalat_guday/role%20based/grade_management_screen.dart';
import 'package:amde_haymanot_abalat_guday/role%20based/library_director_screen.dart';
import 'package:amde_haymanot_abalat_guday/role%20based/plan_management.dart';
import 'package:amde_haymanot_abalat_guday/role%20based/private.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/audit_logs.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/dashboard.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/platform_analytics.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/schools_list.dart';
import 'package:amde_haymanot_abalat_guday/system%20admin/system_settings.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/about_us.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/amde_platform.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/settings_screen.dart';
import 'package:amde_haymanot_abalat_guday/users%20screen/user_attendance_history.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';

// --- Amharic Localization Strings ---
abstract class AmharicStrings {
  static const String guest = 'እንግዳ';
  static const String sundaySchool = 'ሰንበት ትምህርት ቤት';
  static const String mainMenu = 'ዋና ማውጫ';
  static const String home = 'መነሻ';
  static const String management = 'አስተዳደር';
  static const String learning = 'ትምህርት';
  static const String profile = 'የግል ገጽ';
  static const String systemAdmin = 'የስርዓት አስተዳዳሪ';
  static const String systemDashboard = 'የስርዓት ዳሽቦርድ';
  static const String schoolsManagement = 'የት/ቤቶች አስተዳደር';
  static const String userManagement = 'የተጠቃሚዎች አስተዳደር';
  static const String platformAnalytics = 'የመድረክ ትንተና';
  static const String systemAudit = 'የስርዓት ኦዲት';
  static const String systemSettings = 'የስርዓት ማስተካከያዎች';
  static const String personalInfo = 'የግል መረጃ';
  static const String myAttendanceHistory = 'የእኔ ክትትል ታሪክ';
  static const String familyStatus = 'የቤተሰብ መረጃ';
  static const String adminTools = 'የአስተዳደር መሳሪያዎች';
  static const String attendanceManagement = 'የትምህርት ክትትል';
  static const String academicManagement = 'አካዳሚክ አስተዳደር';
  static const String libraryManagement = 'ቤተ-መጽሐፍት አስተዳደር';
  static const String planManagement = 'የእቅድ አስተዳደር';
  static const String memberDevelopment = 'የአባላት ክትትልና እድገት';
  static const String userList = 'የተጠቃሚዎች ዝርዝር';
  static const String superiorLeadership = 'የበላይ አስተዳደር';
  static const String memberAccountAdjustment = 'የአባላት መለያ ማስተካከያ';
  static const String manageFamilyLinks = 'የቤተሰብ ማያያዣ';
  static const String auditReport = 'የኦዲት ሪፖርት';
  static const String newSchoolRegistration = 'አዲስ ት/ቤት መመዝገቢያ';
  static const String application = 'መተግበሪያ';
  static const String settings = 'ቅንብሮች';
  static const String aboutUs = 'ስለ እኛ';
  static const String socialMedia = 'የማህበራዊ ሚዲያ';
  static const String logout = 'ውጣ';
  static const String restartAppTooltip = 'መተግበሪያውን ዳግም አስጀምር';
}

// --- UI Theme Constants ---
const Color primaryColor = Color.fromARGB(255, 1, 37, 100);
const Color accentColor = Color(0xFFFFD700);
const Color subtleTextColor = Color(0xFF6C757D);
const Color surfaceColor = Color(0xFFF4F7FC);
const Color onSurfaceColor = Color(0xFF212529);

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const AppDrawer(
      {super.key, required this.selectedIndex, required this.onItemTapped});

  void _pushScreen(BuildContext context, Widget screen) {
    Navigator.pop(context); // Close the drawer first
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  void _handleNavigation(BuildContext context, int index) {
    Navigator.pop(context); // Close the drawer first
    onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: surfaceColor,
      child: Consumer2<UserProvider, TenantProvider>(
        builder: (context, userProvider, tenantProvider, child) {
          final List<String> roles = userProvider.roles;
          final bool isSuperiorAdmin = roles.contains('superior_admin');
          final bool isPlanAdmin = roles.contains('plan_admin');
          final bool isDevAdmin = roles.contains('development_admin');
          final bool isGradeAdmin = roles.contains('grade_admin');
          final bool isAttendanceAdmin = roles.contains('attendance_admin');
          final bool isLibraryAdmin = roles.contains('library_admin');
          final bool isSystemAdmin = userProvider.isSystemAdmin;

          // Simplified check for Admin Tools section visibility
          final bool showAdminTools = isSuperiorAdmin ||
              isPlanAdmin ||
              isDevAdmin ||
              isGradeAdmin ||
              isAttendanceAdmin ||
              isLibraryAdmin;

          final String fullName = userProvider.userProfile?['full_name'] ??
              (AppLocalizations.of(context)?.settingsName ?? 'Guest');
          final String schoolName =
              tenantProvider.currentTenant?.name ?? AmharicStrings.sundaySchool;
          final String avatarUrl = userProvider.avatarUrl ?? '';

          final dynamic userProfile = userProvider.userProfile;
          final String userIdentifier = userProfile?['id']?.toString() ??
              userProfile?['user_id']?.toString() ??
              fullName.hashCode.toString();

          return Column(
            children: [
              _buildDrawerHeader(
                  context, fullName, schoolName, avatarUrl, userIdentifier),
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  children: [
                    _buildSectionHeader(
                        AppLocalizations.of(context)?.drawerMainMenu ??
                            'Main Menu'),
                    // Main Navigation (Amharic Translation)
                    _buildDrawerItem(context,
                        icon: Iconsax.home_2,
                        title: AppLocalizations.of(context)?.homePageTitle ??
                            'Home',
                        isSelected: selectedIndex == 0,
                        onTap: () => _handleNavigation(context, 0)),
                    _buildDrawerItem(context,
                        icon: Iconsax.shield_tick,
                        title:
                            AppLocalizations.of(context)?.managementPageTitle ??
                                'Management',
                        isSelected: selectedIndex == 1,
                        onTap: () => _handleNavigation(context, 1)),
                    _buildDrawerItem(context,
                        icon: Iconsax.teacher,
                        title:
                            AppLocalizations.of(context)?.learningPageTitle ??
                                'Learning',
                        isSelected: selectedIndex == 2,
                        onTap: () => _handleNavigation(context, 2)),
                    _buildDrawerItem(context,
                        icon: Iconsax.user,
                        title: AppLocalizations.of(context)?.profilePageTitle ??
                            'Profile',
                        isSelected: selectedIndex == 3,
                        onTap: () => _handleNavigation(context, 3)),
                    const Divider(height: 24),

                    // System Admin section (Amharic Translation)
                    if (isSystemAdmin)
                      ExpansionTile(
                        leading: const Icon(Iconsax.cpu, color: Colors.purple),
                        title: Text(
                            AppLocalizations.of(context)?.drawerSystemAdmin ??
                                'System Admin',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: Colors.purple)),
                        childrenPadding: const EdgeInsets.only(left: 16),
                        children: [
                          _buildDrawerItem(context,
                              icon: Iconsax.category,
                              title: AppLocalizations.of(context)
                                      ?.drawerSystemDashboard ??
                                  'System Dashboard',
                              onTap: () => _pushScreen(
                                  context, const SystemAdminDashboard())),
                          _buildDrawerItem(context,
                              icon: Iconsax.teacher,
                              title: AppLocalizations.of(context)
                                      ?.drawerSchoolsManagement ??
                                  'Schools Management',
                              onTap: () => _pushScreen(
                                  context, const SchoolsListScreen())),
                          _buildDrawerItem(context,
                              icon: Iconsax.people,
                              title: AppLocalizations.of(context)
                                      ?.drawerUserManagement ??
                                  'User Management',
                              onTap: () => _pushScreen(
                                  context, const UserManagementScreen())),
                          _buildDrawerItem(context,
                              icon: Iconsax.activity,
                              title: AppLocalizations.of(context)
                                      ?.drawerPlatformAnalytics ??
                                  'Platform Analytics',
                              onTap: () => _pushScreen(
                                  context, const PlatformAnalyticsScreen())),
                          _buildDrawerItem(context,
                              icon: Iconsax.security,
                              title: AppLocalizations.of(context)
                                      ?.drawerSystemAudit ??
                                  'System Audit',
                              onTap: () => _pushScreen(
                                  context, const AuditLogsScreen())),
                          _buildDrawerItem(context,
                              icon: Iconsax.setting_2,
                              title: AppLocalizations.of(context)
                                      ?.drawerSystemSettings ??
                                  'System Settings',
                              onTap: () => _pushScreen(
                                  context, const SystemSettingsScreen())),
                        ],
                      ),

                    _buildSectionHeader(
                        AppLocalizations.of(context)?.settingsUserInfo ??
                            'User Information'),
                    // Personal Info (Amharic Translation)
                    _buildDrawerItem(context,
                        icon: Iconsax.calendar_1,
                        title: AppLocalizations.of(context)?.homePageTitle ??
                            'My Attendance History',
                        onTap: () => _pushScreen(
                            context, const UserAttendanceHistoryScreen())),
                    _buildDrawerItem(context,
                        icon: Iconsax.people,
                        title: AppLocalizations.of(context)
                                ?.drawerManageFamilyLinks ??
                            'Family Status',
                        onTap: () =>
                            _pushScreen(context, const FamilyViewScreen())),

                    // Admin Tools (Amharic Translation)
                    if (showAdminTools)
                      ExpansionTile(
                        leading: const Icon(Iconsax.slider_horizontal_1,
                            color: subtleTextColor),
                        title: Text(
                            AppLocalizations.of(context)?.drawerAdminTools ??
                                'Admin Tools',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: onSurfaceColor)),
                        childrenPadding: const EdgeInsets.only(left: 16),
                        children: [
                          if (isAttendanceAdmin || isSuperiorAdmin)
                            _buildDrawerItem(context,
                                icon: Iconsax.calendar_tick,
                                title: AppLocalizations.of(context)
                                        ?.drawerAttendanceManagement ??
                                    'Attendance Management',
                                onTap: () => _pushScreen(
                                    context, const AttendanceScreen())),
                          if (isGradeAdmin || isSuperiorAdmin)
                            _buildDrawerItem(context,
                                icon: Iconsax.document_text_1,
                                title: AppLocalizations.of(context)
                                        ?.drawerAcademicManagement ??
                                    'Academic Management',
                                onTap: () => _pushScreen(
                                    context, const GradeManagementScreen())),
                          if (isLibraryAdmin || isSuperiorAdmin)
                            _buildDrawerItem(context,
                                icon: Iconsax.book_1,
                                title: AppLocalizations.of(context)
                                        ?.drawerLibraryManagement ??
                                    'Library Management',
                                onTap: () => _pushScreen(
                                    context, const LibraryManagementScreen())),
                          if (isPlanAdmin || isSuperiorAdmin)
                            _buildDrawerItem(context,
                                icon: Iconsax.clipboard_text,
                                title: AppLocalizations.of(context)
                                        ?.drawerPlanManagement ??
                                    'Plan Management',
                                onTap: () => _pushScreen(
                                    context, const PlanControlScreen())),
                          if (isDevAdmin || isSuperiorAdmin)
                            _buildDrawerItem(context,
                                icon: Iconsax.user_octagon,
                                title: AppLocalizations.of(context)
                                        ?.drawerMemberDevelopment ??
                                    'Member Development',
                                onTap: () => _pushScreen(context,
                                    const MemberDevelopmentHubScreen())),
                          if (isSuperiorAdmin)
                            _buildDrawerItem(context,
                                icon: Iconsax.people,
                                title: AppLocalizations.of(context)
                                        ?.drawerUserList ??
                                    'User List',
                                onTap: () => _pushScreen(
                                    context, const UserManagementScreen())),
                        ],
                      ),

                    // Superior Leadership (Amharic Translation)
                    if (isSuperiorAdmin && !isSystemAdmin)
                      ExpansionTile(
                        leading:
                            const Icon(Iconsax.crown_1, color: accentColor),
                        title: Text(
                            AppLocalizations.of(context)
                                    ?.drawerSuperiorLeadership ??
                                'Superior Leadership',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                color: onSurfaceColor)),
                        childrenPadding: const EdgeInsets.only(left: 16),
                        children: [
                          _buildDrawerItem(context,
                              icon: Iconsax.user_edit,
                              title: AppLocalizations.of(context)
                                      ?.drawerMemberAccountAdjustment ??
                                  'Member Account Adjustment',
                              onTap: () => _pushScreen(
                                  context,
                                  const AdminEditUserScreen(
                                      userId: '', userName: ''))),
                          _buildDrawerItem(context,
                              icon: Iconsax.people,
                              title: AppLocalizations.of(context)
                                      ?.drawerManageFamilyLinks ??
                                  'Manage Family Links',
                              onTap: () => _pushScreen(
                                  context, const ManageFamilyLinksScreen())),
                          _buildDrawerItem(context,
                              icon: Iconsax.lock,
                              title: AppLocalizations.of(context)
                                      ?.drawerPermissionsAndScreens ??
                                  'Permissions & Screens',
                              onTap: () => _pushScreen(
                                  context, const SuperAdminDashboardScreen())),
                          _buildDrawerItem(context,
                              icon: Iconsax.shield_search,
                              title: AppLocalizations.of(context)
                                      ?.drawerAuditReport ??
                                  'Audit Report',
                              onTap: () => _pushScreen(
                                  context, const AuditTrailScreen())),
                          _buildDrawerItem(context,
                              icon: Iconsax.building,
                              title: AppLocalizations.of(context)
                                      ?.drawerNewSchoolRegistration ??
                                  'New School Registration',
                              onTap: () => _pushScreen(
                                  context, const AttendanceSummaryScreen())),
                        ],
                      ),

                    const Divider(height: 24),
                    _buildSectionHeader(
                        AppLocalizations.of(context)?.drawerApplication ??
                            'Application'),
                    // Application (Amharic Translation)
                    _buildDrawerItem(context,
                        icon: Iconsax.setting_2,
                        title: AppLocalizations.of(context)?.settingsTitle ??
                            'Settings', onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    }),
                    _buildDrawerItem(context,
                        icon: Iconsax.info_circle,
                        title: AppLocalizations.of(context)?.drawerAboutUs ??
                            'About Us',
                        onTap: () =>
                            _pushScreen(context, const AboutUsScreen())),
                    _buildDrawerItem(context,
                        icon: Iconsax.global,
                        title:
                            AppLocalizations.of(context)?.drawerSocialMedia ??
                                'Social Media',
                        onTap: () =>
                            _pushScreen(context, const AmdePlatform())),
                    const Divider(height: 24),
                    _buildDrawerItem(context,
                        icon: Iconsax.logout,
                        title: AppLocalizations.of(context)?.settingsLogout ??
                            'Logout', onTap: () {
                      Navigator.pop(context);
                      context.read<UserProvider>().handleLogout();
                    }),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Text(title.toUpperCase(),
          style: GoogleFonts.notoSansEthiopic(
              color: subtleTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 12)),
    );
  }

  // =========== THE FIX IS HERE ===========
  Widget _buildDrawerHeader(BuildContext context, String fullName,
      String schoolName, String avatarUrl, String userIdentifier) {
    final bool hasImage = avatarUrl.isNotEmpty;

    // This tag MUST match the tag used in your ProfileScreen for the animation to work.
    final String heroTag = 'profileAvatar-$userIdentifier';

    // No more nested Heroes. The Hero widget is ONLY on the CircleAvatar.
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [primaryColor, Color.fromARGB(255, 4, 53, 136)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: heroTag, // The one and only Hero tag for the avatar
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: accentColor,
                    child: ClipOval(
                      child: hasImage
                          ? Image.network(
                              avatarUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) => Text(
                                fullName.isNotEmpty
                                    ? fullName[0].toUpperCase()
                                    : 'G',
                                style: const TextStyle(
                                    fontSize: 40,
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : Text(
                              fullName.isNotEmpty
                                  ? fullName[0].toUpperCase()
                                  : 'G',
                              style: const TextStyle(
                                  fontSize: 40,
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(fullName,
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(schoolName,
                    style: GoogleFonts.notoSansEthiopic(
                        color: Colors.white.withOpacity(0.8))),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 8,
            child: IconButton(
              icon: const Icon(Iconsax.refresh, color: Colors.white70),
              tooltip: AppLocalizations.of(context)?.drawerRestartApp ??
                  'Restart App',
              onPressed: () {
                AppRestartWrapper.restartApp(context);
              },
            ),
          ),
        ],
      ),
    );
  }
  // =======================================

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon,
      required String title,
      VoidCallback? onTap,
      bool isSelected = false}) {
    final Color textColor = isSelected ? primaryColor : onSurfaceColor;
    return ListTile(
      leading: Icon(icon, color: isSelected ? primaryColor : subtleTextColor),
      title: Text(title,
          style: GoogleFonts.notoSansEthiopic(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: textColor)),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: accentColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
