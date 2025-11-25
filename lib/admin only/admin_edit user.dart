import 'package:amde_haymanot_abalat_guday/services/template_service.dart';
import 'package:amde_haymanot_abalat_guday/services/user_admin_service.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

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

  Map<String, String?> _selectedCustomFieldValues = {};
  Map<String, String?> _initialCustomFieldValues = {};

  bool _isActive = true;
  bool _initialIsActive = true;

  // --- ታክሏል: ለአገልግሎት ሁኔታ የመቆጣጠሪያ ተለዋዋጮች ---
  String? _serviceStatus;
  String? _initialServiceStatus;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
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

      // ሁሉንም የመቆጣጠሪያ ተለዋዋጮች ከሚመጣው የተጠቃሚ መረጃ ማስጀመር
      _isActive = _userDetails?['is_active'] == 1;
      _initialIsActive = _isActive;

      // --- ታክሏል: የአገልግሎት ሁኔታን ማስጀመር ---
      _serviceStatus = _userDetails?['service_status'];
      _initialServiceStatus = _serviceStatus;

      final savedValues =
          _userDetails?['custom_field_values'] as List<dynamic>? ?? [];
      _selectedCustomFieldValues = {
        for (var v in savedValues)
          v['field_id'].toString(): v['option_id'].toString()
      };
      _initialCustomFieldValues = Map.from(_selectedCustomFieldValues);

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

    // በ'is_active' ሁኔታ ላይ የተደረጉ ለውጦችን ማረጋገጥ
    if (_isActive != _initialIsActive) {
      updates['is_active'] = _isActive;
    }

    // --- ታክሏል: በ'service_status' ላይ የተደረጉ ለውጦችን ማረጋገጥ ---
    if (_serviceStatus != _initialServiceStatus) {
      updates['service_status'] = _serviceStatus;
    }

    // በብጁ መስኮች ላይ የተደረጉ ለውጦችን ማረጋገጥ
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

    final result = await UserAdminService.updateUserByAdmin(
        userId: widget.userId, updates: updates);

    if (mounted) {
      final wasSuccessful = result['success'] ?? false;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message']!),
          backgroundColor: wasSuccessful ? successColor : dangerColor));
      if (wasSuccessful) Navigator.of(context).pop(true);
    }
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.userName}ን አስተዳድር')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('ስህተት፦ $_error'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildUserInfoSection(),
                    const Divider(height: 32, thickness: 1),
                    _buildAdminActionsSection(),
                  ],
                ),
    );
  }

  Widget _buildUserInfoSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('የተጠቃሚ መረጃ',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _infoTile(Iconsax.user, 'ሙሉ ስም', _userDetails?['full_name']),
            _infoTile(Iconsax.sms, 'ኢሜይል', _userDetails?['email']),
            _infoTile(Iconsax.security_user, 'የስርዓት ሚና', _userDetails?['role']),
            _infoTile(Iconsax.award, 'የአገልግሎት ሁኔታ',
                _userDetails?['service_status']), // የአሁኑን የአገልግሎት ሁኔታ ያሳያል
            const Divider(height: 24),
            _infoTile(
                Iconsax.user_tag, 'የክርስትና ስም', _userDetails?['christian_name']),
            _infoTile(Iconsax.user_octagon, 'የንስሐ አባት',
                _userDetails?['confession_father_name']),
            _infoTile(Iconsax.woman, "የእናት ስም", _userDetails?['mother_name']),
            const Divider(height: 24),
            _infoTile(Iconsax.call, 'ስልክ ቁጥር', _userDetails?['phone_number']),
            _infoTile(Iconsax.cake, 'ዕድሜ', _userDetails?['age']?.toString()),
            if (_userDetails?['dob'] != null && _userDetails!['dob'].isNotEmpty)
              _infoTile(
                  'የትውልድ ቀን',
                  DateFormat.yMMMd()
                      .format(DateTime.parse(_userDetails!['dob']))),
            _infoTile(Iconsax.rulerpen, 'የትምህርት ደረጃ',
                _userDetails?['academic_level']),
            const Divider(height: 24),
            _infoTile(Iconsax.user_cirlce_add, "የአሳዳጊ ስም",
                _userDetails?['parent_name']),
            _infoTile(Iconsax.call_calling, "የአሳዳጊ ስልክ",
                _userDetails?['parent_phone_number']),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(dynamic iconOrLabel, String value, [String? optionalValue]) {
    String label;
    IconData? icon;
    if (iconOrLabel is IconData) {
      icon = iconOrLabel;
      label = value;
      value = optionalValue ?? '';
    } else {
      label = iconOrLabel as String;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.grey[600], size: 20),
            const SizedBox(width: 16)
          ],
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(value.isNotEmpty ? value : 'አልተገለጸም',
                  textAlign: TextAlign.end,
                  style: TextStyle(color: Colors.grey[800]))),
        ],
      ),
    );
  }

  Widget _buildAdminActionsSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('የአስተዳዳሪ መቆጣጠሪያዎች',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // --- ታክሏል: የአገልግሎት ሁኔታን ለመቆጣጠር Dropdown ---
          DropdownButtonFormField<String>(
            value: _serviceStatus,
            decoration: const InputDecoration(
              labelText: 'የአገልግሎት ሁኔታ',
              prefixIcon: Icon(Iconsax.award),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Active', child: Text('በአገልግሎት ላይ')),
              DropdownMenuItem(value: 'Inactive', child: Text('አያገለግልም')),
              DropdownMenuItem(value: 'OnBreak', child: Text('በእረፍት ላይ')),
            ],
            onChanged: (value) {
              setState(() {
                _serviceStatus = value;
              });
            },
          ),
          const SizedBox(height: 16),

          ..._customFields
              .where((field) => field['managed_by'] == 'ADMIN')
              .map((field) {
            final fieldId = field['id'].toString();
            final options = field['options'] as List<dynamic>? ?? [];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: DropdownButtonFormField<String>(
                value: _selectedCustomFieldValues[fieldId],
                decoration: InputDecoration(
                    labelText: field['name'],
                    border: const OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text('አልተመረጠም')),
                  ...options.map((opt) => DropdownMenuItem(
                      value: opt['id'].toString(),
                      child: Text(opt['option_value'])))
                ],
                onChanged: (value) {
                  setState(() => _selectedCustomFieldValues[fieldId] = value);
                },
              ),
            );
          }).toList(),

          SwitchListTile(
            title: const Text('የአካውንት እንቅስቃሴ'),
            subtitle: Text(_isActive ? 'ተጠቃሚው መግባት ይችላል' : 'የተጠቃሚው አካውንት ታግዷል'),
            value: _isActive,
            onChanged: (val) => setState(() => _isActive = val),
            secondary: Icon(_isActive ? Iconsax.unlock : Iconsax.lock,
                color: primaryColor),
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: _isSaving
                  ? const SizedBox.shrink()
                  : const Icon(Iconsax.save_2),
              onPressed: _isSaving ? null : _submitForm,
              label: _isSaving
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : const Text('የአስተዳዳሪ ለውጦችን ያስቀምጡ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
