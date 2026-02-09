import 'dart:convert';
import 'dart:io';

import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart'; // Import for EthiopianDate
// Import for EthiopianDatePickerDialog
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CreateSchoolScreen extends StatefulWidget {
  const CreateSchoolScreen({super.key});

  @override
  State<CreateSchoolScreen> createState() => _CreateSchoolScreenState();
}

class _CreateSchoolScreenState extends State<CreateSchoolScreen> {
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

  EthiopianDate? _establishedDate; // Use EthiopianDate for state
  bool _isSubmitting = false;

  // Logo Upload
  File? _logoImage;
  String? _logoUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isUploadingLogo = false;

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
      'established_date': _establishedDate?.toDatabaseString(),
      'motto': _mottoController.text.trim(),
      'founding_year': _foundingYearController.text.trim(),
      'logo_url': _logoUrl,
    };

    final result = await SystemAdminService.createSchool(schoolData);

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('ትምህርት ቤቱ በተሳካ ሁኔታ ተፈጥሯል!',
                  style: GoogleFonts.notoSansEthiopic())),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      }
    }
  }

  // --- MODIFIED TO USE ETHIOPIAN DATE PICKER ---
  Future<void> _selectEstablishedDate() async {
    final EthiopianDate? picked = await showDialog<EthiopianDate>(
      context: context,
      builder: (context) => EthiopianDatePickerDialog(
        initialDate: _establishedDate ?? EthiopianDate.now(),
      ),
    );
    if (picked != null && picked != _establishedDate) {
      setState(() => _establishedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('አዲስ ትምህርት ቤት ፍጠር', style: GoogleFonts.notoSansEthiopic()),
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
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('የትምህርት ቤት ሎጎ (አማራጭ)'),
              )),
              const SizedBox(height: 24),

              // Basic Information Section
              Text(
                'መሰረታዊ መረጃ',
                style: GoogleFonts.notoSansEthiopic(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'የትምህርት ቤቱ ስም *',
                  labelStyle: GoogleFonts.notoSansEthiopic(),
                  border: const OutlineInputBorder(),
                  hintText: 'የትምህርት ቤቱን ስም ያስገቡ',
                  hintStyle: GoogleFonts.notoSansEthiopic(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'እባክዎ የትምህርት ቤቱን ስም ያስገቡ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _mottoController,
                decoration: InputDecoration(
                  labelText: 'መሪ ቃል (Motto)',
                  labelStyle: GoogleFonts.notoSansEthiopic(),
                  border: const OutlineInputBorder(),
                  hintText: 'የትምህርት ቤቱን መሪ ቃል ያስገቡ',
                  hintStyle: GoogleFonts.notoSansEthiopic(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _foundingYearController,
                decoration: InputDecoration(
                  labelText: 'የተመሰረተበት ዓመተ ምህረት',
                  labelStyle: GoogleFonts.notoSansEthiopic(),
                  border: const OutlineInputBorder(),
                  hintText: 'ምሳሌ፡ 2000',
                  hintStyle: GoogleFonts.notoSansEthiopic(),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _pastorController,
                decoration: InputDecoration(
                  labelText: 'የፓስተር ስም',
                  labelStyle: GoogleFonts.notoSansEthiopic(),
                  border: const OutlineInputBorder(),
                  hintText: 'የፓስተሩን ስም ያስገቡ',
                  hintStyle: GoogleFonts.notoSansEthiopic(),
                ),
              ),

              const SizedBox(height: 24),

              // Contact Information Section
              Text(
                'የዕውቂያ መረጃ',
                style: GoogleFonts.notoSansEthiopic(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'የኢሜል አድራሻ',
                  labelStyle: GoogleFonts.notoSansEthiopic(),
                  border: const OutlineInputBorder(),
                  hintText: 'school@example.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'ስልክ ቁጥር',
                  labelStyle: GoogleFonts.notoSansEthiopic(),
                  border: const OutlineInputBorder(),
                  hintText: '+251-XXX-XXXXXX',
                ),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'አካላዊ አድራሻ',
                  labelStyle: GoogleFonts.notoSansEthiopic(),
                  border: const OutlineInputBorder(),
                  hintText: 'የትምህርት ቤቱን አድራሻ ያስገቡ',
                  hintStyle: GoogleFonts.notoSansEthiopic(),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // Additional Information Section
              Text(
                'ተጨማሪ መረጃ',
                style: GoogleFonts.notoSansEthiopic(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _serviceTimesController,
                decoration: InputDecoration(
                  labelText: 'የአገልግሎት ሰዓታት',
                  labelStyle: GoogleFonts.notoSansEthiopic(),
                  border: const OutlineInputBorder(),
                  hintText:
                      'እሑድ፡ 8:30 ጥዋት - የልጆች አገልግሎት፣ 10:00 ጥዋት - የወጣቶች አገልግሎት',
                  hintStyle: GoogleFonts.notoSansEthiopic(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'መግለጫ',
                  labelStyle: GoogleFonts.notoSansEthiopic(),
                  border: const OutlineInputBorder(),
                  hintText: 'ስለ ትምህርት ቤቱ አጭር መግለጫ...',
                  hintStyle: GoogleFonts.notoSansEthiopic(),
                ),
                maxLines: 4,
              ),

              const SizedBox(height: 16),

              // Established Date
              ListTile(
                title: Text('የተቋቋመበት ቀን (ሙሉ ቀን)',
                    style: GoogleFonts.notoSansEthiopic()),
                subtitle: Text(
                  _establishedDate != null
                      ? _establishedDate.toString()
                      : 'ቀን ይምረጡ (አማራጭ)',
                  style: GoogleFonts.notoSansEthiopic(),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectEstablishedDate,
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
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
                      : Text(
                          'ትምህርት ቤት ፍጠር',
                          style: GoogleFonts.notoSansEthiopic(fontSize: 16),
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
