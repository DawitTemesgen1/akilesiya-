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
  Map<String, dynamic> _selectedCustomFieldValues = {};
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

    // 2. Group Saved Values by Field ID
    final rawCustomValues = profile['custom_field_values'];
    _selectedCustomFieldValues = {};
    if (rawCustomValues is List) {
      for (var item in rawCustomValues) {
        if (item['field_id'] == null) continue;
        final fid = item['field_id'].toString();
        final val = (item['value'] ?? item['option_id'] ?? item['value_text'])
            ?.toString();
        if (val == null) continue;

        if (_selectedCustomFieldValues.containsKey(fid)) {
          final existing = _selectedCustomFieldValues[fid];
          if (existing is List) {
            if (!existing.contains(val)) existing.add(val);
          } else if (existing != val) {
            _selectedCustomFieldValues[fid] = [existing, val];
          }
        } else {
          _selectedCustomFieldValues[fid] = val;
        }
      }
    } else if (rawCustomValues is Map) {
      _selectedCustomFieldValues = Map<String, dynamic>.from(rawCustomValues);
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

      final allFields =
          fields; // Include all fields, ADMIN managed will be read-only

      setState(() {
        _localCustomFields = allFields;
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

            // Personal Tab Custom Fields
            ..._buildCategorizedCustomFields('PERSONAL'),

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
                  label:
                      AppLocalizations.of(context)!.profileSpiritualClassLabel,
                  icon: Iconsax.teacher,
                  items: spiritualClassOptions,
                  onChanged: (val) => setState(() => _spiritualClass = val),
                  itemBuilder: (item) {
                    final level = item.replaceAll('ኛ ክፍል', '');
                    return AppLocalizations.of(context)!
                        .profileSpiritualGrade(level);
                  }),
            if (profileConfig.isWidgetVisible('academic_level'))
              _buildTextFormField(
                  _academicLevelController,
                  AppLocalizations.of(context)!.profileAcademicLevel,
                  Iconsax.rulerpen),
            if (profileConfig.isWidgetVisible('kifil'))
              _buildTextFormField(_kifilController,
                  AppLocalizations.of(context)!.profileKifil, Iconsax.people),

            // Spiritual Custom Fields
            ..._buildCategorizedCustomFields('SPIRITUAL'),

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

            // Family & Learning (Education) Tab Custom Fields
            ..._buildCategorizedCustomFields('FAMILY'),
            ..._buildCategorizedCustomFields('EDUCATION'),

            // Uncategorized Custom Fields
            ..._buildCategorizedCustomFields(null),

            if (_isLoadingFields)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator())),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: _isSaving
                  ? const SizedBox.shrink()
                  : const Icon(Iconsax.save_2, color: Colors.black),
              onPressed: _isSaving ? null : _submitForm,
              label: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary)),
                    )
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

  List<Widget> _buildCategorizedCustomFields(String? tabName) {
    final fields = _localCustomFields.where((f) {
      final fTab = f['profile_tab']?.toString().toUpperCase();
      if (tabName == null) {
        return fTab == null ||
            !['PERSONAL', 'SPIRITUAL', 'EDUCATION', 'FAMILY'].contains(fTab);
      }
      return fTab == tabName;
    }).toList();

    if (fields.isEmpty) return [];

    return fields.map((field) {
      final fieldId = field['id'].toString();
      final fieldType =
          (field['field_type'] ?? field['type'])?.toString().toUpperCase() ??
              'TEXT';
      final options = field['options'] as List<dynamic>? ?? [];
      final isManagedByAdmin =
          field['managed_by']?.toString().toUpperCase() == 'ADMIN';

      final isTextArea = fieldType == 'TEXTAREA';
      final isChoiceBased = [
        'DROPDOWN',
        'RADIO',
        'CHECKBOX',
        'MULTISELECT',
        'VOTE',
        'TOGGLE'
      ].contains(fieldType);

      // 1. Choice-based fields
      if (isChoiceBased && options.isNotEmpty) {
        final label = field['name'] ?? '';
        final currentValue = _selectedCustomFieldValues[fieldId];

        // Read-only view for Admin-managed fields
        if (isManagedByAdmin) {
          String display = "Not Set";
          if (currentValue != null) {
            if (currentValue is List) {
              final selectedNames = options
                  .where((o) => currentValue.contains(o['id'].toString()))
                  .map((o) => o['option_value'].toString())
                  .join(", ");
              display = selectedNames.isNotEmpty ? selectedNames : "Not Set";
            } else {
              final opt = options.firstWhere(
                  (o) => o['id'].toString() == currentValue.toString(),
                  orElse: () => null);
              display = opt?['option_value'] ?? currentValue.toString();
            }
          }
          return _buildReadOnlyField(label, display, Iconsax.security_user);
        }

        // A. MULTISELECT or CHECKBOX (Group Selection)
        if (fieldType == 'MULTISELECT' || fieldType == 'CHECKBOX') {
          final List<String> selectedList = currentValue is List
              ? List<String>.from(currentValue)
              : (currentValue != null ? [currentValue.toString()] : []);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                children: options.map((opt) {
                  final oid = opt['id'].toString();
                  final isSelected = selectedList.contains(oid);
                  return FilterChip(
                    label: Text(opt['option_value']),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedList.add(oid);
                        } else {
                          selectedList.remove(oid);
                        }
                        _selectedCustomFieldValues[fieldId] =
                            selectedList.isEmpty ? null : selectedList;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          );
        }

        // B. RADIO Buttons
        if (fieldType == 'RADIO') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              RadioGroup<Object>(
                groupValue: currentValue,
                onChanged: (value) {
                  setState(() {
                    _selectedCustomFieldValues[fieldId] = value;
                  });
                },
                child: Column(
                  children: options.map((opt) {
                    final oid = opt['id'].toString();
                    return RadioListTile<String>(
                      title: Text(opt['option_value']),
                      value: oid,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }

        // C. VOTE / RATING
        if (fieldType == 'VOTE') {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: options.map((opt) {
                    final oid = opt['id'].toString();
                    final isSelected = currentValue?.toString() == oid;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(opt['option_value']),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCustomFieldValues[fieldId] =
                                selected ? oid : null;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }

        // D. Fallback to Dropdown
        var val = currentValue is List
            ? (currentValue.isEmpty ? null : currentValue.first.toString())
            : currentValue?.toString();
        if (val != null) {
          final match = options.any((opt) => opt['id'].toString() == val);
          if (!match) val = null;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: DropdownButtonFormField<String>(
            key: ValueKey('dropdown_$fieldId'),
            initialValue: val,
            decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Iconsax.document_filter)),
            items: [
              DropdownMenuItem(
                  value: null,
                  child: Text(AppLocalizations.of(context)!.profileNotSet)),
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

      // 2. Date Picker
      if (fieldType == 'DATE') {
        if (isManagedByAdmin) {
          return _buildReadOnlyField(
              field['name'],
              _selectedCustomFieldValues[fieldId]?.toString() ?? "Not Set",
              Iconsax.calendar);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextFormField(
            key: ValueKey('date_$fieldId'),
            readOnly: true,
            controller: TextEditingController(
              text: _selectedCustomFieldValues[fieldId] ?? '',
            ),
            decoration: InputDecoration(
              labelText: field['name'],
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Iconsax.calendar),
              suffixIcon: IconButton(
                icon: const Icon(Iconsax.close_circle),
                onPressed: () {
                  setState(() {
                    _selectedCustomFieldValues[fieldId] = null;
                  });
                },
              ),
            ),
            onTap: () async {
              final initialDate = _selectedCustomFieldValues[fieldId] != null
                  ? EthiopianDate.fromGregorian(
                      DateTime.tryParse(_selectedCustomFieldValues[fieldId]!) ??
                          DateTime.now())
                  : EthiopianDate.now();

              final EthiopianDate? picked = await showDialog<EthiopianDate>(
                context: context,
                builder: (context) => EthiopianDatePickerDialog(
                  initialDate: initialDate,
                ),
              );
              if (picked != null) {
                setState(() {
                  _selectedCustomFieldValues[fieldId] =
                      picked.toGregorian().toIso8601String().substring(0, 10);
                });
              }
            },
          ),
        );
      }

      // 3. Toggle/Boolean
      if (fieldType == 'YES/NO TOGGLE' ||
          fieldType == 'TOGGLE' ||
          fieldType == 'BOOLEAN') {
        final currentValue = _selectedCustomFieldValues[fieldId];
        final boolValue = currentValue == 'true' ||
            currentValue == '1' ||
            currentValue == 'yes';

        if (isManagedByAdmin) {
          return _buildReadOnlyField(field['name'], boolValue ? "Yes" : "No",
              Iconsax.toggle_on_circle);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: SwitchListTile(
            title: Text(field['name']),
            value: boolValue,
            onChanged: (value) {
              setState(() {
                _selectedCustomFieldValues[fieldId] = value ? 'true' : 'false';
              });
            },
            secondary: const Icon(Iconsax.toggle_on_circle),
          ),
        );
      }

      // Default to Text-based
      if (isManagedByAdmin) {
        return _buildReadOnlyField(
            field['name'],
            _selectedCustomFieldValues[fieldId]?.toString() ?? "Not Set",
            Iconsax.security_user);
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: TextFormField(
          key: ValueKey('text_$fieldId'),
          initialValue: _selectedCustomFieldValues[fieldId]?.toString(),
          maxLines: isTextArea ? 3 : 1,
          decoration: InputDecoration(
              labelText: field['name'],
              border: const OutlineInputBorder(),
              prefixIcon:
                  Icon(isTextArea ? Iconsax.document_text : Iconsax.edit_2)),
          onChanged: (value) {
            setState(() {
              _selectedCustomFieldValues[fieldId] = value;
            });
          },
        ),
      );
    }).toList();
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue:
            (value.isEmpty || value == 'Not Set') ? l10n.profileNotSet : value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey),
          helperText: l10n.profileManagedByAdminReadOnly,
          filled: true,
          fillColor: Colors.grey.withAlpha((0.05 * 255).round()),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildDropdownFormField({
    String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String Function(String)? itemBuilder,
  }) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: DropdownButtonFormField<String>(
              initialValue: value,
              decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: Icon(icon),
                  border: const OutlineInputBorder()),
              items: items
                  .map((item) => DropdownMenuItem(
                      value: item,
                      child:
                          Text(itemBuilder != null ? itemBuilder(item) : item)))
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
                          ? AppLocalizations.of(context)!.profileNotSet
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
