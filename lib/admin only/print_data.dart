// lib/admin only/print_data.dart

import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amde_haymanot_abalat_guday/providers/profile_config_provider.dart';

// --- Amharic Localization Strings for PDF ---
abstract class AmharicStringsPdf {
  static const String documentTitle = 'የአባላት መረጃ';
  static const String notSpecified = 'አልተገለጸም';
  static const String roles = 'ሚናዎች';
  static const String personalInfo = 'የግል መረጃ';
  static const String spiritualInfo = 'መንፈሳዊ መረጃ';
  static const String previousServiceHistory = 'ያለፈ የአገልግሎት ታሪክ';
  static const String familyParentInfo = 'የቤተሰብ / የወላጅ መረጃ';
  static const String additionalInfo = 'ተጨማሪ መረጃ';
}

class UserPdfGenerator {
  final Map<String, dynamic> userData;
  final Set<String> fieldsToInclude;
  final ProfileConfigProvider profileConfig;

  UserPdfGenerator({
    required this.userData,
    required this.fieldsToInclude,
    required this.profileConfig,
  });

  static const Map<String, String> _builtInLabels = {
    'full_name': 'ሙሉ ስም',
    'christian_name': 'የክርስትና ስም',
    'mother_name': 'የእናት ስም',
    'gender': 'ጾታ',
    'dob': 'የትውልድ ዘመን',
    'phone_number': 'ስልክ ቁጥር',
    'email': 'ኢሜይል',
    'spiritual_class': 'የትምህርት ክፍል',
    'confession_father_name': 'የንስሐ አባት ስም',
    'member_level': 'የአባልነት ደረጃ',
    'service_status': 'የአገልግሎት ሁኔታ',
    'service_assignment': 'የአገልግሎት ምድብ',
    'had_previous_service': 'ከዚህ በፊት አገልግለዋል?',
    'previous_department': 'ያገለገሉበት ክፍል',
    'previous_responsibility': 'ኃላፊነት',
    'previous_service_level': 'የአገልግሎት ደረጃ',
    'parent_name': 'የወላጅ ስም',
    'parent_phone_number': 'የወላጅ ስልክ',
  };

