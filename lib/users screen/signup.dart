// lib/users screen/signup.dart

import 'dart:io';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amde_haymanot_abalat_guday/services/tenant_service.dart';
import 'package:amde_haymanot_abalat_guday/services/auth_service.dart';
import 'package:iconsax/iconsax.dart';

// Brand Colors
const Color primarySignupColor = Color.fromARGB(255, 1, 37, 100);
const Color accentSignupColor = Color(0xFFFFD700);

// Data for the Service History Step
const List<String> serviceDepartments = [
  'ትምህርት ክፍል',
  'መዝሙር ክፍል',
  'ኪነጥበብ ክፍል',
  'ልማት ክፍል',
  'ቁጥጥር ክፍል',
  'መብዓና መስተነግዶ',
  'አባላት ጉዳይ',
  'ሂሳብ ክፍል',
  'ፅህፈት ቤት',
  'ግንኙነት ክፍል',
  'ቤተ መጻሕፍት ክፍል',
  'ንብረት ክፍል',
  'ሚዲያ ክፍል',
  'Other'
];
const List<String> officeResponsibilities = ['ሰብሳቢ', 'ምክትል ሰብሳቢ', 'ፀሀፊ'];
const List<String> generalResponsibilities = ['ተጠሪ', 'ንዑስ', 'አባል'];
const List<String> responsibilitiesWithoutLevel = ['ሰብሳቢ', 'ምክትል ሰብሳቢ', 'ፀሀፊ'];
const List<String> serviceLevels = ['Level 1', 'Level 2', 'Level 3'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  final _step1FormKey = GlobalKey<FormState>(); // Account (Phone)
  final _step2FormKey = GlobalKey<FormState>(); // Personal
  final _step3FormKey = GlobalKey<FormState>(); // Guardian
  final _step4FormKey = GlobalKey<FormState>(); // Service
  // Step 5 is Agreement (no form key)

  // Step 1: Account
  String? _selectedTenantId;
  final _emailController = TextEditingController(); // Renamed from phone
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Step 2: Personal
  final _fullNameController = TextEditingController();
  final _christianNameController = TextEditingController();
  final _confessionFatherController = TextEditingController();
  final _motherNameController = TextEditingController();
  String? _gender;
  final _ageController = TextEditingController();
  final _academicLevelController = TextEditingController();
  final _dobController = TextEditingController();
  EthiopianDate? _selectedDob;
  XFile? _profileImageFile;

  // Step 3: Guardian
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();

  // Step 4: Service History
  bool _hadPreviousService = false;
  String? _previousDepartment;
  final _otherDepartmentController = TextEditingController();
  String? _previousResponsibility;
  String? _previousServiceLevel;

  // Step 5: Custom Fields (New)
  List<Map<String, dynamic>> _customFields = [];
  final Map<String, String> _customFieldValues = {};
  bool _isLoadingCustomFields = false;
  final _step5FormKey = GlobalKey<FormState>();

  // Step 6: Pledge (Renamed from Step 5)
  bool _hasAgreed = false;

  late Future<List<TenantSummary>> _tenantsFuture;
  List<String> _availableResponsibilities = generalResponsibilities;

  // Premium Theme Colors matching Login/Start screens
  final Color premiumDark = const Color(0xFF0F0F1E);
  final Color premiumGold = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _tenantsFuture = TenantService.getTenants();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _christianNameController.dispose();
    _confessionFatherController.dispose();
    _motherNameController.dispose();
    _ageController.dispose();
    _academicLevelController.dispose();
    _dobController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _otherDepartmentController.dispose();
    super.dispose();
  }

  Future<void> _selectEthiopianDate(TextEditingController controller,
      Function(EthiopianDate) onDateSelected) async {
    final picked = await showDialog<EthiopianDate>(
      context: context,
      builder: (context) => EthiopianDatePickerDialog(
          initialDate: _selectedDob ?? EthiopianDate.now()),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.toString();
        onDateSelected(picked);
      });
    }
  }

  Future<void> _fetchCustomFields(String tenantId) async {
    setState(() => _isLoadingCustomFields = true);
    final fields = await AuthService.getTenantCustomFields(tenantId);
    setState(() {
      // Filter out ADMIN managed fields for user signup
      _customFields = fields
          .where((f) => f['managed_by'] == 'USER' || f['managed_by'] == null)
          .toList();
      _isLoadingCustomFields = false;
      _customFieldValues.clear();
      // Initialize with empty values if needed, or leave null
    });
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85, maxWidth: 800);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = pickedFile;
      });
    }
  }

  Future<void> _onFormSubmitted() async {
    // Validate Current Step before submitting? Or validate all?
    // User can only reach here if previous steps valid.

    if (!_hasAgreed) {
      _showError('You must agree to the pledge to complete registration.');
      return;
    }

    setState(() => _isLoading = true);

    String? selectedTenantName;
    try {
      final tenants = await _tenantsFuture;
      final selectedTenant =
          tenants.firstWhere((tenant) => tenant.id == _selectedTenantId);
      selectedTenantName = selectedTenant.name;
    } catch (e) {
      _showError("Could not find the selected school. Please try again.");
      setState(() => _isLoading = false);
      return;
    }

    // Call Register API (Email + OTP flow)
    final result = await AuthService.register(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      tenantName: selectedTenantName,
      christianName: _christianNameController.text.trim(),
      confessionFatherName: _confessionFatherController.text.trim(),
      motherName: _motherNameController.text.trim(),
      gender: _gender,
      dob: _dobController.text.trim(),
      academicLevel: _academicLevelController.text.trim(),
      parentName: _parentNameController.text.trim(),
      parentPhone: _parentPhoneController.text.trim(),
      // Combining service info into spiritual class if needed or separate
      // For now, spiritualClass isn't explicitly collected, but we have service history
      // We can map service history if needed, but for now just sending what we have
      customFields: _customFieldValues,
    );

    // Note: Other profile fields are currently not sent to API
    // as we switched to simplified Email Auth.
    // They can be updated later via Edit Profile.

    if (mounted) {
      if (result['success']) {
        // Navigate to OTP Screen with email and password
        context.push('/otp-verify', extra: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        });
      } else {
        _showError(result['message'] ?? 'An unknown error occurred.');
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  InputDecoration _buildInputDecoration(
      {required String labelText, IconData? suffixIcon, IconData? prefixIcon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon:
          prefixIcon != null ? Icon(prefixIcon, color: premiumGold) : null,
      suffixIcon:
          suffixIcon != null ? Icon(suffixIcon, color: premiumGold) : null,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: premiumGold, width: 1.5)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    bool showServiceLevel = _hadPreviousService &&
        _previousResponsibility != null &&
        !responsibilitiesWithoutLevel.contains(_previousResponsibility);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.signupCreateAccount,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.8),
              premiumDark,
              Colors.black,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: premiumGold,
                secondary: premiumGold,
                surface: Colors.transparent,
                onSurface: Colors.white,
              ),
              canvasColor: premiumDark.withValues(alpha: 0.8),
            ),
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepTapped: (step) => setState(() => _currentStep = step),
              onStepContinue: () {
                bool isStepValid = false;
                if (_currentStep == 0) {
                  isStepValid = _step1FormKey.currentState?.validate() ?? false;
                  if (isStepValid && _selectedTenantId != null) {
                    _fetchCustomFields(_selectedTenantId!);
                  }
                }
                if (_currentStep == 1) {
                  isStepValid = _step2FormKey.currentState?.validate() ?? false;
                }
                if (_currentStep == 2) {
                  isStepValid = _step3FormKey.currentState?.validate() ?? false;
                }
                if (_currentStep == 3) {
                  isStepValid = _step4FormKey.currentState?.validate() ?? false;
                }
                if (_currentStep == 4) {
                  isStepValid = _step5FormKey.currentState?.validate() ?? false;
                }
                if (_currentStep == 5) isStepValid = true; // Pledge

                if (isStepValid) {
                  if (_currentStep < 5) {
                    setState(() => _currentStep += 1);
                  } else {
                    _onFormSubmitted();
                  }
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                }
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(color: premiumGold))
                      : Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 12.0,
                          children: [
                            if (_currentStep > 0)
                              OutlinedButton(
                                  onPressed: details.onStepCancel,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white70,
                                    side:
                                        const BorderSide(color: Colors.white30),
                                  ),
                                  child: const Text('BACK')),
                            ElevatedButton(
                              onPressed: details.onStepContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: premiumGold,
                                foregroundColor: premiumDark,
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              child:
                                  Text(_currentStep == 5 ? 'FINISH' : 'NEXT'),
                            ),
                          ],
                        ),
                );
              },
              steps: [
                _buildStep1(l10n),
                _buildStep2(l10n),
                _buildStep3(l10n),
                _buildStep4(l10n, showServiceLevel: showServiceLevel),
                _buildStep5(l10n),
                _buildStep6(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // STEP 1: Account (School + Email)
  Step _buildStep1(AppLocalizations l10n) {
    return Step(
      title: const Text('Account'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _step1FormKey,
        child: Column(
          children: [
            Text('Create your account with email and password.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70)),
            const SizedBox(height: 24),
            FutureBuilder<List<TenantSummary>>(
              future: _tenantsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: premiumGold));
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Text('Could not load schools.',
                      style: GoogleFonts.poppins(color: Colors.redAccent));
                }
                return DropdownButtonFormField<String>(
                  initialValue: _selectedTenantId,
                  hint: Text(l10n.loginSchoolName,
                      style:
                          GoogleFonts.notoSansEthiopic(color: Colors.white70)),
                  items: snapshot.data!
                      .map((school) => DropdownMenuItem(
                          value: school.id, child: Text(school.name)))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _selectedTenantId = val);
                    if (val != null) _fetchCustomFields(val);
                  },
                  validator: (v) =>
                      v == null ? 'Please select your school' : null,
                  decoration: _buildInputDecoration(
                      labelText: "", prefixIcon: Icons.school),
                  dropdownColor: const Color(0xFF1C2230),
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(
                  labelText: "Email Address", prefixIcon: Icons.email),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.errorRequiredField;
                final emailRegex =
                    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                if (!emailRegex.hasMatch(v)) return "Invalid email address";
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(
                labelText: "Password",
                prefixIcon: Icons.lock,
                suffixIcon: Icons.visibility,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: premiumGold,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.errorRequiredField;
                if (v.length < 6) {
                  return "Password must be at least 6 characters";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(
                labelText: "Confirm Password",
                prefixIcon: Icons.lock,
                suffixIcon: Icons.visibility,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: premiumGold,
                  ),
                  onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.errorRequiredField;
                if (v != _passwordController.text) {
                  return "Passwords do not match";
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // STEP 2: Personal Info (Name, etc.)
  Step _buildStep2(AppLocalizations l10n) {
    return Step(
      title: const Text('Personal'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _step2FormKey,
        child: Column(
          children: [
            Text('Please fill in your personal details.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70)),
            const SizedBox(height: 24),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white10,
                    backgroundImage: _profileImageFile != null
                        ? FileImage(File(_profileImageFile!.path))
                            as ImageProvider
                        : null,
                    child: _profileImageFile == null
                        ? const Icon(Icons.person_add_alt_1,
                            size: 60, color: Colors.white70)
                        : null,
                  ),
                  Material(
                    color: premiumGold,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _pickProfileImage,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.camera_alt,
                            color: premiumDark, size: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
                controller: _fullNameController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                    labelText: '1. Full Name (with Grandfather)*'),
                validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            TextFormField(
                controller: _christianNameController,
                style: const TextStyle(color: Colors.white),
                decoration:
                    _buildInputDecoration(labelText: '2. Christian Name')),
            const SizedBox(height: 16),
            TextFormField(
                controller: _confessionFatherController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                    labelText: '3. Confession Father\'s Name')),
            const SizedBox(height: 16),
            TextFormField(
                controller: _motherNameController,
                style: const TextStyle(color: Colors.white),
                decoration:
                    _buildInputDecoration(labelText: '4. Mother\'s Name')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _gender,
                    hint: const Text('5. Gender',
                        style: TextStyle(color: Colors.white70)),
                    items: ['Male', 'Female']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) => setState(() => _gender = val),
                    decoration: _buildInputDecoration(labelText: ""),
                    dropdownColor: const Color(0xFF1C2230),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                      controller: _ageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
                controller: _academicLevelController,
                style: const TextStyle(color: Colors.white),
                decoration:
                    _buildInputDecoration(labelText: '6. Academic Level')),
            const SizedBox(height: 16),
            // Phone removed from here (Moved to Step 1)
            const SizedBox(height: 8),
            // Updated Premium Date of Birth Selector
            InkWell(
              onTap: () => _selectEthiopianDate(
                  _dobController, (date) => _selectedDob = date),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.calendar_1, color: premiumGold, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '10. Date of Birth (Ethiopian)',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            _selectedDob?.toString() ?? 'Select Date',
                            style: GoogleFonts.notoSansEthiopic(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white24, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Step _buildStep3(AppLocalizations l10n) {
    return Step(
      title: const Text('Guardian'),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _step3FormKey,
        child: Column(
          children: [
            Text('If you are under 18, please provide guardian information.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70)),
            const SizedBox(height: 24),
            TextFormField(
                controller: _parentNameController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                    labelText: '1. Parent/Guardian\'s Name')),
            const SizedBox(height: 16),
            TextFormField(
                controller: _parentPhoneController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                    labelText: '5. Parent/Guardian\'s Phone'),
                keyboardType: TextInputType.phone),
          ],
        ),
      ),
    );
  }

  Step _buildStep4(AppLocalizations l10n, {required bool showServiceLevel}) {
    // Service History (Same as before)
    return Step(
      title: const Text('Service'),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _step4FormKey,
        child: Column(
          children: [
            Text('Please provide your past service history, if any.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16)),
              child: SwitchListTile(
                title: Text('ከዚህ በፊት ሲያገለግሉ ነበር?',
                    style: GoogleFonts.notoSansEthiopic(color: Colors.white)),
                value: _hadPreviousService,
                onChanged: (val) {
                  setState(() {
                    _hadPreviousService = val;
                    if (!val) {
                      _previousDepartment = null;
                      _previousResponsibility = null;
                      _previousServiceLevel = null;
                      _otherDepartmentController.clear();
                    }
                  });
                },
                activeThumbColor: premiumGold,
              ),
            ),
            if (_hadPreviousService) ...[
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: _previousDepartment,
                hint: Text('የሚያገለግሉበት ክፍል',
                    style: GoogleFonts.notoSansEthiopic(color: Colors.white70)),
                items: serviceDepartments
                    .map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(d, style: GoogleFonts.notoSansEthiopic())))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _previousDepartment = val;
                    _previousResponsibility = null;
                    _previousServiceLevel = null;
                    if (val == 'ፅህፈት ቤት') {
                      _availableResponsibilities = officeResponsibilities;
                    } else {
                      _availableResponsibilities = generalResponsibilities;
                    }
                  });
                },
                validator: (v) => _hadPreviousService && v == null
                    ? 'Please select a department'
                    : null,
                decoration: _buildInputDecoration(labelText: ""),
                dropdownColor: const Color(0xFF1C2230),
              ),
              if (_previousDepartment == 'Other') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _otherDepartmentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                      labelText: 'Please specify other department'),
                  validator: (v) =>
                      _previousDepartment == 'Other' && (v == null || v.isEmpty)
                          ? 'Required'
                          : null,
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _previousResponsibility,
                hint: Text('የሚያገለግሉት ኃላፊነት',
                    style: GoogleFonts.notoSansEthiopic(color: Colors.white70)),
                items: _availableResponsibilities
                    .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r, style: GoogleFonts.notoSansEthiopic())))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _previousResponsibility = val;
                    if (val != null &&
                        responsibilitiesWithoutLevel.contains(val)) {
                      _previousServiceLevel = null;
                    }
                  });
                },
                validator: (v) => _hadPreviousService && v == null
                    ? 'Please select a responsibility'
                    : null,
                decoration: _buildInputDecoration(labelText: ""),
                dropdownColor: const Color(0xFF1C2230),
              ),
              if (showServiceLevel) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _previousServiceLevel,
                  hint: Text('Service Level',
                      style: GoogleFonts.poppins(color: Colors.white70)),
                  items: serviceLevels
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _previousServiceLevel = val),
                  validator: (v) => showServiceLevel && v == null
                      ? 'Please select a level'
                      : null,
                  decoration: _buildInputDecoration(labelText: ""),
                  dropdownColor: const Color(0xFF1C2230),
                ),
              ]
            ],
          ],
        ),
      ),
    );
  }

  // STEP 5: Custom Fields
  Step _buildStep5(AppLocalizations l10n) {
    return Step(
      title: const Text('More Info'),
      isActive: _currentStep >= 4,
      state: _currentStep > 4 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _step5FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Please provide additional information required by your school.',
                style: GoogleFonts.poppins(color: Colors.white70)),
            const SizedBox(height: 16),
            if (_isLoadingCustomFields)
              Center(child: CircularProgressIndicator(color: premiumGold))
            else if (_customFields.isEmpty)
              Text("No additional information required.",
                  style: GoogleFonts.poppins(
                      color: Colors.white60, fontStyle: FontStyle.italic))
            else
              ..._customFields.map((field) {
                final options = field['options'] as List<dynamic>;
                return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField<String>(
                      initialValue: _customFieldValues[field['id'].toString()],
                      style: GoogleFonts.notoSansEthiopic(color: Colors.white),
                      items: options.map<DropdownMenuItem<String>>((opt) {
                        return DropdownMenuItem<String>(
                          value: opt['id'].toString(),
                          child: Text(opt['option_value'],
                              style: GoogleFonts.notoSansEthiopic()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          if (val != null) {
                            _customFieldValues[field['id'].toString()] = val;
                          }
                        });
                      },
                      decoration:
                          _buildInputDecoration(labelText: field['name']),
                      dropdownColor: const Color(0xFF1C2230),
                      validator: (v) => v == null ? 'Required' : null,
                    ));
              })
          ],
        ),
      ),
    );
  }

  // STEP 6: Pledge
  Step _buildStep6(AppLocalizations l10n) {
    const pledgeText =
        "እኔ ... እውነተኛይቱ የኢትዮጵያ ኦርቶዶክስ ተዋህዶ ቤ/ያን እምነትና ስርዓት ተከታይ የሆንኩኝ ... በፍፁም ልብ ለማገልገል ... ቃል እየገባሁ ... የበኩሌን ሁሉ ለመወጣት ቃል እገባለሁ።";
    return Step(
      title: const Text('Pledge'),
      isActive: _currentStep >= 5,
      state: _currentStep > 5 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Membership Pledge',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: premiumGold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              border: Border.all(color: premiumGold.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: Text(pledgeText,
                  style: GoogleFonts.notoSansEthiopic(
                      height: 1.7, color: Colors.white, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('I have read and agree to the pledge.',
                style: TextStyle(color: Colors.white)),
            value: _hasAgreed,
            onChanged: (val) => setState(() => _hasAgreed = val ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: premiumGold,
            checkColor: premiumDark,
          ),
        ],
      ),
    );
  }
}
