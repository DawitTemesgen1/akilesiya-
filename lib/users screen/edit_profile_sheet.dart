// lib/users screen/edit_profile_sheet.dart

import 'package:amde_haymanot_abalat_guday/providers/profile_config_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

const Color primaryColor = Color.fromARGB(255, 1, 37, 100);
const Color accentColor = Color(0xFFFFD700);
const Color dangerColor = Color(0xFFDC3545);
const Color successColor = Color(0xFF198754);

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
  Map<String, String?> _selectedCustomFieldValues = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeState();
    });
  }

  void _initializeState() {
    final profile = context.read<UserProvider>().userProfile;
    if (profile != null) {
      _fullNameController = TextEditingController(text: profile['full_name']);
      _christianNameController =
          TextEditingController(text: profile['christian_name']);
      _phoneController = TextEditingController(text: profile['phone_number']);
      _motherNameController =
          TextEditingController(text: profile['mother_name']);
      _confessionFatherController =
          TextEditingController(text: profile['confession_father_name']);
      _academicLevelController =
          TextEditingController(text: profile['academic_level']);
      _kifilController = TextEditingController(text: profile['kifil']);
      _parentNameController =
          TextEditingController(text: profile['parent_name']);
      _parentPhoneController =
          TextEditingController(text: profile['parent_phone_number']);
      _gender = profile['gender'];
      _dob = (profile['dob'] != null && profile['dob'].toString().isNotEmpty)
          ? DateTime.tryParse(profile['dob'].toString())
          : null;

      // ======================= THE FIX =======================
      // The UserProvider now stores 'custom_field_values' as a Map.
      // This line now correctly reads that Map instead of a List.
      _selectedCustomFieldValues = Map<String, String?>.from(
          profile['custom_field_values'] as Map? ?? {});
      // =======================================================

      setState(() {
        _isInitialized = true;
      });
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
      'custom_field_values': _selectedCustomFieldValues,
    };

    final result = await ProfileService.updateMyProfile(updatedData);

    if (mounted) {
      final wasSuccessful = result['success'] ?? false;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message']!),
          backgroundColor: wasSuccessful ? successColor : dangerColor));
      if (wasSuccessful) Navigator.of(context).pop(true);
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final profileConfig = context.watch<ProfileConfigProvider>();
    final userCustomFields = profileConfig.customFields
        .where((f) => f['managed_by'] == 'USER')
        .toList();

    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profileEditTitle),
          backgroundColor: primaryColor,
          foregroundColor: accentColor),
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
              _buildDropdownFormField(
                  value: _gender,
                  label: AppLocalizations.of(context)!.profileGender,
                  icon: Iconsax.people,
                  items: [
                    AppLocalizations.of(context)!.profileGenderMale,
                    AppLocalizations.of(context)!.profileGenderFemale
                  ],
                  onChanged: (val) => setState(() => _gender = val)),
            if (profileConfig.isWidgetVisible('dob')) _buildDatePicker(),
            _buildSectionHeader(
                AppLocalizations.of(context)!.profileSpiritualAcademic),
            if (profileConfig.isWidgetVisible('confession_father_name'))
              _buildTextFormField(
                  _confessionFatherController,
                  AppLocalizations.of(context)!.profileConfessionFather,
                  Iconsax.user_square),
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
            if (userCustomFields.isNotEmpty) ...[
              _buildSectionHeader(
                  AppLocalizations.of(context)!.profileAdditionalInfo),
              ...userCustomFields.map((field) {
                final fieldId = field['id'].toString();
                final options = field['options'] as List<dynamic>? ?? [];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCustomFieldValues[fieldId],
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
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor))
                  : Text(AppLocalizations.of(context)!.profileSaveChanges),
              style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: primaryColor,
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
              value: value,
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
