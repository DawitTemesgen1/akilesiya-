import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
// If HTTP package is needed for image fetching in PDF
import 'package:http/http.dart' as http;

class UserDataPrintPreview extends StatelessWidget {
  final Map<String, dynamic> user;
  final List<dynamic> customFields;
  final Uint8List appLogoBytes; // Preloaded bytes

  const UserDataPrintPreview({
    Key? key,
    required this.user,
    required this.customFields,
    required this.appLogoBytes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('የህትመት ቅድመ እይታ (Print Preview)',
            style: GoogleFonts.notoSansEthiopic()),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printPdf(context),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) =>
            _generatePdf(format, user, customFields, appLogoBytes),
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }

  Future<void> _printPdf(BuildContext context) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async =>
          _generatePdf(format, user, customFields, appLogoBytes),
    );
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format,
      Map<String, dynamic> user,
      List<dynamic> customFields,
      Uint8List appLogoBytes) async {
    final pdf = pw.Document();

    // 1. Load Fonts
    final ttf =
        await fontFromAssetBundle('assets/fonts/NotoSansEthiopic-Regular.ttf');

    // 2. Load Logos
    // (A) App Logo (Akilesiya) - From Bytes
    final appLogoImage = pw.MemoryImage(appLogoBytes);

    // (B) School Logo (Sunday School / Tenant Logo)
    pw.ImageProvider? schoolLogoProvider;

    try {
      if (user['school_logo_url'] != null &&
          user['school_logo_url'].toString().isNotEmpty) {
        final response = await http.get(Uri.parse(user['school_logo_url']));
        if (response.statusCode == 200) {
          schoolLogoProvider = pw.MemoryImage(response.bodyBytes);
        }
      }
    } catch (e) {
      debugPrint('Error loading school logo for PDF: $e');
    }

    // Fallback if no specific logo found
    schoolLogoProvider ??= appLogoImage;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- HEADER WITH LOGOS ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Sunday School / School Logo
                  pw.Container(
                    width: 60,
                    height: 60,
                    child: pw.Image(schoolLogoProvider!),
                  ),

                  // Center: Title
                  pw.Column(
                    children: [
                      pw.Text(
                        user['school_name'] ?? 'Sunday School',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'የአባል መረጃ ቅጽ (Member Data Form)',
                        style: pw.TextStyle(font: ttf, fontSize: 14),
                      ),
                    ],
                  ),

                  // Right: App / Akilesiya Logo
                  pw.Container(
                    width: 60,
                    height: 60,
                    child: pw.Image(appLogoImage),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // --- USER INFORMATION ---
              _buildPdfInfoRow('ሙሉ ስም (Full Name)', user['full_name'], ttf),
              _buildPdfInfoRow('ኢሜይል (Email)', user['email'], ttf),
              _buildPdfInfoRow('ስልክ (Phone)', user['phone_number'], ttf),
              _buildPdfInfoRow('እድሜ (Age)', user['age']?.toString() ?? '', ttf),
              _buildPdfInfoRow('ጾታ (Gender)', user['gender'] ?? '', ttf),
              _buildPdfInfoRow(
                  'የትምህርት ደረጃ (Academic Level)', user['academic_level'], ttf),
              pw.SizedBox(height: 10),

              // --- SPIRITUAL INFO ---
              pw.Text('መንፈሳዊ መረጃ',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Divider(thickness: 0.5),
              _buildPdfInfoRow(
                  'የክርስትና ስም (Christian Name)', user['christian_name'], ttf),
              _buildPdfInfoRow(
                  'የንስሐ አባት (Confessor)', user['confession_father_name'], ttf),
              _buildPdfInfoRow(
                  'የአገልግሎት ክፍል (Ministry)', user['ministry_department'], ttf),
              pw.SizedBox(height: 10),

              // --- CUSTOM FIELDS ---
              if (customFields.isNotEmpty) ...[
                pw.Text('ተጨማሪ መረጃዎች',
                    style: pw.TextStyle(
                        font: ttf,
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold)),
                pw.Divider(thickness: 0.5),
                ...customFields.map((field) {
                  return _buildPdfInfoRow(
                    field['field_name'] ?? 'Field',
                    field['selected_value'] ?? '-',
                    ttf,
                  );
                }).toList(),
              ],

              pw.Spacer(),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Generated by Akilesiya',
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                  pw.Text(DateTime.now().toString().split('.')[0],
                      style: pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                ],
              )
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfInfoRow(String label, String? value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value ?? '-',
              style: pw.TextStyle(font: font),
            ),
          ),
        ],
      ),
    );
  }
}
