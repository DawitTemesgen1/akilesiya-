// lib/admin only/customize_profile_view_screen.dart

import 'package:amde_haymanot_abalat_guday/services/user_admin_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor = Color.fromARGB(255, 1, 37, 100);
const Color successColor = Color(0xFF198754);
const Color dangerColor = Color(0xFFDC3545);

// --- Master Configuration (keys remain in English for backend mapping) ---
class ProfileWidgetConfig {
  final String key;
  final String title; // English title as a fallback/key
  final String subtitle;
  ProfileWidgetConfig(
      {required this.key, required this.title, required this.subtitle});
}

final List<ProfileWidgetConfig> allProfileWidgets = [
  ProfileWidgetConfig(
      key: 'christian_name',
      title: 'Christian Name',
      subtitle: 'The user\'s spiritual name.'),
  ProfileWidgetConfig(
      key: 'confession_father',
      title: 'Confession Father',
      subtitle: 'Name of the user\'s spiritual father.'),
  ProfileWidgetConfig(
      key: 'mother_name', title: 'Mother\'s Name', subtitle: ''),
  ProfileWidgetConfig(key: 'gender', title: 'Gender', subtitle: ''),
  ProfileWidgetConfig(key: 'age', title: 'Age', subtitle: ''),
  ProfileWidgetConfig(
      key: 'academic_level',
      title: 'Academic Level',
      subtitle: 'e.g., High School, University'),
  ProfileWidgetConfig(
      key: 'spiritual_class',
      title: 'Spiritual Class',
      subtitle: 'The user\'s current spiritual grade.'),
  ProfileWidgetConfig(
      key: 'kifil',
      title: 'Kifil',
      subtitle: 'The user\'s local group or "Kifil".'),
];

// --- Amharic Translations Map ---
const Map<String, Map<String, String>> _widgetTranslations = {
  'christian_name': {
    'title': 'የክርስትና ስም',
    'subtitle': 'የተጠቃሚው መንፈሳዊ ስም።',
  },
  'confession_father': {
    'title': 'የንስሐ አባት',
    'subtitle': 'የተጠቃሚው የንስሐ አባት ስም።',
  },
  'mother_name': {
    'title': 'የእናት ስም',
    'subtitle': '',
  },
  'gender': {
    'title': 'ጾታ',
    'subtitle': '',
  },
  'age': {
    'title': 'ዕድሜ',
    'subtitle': '',
  },
  'academic_level': {
    'title': 'የትምህርት ደረጃ',
    'subtitle': 'ለምሳሌ፦ ሁለተኛ ደረጃ፣ ዩኒቨርሲቲ',
  },
  'spiritual_class': {
    'title': 'የመንፈሳዊ ትምህርት ክፍል',
    'subtitle': 'የተጠቃሚው የአሁኑ መንፈሳዊ ክፍል።',
  },
  'kifil': {
    'title': 'ክፍል',
    'subtitle': 'የተጠቃሚው የአካባቢ ቡድን ወይም "ክፍል"።',
  },
};

class CustomizeProfileViewScreen extends StatefulWidget {
  const CustomizeProfileViewScreen({super.key});

  @override
  State<CustomizeProfileViewScreen> createState() =>
      _CustomizeProfileViewScreenState();
}

class _CustomizeProfileViewScreenState
    extends State<CustomizeProfileViewScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  Map<String, bool> _visibilitySettings = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final result = await UserAdminService.getProfileSettings();
    if (result['success'] == true && mounted) {
      setState(() {
        _visibilitySettings = Map<String, bool>.from(result['data']);
        _isLoading = false;
      });
    } else {
      // Production recommendation: Implement robust error handling
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? 'ቅንብሮችን መጫን አልተቻለም።'),
          backgroundColor: dangerColor,
        ));
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    final result =
        await UserAdminService.updateProfileSettings(_visibilitySettings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'ስህተት ተፈጥሯል።'),
        backgroundColor: result['success'] == true ? successColor : dangerColor,
      ));
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('የመገለጫ እይታን አብጅ', style: GoogleFonts.notoSansEthiopic()),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveSettings,
            tooltip: 'ቅንብሮችን አስቀምጥ',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: allProfileWidgets.length,
              itemBuilder: (context, index) {
                final widgetConfig = allProfileWidgets[index];
                final translations = _widgetTranslations[widgetConfig.key];
                final isVisible = _visibilitySettings[widgetConfig.key] ?? true;

                return SwitchListTile(
                  title: Text(
                    translations?['title'] ?? widgetConfig.title,
                    style: GoogleFonts.notoSansEthiopic(),
                  ),
                  subtitle: (translations?['subtitle'] ?? widgetConfig.subtitle)
                          .isNotEmpty
                      ? Text(
                          translations?['subtitle'] ?? widgetConfig.subtitle,
                          style: GoogleFonts.notoSansEthiopic(),
                        )
                      : null,
                  value: isVisible,
                  onChanged: (bool value) {
                    setState(() {
                      _visibilitySettings[widgetConfig.key] = value;
                    });
                  },
                );
              },
            ),
    );
  }
}
