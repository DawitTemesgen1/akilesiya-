import 'dart:convert';
import 'dart:io';

import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';

class EditSchoolScreen extends StatefulWidget {
  final Map<String, dynamic> school;

  const EditSchoolScreen({super.key, required this.school});

  @override
  State<EditSchoolScreen> createState() => _EditSchoolScreenState();
}

class _EditSchoolScreenState extends State<EditSchoolScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pastorController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _serviceTimesController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mottoController = TextEditingController();
  final _foundingYearController = TextEditingController();

  DateTime? _establishedDate;
  bool _isSubmitting = false;
  bool _isActive = true;

  // Logo Upload
  File? _logoImage;
  String? _logoUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingLogo = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final school = widget.school;
    _nameController.text = school['name'] ?? '';
    _pastorController.text = school['pastor_name'] ?? '';
    _emailController.text = school['email'] ?? '';
    _phoneController.text = school['phone'] ?? '';
    _addressController.text = school['address'] ?? '';
    _serviceTimesController.text = school['service_times'] ?? '';
    _descriptionController.text = school['description'] ?? '';
    _isActive = school['is_active'] == 1 || school['is_active'] == true;

    // New Fields
    _mottoController.text = school['motto'] ?? '';
    _foundingYearController.text = school['founding_year'] != null
        ? school['founding_year'].toString()
        : '';
    _logoUrl = school['logo_url'];

    if (school['established_date'] != null) {
      try {
        _establishedDate = DateTime.parse(school['established_date']);
      } catch (e) {
        // Ignored
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _logoImage = File(image.path);
        _isUploadingLogo = true;
      });

      try {
        final response = await ApiService.uploadImage(image);
        final respStr = await response.stream.bytesToString();
        final jsonResp = json.decode(respStr);

        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() {
            _logoUrl = jsonResp['url'];
            _isUploadingLogo = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ሎጎ በተሳካ ሁኔታ ተጭኗል')),
          );
        } else {
          throw Exception(jsonResp['message'] ?? 'Upload failed');
        }
      } catch (e) {
        setState(() => _isUploadingLogo = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ሎጎ መጫን አልተቻለም: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isUploadingLogo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('እባክዎ ሎጎው እስኪጫን ይጠብቁ...')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final schoolData = {
      'name': _nameController.text.trim(),
      'pastor_name': _pastorController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'service_times': _serviceTimesController.text.trim(),
      'description': _descriptionController.text.trim(),
      'is_active': _isActive,
      'established_date': _establishedDate?.toIso8601String().split('T')[0],
      // New
      'motto': _mottoController.text.trim(),
      'founding_year': _foundingYearController.text.trim(),
      'logo_url': _logoUrl,
    };

    final result =
        await SystemAdminService.updateSchool(widget.school['id'], schoolData);

    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ትምህርት ቤቱ በተሳካ ሁኔታ ተዘምኗል!'), // ተተርጉሟል
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // ወደ ኋላ ይመለሳል
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectEstablishedDate() async {
    final initialDate = _establishedDate != null
        ? EthiopianDate.fromGregorian(_establishedDate!)
        : EthiopianDate.now();

    final pickedEth = await showDialog<EthiopianDate>(
      context: context,
      builder: (context) => EthiopianDatePickerDialog(
        initialDate: initialDate,
      ),
    );

    if (pickedEth != null) {
      final picked = pickedEth.toGregorian();
      if (picked != _establishedDate) {
        setState(() => _establishedDate = picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ትምህርት ቤት ያርትዑ'),
        actions: [
          IconButton(
            icon: _isSubmitting
                ? const CircularProgressIndicator()
                : const Icon(Icons.save),
            onPressed: _isSubmitting ? null : _submitForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _logoImage != null
                          ? FileImage(_logoImage!)
                          : (_logoUrl != null
                              ? NetworkImage(_logoUrl!)
                              : const AssetImage(
                                      'assets/icon/launcher_logo.png')
                                  as ImageProvider),
                      backgroundColor: Colors.grey[200],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: _isUploadingLogo
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // የመሰረታዊ መረጃ ክፍል
              const Text(
                'መሰረታዊ መረጃ', // ተተርጉሟል
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'የትምህርት ቤቱ ስም *', // ተተርጉሟል
                  border: OutlineInputBorder(),
                  hintText: 'የትምህርት ቤቱን ስም ያስገቡ', // ተተርጉሟል
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'እባክዎ የትምህርት ቤቱን ስም ያስገቡ'; // ተተርጉሟል
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _mottoController,
                decoration: const InputDecoration(
                  labelText: 'መሪ ቃል (Motto)',
                  border: OutlineInputBorder(),
                  hintText: 'የትምህርት ቤቱን መሪ ቃል ያስገቡ',
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _foundingYearController,
                decoration: const InputDecoration(
                  labelText: 'የተመሰረተበት ዓመተ ምህረት',
                  border: OutlineInputBorder(),
                  hintText: 'ምሳሌ፡ 2000',
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _pastorController,
                decoration: const InputDecoration(
                  labelText: 'የፓስተር ስም', // ተተርጉሟል
                  border: OutlineInputBorder(),
                  hintText: 'የፓስተሩን ስም ያስገቡ', // ተተርጉሟል
                ),
              ),

              const SizedBox(height: 16),

              // የሁኔታ መቀየሪያ
              SwitchListTile(
                title: const Text('የትምህርት ቤቱ ሁኔታ'), // ተተርጉሟል
                subtitle: Text(_isActive ? 'ንቁ' : 'ንቁ ያልሆነ'), // ተተርጉሟል
                value: _isActive,
                onChanged: (value) {
                  setState(() => _isActive = value);
                },
              ),

              const SizedBox(height: 16),

              // የመገኛ መረጃ ክፍል
              const Text(
                'የመገኛ መረጃ', // ተተርጉሟል
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'የኢሜይል አድራሻ', // ተተርጉሟል
                  border: OutlineInputBorder(),
                  hintText: 'school@example.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'ስልክ ቁጥር', // ተተርጉሟል
                  border: OutlineInputBorder(),
                  hintText: '+251-XXX-XXXXXX',
                ),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'አካላዊ አድራሻ', // ተተርጉሟል
                  border: OutlineInputBorder(),
                  hintText: 'የትምህርት ቤቱን አድራሻ ያስገቡ', // ተተርጉሟል
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // ተጨማሪ መረጃ ክፍል
              const Text(
                'ተጨማሪ መረጃ', // ተተርጉሟል
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _serviceTimesController,
                decoration: const InputDecoration(
                  labelText: 'የአገልግሎት ሰዓታት', // ተተርጉሟል
                  border: OutlineInputBorder(),
                  hintText:
                      'እሁድ: 2:30 - የህጻናት አገልግሎት, 4:00 - የወጣቶች አገልግሎት', // ተተርጉሟል
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'መግለጫ', // ተተርጉሟል
                  border: OutlineInputBorder(),
                  hintText: 'ስለ ትምህርት ቤቱ አጭር መግለጫ...', // ተተርጉሟል
                ),
                maxLines: 4,
              ),

              const SizedBox(height: 16),

              // የተቋቋመበት ቀን
              ListTile(
                title: const Text('የተቋቋመበት ቀን'), // ተተርጉሟል
                subtitle: Text(
                  _establishedDate != null
                      ? '${_establishedDate!.year}-${_establishedDate!.month.toString().padLeft(2, '0')}-${_establishedDate!.day.toString().padLeft(2, '0')}'
                      : 'ቀን ይምረጡ', // ተተርጉሟል
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectEstablishedDate,
              ),

              const SizedBox(height: 32),

              // የማስገቢያ አዝራር
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'ትምህርት ቤቱን ያዘምኑ', // ተተርጉሟል
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pastorController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _serviceTimesController.dispose();
    _descriptionController.dispose();
    _mottoController.dispose();
    _foundingYearController.dispose();
    super.dispose();
  }
}