  Future<void> generateAndShowPdf() async {
    final doc = pw.Document();

    // Debug: Print what's in userData
    debugPrint('=== PDF Generation Debug ===');
    debugPrint('school_name: ${userData['school_name']}');
    debugPrint('school_logo_url: ${userData['school_logo_url']}');
    debugPrint('tenant_id: ${userData['tenant_id']}');
    debugPrint('All userData keys: ${userData.keys.toList()}');
    debugPrint('===========================');

    // Use NotoSansEthiopic fonts
    final notoTtf = await PdfGoogleFonts.notoSansEthiopicRegular();
    final notoTtfBold = await PdfGoogleFonts.notoSansEthiopicBold();

    // Robust Logo Loading Logic for Multi-Platform/Web
    Uint8List? logoBytes;
    List<String> possiblePaths = [
      'assets/images/logo.png', // Standard mobile
      'images/logo.png', // Web attempt 1
      'assets/logo.png', // Legacy path
    ];

    for (final path in possiblePaths) {
      try {
        await Future.delayed(Duration.zero);
        final ByteData data = await rootBundle.load(path);
        logoBytes = data.buffer.asUint8List();
        debugPrint('Successfully loaded logo from: $path');
        break;
      } catch (e) {
        debugPrint('Failed to load logo from $path');
      }
    }

    if (logoBytes == null) {
      // Transparent 1x1 pixel fallback
      logoBytes = Uint8List.fromList([
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
        0x00,
        0x00,
        0x00,
        0x0D,
        0x49,
        0x48,
        0x44,
        0x52,
        0x00,
        0x00,
        0x00,
        0x01,
        0x00,
        0x00,
        0x00,
        0x01,
        0x08,
        0x06,
        0x00,
        0x00,
        0x00,
        0x1F,
        0x15,
        0xC4,
        0x89,
        0x00,
        0x00,
        0x00,
        0x0A,
        0x49,
        0x44,
        0x41,
        0x54,
        0x78,
        0x9C,
        0x63,
        0x00,
        0x01,
        0x00,
        0x00,
        0x05,
        0x00,
        0x01,
        0x0D,
        0x0A,
        0x2D,
        0xB4,
        0x00,
        0x00,
        0x00,
        0x00,
        0x49,
        0x45,
        0x4E,
        0x44,
        0xAE,
        0x42,
        0x60,
        0x82
      ]);
    }

    final logoImage = pw.MemoryImage(logoBytes);

    // Load Sunday School Logo (from user's school)
    pw.MemoryImage? schoolLogoImage;
    if (userData['school_logo_url'] != null &&
        userData['school_logo_url'].toString().isNotEmpty) {
      try {
        final schoolLogoUrl = userData['school_logo_url'].toString();
        // If it's a relative path, prepend the base URL
        final fullSchoolLogoUrl = schoolLogoUrl.startsWith('http')
            ? schoolLogoUrl
            : '${ApiService.baseUrl.replaceAll('/api', '')}/$schoolLogoUrl';
        schoolLogoImage =
            (await networkImage(fullSchoolLogoUrl)) as pw.MemoryImage?;
        debugPrint('Successfully loaded school logo from: $fullSchoolLogoUrl');
      } catch (e) {
        debugPrint('Failed to load school logo: $e');
      }
    }

    pw.MemoryImage? userImage;
    if (userData['profile_image_url'] != null &&
        userData['profile_image_url'].toString().isNotEmpty) {
      final imageUrl =
          '${ApiService.baseUrl.replaceAll('/api', '')}/${userData['profile_image_url']}';
      try {
        userImage = (await networkImage(imageUrl)) as pw.MemoryImage?;
      } catch (e) {
        debugPrint("Could not fetch user image for PDF: $e");
      }
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          final fullName = userData['full_name']?.toString() ?? 'N/A';
          final email = userData['email']?.toString() ?? 'N/A';
          final roles = userData['role']?.toString() ?? 'user';
          final schoolName = userData['school_name']?.toString() ?? '';

          return [
            // Header with 3 sections: School Logo | Title | App Logo
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Left: School Logo (only if available)
                if (schoolLogoImage != null)
                  pw.Container(
                    width: 60,
                    height: 60,
                    child: pw.Image(schoolLogoImage, fit: pw.BoxFit.contain),
                  )
                else
                  pw.SizedBox(width: 60, height: 60), // Empty space if no logo

                // Center: Title and School Name
                pw.Expanded(
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        schoolName,
                        style: pw.TextStyle(
                          font: notoTtfBold,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        AmharicStringsPdf.documentTitle,
                        style: pw.TextStyle(
                          font: notoTtf,
                          fontSize: 14,
                          color: PdfColors.grey700,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Right: App Logo (Akilesiya)
                pw.Container(
                  width: 60,
                  height: 60,
                  child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                ),
              ],
            ),
            pw.Divider(thickness: 2),
            pw.SizedBox(height: 20),
            pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
              if (userImage != null)
                pw.ClipRRect(
                    horizontalRadius: 40,
                    verticalRadius: 40,
                    child: pw.Image(userImage,
                        width: 80, height: 80, fit: pw.BoxFit.cover))
              else
                pw.Container(
                    width: 80,
                    height: 80,
                    decoration: const pw.BoxDecoration(
                        color: PdfColors.grey, shape: pw.BoxShape.circle),
                    child: pw.Center(
                        child: pw.Text(fullName.isNotEmpty ? fullName[0] : '?',
                            style: const pw.TextStyle(
                                fontSize: 40, color: PdfColors.white)))),
              pw.SizedBox(width: 20),
              pw.Expanded(
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                    pw.Text(fullName,
                        style: pw.TextStyle(
                            font: notoTtfBold,
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5),
                    pw.Text(email,
                        style: pw.TextStyle(font: notoTtf, fontSize: 14)),
                    pw.SizedBox(height: 5),
                    pw.Text("${AmharicStringsPdf.roles}: $roles", // Translated
                        style: pw.TextStyle(
                            font: notoTtf,
                            fontSize: 12,
                            color: PdfColors.grey600)),
                  ])),
            ]),
            pw.SizedBox(height: 30),
            _buildPdfSection(
              title: AmharicStringsPdf.personalInfo, // Translated
              sectionKeys: [
                'full_name',
                'christian_name',
                'mother_name',
                'gender',
                'dob',
                'phone_number',
                'email'
              ],
              baseFont: notoTtf,
              boldFont: notoTtfBold,
            ),
            _buildPdfSection(
              title: AmharicStringsPdf.spiritualInfo, // Translated
              sectionKeys: [
                'spiritual_class',
                'confession_father_name',
                'member_level',
                'service_status',
                'service_assignment'
              ],
              baseFont: notoTtf,
              boldFont: notoTtfBold,
            ),
            if (userData['had_previous_service'] == 1)
              _buildPdfSection(
                title: AmharicStringsPdf.previousServiceHistory, // Translated
                sectionKeys: [
                  'previous_department',
                  'previous_responsibility',
                  'previous_service_level'
                ],
                baseFont: notoTtf,
                boldFont: notoTtfBold,
              ),
            _buildPdfSection(
              title: AmharicStringsPdf.familyParentInfo, // Translated
              sectionKeys: ['parent_name', 'parent_phone_number'],
              baseFont: notoTtf,
              boldFont: notoTtfBold,
            ),
            _buildCustomFieldsPdfSection(
                baseFont: notoTtf, boldFont: notoTtfBold),
          ];
        },
      ),
    );
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }

  pw.Widget _buildPdfSection({
    required String title,
    required List<String> sectionKeys,
    required pw.Font baseFont,
    required pw.Font boldFont,
  }) {
    final Map<String, String> sectionData = {};
    for (var key in sectionKeys) {
      if (fieldsToInclude.contains(key)) {
        var value = userData[key];
        if (key == 'dob' && value != null) {
          try {
            value = DateFormat.yMMMd().format(DateTime.parse(value.toString()));
          } catch (e) {/* ignore date parsing errors */}
        }
        sectionData[_builtInLabels[key] ?? key] =
            value?.toString().isNotEmpty == true
                ? value.toString()
                : AmharicStringsPdf.notSpecified; // Translated
      }
    }

    if (sectionData.isEmpty) return pw.SizedBox.shrink();

    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex("#012564"))),
          pw.Divider(height: 8),
          pw.SizedBox(height: 5),
          ...sectionData.entries.map((entry) => _buildPdfRow(
              label: entry.key, value: entry.value, baseFont: baseFont)),
          pw.SizedBox(height: 20),
        ]);
  }

  // =======================================================
  // --- THE DEFINITIVE FIX IS HERE (with Translation) ---
  // =======================================================
  pw.Widget _buildCustomFieldsPdfSection(
      {required pw.Font baseFont, required pw.Font boldFont}) {
    // 1. Safely cast the incoming data to a List<dynamic>.
    final customFieldsList = userData['custom_fields'] as List<dynamic>? ?? [];
    if (customFieldsList.isEmpty) return pw.SizedBox.shrink();

    final Map<String, String> customData = {};

    // 2. Iterate through the definitions from the provider.
    for (var fieldDef in profileConfig.customFields) {
      final fieldKey = 'custom_${fieldDef['id']}';

      // 3. Check if this field was selected by the admin.
      if (fieldsToInclude.contains(fieldKey)) {
        String displayValue = AmharicStringsPdf.notSpecified; // Translated

        // 4. Find the matching field in the user's data list by its name.
        try {
          final savedField = customFieldsList.firstWhere(
            (f) => f['fieldName'] == fieldDef['name'],
            orElse: () => null,
          );
          if (savedField != null) {
            displayValue = savedField['optionValue'] ??
                AmharicStringsPdf.notSpecified; // Translated
          }
        } catch (e) {/* ignore find errors */}

        customData[fieldDef['name']] = displayValue;
      }
    }

    if (customData.isEmpty) return pw.SizedBox.shrink();

    // 5. Build the PDF section using the dynamically created map.
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(AmharicStringsPdf.additionalInfo, // Translated
              style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex("#012564"))),
          pw.Divider(height: 8),
          pw.SizedBox(height: 5),
          ...customData.entries.map((entry) => _buildPdfRow(
              label: entry.key, value: entry.value, baseFont: baseFont)),
          pw.SizedBox(height: 20),
        ]);
  }

  pw.Widget _buildPdfRow(
      {required String label,
      required String value,
      required pw.Font baseFont}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$label:',
              style: pw.TextStyle(font: baseFont, color: PdfColors.grey700)),
          pw.SizedBox(width: 20),
          pw.Expanded(
            child: pw.Text(
              value,
              style:
                  pw.TextStyle(font: baseFont, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
