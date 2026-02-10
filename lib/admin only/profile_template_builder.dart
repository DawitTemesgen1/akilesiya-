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

const Map<String, String> _fieldTypeTranslations = {
  'TEXT': 'የጽሑፍ መስክ (Text)',
  'TEXTAREA': 'ረጅም ጽሑፍ (Text Area)',
  'NUMBER': 'ቁጥር (Number)',
  'EMAIL': 'ኢሜይል (Email)',
  'PHONE': 'ስልክ (Phone)',
  'URL': 'ድረ-ገጽ (URL)',
  'DATE': 'ቀን (Date)',
  'TIME': 'ሰዓት (Time)',
  'DATETIME': 'ቀን እና ሰዓት (Date & Time)',
  'DROPDOWN': 'የምርጫ ዝርዝር (Dropdown)',
  'MULTISELECT': 'ብዙ ምርጫ (Multi-Select)',
  'RADIO': 'አንድ ምርጫ (Radio Buttons)',
  'CHECKBOX': 'ምልክት ማድረጊያ (Checkboxes)',
  'FILE': 'ፋይል (File Upload)',
  'IMAGE': 'ምስል (Image Upload)',
  'LOCATION': 'ቦታ (Location Picker)',
  'PRICE': 'ዋጋ (Price)',
  'CURRENCY': 'ምንዛሬ (Currency)',
  'TOGGLE': 'አዎ/አይ (Yes/No Toggle)',
  'VOTE': 'የድምፅ መስጫ (Vote/Rating)',
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
      if (dialogContext != null && dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }
    }
  }

  void _showAddFieldDialog() {
    final nameController = TextEditingController();
    final optionController = TextEditingController();
    String managedBy = 'USER';
    String profileTab = 'PERSONAL';
    String fieldType = 'TEXT';
    List<String> draftOptions = [];
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: Text('አዲስ ብጁ መስክ ይፍጠሩ', style: GoogleFonts.notoSansEthiopic()),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                      labelText: 'የመስክ ስም',
                      labelStyle: GoogleFonts.notoSansEthiopic())),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: managedBy,
                decoration: InputDecoration(
                    labelText: 'ይህን መስክ ማስተካከል የሚችለው ማን ነው?',
                    labelStyle: GoogleFonts.notoSansEthiopic()),
                items: _managedByTranslations.entries
                    .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value,
                            style: GoogleFonts.notoSansEthiopic())))
                    .toList(),
                onChanged: (value) => setDialogState(() => managedBy = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: profileTab,
                decoration: InputDecoration(
                    labelText: 'በየትኛው የመገለጫ ትር ላይ ይታይ?',
                    labelStyle: GoogleFonts.notoSansEthiopic()),
                items: _profileTabTranslations.entries
                    .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value,
                            style: GoogleFonts.notoSansEthiopic())))
                    .toList(),
                onChanged: (value) => setDialogState(() => profileTab = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: fieldType,
                decoration: InputDecoration(
                    labelText: 'የመስክ ዓይነት (Field Type)',
                    labelStyle: GoogleFonts.notoSansEthiopic()),
                items: _fieldTypeTranslations.entries
                    .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value,
                            style: GoogleFonts.notoSansEthiopic())))
                    .toList(),
                onChanged: (value) => setDialogState(() => fieldType = value!),
              ),
              if (['DROPDOWN', 'MULTISELECT', 'RADIO', 'CHECKBOX', 'VOTE']
                  .contains(fieldType)) ...[
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                      child: Text('አማራጮች (Options)',
                          style: GoogleFonts.notoSansEthiopic(
                              fontWeight: FontWeight.bold))),
                ]),
                const Divider(),
                ...draftOptions.asMap().entries.map((entry) => ListTile(
                      title: Text(entry.value,
                          style: GoogleFonts.notoSansEthiopic()),
                      trailing: IconButton(
                          icon: const Icon(Icons.remove_circle,
                              color: dangerColor),
                          onPressed: () => setDialogState(
                              () => draftOptions.removeAt(entry.key))),
                    )),
                Row(children: [
                  Expanded(
                    child: TextField(
                        controller: optionController,
                        decoration: InputDecoration(
                            labelText: 'አዲስ አማራጭ',
                            labelStyle: GoogleFonts.notoSansEthiopic())),
                  ),
                  IconButton(
                      icon: const Icon(Icons.add_circle, color: successColor),
                      onPressed: () {
                        if (optionController.text.trim().isNotEmpty) {
                          setDialogState(() =>
                              draftOptions.add(optionController.text.trim()));
                          optionController.clear();
                        }
                      }),
                ]),
              ],
            ]),
          ),
          actions: [
            TextButton(
                onPressed: isSubmitting ? null : () => Navigator.of(ctx).pop(),
                child: Text('ይቅር', style: GoogleFonts.notoSansEthiopic())),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty) return;
                      setDialogState(() => isSubmitting = true);
                      try {
                        final result = await TemplateService.createCustomField(
                            nameController.text.trim(),
                            managedBy,
                            profileTab,
                            fieldType);

                        if (result['success'] == true) {
                          final fieldId = int.tryParse(
                                  result['data']?['id']?.toString() ?? '0') ??
                              0;
                          if (fieldId != 0 && draftOptions.isNotEmpty) {
                            for (var opt in draftOptions) {
                              await TemplateService.createFieldOption(
                                  fieldId, opt);
                            }
                          }
                        }

                        _handleApiResponse(result, dialogContext: ctx);
                      } finally {
                        if (dialogCtx.mounted) {
                          setDialogState(() => isSubmitting = false);
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('ፍጠር', style: GoogleFonts.notoSansEthiopic()),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFieldDialog(dynamic field) {
    final nameController = TextEditingController(text: field['name']);
    final optionController = TextEditingController();
    String managedBy = field['managed_by'] ?? 'ADMIN';
    String profileTab = field['profile_tab'] ?? 'PERSONAL';
    String fieldType = field['field_type'] ?? 'TEXT';
    List<dynamic> existingOptions = List.from(field['options'] ?? []);
    List<String> draftOptions = [];
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: Text('መስኩን ያስተካክሉ', style: GoogleFonts.notoSansEthiopic()),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                      labelText: 'የመስክ ስም',
                      labelStyle: GoogleFonts.notoSansEthiopic())),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: managedBy,
                decoration: InputDecoration(
                    labelText: 'ይህን መስክ ማስተካከል የሚችለው ማን ነው?',
                    labelStyle: GoogleFonts.notoSansEthiopic()),
                items: _managedByTranslations.entries
                    .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value,
                            style: GoogleFonts.notoSansEthiopic())))
                    .toList(),
                onChanged: (value) => setDialogState(() => managedBy = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: profileTab,
                decoration: InputDecoration(
                    labelText: 'በየትኛው የመገለጫ ትር ላይ ይታይ?',
                    labelStyle: GoogleFonts.notoSansEthiopic()),
                items: _profileTabTranslations.entries
                    .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value,
                            style: GoogleFonts.notoSansEthiopic())))
                    .toList(),
                onChanged: (value) => setDialogState(() => profileTab = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: fieldType,
                decoration: InputDecoration(
                    labelText: 'የመስክ ዓይነት (Field Type)',
                    labelStyle: GoogleFonts.notoSansEthiopic()),
                items: _fieldTypeTranslations.entries
                    .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value,
                            style: GoogleFonts.notoSansEthiopic())))
                    .toList(),
                onChanged: (value) => setDialogState(() => fieldType = value!),
              ),
              if (['DROPDOWN', 'MULTISELECT', 'RADIO', 'CHECKBOX', 'VOTE']
                  .contains(fieldType)) ...[
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                      child: Text('አማራጮች (Options)',
                          style: GoogleFonts.notoSansEthiopic(
                              fontWeight: FontWeight.bold))),
                ]),
                const Divider(),
                ...existingOptions.map((opt) => ListTile(
                      title: Text(opt['option_value'] ?? '',
                          style: GoogleFonts.notoSansEthiopic()),
                      trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: dangerColor),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: Text('አማራጩ ይጥፋ?',
                                    style: GoogleFonts.notoSansEthiopic()),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(c, false),
                                      child: Text('ይቅር',
                                          style:
                                              GoogleFonts.notoSansEthiopic())),
                                  TextButton(
                                      onPressed: () => Navigator.pop(c, true),
                                      child: Text('አጥፋ',
                                          style: GoogleFonts.notoSansEthiopic(
                                              color: dangerColor))),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              final res =
                                  await TemplateService.deleteFieldOption(
                                      opt['id']);
                              if (res['success'] == true) {
                                setDialogState(() => existingOptions
                                    .removeWhere((o) => o['id'] == opt['id']));
                                _loadFields();
                              }
                            }
                          }),
                    )),
                ...draftOptions.asMap().entries.map((entry) => ListTile(
                      title: Text(entry.value,
                          style:
                              GoogleFonts.notoSansEthiopic(color: Colors.blue)),
                      subtitle: Text('አዲስ አማራጭ',
                          style: GoogleFonts.notoSansEthiopic(fontSize: 10)),
                      trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: dangerColor),
                          onPressed: () => setDialogState(
                              () => draftOptions.removeAt(entry.key))),
                    )),
                Row(children: [
                  Expanded(
                    child: TextField(
                        controller: optionController,
                        decoration: InputDecoration(
                            labelText: 'አዲስ አማራጭ ያክሉ',
                            labelStyle: GoogleFonts.notoSansEthiopic())),
                  ),
                  IconButton(
                      icon: const Icon(Icons.add_circle, color: successColor),
                      onPressed: () {
                        if (optionController.text.trim().isNotEmpty) {
                          setDialogState(() =>
                              draftOptions.add(optionController.text.trim()));
                          optionController.clear();
                        }
                      }),
                ]),
              ],
            ]),
          ),
          actions: [
            TextButton(
                onPressed: isSubmitting ? null : () => Navigator.of(ctx).pop(),
                child: Text('ይቅር', style: GoogleFonts.notoSansEthiopic())),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty) return;
                      setDialogState(() => isSubmitting = true);
                      try {
                        final result = await TemplateService.updateCustomField(
                            int.tryParse(field['id'].toString()) ?? 0,
                            nameController.text.trim(),
                            managedBy,
                            profileTab,
                            fieldType);

                        if (result['success'] == true) {
                          final fieldId =
                              int.tryParse(field['id'].toString()) ?? 0;
                          if (draftOptions.isNotEmpty) {
                            for (var opt in draftOptions) {
                              await TemplateService.createFieldOption(
                                  fieldId, opt);
                            }
                          }
                        }

                        _handleApiResponse(result, dialogContext: ctx);
                      } finally {
                        if (dialogCtx.mounted) {
                          setDialogState(() => isSubmitting = false);
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('አስቀምጥ', style: GoogleFonts.notoSansEthiopic()),
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
      onSave: (value, dialogCtx) async {
        final fieldId = int.tryParse(field['id'].toString()) ?? 0;
        final result = await TemplateService.createFieldOption(fieldId, value);
        _handleApiResponse(result, dialogContext: dialogCtx);
      },
      parentCtx: context,
    );
  }

  void _deleteField(dynamic id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('መስኩ ይጥፋ?', style: GoogleFonts.notoSansEthiopic()),
        content: Text('ይህን መስክ መሰረዝ በእርግጠኝነት ይፈልጋሉ? ይህ ተግባር ሊመለስ አይችልም።',
            style: GoogleFonts.notoSansEthiopic()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('ይቅር', style: GoogleFonts.notoSansEthiopic())),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('አጥፋ',
                  style: GoogleFonts.notoSansEthiopic(color: dangerColor))),
        ],
      ),
    );

    if (confirmed == true) {
      final fieldId = int.tryParse(id.toString()) ?? 0;
      final result = await TemplateService.deleteCustomField(fieldId);
      _handleApiResponse(result);
    }
  }

  void _deleteOption(dynamic id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('አማራጩ ይጥፋ?', style: GoogleFonts.notoSansEthiopic()),
        content: Text('ይህን አማራጭ መሰረዝ በእርግጠኝነት ይፈልጋሉ?',
            style: GoogleFonts.notoSansEthiopic()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('ይቅር', style: GoogleFonts.notoSansEthiopic())),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('አጥፋ',
                  style: GoogleFonts.notoSansEthiopic(color: dangerColor))),
        ],
      ),
    );

    if (confirmed == true) {
      final optionId = int.tryParse(id.toString()) ?? 0;
      final result = await TemplateService.deleteFieldOption(optionId);
      _handleApiResponse(result);
    }
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
                debugPrint('DEBUG: field data: $field');
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'ትር: ${_profileTabTranslations[field['profile_tab']?.toString().toUpperCase()] ?? field['profile_tab']} | የሚስተካከለው በ: ${_managedByTranslations[field['managed_by']?.toString().toUpperCase()] ?? field['managed_by']}',
                            style: GoogleFonts.notoSansEthiopic(fontSize: 12)),
                        Text(
                            'ዓይነት: ${_fieldTypeTranslations[field['field_type']?.toString().toUpperCase()] ?? field['field_type'] ?? 'ያልታወቀ'}',
                            style: GoogleFonts.notoSansEthiopic(
                                fontSize: 12, color: Colors.blueGrey)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: const Icon(Iconsax.edit, color: primaryColor),
                            onPressed: () => _showEditFieldDialog(field)),
                        IconButton(
                            icon: const Icon(Iconsax.trash, color: dangerColor),
                            onPressed: () => _deleteField(field['id'])),
                      ],
                    ),
                    children: [
                      ...options.map((opt) => ListTile(
                            title: Text(opt['option_value'],
                                style: GoogleFonts.notoSansEthiopic()),
                            trailing: IconButton(
                                icon: const Icon(Iconsax.close_circle,
                                    color: Colors.grey),
                                onPressed: () => _deleteOption(opt['id'])),
                          )),
                      if ([
                        'DROPDOWN',
                        'MULTISELECT',
                        'RADIO',
                        'CHECKBOX',
                        'VOTE'
                      ].contains(field['field_type']?.toString().toUpperCase()))
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
      required Function(String, BuildContext) onSave,
      BuildContext? parentCtx}) {
    final controller = TextEditingController();
    bool isSaving = false;

    showDialog(
        context: parentCtx ?? context,
        builder: (ctx) => StatefulBuilder(
              builder: (dialogCtx, setDialogState) => AlertDialog(
                title: Text(title, style: GoogleFonts.notoSansEthiopic()),
                content: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                        labelText: label,
                        labelStyle: GoogleFonts.notoSansEthiopic())),
                actions: [
                  TextButton(
                      onPressed:
                          isSaving ? null : () => Navigator.of(ctx).pop(),
                      child:
                          Text('ይቅር', style: GoogleFonts.notoSansEthiopic())),
                  ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (controller.text.trim().isNotEmpty) {
                              setDialogState(() => isSaving = true);
                              try {
                                await onSave(controller.text.trim(), ctx);
                              } finally {
                                if (dialogCtx.mounted) {
                                  setDialogState(() => isSaving = false);
                                }
                              }
                            }
                          },
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text('አስቀምጥ', style: GoogleFonts.notoSansEthiopic()),
                  ),
                ],
              ),
            ));
  }
}
