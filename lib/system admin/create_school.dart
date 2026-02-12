import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/system_admin_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';
import 'package:amde_haymanot_abalat_guday/providers/theme_provider.dart';
import 'package:provider/provider.dart';

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

  EthiopianDate? _establishedDate;
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
            const SnackBar(content: Text('Logo uploaded successfully')),
          );
        } else {
          throw Exception(jsonResp['message'] ?? 'Upload failed');
        }
      } catch (e) {
        setState(() => _isUploadingLogo = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload logo: $e')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isUploadingLogo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please wait while the logo is uploading...')),
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
          const SnackBar(
            content: Text('School created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode(context);
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Glassmorphic App Bar
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () => Navigator.of(context).pop(),
              color: isDark ? Colors.white : Colors.black87,
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Text(
                    'Create School',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            primaryColor.withValues(alpha: 0.2),
                            Colors.black.withValues(alpha: 0.1)
                          ]
                        : [
                            primaryColor.withValues(alpha: 0.1),
                            Colors.white.withValues(alpha: 0.5)
                          ],
                  ),
                ),
              ),
            ),
            actions: [
              if (_isSubmitting)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))))
              else
                IconButton(
                  icon: Icon(Iconsax.add_circle, color: primaryColor),
                  onPressed: _submitForm,
                ),
              const SizedBox(width: 8),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo Section
                    FadeInDown(
                      duration: const Duration(milliseconds: 500),
                      child: Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryColor.withValues(alpha: 0.1),
                                border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    width: 2),
                                image: _logoImage != null
                                    ? DecorationImage(
                                        image: FileImage(_logoImage!),
                                        fit: BoxFit.cover)
                                    : (_logoUrl != null && _logoUrl!.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(_logoUrl!),
                                            fit: BoxFit.cover)
                                        : null),
                              ),
                              child: _logoUrl == null && _logoImage == null
                                  ? Icon(Iconsax.teacher,
                                      size: 40, color: primaryColor)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.1),
                                          blurRadius: 10)
                                    ],
                                  ),
                                  child: _isUploadingLogo
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white))
                                      : const Icon(Iconsax.camera,
                                          color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('School Logo (Optional)',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)))),
                    const SizedBox(height: 32),

                    // Basic Info Section
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      child:
                          _buildSectionTitle('Basic Information', Iconsax.user),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 650),
                      child: _buildTextField(_nameController, 'School Name *',
                          Iconsax.teacher, isDark, primaryColor,
                          validator: (v) =>
                              v?.isEmpty ?? true ? 'Name required' : null),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 700),
                      child: _buildTextField(_mottoController, 'Motto',
                          Iconsax.quote_down, isDark, primaryColor),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 750),
                      child: Row(
                        children: [
                          Expanded(
                              child: _buildTextField(
                                  _foundingYearController,
                                  'Est. Year',
                                  Iconsax.calendar_1,
                                  isDark,
                                  primaryColor,
                                  keyboardType: TextInputType.number)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildTextField(
                                  _pastorController,
                                  'Pastor',
                                  Iconsax.user_tag,
                                  isDark,
                                  primaryColor)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Contact Info Section
                    FadeInUp(
                      duration: const Duration(milliseconds: 850),
                      child: _buildSectionTitle(
                          'Contact & Location', Iconsax.location),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 900),
                      child: _buildTextField(_emailController, 'Email',
                          Iconsax.direct, isDark, primaryColor,
                          keyboardType: TextInputType.emailAddress),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 950),
                      child: _buildTextField(_phoneController, 'Phone',
                          Iconsax.call, isDark, primaryColor,
                          keyboardType: TextInputType.phone),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: _buildTextField(_addressController, 'Address',
                          Iconsax.map, isDark, primaryColor,
                          maxLines: 2),
                    ),
                    const SizedBox(height: 32),

                    // Additional Info Section
                    FadeInUp(
                      duration: const Duration(milliseconds: 1050),
                      child: _buildSectionTitle(
                          'Services & Description', Iconsax.more_square),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1100),
                      child: _buildTextField(
                          _serviceTimesController,
                          'Service Times',
                          Iconsax.timer_1,
                          isDark,
                          primaryColor,
                          maxLines: 2),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1150),
                      child: _buildTextField(
                          _descriptionController,
                          'Description',
                          Iconsax.document_text,
                          isDark,
                          primaryColor,
                          maxLines: 4),
                    ),
                    const SizedBox(height: 16),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1200),
                      child: _buildDateTile('Established Date',
                          Iconsax.calendar, isDark, primaryColor),
                    ),
                    const SizedBox(height: 48),

                    // Create Button
                    FadeInUp(
                      duration: const Duration(milliseconds: 1300),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text('Create School',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 10),
        Text(title,
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool isDark, Color primaryColor,
      {String? Function(String?)? validator,
      TextInputType? keyboardType,
      int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
        prefixIcon:
            Icon(icon, color: primaryColor.withValues(alpha: 0.5), size: 18),
        filled: true,
        fillColor: isDark
            ? Colors.grey[900]!.withValues(alpha: 0.5)
            : Colors.grey[100],
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: primaryColor, width: 1)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildDateTile(
      String label, IconData icon, bool isDark, Color primaryColor) {
    return GestureDetector(
      onTap: _selectEstablishedDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey[900]!.withValues(alpha: 0.5)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryColor.withValues(alpha: 0.5), size: 18),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 14)),
            const Spacer(),
            Text(
              _establishedDate != null
                  ? _establishedDate.toString()
                  : 'Select Date',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
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
