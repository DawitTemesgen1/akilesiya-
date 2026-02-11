import 'dart:developer' as developer;
import 'package:amde_haymanot_abalat_guday/providers/profile_config_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/profile_service.dart';
import 'package:amde_haymanot_abalat_guday/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';

import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// AppTheme import removed
// Colors removed, using Theme.of(context) instead

// Spiritual class options (from grade management)
const List<String> spiritualClassOptions = [
  '1ኛ ክፍል',
  '2ኛ ክፍል',
  '3ኛ ክፍል',
  '4ኛ ክፍል',
  '5ኛ ክፍል',
  '6ኛ ክፍል',
  '7ኛ ክፍል',
  '8ኛ ክፍል',
  '9ኛ ክፍል',
  '10ኛ ክፍል',
  '11ኛ ክፍል',
  '12ኛ ክፍል'
];

class UserEditProfileScreen extends StatefulWidget {
  const UserEditProfileScreen({super.key});
  @override
  State<UserEditProfileScreen> createState() => _UserEditProfileScreenState();
}

class _UserEditProfileScreenState extends State<UserEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isInitialized = false;

  late TextEditingController _fullNameController;
  late TextEditingController _christianNameController;
  late TextEditingController _phoneController;
  late TextEditingController _motherNameController;
  late TextEditingController _confessionFatherController;
  late TextEditingController _academicLevelController;
  late TextEditingController _kifilController;
  late TextEditingController _parentNameController;
  late TextEditingController _parentPhoneController;
  String? _gender;
  DateTime? _dob;
  String? _spiritualClass;
  Map<String, String?> _selectedCustomFieldValues = {};
  List<dynamic> _localCustomFields = [];
  bool _isLoadingFields = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeState();
    });
  }

  Future<void> _initializeState() async {
    // Force fetch config to ensure we have the latest fields (and retry if prev failed)
    context.read<ProfileConfigProvider>().fetchConfig();

    final profile = context.read<UserProvider>().userProfile;
    if (profile == null) return;

    // 1. Setup Controllers
    _fullNameController = TextEditingController(text: profile['full_name']);
    _christianNameController =
        TextEditingController(text: profile['christian_name']);
    _phoneController = TextEditingController(text: profile['phone_number']);
    _motherNameController = TextEditingController(text: profile['mother_name']);
    _confessionFatherController =
        TextEditingController(text: profile['confession_father_name']);
    _academicLevelController =
        TextEditingController(text: profile['academic_level']);
    _kifilController = TextEditingController(text: profile['kifil']);
    _parentNameController = TextEditingController(text: profile['parent_name']);
    _parentPhoneController =
        TextEditingController(text: profile['parent_phone_number']);
    _gender = profile['gender'];
    _dob = (profile['dob'] != null && profile['dob'].toString().isNotEmpty)
        ? DateTime.tryParse(profile['dob'].toString())
        : null;
    _spiritualClass = profile['spiritual_class'];

    // 2. Parse Saved Values
    final rawCustomValues = profile['custom_field_values'];
    if (rawCustomValues is List) {
      _selectedCustomFieldValues = {
        for (var item in rawCustomValues)
          if (item['field_id'] != null)
            item['field_id'].toString():
                (item['value'] ?? item['option_id'] ?? item['value_text'])
                    ?.toString()
      };
    } else if (rawCustomValues is Map) {
      _selectedCustomFieldValues = Map<String, String?>.from(rawCustomValues);
    } else {
      _selectedCustomFieldValues = {};
    }

    setState(() {
      _isInitialized = true;
    });

    // 3. Fetch Custom Fields Definitions Directly
    if (profile['tenant_id'] != null) {
      await _fetchCustomFieldsDirectly(profile['tenant_id'].toString());

      // 4. Populate values from custom_fields_detail (Robust fallback)
      if (profile['custom_fields_detail'] is List) {
        final details = profile['custom_fields_detail'] as List;
        for (var detail in details) {
          if (detail is Map && detail['field_name'] != null) {
            final fieldName = detail['field_name'];
            final fieldValue = detail['field_value']?.toString();
            if (fieldValue == null) continue;

            try {
              dynamic fieldDef;
              for (var f in _localCustomFields) {
                if (f['name'] == fieldName) {
                  fieldDef = f;
                  break;
                }
              }
              if (fieldDef == null) continue;

              final fieldId = fieldDef['id'].toString();
              final fieldType = (fieldDef['field_type'] ?? fieldDef['type'])
                      ?.toString()
                      .toUpperCase() ??
                  'TEXT';

              // If it's an option-based type, we need the option ID
              if (['DROPDOWN', 'RADIO', 'CHECKBOX', 'MULTISELECT', 'VOTE']
                  .contains(fieldType)) {
                if (fieldDef['options'] is List) {
                  final options = fieldDef['options'] as List;
                  final matchingOption = options.firstWhere(
                    (opt) =>
                        opt['option_value'].toString().trim() ==
                        fieldValue.trim(),
                    orElse: () => null,
                  );
                  if (matchingOption != null) {
                    _selectedCustomFieldValues[fieldId] =
                        matchingOption['id'].toString();
                  } else {
                    // Fallback: maybe the value recorded IS the option ID?
                    final isOptionIdMatch = options.any(
                        (opt) => opt['id'].toString() == fieldValue.trim());
                    if (isOptionIdMatch) {
                      _selectedCustomFieldValues[fieldId] = fieldValue.trim();
                    }
                  }
                }
              } else {
                // For text types, use the raw value
                _selectedCustomFieldValues[fieldId] = fieldValue;
              }
            } catch (e) {
              developer.log("DEBUG: Error mapping field $fieldName: $e",
                  name: 'EditProfileSheet');
            }
          }
        }
        setState(() {});
      }
    } else {
      developer.log("DEBUG: No tenant_id found for fields fetch.",
          name: 'EditProfileSheet');
    }
  }

  Future<void> _fetchCustomFieldsDirectly(String tenantId) async {
    if (!mounted) return;
    setState(() => _isLoadingFields = true);
    try {
      final fields = await AuthService.getTenantCustomFields(tenantId);
      if (!mounted) return;

      final userFields = fields.where((f) {
        final filledBy = f['filled_by']?.toString().toUpperCase();
        // Show fields that can be filled by USER
        return filledBy == 'USER' || filledBy == 'BOTH' || filledBy == null;
      }).toList();

      setState(() {
        _localCustomFields = userFields;
        _isLoadingFields = false;
      });
    } catch (e) {
      developer.log("DEBUG: Error fetching custom fields: $e",
          name: 'EditProfileSheet', error: e);
      if (mounted) setState(() => _isLoadingFields = false);
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _fullNameController.dispose();
      _christianNameController.dispose();
      _phoneController.dispose();
      _motherNameController.dispose();
      _confessionFatherController.dispose();
      _academicLevelController.dispose();
      _kifilController.dispose();
      _parentNameController.dispose();
      _parentPhoneController.dispose();
    }
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;
    setState(() => _isSaving = true);

    final Map<String, dynamic> updatedData = {
      'full_name': _fullNameController.text.trim(),
      'christian_name': _christianNameController.text.trim(),
      'phone_number': _phoneController.text.trim(),
      'mother_name': _motherNameController.text.trim(),
      'confession_father_name': _confessionFatherController.text.trim(),
      'academic_level': _academicLevelController.text.trim(),
      'kifil': _kifilController.text.trim(),
      'parent_name': _parentNameController.text.trim(),
      'parent_phone_number': _parentPhoneController.text.trim(),
      'gender': _gender,
      'dob': _dob?.toIso8601String().substring(0, 10),
      'spiritual_class': _spiritualClass,
      'custom_field_values': _selectedCustomFieldValues,
    };

    final result = await ProfileService.updateMyProfile(updatedData);
    if (mounted) {
      final wasSuccessful = result['success'] ?? false;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message']!),
          backgroundColor: wasSuccessful
              ? Colors.green
              : Theme.of(context).colorScheme.error));
      if (wasSuccessful) Navigator.of(context).pop(true);
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileConfig = context.watch<ProfileConfigProvider>();
    final userCustomFields = _localCustomFields;

    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profileEditTitle,
              style: TextStyle(
                  color: Theme.of(context).appBarTheme.foregroundColor)),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionHeader(
                AppLocalizations.of(context)!.profilePersonalInfo),
            if (profileConfig.isWidgetVisible('full_name'))
              _buildTextFormField(_fullNameController,
                  AppLocalizations.of(context)!.profileFullName, Iconsax.user),
            if (profileConfig.isWidgetVisible('christian_name'))
              _buildTextFormField(
                  _christianNameController,
                  AppLocalizations.of(context)!.profileChristianName,
                  Iconsax.user_tag),
            if (profileConfig.isWidgetVisible('mother_name'))
              _buildTextFormField(
                  _motherNameController,
                  AppLocalizations.of(context)!.profileMotherName,
                  Iconsax.woman),
            if (profileConfig.isWidgetVisible('phone_number'))
              _buildTextFormField(
                  _phoneController,
                  AppLocalizations.of(context)!.profilePhoneNumber,
                  Iconsax.call,
                  keyboardType: TextInputType.phone),
            if (profileConfig.isWidgetVisible('gender'))
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                    initialValue:
                        _gender, // Ensure this matches one of the values below
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.profileGender,
                        prefixIcon: const Icon(Iconsax.people),
                        border: const OutlineInputBorder()),
                    items: [
                      DropdownMenuItem(
                          value: 'Male',
                          child: Text(
                              AppLocalizations.of(context)!.profileGenderMale)),
                      DropdownMenuItem(
                          value: 'Female',
                          child: Text(AppLocalizations.of(context)!
                              .profileGenderFemale)),
                    ],
                    onChanged: (val) => setState(() => _gender = val)),
              ),
            if (profileConfig.isWidgetVisible('dob')) _buildDatePicker(),
            _buildSectionHeader(
                AppLocalizations.of(context)!.profileSpiritualAcademic),
            if (profileConfig.isWidgetVisible('confession_father_name'))
              _buildTextFormField(
                  _confessionFatherController,
                  AppLocalizations.of(context)!.profileConfessionFather,
                  Iconsax.user_square),
            if (profileConfig.isWidgetVisible('spiritual_class'))
              _buildDropdownFormField(
                  value: _spiritualClass,
                  label: 'የመንፈሳዊ ትምህርት ክፍል',
                  icon: Iconsax.teacher,
                  items: spiritualClassOptions,
                  onChanged: (val) => setState(() => _spiritualClass = val)),
            if (profileConfig.isWidgetVisible('academic_level'))
              _buildTextFormField(
                  _academicLevelController,
                  AppLocalizations.of(context)!.profileAcademicLevel,
                  Iconsax.rulerpen),
            if (profileConfig.isWidgetVisible('kifil'))
              _buildTextFormField(_kifilController,
                  AppLocalizations.of(context)!.profileKifil, Iconsax.people),
            _buildSectionHeader(
                AppLocalizations.of(context)!.profileGuardianInfo),
            if (profileConfig.isWidgetVisible('parent_name'))
              _buildTextFormField(
                  _parentNameController,
                  AppLocalizations.of(context)!.profileGuardianName,
                  Iconsax.user_cirlce_add),
            if (profileConfig.isWidgetVisible('parent_phone_number'))
              _buildTextFormField(
                  _parentPhoneController,
                  AppLocalizations.of(context)!.profileGuardianPhone,
                  Iconsax.call_calling,
                  keyboardType: TextInputType.phone),
            if (_isLoadingFields)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator())),
            if (userCustomFields.isNotEmpty) ...[
              _buildSectionHeader(
                  AppLocalizations.of(context)!.profileAdditionalInfo),
              ...userCustomFields.map((field) {
                final fieldId = field['id'].toString();
                final fieldType = (field['field_type'] ?? field['type'])
                        ?.toString()
                        .toUpperCase() ??
                    'TEXT';
                final options = field['options'] as List<dynamic>? ?? [];

                final isTextArea = fieldType == 'TEXTAREA';
                final isChoiceBased = [
                  'DROPDOWN',
                  'RADIO',
                  'CHECKBOX',
                  'MULTISELECT',
                  'VOTE',
                  'TOGGLE'
                ].contains(fieldType);

                // 1. Prioritize Choice-based if options exist
                if (isChoiceBased && options.isNotEmpty) {
                  // Validate value exists in options to prevent Dropdown crash
                  var val = _selectedCustomFieldValues[fieldId];
                  if (val != null && options.isNotEmpty) {
                    final rawValue = val.toString();
                    final matches = options
                        .where((opt) => opt['id'].toString() == rawValue);
                    final match = matches.isNotEmpty ? matches.first : null;
                    if (match == null) {
                      developer.log(
                          "DEBUG: Value $val not found in options for field $fieldId.",
                          name: 'EditProfileSheet');
                      val = null;
                    }
                  } else if (val != null && options.isEmpty) {
                    val = null;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: DropdownButtonFormField<String>(
                      key: ValueKey('dropdown_$fieldId'),
                      initialValue: val,
                      decoration: InputDecoration(
                          labelText: field['name'],
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(fieldType == 'VOTE'
                              ? Iconsax.ranking
                              : Iconsax.document_filter)),
                      items: [
                        DropdownMenuItem(
                            value: null,
                            child: Text(
                                AppLocalizations.of(context)!.profileNotSet)),
                        ...options.map((opt) => DropdownMenuItem(
                            value: opt['id'].toString(),
                            child: Text(opt['option_value'])))
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCustomFieldValues[fieldId] = value;
                        });
                      },
                    ),
                  );
                }

                // 2. Default to Text-based (includes TEXT, TEXTAREA, and fallbacks)
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    key: ValueKey('text_$fieldId'),
                    initialValue: _selectedCustomFieldValues[fieldId],
                    maxLines: isTextArea ? 3 : 1,
                    decoration: InputDecoration(
                        labelText: field['name'],
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(isTextArea
                            ? Iconsax.document_text
                            : Iconsax.edit_2)),
                    onChanged: (value) {
                      setState(() {
                        _selectedCustomFieldValues[fieldId] = value;
                      });
                    },
                  ),
                );
              }),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: _isSaving
                  ? const SizedBox.shrink()
                  : const Icon(Iconsax.save_2, color: Colors.black),
              onPressed: _isSaving ? null : _submitForm,
              label: _isSaving
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary))
                  : Text(AppLocalizations.of(context)!.profileSaveChanges,
                      style: const TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.black, // Ensure text is visible
                  padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold)));

  Widget _buildTextFormField(
          TextEditingController controller, String label, IconData icon,
          {TextInputType? keyboardType}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: Icon(icon),
                  border: const OutlineInputBorder()),
              keyboardType: keyboardType));

  Widget _buildDropdownFormField(
          {String? value,
          required String label,
          required IconData icon,
          required List<String> items,
          required ValueChanged<String?> onChanged}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: DropdownButtonFormField<String>(
              initialValue: value,
              decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: Icon(icon),
                  border: const OutlineInputBorder()),
              items: items
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: onChanged));

  Widget _buildDatePicker() => Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () async {
          final initialDate = _dob != null
              ? EthiopianDate.fromGregorian(_dob!)
              : EthiopianDate.now();
          final pickedDate = await showDialog<EthiopianDate>(
            context: context,
            builder: (context) =>
                EthiopianDatePickerDialog(initialDate: initialDate),
          );
          if (pickedDate != null) {
            setState(() => _dob = pickedDate.toGregorian());
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            children: [
              const Icon(Iconsax.calendar_1, color: Colors.blueAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.profileSelectDob,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      _dob == null
                          ? 'Not Set'
                          : EthiopianDate.fromGregorian(_dob!).toString(),
                      style: GoogleFonts.notoSansEthiopic(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ));
}
