import 'package:amde_haymanot_abalat_guday/admin%20only/admin_edit%20user.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/admin_hub.dart';

import 'package:amde_haymanot_abalat_guday/admin%20only/grade_attendance_audit.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/manage_family.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/profile_template_builder.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/student_list.dart';
import 'package:amde_haymanot_abalat_guday/app_restart_wrapper.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/tenant_provider.dart';
import 'package:amde_haymanot_abalat_guday/admin%20only/permission_management.dart';
import 'package:amde_haymanot_abalat_guday/role%20based/activity_screen.dart';
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
  static const String systemAdmin = 'የስርዓት አስተዳዳሪ';
  static const String attendanceManagement = 'የትምህርት ክትትል';
  static const String attendanceSummary = 'የክትትል ሪፖርት';
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
  static const String profileTemplateeEditor = 'የመገለጫ አብነት አርታዒ';
  static const String app = 'መተግበሪያ';
  static const String settings = 'ቅንብሮች';
  static const String aboutUs = 'ስለ እኛ';
  static const String socialMedia = 'የማህበራዊ ሚዲያ';
  static const String logout = 'ውጣ';
  static const String userActivity = 'የተጠቃሚ እንቅስቃሴ';
}

// --- UI Theme Constants ---
const Color premiumDark = Color(0xFF0F0F1E);
const Color premiumGold = Color(0xFFFFD700);

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
      backgroundColor: premiumDark,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1A2E).withOpacity(0.95),
              premiumDark,
              Colors.black,
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
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

            final List<String> allowedScreens = userProvider.allowedScreens;

            // Simplified check for Admin Tools section visibility
            final bool showAdminTools = isSuperiorAdmin ||
                isPlanAdmin ||
                isDevAdmin ||
                isGradeAdmin ||
                isAttendanceAdmin ||
                isLibraryAdmin ||
                allowedScreens.any((s) => [
                      'ATTENDANCE_MANAGEMENT',
                      'ATTENDANCE_SUMMARY',
                      'ACADEMIC_MANAGEMENT',
                      'LIBRARY_MANAGEMENT',
                      'PLAN_MANAGEMENT',
                      'MEMBER_DEVELOPMENT',
                      'USER_LIST'
                    ].contains(s));

            final String fullName = userProvider.userProfile?['full_name'] ??
                (AppLocalizations.of(context)?.settingsName ?? 'Guest');
            final String schoolName = tenantProvider.currentTenant?.name ??
                AmharicStrings.sundaySchool;
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
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.white10,
                      iconTheme: const IconThemeData(color: Colors.white70),
                      textTheme: Theme.of(context)
                          .textTheme
                          .apply(bodyColor: Colors.white),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      children: [
                        _buildSectionHeader(
                            AppLocalizations.of(context)?.drawerMainMenu ??
                                AmharicStrings.mainMenu),
                        // Main Navigation
                        _buildDrawerItem(context,
                            icon: Iconsax.home_2,
                            title:
                                AppLocalizations.of(context)?.homePageTitle ??
                                    'Home',
                            isSelected: selectedIndex == 0,
                            onTap: () => _handleNavigation(context, 0)),
                        _buildDrawerItem(context,
                            icon: Iconsax.shield_tick,
                            title: AppLocalizations.of(context)
                                    ?.managementPageTitle ??
                                'Management',
                            isSelected: selectedIndex == 1,
                            onTap: () => _handleNavigation(context, 1)),
                        _buildDrawerItem(context,
                            icon: Iconsax.teacher,
                            title: AppLocalizations.of(context)
                                    ?.learningPageTitle ??
                                'Learning',
                            isSelected: selectedIndex == 2,
                            onTap: () => _handleNavigation(context, 2)),
                        _buildDrawerItem(context,
                            icon: Iconsax.user,
                            title: AppLocalizations.of(context)
                                    ?.profilePageTitle ??
                                'Profile',
                            isSelected: selectedIndex == 3,
                            onTap: () => _handleNavigation(context, 3)),
                        const Divider(height: 32, thickness: 0.5),

                        // System Admin section
                        if (isSystemAdmin)
                          _buildExpansionTile(
                            context,
                            title: AppLocalizations.of(context)
                                    ?.drawerSystemAdmin ??
                                AmharicStrings.systemAdmin,
                            icon: Iconsax.cpu,
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
                                  icon: Iconsax.lock,
                                  title: AppLocalizations.of(context)
                                          ?.drawerPermissionsAndScreens ??
                                      'Permissions & Screens',
                                  onTap: () => _pushScreen(context,
                                      const SuperAdminDashboardScreen())),
                              _buildDrawerItem(context,
                                  icon: Iconsax.edit_2,
                                  title: AmharicStrings.profileTemplateeEditor,
                                  onTap: () => _pushScreen(context,
                                      const ProfileTemplateBuilderScreen())),
                              _buildDrawerItem(context,
                                  icon: Iconsax.activity,
                                  title: AmharicStrings.userActivity,
                                  onTap: () => _pushScreen(
                                      context, const UserActivityScreen())),
                              _buildDrawerItem(context,
                                  icon: Iconsax.activity,
                                  title: AppLocalizations.of(context)
                                          ?.drawerPlatformAnalytics ??
                                      'Platform Analytics',
                                  onTap: () => _pushScreen(context,
                                      const PlatformAnalyticsScreen())),
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

                        // Admin Tools
                        if (showAdminTools)
                          _buildExpansionTile(
                            context,
                            title: AppLocalizations.of(context)
                                    ?.drawerAdminTools ??
                                'Admin Tools',
                            icon: Iconsax.layer,
                            children: [
                              if (isAttendanceAdmin ||
                                  isSuperiorAdmin ||
                                  allowedScreens
                                      .contains('ATTENDANCE_MANAGEMENT'))
                                _buildDrawerItem(context,
                                    icon: Iconsax.calendar_tick,
                                    title: AppLocalizations.of(context)
                                            ?.drawerAttendanceManagement ??
                                        AmharicStrings.attendanceManagement,
                                    onTap: () => _pushScreen(
                                        context, const AttendanceScreen())),
                              if (isAttendanceAdmin ||
                                  isSuperiorAdmin ||
                                  allowedScreens.contains('ATTENDANCE_SUMMARY'))
                                _buildDrawerItem(context,
                                    icon: Iconsax.chart_square,
                                    title: AmharicStrings.attendanceSummary,
                                    onTap: () => _pushScreen(context,
                                        const AttendanceSummaryScreen())),
                              if (isGradeAdmin ||
                                  isSuperiorAdmin ||
                                  allowedScreens
                                      .contains('ACADEMIC_MANAGEMENT'))
                                _buildDrawerItem(context,
                                    icon: Iconsax.document_text_1,
                                    title: AppLocalizations.of(context)
                                            ?.drawerAcademicManagement ??
                                        AmharicStrings.academicManagement,
                                    onTap: () => _pushScreen(context,
                                        const GradeManagementScreen())),
                              if (isLibraryAdmin ||
                                  isSuperiorAdmin ||
                                  allowedScreens.contains('LIBRARY_MANAGEMENT'))
                                _buildDrawerItem(context,
                                    icon: Iconsax.book_1,
                                    title: AppLocalizations.of(context)
                                            ?.drawerLibraryManagement ??
                                        AmharicStrings.libraryManagement,
                                    onTap: () => _pushScreen(context,
                                        const LibraryManagementScreen())),
                              if (isPlanAdmin ||
                                  isSuperiorAdmin ||
                                  allowedScreens.contains('PLAN_MANAGEMENT'))
                                _buildDrawerItem(context,
                                    icon: Iconsax.clipboard_text,
                                    title: AppLocalizations.of(context)
                                            ?.drawerPlanManagement ??
                                        AmharicStrings.planManagement,
                                    onTap: () => _pushScreen(
                                        context, const PlanControlScreen())),
                              if (isDevAdmin ||
                                  isSuperiorAdmin ||
                                  allowedScreens.contains('MEMBER_DEVELOPMENT'))
                                _buildDrawerItem(context,
                                    icon: Iconsax.user_octagon,
                                    title: AppLocalizations.of(context)
                                            ?.drawerMemberDevelopment ??
                                        AmharicStrings.memberDevelopment,
                                    onTap: () => _pushScreen(context,
                                        const MemberDevelopmentHubScreen())),
                              if (isSuperiorAdmin ||
                                  allowedScreens.contains('USER_LIST'))
                                _buildDrawerItem(context,
                                    icon: Iconsax.people,
                                    title: AppLocalizations.of(context)
                                            ?.drawerUserList ??
                                        AmharicStrings.userList,
                                    onTap: () => _pushScreen(
                                        context, const UserManagementScreen())),
                            ],
                          ),

                        // Superior Leadership
                        if ((isSuperiorAdmin ||
                                allowedScreens.any((s) => [
                                      'ADMIN_HUB',
                                      'MEMBER_ACCOUNT_ADJUSTMENT',
                                      'MANAGE_FAMILY_LINKS',
                                      'PERMISSIONS_AND_SCREENS',
                                      'AUDIT_REPORT'
                                    ].contains(s))) &&
                            !isSystemAdmin)
                          _buildExpansionTile(
                            context,
                            title: AppLocalizations.of(context)
                                    ?.drawerSuperiorLeadership ??
                                AmharicStrings.superiorLeadership,
                            icon: Iconsax.crown_1,
                            children: [
                              if (isSuperiorAdmin ||
                                  allowedScreens.contains('ADMIN_HUB'))
                                _buildDrawerItem(context,
                                    icon: Iconsax.category,
                                    title: 'Admin Hub',
                                    onTap: () => _pushScreen(
                                        context, const AdminHubScreen())),
                              if (isSuperiorAdmin ||
                                  allowedScreens
                                      .contains('MEMBER_ACCOUNT_ADJUSTMENT'))
                                _buildDrawerItem(context,
                                    icon: Iconsax.user_edit,
                                    title: AppLocalizations.of(context)
                                            ?.drawerMemberAccountAdjustment ??
                                        AmharicStrings.memberAccountAdjustment,
                                    onTap: () => _pushScreen(
                                        context,
                                        const AdminEditUserScreen(
                                            userId: '', userName: ''))),
                              if (isSuperiorAdmin ||
                                  allowedScreens
                                      .contains('MANAGE_FAMILY_LINKS'))
                                _buildDrawerItem(context,
                                    icon: Iconsax.people,
                                    title: AppLocalizations.of(context)
                                            ?.drawerManageFamilyLinks ??
                                        AmharicStrings.manageFamilyLinks,
                                    onTap: () => _pushScreen(context,
                                        const ManageFamilyLinksScreen())),
                              if (isSuperiorAdmin ||
                                  allowedScreens
                                      .contains('PERMISSIONS_AND_SCREENS'))
                                _buildDrawerItem(context,
                                    icon: Iconsax.lock,
                                    title: AppLocalizations.of(context)
                                            ?.drawerPermissionsAndScreens ??
                                        'Permissions & Screens',
                                    onTap: () => _pushScreen(context,
                                        const SuperAdminDashboardScreen())),
                              if (isSuperiorAdmin ||
                                  allowedScreens.contains('AUDIT_REPORT'))
                                _buildDrawerItem(context,
                                    icon: Iconsax.shield_search,
                                    title: AppLocalizations.of(context)
                                            ?.drawerAuditReport ??
                                        AmharicStrings.auditReport,
                                    onTap: () => _pushScreen(
                                        context, const AuditTrailScreen())),
                            ],
                          ),

                        _buildSectionHeader(
                            AppLocalizations.of(context)?.settingsUserInfo ??
                                'User Information'),
                        // Personal Info
                        _buildDrawerItem(context,
                            icon: Iconsax.calendar_1,
                            title: AppLocalizations.of(context)
                                    ?.attendanceHistoryTitle ??
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

                        const Divider(height: 32, thickness: 0.5),
                        _buildSectionHeader(
                            AppLocalizations.of(context)?.drawerApplication ??
                                AmharicStrings.app),
                        // Application
                        _buildDrawerItem(context,
                            icon: Iconsax.setting_2,
                            title:
                                AppLocalizations.of(context)?.settingsTitle ??
                                    AmharicStrings.settings, onTap: () {
                          Navigator.pop(context);
                          context.push('/settings');
                        }),
                        _buildDrawerItem(context,
                            icon: Iconsax.info_circle,
                            title:
                                AppLocalizations.of(context)?.drawerAboutUs ??
                                    AmharicStrings.aboutUs,
                            onTap: () =>
                                _pushScreen(context, const AboutUsScreen())),
                        _buildDrawerItem(context,
                            icon: Iconsax.global,
                            title: AppLocalizations.of(context)
                                    ?.drawerSocialMedia ??
                                AmharicStrings.socialMedia,
                            onTap: () =>
                                _pushScreen(context, const AmdePlatform())),
                        const Divider(height: 24, thickness: 0.5),
                        _buildDrawerItem(context,
                            icon: Iconsax.logout,
                            title:
                                AppLocalizations.of(context)?.settingsLogout ??
                                    AmharicStrings.logout, onTap: () {
                          Navigator.pop(context);
                          context.read<UserProvider>().handleLogout();
                        }),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(title.toUpperCase(),
          style: GoogleFonts.notoSansEthiopic(
              color: Colors.white54,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.2)),
    );
  }

  Widget _buildExpansionTile(BuildContext context,
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(icon, color: premiumGold),
        collapsedIconColor: Colors.white70,
        iconColor: premiumGold,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(title,
            style: GoogleFonts.notoSansEthiopic(
                fontWeight: FontWeight.w600, color: Colors.white)),
        childrenPadding: const EdgeInsets.only(left: 16),
        children: children,
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, String fullName,
      String schoolName, String avatarUrl, String userIdentifier) {
    final bool hasImage = avatarUrl.isNotEmpty;
    final String heroTag = 'profileAvatar-$userIdentifier';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 24, right: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A8A).withOpacity(0.5),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: premiumGold, width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: premiumGold.withOpacity(0.2), blurRadius: 10)
                    ]),
                child: Hero(
                  tag: heroTag,
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: premiumDark,
                    child: ClipOval(
                      child: hasImage
                          ? Image.network(
                              avatarUrl,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stack) => Text(
                                fullName.isNotEmpty
                                    ? fullName[0].toUpperCase()
                                    : 'G',
                                style: const TextStyle(
                                    fontSize: 32,
                                    color: premiumGold,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : Text(
                              fullName.isNotEmpty
                                  ? fullName[0].toUpperCase()
                                  : 'G',
                              style: const TextStyle(
                                  fontSize: 32,
                                  color: premiumGold,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.refresh, color: Colors.white70),
                tooltip:
                    AppLocalizations.of(context)?.drawerRestartApp ?? 'Restart',
                onPressed: () => AppRestartWrapper.restartApp(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(fullName,
              style: GoogleFonts.notoSansEthiopic(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(schoolName,
              style: GoogleFonts.notoSansEthiopic(
                  fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon,
      required String title,
      VoidCallback? onTap,
      bool isSelected = false}) {
    final Color textColor = isSelected ? premiumGold : Colors.white;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: isSelected
          ? BoxDecoration(
              color: premiumGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: premiumGold.withOpacity(0.3)))
          : null,
      child: ListTile(
        leading: Icon(icon,
            size: 22, color: isSelected ? premiumGold : Colors.white70),
        title: Text(title,
            style: GoogleFonts.notoSansEthiopic(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: textColor)),
        onTap: onTap,
        selected: isSelected,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        dense: true,
      ),
    );
  }
}
