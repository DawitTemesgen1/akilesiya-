// lib/admin only/profile_template_builder_screen.dart

import 'package:amde_haymanot_abalat_guday/services/template_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

// --- Colors ---
const Color primaryColor = Color.fromARGB(255, 1, 37, 100);
const Color dangerColor = Color(0xFFDC3545);
const Color successColor = Color(0xFF198754);

// --- Translation Maps ---
const Map<String, String> _managedByTranslations = {
  'ADMIN': 'አስተዳዳሪ ብቻ',
  'USER': 'ተጠቃሚ',
};

const Map<String, String> _profileTabTranslations = {
  'PERSONAL': 'የግል',
  'SPIRITUAL': 'መንፈሳዊ',
  'FAMILY': 'ቤተሰብ',
  'EDUCATION': 'ትምህርት',
};

class ProfileTemplateBuilderScreen extends StatefulWidget {
  const ProfileTemplateBuilderScreen({super.key});
  @override
  State<ProfileTemplateBuilderScreen> createState() =>
      _ProfileTemplateBuilderScreenState();
}

class _ProfileTemplateBuilderScreenState
    extends State<ProfileTemplateBuilderScreen> {
  late Future<List<dynamic>> _fieldsFuture;

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  void _loadFields() {
    setState(() {
      _fieldsFuture = TemplateService.getCustomFields().then((res) {
        if (res['success'] == true) return res['data'] ?? [];
        throw Exception(res['message'] ?? 'መስኮችን መጫን አልተቻለም።');
      });
    });
  }

  void _handleApiResponse(Map<String, dynamic> result,
      {BuildContext? dialogContext}) {
    if (!mounted) return;
    final wasSuccessful = result['success'] ?? false;
    final message = result['message'] ??
        (wasSuccessful ? 'ክንውኑ በተሳካ ሁኔታ ተጠናቋል!' : 'ያልታወቀ ስህተት ተፈጥሯል።');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: wasSuccessful ? successColor : dangerColor));
    if (wasSuccessful) {
      _loadFields();
      if (dialogContext != null) Navigator.of(dialogContext).pop();
    }
  }

  void _showAddFieldDialog() {
    final nameController = TextEditingController();
    String managedBy = 'ADMIN';
    String profileTab = 'PERSONAL'; // Default tab

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: Text('አዲስ ብጁ መስክ ይፍጠሩ', style: GoogleFonts.notoSansEthiopic()),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(
                    labelText: 'የመስክ ስም',
                    labelStyle: GoogleFonts.notoSansEthiopic())),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: managedBy,
              decoration: InputDecoration(
                  labelText: 'ይህን መስክ ማስተካከል የሚችለው ማን ነው?',
                  labelStyle: GoogleFonts.notoSansEthiopic()),
              items: _managedByTranslations.entries
                  .map((e) => DropdownMenuItem(
                      value: e.key,
                      child:
                          Text(e.value, style: GoogleFonts.notoSansEthiopic())))
                  .toList(),
              onChanged: (value) => setDialogState(() => managedBy = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: profileTab,
              decoration: InputDecoration(
                  labelText: 'በየትኛው የመገለጫ ትር ላይ ይታይ?',
                  labelStyle: GoogleFonts.notoSansEthiopic()),
              items: _profileTabTranslations.entries
                  .map((e) => DropdownMenuItem(
                      value: e.key,
                      child:
                          Text(e.value, style: GoogleFonts.notoSansEthiopic())))
                  .toList(),
              onChanged: (value) => setDialogState(() => profileTab = value!),
            ),
          ]),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('ይቅር', style: GoogleFonts.notoSansEthiopic())),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                final result = await TemplateService.createCustomField(
                    nameController.text.trim(), managedBy, profileTab);
                _handleApiResponse(result, dialogContext: ctx);
              },
              child: Text('ፍጠር', style: GoogleFonts.notoSansEthiopic()),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptionDialog(dynamic field) {
    _showEditDialog(
      title: 'ለ"${field['name']}" አማራጭ ያክሉ',
      label: 'የአማራጭ ስም',
      onSave: (value) async {
        final result =
            await TemplateService.createFieldOption(field['id'], value);
        _handleApiResponse(result, dialogContext: context);
      },
      parentCtx: context,
    );
  }

  void _deleteField(int fieldId) async {
    final result = await TemplateService.deleteCustomField(fieldId);
    _handleApiResponse(result);
  }

  void _deleteOption(int optionId) async {
    final result = await TemplateService.deleteFieldOption(optionId);
    _handleApiResponse(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text('የመገለጫ አብነት ግንባታ', style: GoogleFonts.notoSansEthiopic())),
      body: FutureBuilder<List<dynamic>>(
        future: _fieldsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("ስህተት: ${snapshot.error}"));
          }
          final fields = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async => _loadFields(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: fields.length,
              itemBuilder: (context, index) {
                final field = fields[index];
                final options = field['options'] as List<dynamic>? ?? [];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 6.0, horizontal: 8.0),
                  child: ExpansionTile(
                    leading: Icon(
                        field['managed_by'] == 'ADMIN'
                            ? Iconsax.security_user
                            : Iconsax.user,
                        color: primaryColor),
                    title: Text(field['name'],
                        style: GoogleFonts.notoSansEthiopic(
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'ትር: ${_profileTabTranslations[field['profile_tab']] ?? field['profile_tab']} | የሚስተካከለው በ: ${_managedByTranslations[field['managed_by']] ?? field['managed_by']}',
                        style: GoogleFonts.notoSansEthiopic()),
                    trailing: IconButton(
                        icon: const Icon(Iconsax.trash, color: dangerColor),
                        onPressed: () => _deleteField(field['id'])),
                    children: [
                      ...options.map((opt) => ListTile(
                            title: Text(opt['option_value'],
                                style: GoogleFonts.notoSansEthiopic()),
                            trailing: IconButton(
                                icon: const Icon(Iconsax.close_circle,
                                    color: Colors.grey),
                                onPressed: () => _deleteOption(opt['id'])),
                          )),
                      TextButton.icon(
                          icon: const Icon(Iconsax.add),
                          label: Text('አማራጭ ያክሉ',
                              style: GoogleFonts.notoSansEthiopic()),
                          onPressed: () => _showAddOptionDialog(field)),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _showAddFieldDialog, child: const Icon(Iconsax.add)),
    );
  }

  void _showEditDialog(
      {required String title,
      required String label,
      required Function(String) onSave,
      BuildContext? parentCtx}) {
    final controller = TextEditingController();
    showDialog(
        context: parentCtx ?? context,
        builder: (ctx) => AlertDialog(
              title: Text(title, style: GoogleFonts.notoSansEthiopic()),
              content: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                      labelText: label,
                      labelStyle: GoogleFonts.notoSansEthiopic())),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text('ይቅር', style: GoogleFonts.notoSansEthiopic())),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      onSave(controller.text.trim());
                    }
                  },
                  child: Text('አስቀምጥ', style: GoogleFonts.notoSansEthiopic()),
                ),
              ],
            ));
  }
}
