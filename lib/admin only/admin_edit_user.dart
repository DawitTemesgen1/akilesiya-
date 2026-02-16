import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/template_service.dart';
import 'package:amde_haymanot_abalat_guday/services/user_admin_service.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:collection/collection.dart';

import 'package:amde_haymanot_abalat_guday/admin%20only/user_data_print_preview.dart';
import 'package:flutter/services.dart';
import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';

// --- ቀለሞች ---
const Color primaryColor = Color.fromARGB(255, 1, 37, 100);
const Color dangerColor = Color(0xFFDC3545);
const Color successColor = Color(0xFF198754);

class AdminEditUserScreen extends StatefulWidget {
  final String userId;
  final String userName;
  const AdminEditUserScreen(
      {super.key, required this.userId, required this.userName});

  @override
  State<AdminEditUserScreen> createState() => _AdminEditUserScreenState();
}

class _AdminEditUserScreenState extends State<AdminEditUserScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  Map<String, dynamic>? _userDetails;
  List<dynamic> _customFields = [];

  // Controllers for all fields
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _christianNameController = TextEditingController();
  final _confessionFatherController = TextEditingController();
  final _academicLevelController = TextEditingController();
  final _kifilController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _serviceSectorController = TextEditingController();

  Map<String, dynamic> _selectedCustomFieldValues = {};
  Map<String, dynamic> _initialCustomFieldValues = {};

  bool _isActive = true;
  String? _serviceStatus;
  String? _spiritualClass;
  String? _role;

  // Initial values for comparison
  late Map<String, dynamic> _initialValues;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _christianNameController.dispose();
    _confessionFatherController.dispose();
    _academicLevelController.dispose();
    _kifilController.dispose();
    _motherNameController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _serviceSectorController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        UserAdminService.getUserDetailsForAdmin(widget.userId),
        TemplateService.getCustomFields(),
      ]);
      final userResult = results[0];
      final templateResult = results[1];

      if (userResult['success'] != true || templateResult['success'] != true) {
        throw Exception(userResult['message'] ?? templateResult['message']);
      }

      _userDetails = userResult['data'];
      _customFields = templateResult['data'];

      // Populate controllers
      _fullNameController.text = _userDetails?['full_name'] ?? "";
      _phoneController.text = _userDetails?['phone_number'] ?? "";
      _christianNameController.text = _userDetails?['christian_name'] ?? "";
      _confessionFatherController.text =
          _userDetails?['confession_father_name'] ?? "";
      _academicLevelController.text = _userDetails?['academic_level'] ?? "";
      _kifilController.text = _userDetails?['kifil'] ?? "";
      _motherNameController.text = _userDetails?['mother_name'] ?? "";
      _parentNameController.text = _userDetails?['parent_name'] ?? "";
      _parentPhoneController.text = _userDetails?['parent_phone_number'] ?? "";
      _serviceSectorController.text = _userDetails?['service_sector'] ?? "";

      _isActive = _userDetails?['is_active'] == 1;
      _serviceStatus = _userDetails?['service_status'];
      _spiritualClass = _userDetails?['spiritual_class'];
      _role = _userDetails?['role'];

      final rawCustomValues = _userDetails?['custom_field_values'];
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
      _initialCustomFieldValues =
          jsonDecode(jsonEncode(_selectedCustomFieldValues));

      // Store initial values for change detection
      _initialValues = {
        'full_name': _fullNameController.text,
        'phone_number': _phoneController.text,
        'christian_name': _christianNameController.text,
        'confession_father_name': _confessionFatherController.text,
        'academic_level': _academicLevelController.text,
        'kifil': _kifilController.text,
        'mother_name': _motherNameController.text,
        'parent_name': _parentNameController.text,
        'parent_phone_number': _parentPhoneController.text,
        'service_sector': _serviceSectorController.text,
        'is_active': _isActive,
        'service_status': _serviceStatus,
        'spiritual_class': _spiritualClass,
        'role': _role,
      };

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = "መረጃ መጫን አልተሳካም፦ ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final updates = <String, dynamic>{};

    void addIfChanged(String key, dynamic currentValue) {
      if (currentValue != _initialValues[key]) {
        updates[key] = currentValue;
      }
    }

    addIfChanged('is_active', _isActive);
    addIfChanged('service_status', _serviceStatus);
    addIfChanged('service_sector', _serviceSectorController.text);
    addIfChanged('spiritual_class', _spiritualClass);
    addIfChanged('role', _role);

    // Custom fields change detection
    if (!const MapEquality()
        .equals(_selectedCustomFieldValues, _initialCustomFieldValues)) {
      updates['custom_field_values'] = _selectedCustomFieldValues;
    }

    if (updates.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('ምንም ለውጦች አልተደረጉም።')));
      setState(() => _isSaving = false);
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final result = await UserAdminService.updateUserByAdmin(
        userId: widget.userId, updates: updates);

    if (mounted) {
      final wasSuccessful = result['success'] ?? false;
      messenger.showSnackBar(SnackBar(
          content: Text(result['message']!),
          backgroundColor: wasSuccessful ? successColor : dangerColor));
      if (wasSuccessful) navigator.pop(true);
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('${widget.userName}ን ያስተዳድሩ'),
          actions: [
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: _userDetails == null ? null : _handlePrint,
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'ጠቅላላ'),
              Tab(text: 'መንፈሳዊ'),
              Tab(text: 'ትምህርት'),
              Tab(text: 'ቤተሰብ'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('ስህተት፦ $_error'))
                : TabBarView(
                    children: [
                      _buildGeneralTab(),
                      _buildSpiritualTab(),
                      _buildEducationTab(),
                      _buildFamilyTab(),
                    ],
                  ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Iconsax.save_2),
            onPressed: _isSaving ? null : _submitForm,
            label: Text(_isSaving ? "በማስቀመጥ ላይ..." : 'የአስተዳዳሪ ለውጦችን ያስቀምጡ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReadOnlyField('ሙሉ ስም', _fullNameController.text, Iconsax.user),
        const SizedBox(height: 16),
        _buildReadOnlyField('ስልክ ቁጥር', _phoneController.text, Iconsax.call),
        const SizedBox(height: 24),
        _buildSectionHeader('ሁኔታ እና ሚና (Editable)'),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue:
              const ['Active', 'Inactive', 'OnBreak'].contains(_serviceStatus)
                  ? _serviceStatus
                  : null,
          decoration: InputDecoration(
            labelText: 'የአገልግሎት ሁኔታ',
            prefixIcon: const Icon(Iconsax.award),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: const [
            DropdownMenuItem(value: 'Active', child: Text('በአገልግሎት ላይ')),
            DropdownMenuItem(value: 'Inactive', child: Text('አያገለግልም')),
            DropdownMenuItem(value: 'OnBreak', child: Text('በእረፍት ላይ')),
          ],
          onChanged: (value) => setState(() => _serviceStatus = value),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _serviceSectorController,
          decoration: InputDecoration(
            labelText: 'የአገልግሎት ዘርፍ (Service Sector)',
            prefixIcon: const Icon(Iconsax.briefcase),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            helperText:
                "ተጠቃሚው የሚገኝበት የአገልግሎት ዘርፍ (ለምሳሌ፦ መዘምራን፣ ሰንበት ትምህርት ቤት...)",
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue:
              const ['admin', 'servant', 'user'].contains(_role) ? _role : null,
          decoration: InputDecoration(
            labelText: 'የስርዓት ሚና',
            prefixIcon: const Icon(Iconsax.security_user),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: const [
            DropdownMenuItem(value: 'admin', child: Text('አስተዳዳሪ')),
            DropdownMenuItem(value: 'servant', child: Text('አገልጋይ')),
            DropdownMenuItem(value: 'user', child: Text('ተራ አባል')),
          ],
          onChanged: (value) => setState(() => _role = value),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('የአካውንት እንቅስቃሴ'),
          subtitle: Text(_isActive ? 'ተጠቃሚው መግባት ይችላል' : 'የተጠቃሚው አካውንት ታግዷል'),
          value: _isActive,
          onChanged: (val) => setState(() => _isActive = val),
          secondary: Icon(_isActive ? Iconsax.unlock : Iconsax.lock,
              color: primaryColor),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 24),
        _buildTabCustomFields('PERSONAL'),
      ],
    );
  }

  Widget _buildSpiritualTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReadOnlyField(
            'የክርስትና ስም', _christianNameController.text, Iconsax.user_tag),
        const SizedBox(height: 16),
        _buildReadOnlyField(
            'የንስሐ አባት', _confessionFatherController.text, Iconsax.user_octagon),
        const SizedBox(height: 24),
        _buildSectionHeader('መንፈሳዊ ሁኔታ (Editable)'),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: const ['ሳሙኤል ተረኛ', 'ዲያቆን', 'መሪ', 'ተረኛ', 'ተማሪ']
                  .contains(_spiritualClass)
              ? _spiritualClass
              : null,
          decoration: InputDecoration(
            labelText: 'የመንፈሳዊ ክፍል',
            prefixIcon: const Icon(Iconsax.teacher),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: const [
            DropdownMenuItem(value: 'ሳሙኤል ተረኛ', child: Text('ሳሙኤል ተረኛ')),
            DropdownMenuItem(value: 'ዲያቆን', child: Text('ዲያቆን')),
            DropdownMenuItem(value: 'መሪ', child: Text('መሪ')),
            DropdownMenuItem(value: 'ተረኛ', child: Text('ተረኛ')),
            DropdownMenuItem(value: 'ተማሪ', child: Text('ተማሪ')),
          ],
          onChanged: (value) => setState(() => _spiritualClass = value),
        ),
        const SizedBox(height: 24),
        _buildTabCustomFields('SPIRITUAL'),
      ],
    );
  }

  Widget _buildEducationTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReadOnlyField(
            'የትምህርት ደረጃ', _academicLevelController.text, Iconsax.rulerpen),
        const SizedBox(height: 16),
        _buildReadOnlyField(
            'ክፍል (Kifil)', _kifilController.text, Iconsax.hierarchy),
        const SizedBox(height: 24),
        _buildTabCustomFields('EDUCATION'),
      ],
    );
  }

  Widget _buildFamilyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReadOnlyField(
            'የእናት ስም', _motherNameController.text, Iconsax.woman),
        const SizedBox(height: 16),
        _buildReadOnlyField(
            'የአሳዳጊ ስም', _parentNameController.text, Iconsax.user_cirlce_add),
        const SizedBox(height: 16),
        _buildReadOnlyField(
            'የአሳዳጊ ስልክ', _parentPhoneController.text, Iconsax.call_calling),
        const SizedBox(height: 24),
        _buildTabCustomFields('FAMILY'),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value.isNotEmpty ? value : 'ያልተሞላ',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
    );
  }

  Widget _buildTabCustomFields(String tabName) {
    final fields = _customFields.where((field) {
      final managedBy = field['managed_by']?.toString().toUpperCase();
      final onThisTab =
          field['profile_tab']?.toString().toUpperCase() == tabName;
      final isAdminManaged = managedBy == 'ADMIN' || managedBy == 'BOTH';
      return onThisTab && isAdminManaged;
    }).toList();

    if (fields.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('ተጨማሪ መረጃ (Admin Managed)'),
        const SizedBox(height: 12),
        ...fields.map((field) {
          final fieldId = field['id'].toString();
          final fieldType = (field['field_type'] ?? field['type'])
                  ?.toString()
                  .toUpperCase() ??
              'TEXT';
          final options = field['options'] as List<dynamic>? ?? [];
          final label = field['name'] ?? '';
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
            final currentValue = _selectedCustomFieldValues[fieldId];

            // A. MULTISELECT or CHECKBOX
            if (fieldType == 'MULTISELECT' || fieldType == 'CHECKBOX') {
              final List<String> selectedList = currentValue is List
                  ? List<String>.from(currentValue)
                  : (currentValue != null ? [currentValue.toString()] : []);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
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

            // B. RADIO
            if (fieldType == 'RADIO') {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  ...options.map((opt) {
                    final oid = opt['id'].toString();
                    return RadioListTile<String>(
                      title: Text(opt['option_value']),
                      value: oid,
                      groupValue: currentValue?.toString(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCustomFieldValues[fieldId] = value;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              );
            }

            // C. VOTE
            if (fieldType == 'VOTE') {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
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

            // D. Dropdown Fallback
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
                initialValue: val,
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Iconsax.security_user),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('አልተመረጠም')),
                  ...options.map((opt) => DropdownMenuItem(
                        value: opt['id'].toString(),
                        child: Text(opt['option_value'] ?? ""),
                      ))
                ],
                onChanged: (value) {
                  setState(() => _selectedCustomFieldValues[fieldId] = value);
                },
              ),
            );
          }

          // 2. Date Picker
          if (fieldType == 'DATE') {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: _selectedCustomFieldValues[fieldId] ?? '',
                ),
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
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
                  final initialDate =
                      _selectedCustomFieldValues[fieldId] != null
                          ? EthiopianDate.fromGregorian(DateTime.tryParse(
                                  _selectedCustomFieldValues[fieldId]!) ??
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
                      _selectedCustomFieldValues[fieldId] = picked
                          .toGregorian()
                          .toIso8601String()
                          .substring(0, 10);
                    });
                  }
                },
              ),
            );
          }

          // 3. Toggle/Boolean
          if (fieldType == 'TOGGLE' ||
              fieldType == 'BOOLEAN' ||
              fieldType == 'YES/NO TOGGLE') {
            final currentValue = _selectedCustomFieldValues[fieldId];
            final boolValue = currentValue == 'true' ||
                currentValue == '1' ||
                currentValue == 'yes';

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SwitchListTile(
                title: Text(label),
                value: boolValue,
                onChanged: (value) {
                  setState(() {
                    _selectedCustomFieldValues[fieldId] =
                        value ? 'true' : 'false';
                  });
                },
                secondary: const Icon(Iconsax.toggle_on_circle),
              ),
            );
          }

          // Default Text-based
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: TextFormField(
              initialValue: _selectedCustomFieldValues[fieldId]?.toString(),
              maxLines: isTextArea ? 3 : 1,
              decoration: InputDecoration(
                labelText: label,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon:
                    Icon(isTextArea ? Iconsax.document_text : Iconsax.edit_2),
              ),
              onChanged: (value) {
                setState(() => _selectedCustomFieldValues[fieldId] = value);
              },
            ),
          );
        }),
      ],
    );
  }

  Future<void> _handlePrint() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      Uint8List? appLogoBytes;
      List<String> possiblePaths = [
        'assets/images/logo.png',
        'images/logo.png',
        'assets/assets/images/logo.png',
      ];

      for (final path in possiblePaths) {
        try {
          await Future.delayed(Duration.zero);
          final ByteData data = await rootBundle.load(path);
          appLogoBytes = data.buffer.asUint8List();
          break;
        } catch (e) {
          debugPrint('Failed to load logo from $path');
        }
      }

      appLogoBytes ??= Uint8List.fromList([
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

      final List<dynamic> fieldsForPrint = [];
      for (var field in _customFields) {
        final fieldId = field['id'].toString();
        final managedBy = field['managed_by']?.toString().toUpperCase();
        // Only include admin-managed fields if that's what we're editing
        if (managedBy != 'ADMIN' && managedBy != 'BOTH') continue;

        final rawValue = _selectedCustomFieldValues[fieldId];
        if (rawValue == null) continue;

        final options = field['options'] as List<dynamic>? ?? [];
        final fieldType =
            (field['field_type'] ?? field['type'])?.toString().toUpperCase() ??
                'TEXT';

        String displayValue = "";

        if (rawValue is List) {
          // Multi-select / Checkbox
          final optionNames = <String>[];
          for (var vid in rawValue) {
            final opt = options
                .firstWhereOrNull((o) => o['id'].toString() == vid.toString());
            if (opt != null) optionNames.add(opt['option_value'] ?? "");
          }
          displayValue = optionNames.join(", ");
        } else if (options.isNotEmpty &&
            ['DROPDOWN', 'RADIO', 'VOTE'].contains(fieldType)) {
          // Single-choice option based
          final opt = options.firstWhereOrNull(
              (o) => o['id'].toString() == rawValue.toString());
          displayValue = opt?['option_value'] ?? rawValue.toString();
        } else if (fieldType == 'TOGGLE' ||
            fieldType == 'BOOLEAN' ||
            fieldType == 'YES/NO TOGGLE') {
          displayValue = (rawValue == 'true' || rawValue == '1') ? "አዎ" : "አይ";
        } else {
          // Text, Date, etc.
          displayValue = rawValue.toString();
        }

        if (displayValue.isNotEmpty) {
          fieldsForPrint.add({
            'field_name': field['name'],
            'selected_value': displayValue,
          });
        }
      }

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDataPrintPreview(
              user: _userDetails!,
              customFields: fieldsForPrint,
              appLogoBytes: appLogoBytes!,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error preparing print preview: $e')),
        );
      }
    }
  }
}
