import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';
import 'package:google_fonts/google_fonts.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({Key? key}) : super(key: key);

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
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
              content: Text('ቅንብሮቹ በተሳካ ሁኔታ ተቀምጠዋል!',
                  style: GoogleFonts.notoSansEthiopic())),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  Widget _buildSwitchSetting(String title, String subtitle, String key) {
    return SwitchListTile(
      title: Text(title, style: GoogleFonts.notoSansEthiopic()),
      subtitle: Text(subtitle, style: GoogleFonts.notoSansEthiopic()),
      value: _settings[key] ?? false,
      onChanged: (value) {
        setState(() => _settings[key] = value);
      },
    );
  }

  Widget _buildTextSetting(String title, String subtitle, String key) {
    return ListTile(
      title: Text(title, style: GoogleFonts.notoSansEthiopic()),
      subtitle: Text(subtitle, style: GoogleFonts.notoSansEthiopic()),
      trailing: SizedBox(
        width: 200,
        child: TextFormField(
          initialValue: _settings[key]?.toString() ?? '',
          onChanged: (value) => _settings[key] = value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberSetting(String title, String subtitle, String key) {
    return ListTile(
      title: Text(title, style: GoogleFonts.notoSansEthiopic()),
      subtitle: Text(subtitle, style: GoogleFonts.notoSansEthiopic()),
      trailing: SizedBox(
        width: 100,
        child: TextFormField(
          initialValue: _settings[key]?.toString() ?? '',
          keyboardType: TextInputType.number,
          onChanged: (value) =>
              _settings[key] = int.tryParse(value) ?? _settings[key],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('የስርዓት ቅንብሮች', style: GoogleFonts.notoSansEthiopic()),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveSettings,
            tooltip: 'ቅንብሮችን አስቀምጥ',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'የፕላትፎርም ቅንብሮች',
                            style: GoogleFonts.notoSansEthiopic(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildTextSetting(
                            'የፕላትፎርም ስም',
                            'ለፕላትፎርሙ የሚታይ ስም',
                            'platform_name',
                          ),
                          _buildSwitchSetting(
                            'አዲስ ምዝገባዎችን ፍቀድ',
                            'አዲስ ትምህርት ቤቶች እና ተጠቃሚዎች እንዲመዘገቡ ፍቀድ',
                            'allow_new_registrations',
                          ),
                          _buildSwitchSetting(
                            'የኢሜል ማረጋገጫ ጠይቅ',
                            'ተጠቃሚዎች የኢሜል አድራሻቸውን ማረጋገጥ አለባቸው',
                            'require_email_verification',
                          ),
                          _buildNumberSetting(
                            'ከፍተኛው የት/ቤቶች ብዛት በአንድ አካውንት',
                            'አንድ ተጠቃሚ ሊፈጥር የሚችለው ከፍተኛው የት/ቤቶች ብዛት',
                            'max_schools_per_account',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'የስርዓት ቅንብሮች',
                            style: GoogleFonts.notoSansEthiopic(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildSwitchSetting(
                            'የጥገና ሁነታ',
                            'መላውን ፕላትፎርም በጥገና ሁነታ ላይ አድርግ',
                            'maintenance_mode',
                          ),
                          _buildSwitchSetting(
                            'የኢሜል ማሳወቂያዎች',
                            'በስርዓት-ሰፊ የኢሜል ማሳወቂያዎችን ላክ',
                            'email_notifications',
                          ),
                          _buildNumberSetting(
                            'የመረጃ ማቆያ (በቀናት)',
                            'አካውንት ከተሰረዘ በኋላ የተጠቃሚ መረጃ ለምን ያህል ጊዜ እንደሚቆይ',
                            'data_retention_days',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'አደገኛ ቀጠና',
                            style: GoogleFonts.notoSansEthiopic(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'እነዚህ እርምጃዎች የማይመለሱ እና በፕላትፎርሙ ላይ ያሉትን ሁሉንም ተጠቃሚዎች ሊነኩ ይችላሉ።',
                            style:
                                GoogleFonts.notoSansEthiopic(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.delete_forever),
                                label: Text('ሁሉንም የፍተሻ መዝገቦች አጽዳ',
                                    style: GoogleFonts.notoSansEthiopic()),
                                onPressed: () => _showClearLogsConfirmation(),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.backup),
                                label: Text('ሁሉንም መረጃዎች ላክ',
                                    style: GoogleFonts.notoSansEthiopic()),
                                onPressed: () => _exportAllData(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showClearLogsConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ሁሉንም የፍተሻ መዝገቦች ለማጽዳት እርግጠኛ ነዎት?',
            style: GoogleFonts.notoSansEthiopic()),
        content: Text(
            'ይህ እርምጃ ሁሉንም የስርዓት ፍተሻ መዝገቦች በቋሚነት ይሰርዛል። ይህ ሊቀለበስ አይችልም።',
            style: GoogleFonts.notoSansEthiopic()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ይቅር', style: GoogleFonts.notoSansEthiopic()),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _clearAuditLogs();
            },
            child:
                Text('ሁሉንም መዝገቦች አጽዳ', style: GoogleFonts.notoSansEthiopic()),
          ),
        ],
      ),
    );
  }

  void _clearAuditLogs() {
    // TODO: Implement clear audit logs functionality
    // Example: SystemAdminService.clearAllAuditLogs();
  }

  void _exportAllData() {
    // TODO: Implement export all data functionality
    // Example: SystemAdminService.exportAllData();
  }
}
