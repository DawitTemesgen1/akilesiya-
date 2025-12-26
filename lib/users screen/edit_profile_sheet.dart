// lib/users screen/edit_profile_sheet.dart

import 'package:amde_haymanot_abalat_guday/providers/profile_config_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/profile_service.dart';
import 'package:amde_haymanot_abalat_guday/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';

import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
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
          if (item['field_id'] != null && item['option_id'] != null)
            item['field_id'].toString(): item['option_id'].toString()
      };
    } else if (rawCustomValues is Map) {
      _selectedCustomFieldValues = Map<String, String?>.from(rawCustomValues);
    } else {
      _selectedCustomFieldValues = {};
    }

    setState(() {
      _isInitialized = true;
    });

    // 3. Fetch Custom Fields Definitions Directly (Bypassing Provider)
    if (profile['tenant_id'] != null) {
      await _fetchCustomFieldsDirectly(profile['tenant_id'].toString());
    } else {
      print("DEBUG: No tenant_id found for fields fetch.");
    }
  }

  Future<void> _fetchCustomFieldsDirectly(String tenantId) async {
    if (!mounted) return;
    setState(() => _isLoadingFields = true);
    try {
      final fields = await AuthService.getTenantCustomFields(tenantId);
      if (!mounted) return;

      final userFields = fields.where((f) {
        final managedBy = f['managed_by']?.toString().toUpperCase();
        return managedBy == 'USER' || managedBy == null || managedBy == 'NULL';
      }).toList();

      setState(() {
        _localCustomFields = userFields;
        _isLoadingFields = false;
      });
    } catch (e) {
      print("DEBUG: Error fetching custom fields: $e");
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

    final fullProfile = context.read<UserProvider>().userProfile ?? {};
    final Map<String, dynamic> updatedData = {
      ...fullProfile,
      'full_name': _fullNameController.text,
      'christian_name': _christianNameController.text,
      'phone_number': _phoneController.text,
      'mother_name': _motherNameController.text,
      'confession_father_name': _confessionFatherController.text,
      'academic_level': _academicLevelController.text,
      'kifil': _kifilController.text,
      'parent_name': _parentNameController.text,
      'parent_phone_number': _parentPhoneController.text,
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
    }
    if (mounted) setState(() => _isSaving = false);
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
                    value:
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
                final options = field['options'] as List<dynamic>? ?? [];

                // Validate value exists in options to prevent Dropdown crash
                var val = _selectedCustomFieldValues[fieldId];
                if (val != null && options.isNotEmpty) {
                  final exists =
                      options.any((opt) => opt['id'].toString() == val);
                  if (!exists) val = null;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String>(
                    value: val,
                    decoration: InputDecoration(
                        labelText: field['name'],
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Iconsax.document_filter)),
                    items: [
                      DropdownMenuItem(
                          value: null,
                          child: Text(
                              AppLocalizations.of(context)!.profileNotSet)),
                      ...options.map((opt) => DropdownMenuItem(
                          value: opt['id'].toString(),
                          child: Text(opt['option_value'])))
                    ],
                    onChanged: (value) => setState(
                        () => _selectedCustomFieldValues[fieldId] = value),
                  ),
                );
              }),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: _isSaving
                  ? const SizedBox.shrink()
                  : const Icon(Iconsax.save_2),
              onPressed: _isSaving ? null : _submitForm,
              label: _isSaving
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary))
                  : Text(AppLocalizations.of(context)!.profileSaveChanges),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.primary,
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
      child: ListTile(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: Colors.grey.shade400)),
          leading: const Icon(Iconsax.calendar_1),
          title: Text(_dob == null
              ? AppLocalizations.of(context)!.profileSelectDob
              : DateFormat.yMMMd().format(_dob!)),
          onTap: () async {
            final pickedDate = await showDatePicker(
                context: context,
                initialDate: _dob ?? DateTime(2000),
                firstDate: DateTime(1950),
                lastDate: DateTime.now());
            if (pickedDate != null) setState(() => _dob = pickedDate);
          }));
}
