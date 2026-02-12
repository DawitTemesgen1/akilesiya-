import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  Map<String, dynamic> _settings = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final result = await SystemAdminService.getSystemSettings();
    if (mounted) {
      if (result['success'] == true) {
        setState(() => _settings = result['data']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['message']), backgroundColor: Colors.red));
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    final result = await SystemAdminService.updateSystemSettings(_settings);
    setState(() => _isSaving = false);

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Settings saved successfully!',
                  style: GoogleFonts.poppins()),
              backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(result['message']), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Glassmorphic App Bar
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.of(context).pop(),
              color: isDark ? Colors.white : Colors.black87,
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Text(
                    'System Settings',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [primaryColor.withValues(alpha: 0.3), Colors.black]
                        : [primaryColor.withValues(alpha: 0.1), Colors.white],
                  ),
                ),
              ),
            ),
            actions: [
              if (_isSaving)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else
                IconButton(
                    icon: Icon(Iconsax.tick_circle, color: primaryColor),
                    onPressed: _saveSettings),
              const SizedBox(width: 8),
            ],
          ),

          if (_isLoading)
            const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()))
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Platform Configuration
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child: _buildSettingsGroup(
                          'Platform Configuration',
                          Iconsax.setting_2,
                          [
                            _buildTextSetting(
                                'Platform Name',
                                'Display name for the platform',
                                'platform_name',
                                Iconsax.edit_2,
                                isDark),
                            _buildSwitchSetting(
                                'New Registrations',
                                'Allow new schools to register',
                                'allow_new_registrations',
                                Iconsax.user_add,
                                isDark,
                                primaryColor),
                            _buildSwitchSetting(
                                'Email Verification',
                                'Require users to verify email',
                                'require_email_verification',
                                Iconsax.sms_tracking,
                                isDark,
                                primaryColor),
                          ],
                          isDark,
                          primaryColor),
                    ),
                    const SizedBox(height: 20),

                    // System Governance
                    FadeInUp(
                      duration: const Duration(milliseconds: 700),
                      child: _buildSettingsGroup(
                          'System Governance',
                          Iconsax.judge,
                          [
                            _buildSwitchSetting(
                                'Maintenance Mode',
                                'Put platform in maintenance mode',
                                'maintenance_mode',
                                Iconsax.warning_2,
                                isDark,
                                primaryColor),
                            _buildNumberSetting(
                                'Max Schools',
                                'Maximum schools per account',
                                'max_schools_per_account',
                                Iconsax.bank,
                                isDark),
                            _buildNumberSetting(
                                'Data Retention',
                                'Retention period in days',
                                'data_retention_days',
                                Iconsax.data,
                                isDark),
                          ],
                          isDark,
                          primaryColor),
                    ),
                    const SizedBox(height: 32),

                    // Danger Zone
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: _buildDangerZone(isDark),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(String title, IconData icon, List<Widget> children,
      bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900]!.withValues(alpha: 0.5) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 20),
              const SizedBox(width: 12),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(String title, String subtitle, String key,
      IconData icon, bool isDark, Color primaryColor) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 20, color: Colors.grey),
      title: Text(title,
          style:
              GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
      trailing: Switch.adaptive(
        value: _settings[key] ?? false,
        activeColor: primaryColor,
        onChanged: (v) => setState(() => _settings[key] = v),
      ),
    );
  }

  Widget _buildTextSetting(
      String title, String subtitle, String key, IconData icon, bool isDark) {
    return _buildInputSetting(
        title, subtitle, key, icon, isDark, TextInputType.text);
  }

  Widget _buildNumberSetting(
      String title, String subtitle, String key, IconData icon, bool isDark) {
    return _buildInputSetting(
        title, subtitle, key, icon, isDark, TextInputType.number);
  }

  Widget _buildInputSetting(String title, String subtitle, String key,
      IconData icon, bool isDark, TextInputType type) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 20, color: Colors.grey),
      title: Text(title,
          style:
              GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
      trailing: SizedBox(
        width: 120,
        child: TextFormField(
          initialValue: _settings[key]?.toString() ?? '',
          keyboardType: type,
          style: GoogleFonts.poppins(fontSize: 13),
          onChanged: (v) {
            if (type == TextInputType.number) {
              _settings[key] = int.tryParse(v) ?? _settings[key];
            } else {
              _settings[key] = v;
            }
          },
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
          ),
        ),
      ),
    );
  }

  Widget _buildDangerZone(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.danger, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Text('Danger Zone',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Critical system actions. These operations are irreversible and affect all tenants.',
            style: GoogleFonts.poppins(
                fontSize: 12, color: Colors.red.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _confirmAction(
                      'Clear Logs',
                      'This will delete all system audit logs. This cannot be undone.',
                      () {}),
                  icon: const Icon(Iconsax.trash, size: 16),
                  label: Text('Clear Logs',
                      style: GoogleFonts.poppins(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Iconsax.document_download, size: 16),
                  label: Text('Export All',
                      style: GoogleFonts.poppins(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmAction(String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(message, style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child:
                  const Text('Confirm', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
