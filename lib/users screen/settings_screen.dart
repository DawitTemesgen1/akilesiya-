import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/language_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _appVersion = '1.0.0';
  static const String _buildNumber = '1';

  void _showLogoutDialog(
      BuildContext context, AppLocalizations l10n, bool isAmharic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.settingsLogout,
          style: isAmharic
              ? GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold)
              : GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.settingsLogoutConfirmation,
          style: isAmharic
              ? GoogleFonts.notoSansEthiopic()
              : GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.settingsCancel,
              style: isAmharic
                  ? GoogleFonts.notoSansEthiopic()
                  : GoogleFonts.poppins(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<UserProvider>().handleLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              l10n.settingsConfirm,
              style: isAmharic
                  ? GoogleFonts.notoSansEthiopic()
                  : GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final userProvider = context.watch<UserProvider>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isAmharic = languageProvider.currentLocale.languageCode == 'am';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: isAmharic
              ? GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold)
              : GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info Card
          if (userProvider.isLoggedIn)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.settingsUserInfo,
                      style: isAmharic
                          ? GoogleFonts.notoSansEthiopic(
                              fontSize: 16, fontWeight: FontWeight.bold)
                          : GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      context,
                      Iconsax.user,
                      l10n.settingsName, // "Full Name"
                      userProvider.userProfile?['full_name']?.toString() ??
                          'N/A',
                      isAmharic,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      Iconsax.user_tick,
                      "Christian Name",
                      userProvider.userProfile?['christian_name']?.toString() ??
                          'Not Set',
                      isAmharic,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      Iconsax.call,
                      "Phone",
                      userProvider.userProfile?['phone_number']?.toString() ??
                          'N/A',
                      isAmharic,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      Iconsax.woman,
                      "Mother's Name",
                      userProvider.userProfile?['mother_name']?.toString() ??
                          'Not Set',
                      isAmharic,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      Iconsax.user_cirlce_add,
                      "Confession Father",
                      userProvider.userProfile?['confession_father_name']
                              ?.toString() ??
                          'Not Set',
                      isAmharic,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      Iconsax.man,
                      "Gender",
                      userProvider.userProfile?['gender']?.toString() ??
                          'Not Set',
                      isAmharic,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      Iconsax.calendar,
                      "Date of Birth",
                      userProvider.userProfile?['dob']?.toString() ?? 'Not Set',
                      isAmharic,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      Iconsax.teacher,
                      "Academic Level",
                      userProvider.userProfile?['academic_level']?.toString() ??
                          'Not Set',
                      isAmharic,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      Iconsax.people,
                      "Guardian Name",
                      userProvider.userProfile?['parent_name']?.toString() ??
                          'Not Set',
                      isAmharic,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      context,
                      Iconsax.call_add,
                      "Guardian Phone",
                      userProvider.userProfile?['parent_phone_number']
                              ?.toString() ??
                          'Not Set',
                      isAmharic,
                    ),
                    // Display Custom Fields (Matching Style)
                    if (userProvider.userProfile != null &&
                        userProvider.userProfile!['custom_fields_detail'] !=
                            null)
                      ...(userProvider.userProfile!['custom_fields_detail']
                              as List)
                          .map((field) {
                        return Column(
                          children: [
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              context,
                              Iconsax.tag, // Generic tag icon for custom fields
                              field['field_name']?.toString() ?? 'Field',
                              field['field_value']?.toString() ?? 'Not Set',
                              isAmharic,
                            ),
                          ],
                        );
                      }),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionHeader(
              l10n.settingsAppearance, Iconsax.brush_1, isAmharic),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildThemeTile(context, themeProvider, l10n, isAmharic),
                const Divider(height: 1),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Language Section
          _buildSectionHeader(
              l10n.settingsLanguage, Iconsax.language_square, isAmharic),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                _buildLanguageTile(context, languageProvider, l10n, isAmharic),
          ),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(
              l10n.settingsAbout, Iconsax.info_circle, isAmharic),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Iconsax.info_circle),
              title: Text(
                l10n.settingsAppVersion,
                style: isAmharic
                    ? GoogleFonts.notoSansEthiopic()
                    : GoogleFonts.poppins(),
              ),
              trailing: Text(
                '$_appVersion ($_buildNumber)',
                style: isAmharic
                    ? GoogleFonts.notoSansEthiopic(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold)
                    : GoogleFonts.poppins(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Logout Button
          if (userProvider.isLoggedIn)
            ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context, l10n, isAmharic),
              icon: const Icon(Iconsax.logout),
              label: Text(
                l10n.settingsLogout,
                style: isAmharic
                    ? GoogleFonts.notoSansEthiopic(fontWeight: FontWeight.bold)
                    : GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isAmharic) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: isAmharic
              ? GoogleFonts.notoSansEthiopic(
                  fontSize: 18, fontWeight: FontWeight.bold)
              : GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label,
      String value, bool isAmharic) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: isAmharic
                    ? GoogleFonts.notoSansEthiopic(
                        fontSize: 12, color: Colors.grey[600])
                    : GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: isAmharic
                    ? GoogleFonts.notoSansEthiopic(
                        fontSize: 14, fontWeight: FontWeight.w500)
                    : GoogleFonts.poppins(
                        fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeTile(BuildContext context, ThemeProvider themeProvider,
      AppLocalizations l10n, bool isAmharic) {
    return ExpansionTile(
      leading: const Icon(Iconsax.moon),
      title: Text(
        l10n.settingsTheme,
        style:
            isAmharic ? GoogleFonts.notoSansEthiopic() : GoogleFonts.poppins(),
      ),
      subtitle: Text(
        _getThemeModeLabel(themeProvider.themeMode, l10n),
        style: isAmharic
            ? GoogleFonts.notoSansEthiopic(
                fontSize: 12, color: Colors.grey[600])
            : GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
      ),
      children: [
        RadioGroup<ThemeMode>(
          groupValue: themeProvider.themeMode,
          onChanged: (value) {
            if (value != null) {
              themeProvider.setThemeMode(value);
            }
          },
          child: Column(
            children: [
              RadioListTile<ThemeMode>(
                title: Text(
                  l10n.settingsThemeLight,
                  style: isAmharic
                      ? GoogleFonts.notoSansEthiopic()
                      : GoogleFonts.poppins(),
                ),
                value: ThemeMode.light,
              ),
              RadioListTile<ThemeMode>(
                title: Text(
                  l10n.settingsThemeDark,
                  style: isAmharic
                      ? GoogleFonts.notoSansEthiopic()
                      : GoogleFonts.poppins(),
                ),
                value: ThemeMode.dark,
              ),
              RadioListTile<ThemeMode>(
                title: Text(
                  l10n.settingsThemeSystem,
                  style: isAmharic
                      ? GoogleFonts.notoSansEthiopic()
                      : GoogleFonts.poppins(),
                ),
                value: ThemeMode.system,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageTile(
      BuildContext context,
      LanguageProvider languageProvider,
      AppLocalizations l10n,
      bool isAmharic) {
    final currentLang = languageProvider.currentLocale.languageCode;
    return ListTile(
      leading: const Icon(Iconsax.language_square),
      title: Text(
        l10n.settingsCurrentLanguage,
        style:
            isAmharic ? GoogleFonts.notoSansEthiopic() : GoogleFonts.poppins(),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: currentLang,
            items: [
              DropdownMenuItem(
                value: 'am',
                child: Text(
                  l10n.settingsLanguageAmharic,
                  style: isAmharic
                      ? GoogleFonts.notoSansEthiopic()
                      : GoogleFonts.poppins(),
                ),
              ),
              DropdownMenuItem(
                value: 'en',
                child: Text(
                  l10n.settingsLanguageEnglish,
                  style: isAmharic
                      ? GoogleFonts.notoSansEthiopic()
                      : GoogleFonts.poppins(),
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                languageProvider.setLocale(Locale(value));
              }
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: l10n.settingsLanguageToggleTooltip,
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              final next = currentLang == 'am' ? 'en' : 'am';
              languageProvider.setLocale(Locale(next));
            },
          ),
        ],
      ),
    );
  }

  String _getThemeModeLabel(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.settingsThemeLight;
      case ThemeMode.dark:
        return l10n.settingsThemeDark;
      case ThemeMode.system:
        return l10n.settingsThemeSystem;
    }
  }
}
