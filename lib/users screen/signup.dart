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

  // Step 5: Custom Fields (New)
  List<Map<String, dynamic>> _customFields = [];
  final Map<String, String> _customFieldValues = {};
  bool _isLoadingCustomFields = false;
  final _step5FormKey = GlobalKey<FormState>();

  // Step 6: Pledge (Renamed from Step 5)
  bool _hasAgreed = false;

  late Future<List<TenantSummary>> _tenantsFuture;

  // State for localized fields
  final _otherResponsibilityController = TextEditingController();
  String? _selectedAcademicLevel;
  bool _attemptedSubmit = false;

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
    _otherResponsibilityController.dispose();
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
    try {
      final fields = await AuthService.getTenantCustomFields(tenantId);
      setState(() {
        // Filter out ADMIN managed fields for user signup
        _customFields = fields
            .where((f) => f['managed_by'] == 'USER' || f['managed_by'] == null)
            .toList();

        _customFieldValues.clear();
        for (var f in _customFields) {
          // Initialize with empty string for mandatory fields
          _customFieldValues[f['id'].toString()] = '';
        }
      });
    } catch (e) {
      debugPrint("Error fetching custom fields: $e");
    } finally {
      setState(() => _isLoadingCustomFields = false);
    }
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
    setState(() => _attemptedSubmit = true);
    if (!_hasAgreed) return;

    // Validate current step before final submission
    final currentKey = _getStepFormKey(_currentStep);
    if (currentKey != null && !currentKey.currentState!.validate()) {
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
      academicLevel: _selectedAcademicLevel ?? '',
      parentName: _parentNameController.text.trim(),
      parentPhone: _parentPhoneController.text.trim(),
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

  GlobalKey<FormState>? _getStepFormKey(int step) {
    switch (step) {
      case 0:
        return _step1FormKey;
      case 1:
        return _step2FormKey;
      case 2:
        return _step3FormKey;
      case 3:
        return _step4FormKey;
      case 4:
        return _step5FormKey;
      default:
        return null;
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
          borderSide: BorderSide(color: Colors.white.withAlpha(0x1A))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: premiumGold, width: 1.5)),
      filled: true,
      fillColor: Colors.white.withAlpha(0x14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.signupCreateAccount,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              premiumDark,
              const Color(0xFF16162D),
              premiumDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      _buildHeader(l10n),
                      const SizedBox(height: 20),
                      _buildCurrentStep(l10n),
                      const SizedBox(height: 40),
                      _buildNavigationButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(6, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? premiumGold
                    : Colors.white.withAlpha(0x0D),
                borderRadius: BorderRadius.circular(2),
                boxShadow: index <= _currentStep
                    ? [
                        BoxShadow(
                          color: premiumGold.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 0),
                        )
                      ]
                    : [],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    String title = '';
    String subtitle = '';

    switch (_currentStep) {
      case 0:
        title = l10n.signupStepAccountTitle;
        subtitle = l10n.signupStepAccountSubtitle;
        break;
      case 1:
        title = l10n.signupStepPersonalTitle;
        subtitle = l10n.signupStepPersonalSubtitle;
        break;
      case 2:
        title = l10n.signupStepGuardianTitle;
        subtitle = l10n.signupStepGuardianSubtitle;
        break;
      case 3:
        title = l10n.signupStepServiceTitle;
        subtitle = l10n.signupStepServiceSubtitle;
        break;
      case 4:
        title = l10n.signupStepAdditionalTitle;
        subtitle = l10n.signupStepAdditionalSubtitle;
        break;
      case 5:
        title = l10n.signupStepPledgeTitle;
        subtitle = l10n.signupStepPledgeSubtitle;
        break;
    }

    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white60,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCurrentStep(AppLocalizations l10n) {
    Widget content;
    switch (_currentStep) {
      case 0:
        content = _buildStep1Content(l10n);
        break;
      case 1:
        content = _buildStep2Content(l10n);
        break;
      case 2:
        content = _buildStep3Content(l10n);
        break;
      case 3:
        content = _buildStep4Content(l10n);
        break;
      case 4:
        content = _buildStep5Content(l10n);
        break;
      case 5:
        content = _buildStep6Content(l10n);
        break;
      default:
        content = const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<int>(_currentStep),
        child: content,
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final l10n = AppLocalizations.of(context)!;
    final isLastStep = _currentStep == 5;

    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _currentStep--),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                l10n.signupButtonBack,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _currentStep == 5 ? _onFormSubmitted : _onStepContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: premiumGold,
              foregroundColor: premiumDark,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 8,
              shadowColor: premiumGold.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF0F0F1E)),
                    ),
                  )
                : Text(
                    isLastStep
                        ? l10n.signupButtonCreateAccount
                        : l10n.signupButtonNextStep,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  void _onStepContinue() {
    final l10n = AppLocalizations.of(context)!;
    bool isValid = false;
    switch (_currentStep) {
      case 0:
        isValid = _step1FormKey.currentState?.validate() ?? false;
        if (isValid && _selectedTenantId != null) {
          _fetchCustomFields(_selectedTenantId!);
        }
        break;
      case 1:
        isValid = _step2FormKey.currentState?.validate() ?? false;
        break;
      case 2:
        isValid = _step3FormKey.currentState?.validate() ?? false;
        break;
      case 3:
        isValid = _step4FormKey.currentState?.validate() ?? false;
        break;
      case 4:
        isValid = _step5FormKey.currentState?.validate() ?? false;
        break;
      case 5:
        isValid = _hasAgreed;
        break;
    }

    if (isValid) {
      if (_currentStep < 5) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 5 && !_hasAgreed) {
      _showError(l10n.signupErrorAgreeRequired);
    }
  }

  // STEP 1 CONTENT
  Widget _buildStep1Content(AppLocalizations l10n) {
    return Form(
      key: _step1FormKey,
      child: Column(
        children: [
          _buildFieldContainer(
            child: FutureBuilder<List<TenantSummary>>(
              future: _tenantsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                  ));
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Text(l10n.signupSchoolSelectionError,
                      style: GoogleFonts.poppins(color: Colors.redAccent));
                }
                return DropdownButtonFormField<String>(
                  initialValue: _selectedTenantId,
                  hint: Text(l10n.loginSchoolName,
                      style:
                          GoogleFonts.notoSansEthiopic(color: Colors.white70)),
                  isExpanded: true,
                  items: snapshot.data!
                      .map((school) => DropdownMenuItem(
                          value: school.id, child: Text(school.name)))
                      .toList(),
                  onChanged: (val) {
                    setState(() => _selectedTenantId = val);
                    if (val != null) _fetchCustomFields(val);
                  },
                  validator: (v) =>
                      v == null ? l10n.signupErrorSelectSchool : null,
                  style: GoogleFonts.notoSansEthiopic(color: Colors.white),
                  decoration: _buildInputDecoration(
                      labelText: l10n.signupSelectSchool,
                      prefixIcon: Icons.school),
                  dropdownColor: const Color(0xFF1C2230),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldContainer(
            child: TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(
                  labelText: l10n.signupEmailAddress, prefixIcon: Icons.email),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.errorRequiredField;
                final emailRegex =
                    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                if (!emailRegex.hasMatch(v)) return l10n.signupInvalidEmail;
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldContainer(
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(
                labelText: l10n.signupPassword,
                prefixIcon: Icons.lock,
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
                  return l10n.signupPasswordLengthError;
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldContainer(
            child: TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(
                labelText: l10n.signupConfirmPassword,
                prefixIcon: Icons.lock,
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
                  return l10n.signupPasswordsDoNotMatch;
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2 CONTENT
  Widget _buildStep2Content(AppLocalizations l10n) {
    return Form(
      key: _step2FormKey,
      child: Column(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: premiumGold, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white10,
                    backgroundImage: _profileImageFile != null
                        ? FileImage(File(_profileImageFile!.path))
                            as ImageProvider
                        : null,
                    child: _profileImageFile == null
                        ? Icon(Icons.person_add_alt_1,
                            size: 40, color: premiumGold)
                        : null,
                  ),
                ),
                Material(
                  color: premiumGold,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _pickProfileImage,
                    customBorder: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.camera_alt,
                          color: Color(0xFF0F0F1E), size: 18),
                    ),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildFieldContainer(
            child: TextFormField(
              controller: _fullNameController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(
                  labelText: l10n.signupLabelFullName,
                  prefixIcon: Icons.person),
              validator: (v) =>
                  (v == null || v.isEmpty) ? l10n.errorRequiredField : null,
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldContainer(
            child: TextFormField(
              controller: _christianNameController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(
                  labelText: l10n.signupLabelChristianName,
                  prefixIcon: Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldContainer(
            child: TextFormField(
              controller: _confessionFatherController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(
                  labelText: l10n.signupLabelConfessionFather,
                  prefixIcon: Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldContainer(
            child: DropdownButtonFormField<String>(
              initialValue: _selectedAcademicLevel,
              isExpanded: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              dropdownColor: const Color(0xFF1C2230),
              decoration: _buildInputDecoration(
                  labelText: l10n.signupLabelAcademicLevel,
                  prefixIcon: Icons.school_outlined),
              items: [
                'Primary School',
                'High School',
                'Preparatory',
                'Certificate',
                'Diploma',
                'Degree',
                'Masters',
                'PhD',
                'Other'
              ]
                  .map((l) => DropdownMenuItem(
                      value: l, child: Text(_getAcademicLevelLabel(l, l10n))))
                  .toList(),
              onChanged: (val) => setState(() => _selectedAcademicLevel = val),
              validator: (v) =>
                  (v == null || v.isEmpty) ? l10n.errorRequiredField : null,
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldContainer(
            child: TextFormField(
              controller: _motherNameController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(
                  labelText: l10n.signupLabelMotherName,
                  prefixIcon: Icons.family_restroom),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFieldContainer(
                  child: DropdownButtonFormField<String>(
                    initialValue: _gender,
                    hint: Text(l10n.signupLabelGender,
                        style: const TextStyle(color: Colors.white70)),
                    items: ['Male', 'Female']
                        .map((g) => DropdownMenuItem(
                            value: g, child: Text(_getGenderLabel(g, l10n))))
                        .toList(),
                    onChanged: (val) => setState(() => _gender = val),
                    validator: (v) => (v == null || v.isEmpty)
                        ? l10n.errorRequiredField
                        : null,
                    decoration: _buildInputDecoration(
                        labelText: l10n.signupLabelGender),
                    dropdownColor: const Color(0xFF1C2230),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFieldContainer(
                  child: TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    style: const TextStyle(color: Colors.white),
                    onTap: () => _selectEthiopianDate(
                        _dobController, (d) => _selectedDob = d),
                    decoration: _buildInputDecoration(
                        labelText: l10n.profileDob,
                        prefixIcon: Icons.calendar_today),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 3 CONTENT
  Widget _buildStep3Content(AppLocalizations l10n) {
    return Form(
      key: _step3FormKey,
      child: Column(
        children: [
          _buildFieldContainer(
            child: TextFormField(
              controller: _parentNameController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration(
                  labelText: l10n.signupLabelParentName,
                  prefixIcon: Icons.person_pin),
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldContainer(
            child: TextFormField(
              controller: _parentPhoneController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: _buildInputDecoration(
                  labelText: l10n.signupLabelParentPhone,
                  prefixIcon: Icons.phone_android),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 4 CONTENT
  Widget _buildStep4Content(AppLocalizations l10n) {
    return Form(
      key: _step4FormKey,
      child: Column(
        children: [
          _buildFieldContainer(
            child: CheckboxListTile(
              onChanged: (val) =>
                  setState(() => _hadPreviousService = val ?? false),
              title: Text(
                l10n.signupPreviousServiceCheck,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              value: _hadPreviousService,
              activeColor: premiumGold,
              checkColor: premiumDark,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          if (_hadPreviousService) ...[
            const SizedBox(height: 20),
            _buildFieldContainer(
              child: DropdownButtonFormField<String>(
                value: _previousDepartment,
                hint: Text(l10n.signupLabelDept,
                    style: const TextStyle(color: Colors.white70)),
                isExpanded: true,
                dropdownColor: const Color(0xFF1C2230),
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                    labelText: l10n.signupLabelDept, prefixIcon: Icons.work),
                items: serviceDepartments
                    .map((d) => DropdownMenuItem(
                        value: d, child: Text(_getDepartmentLabel(d, l10n))))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _previousDepartment = val;
                    _previousResponsibility = null;
                  });
                },
                validator: (v) =>
                    (_hadPreviousService && (v == null || v.isEmpty))
                        ? l10n.errorRequiredField
                        : null,
              ),
            ),
            if (_previousDepartment == 'Other') ...[
              const SizedBox(height: 16),
              _buildFieldContainer(
                child: TextFormField(
                  controller: _otherDepartmentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    labelText: l10n.signupOtherSpecify,
                  ),
                  validator: (v) => (_previousDepartment == 'Other' &&
                          (v == null || v.isEmpty))
                      ? l10n.errorRequiredField
                      : null,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildFieldContainer(
              child: DropdownButtonFormField<String>(
                value: _previousResponsibility,
                hint: Text(l10n.signupLabelResponsibility,
                    style: const TextStyle(color: Colors.white70)),
                isExpanded: true,
                dropdownColor: const Color(0xFF1C2230),
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                    labelText: l10n.signupLabelResponsibility,
                    prefixIcon: Icons.assignment_ind),
                items: (_previousDepartment == 'ፅህፈት ቤት'
                        ? officeResponsibilities
                        : generalResponsibilities)
                    .map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(_getResponsibilityLabel(r, l10n))))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _previousResponsibility = val),
                validator: (v) =>
                    (_hadPreviousService && (v == null || v.isEmpty))
                        ? l10n.errorRequiredField
                        : null,
              ),
            ),
            if (_previousResponsibility == 'Other') ...[
              const SizedBox(height: 16),
              _buildFieldContainer(
                child: TextFormField(
                  controller: _otherResponsibilityController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    labelText: l10n.signupOtherSpecify,
                  ),
                  validator: (v) => (_previousResponsibility == 'Other' &&
                          (v == null || v.isEmpty))
                      ? l10n.errorRequiredField
                      : null,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // STEP 5 CONTENT
  Widget _buildStep5Content(AppLocalizations l10n) {
    return Form(
      key: _step5FormKey,
      child: Column(
        children: [
          if (_isLoadingCustomFields)
            const Center(
                child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            ))
          else if (_customFields.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: premiumGold),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.signupNoCustomFields,
                      style: const TextStyle(
                          color: Colors.white70, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._customFields.map((field) {
              final options = field['options'] as List<dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildFieldContainer(
                  child: DropdownButtonFormField<String>(
                    initialValue:
                        (_customFieldValues[field['id'].toString()] != null &&
                                _customFieldValues[field['id'].toString()]!
                                    .isNotEmpty &&
                                options.any((opt) =>
                                    opt['id'].toString() ==
                                    _customFieldValues[field['id'].toString()]))
                            ? _customFieldValues[field['id'].toString()]
                            : null,
                    isExpanded: true,
                    style: GoogleFonts.notoSansEthiopic(color: Colors.white),
                    items: options.map<DropdownMenuItem<String>>((opt) {
                      return DropdownMenuItem<String>(
                        value: opt['id'].toString(),
                        child: Text(
                          opt['option_value'],
                          style: GoogleFonts.notoSansEthiopic(),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        if (val != null) {
                          _customFieldValues[field['id'].toString()] = val;
                        }
                      });
                    },
                    decoration: _buildInputDecoration(labelText: field['name']),
                    dropdownColor: const Color(0xFF1C2230),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? l10n.commonRequired : null,
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStep6Content(AppLocalizations l10n) {
    return FutureBuilder<List<TenantSummary>>(
      future: _tenantsFuture,
      builder: (context, snapshot) {
        String schoolDisplay = "...";
        if (snapshot.hasData && _selectedTenantId != null) {
          try {
            schoolDisplay = snapshot.data!
                .firstWhere((t) => t.id == _selectedTenantId)
                .name;
          } catch (_) {}
        }

        final pledgeText = l10n.signupPledgeText(
          _christianNameController.text.isNotEmpty
              ? _christianNameController.text
              : "...",
          schoolDisplay,
        );

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Text(
                pledgeText,
                style: GoogleFonts.notoSansEthiopic(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            if (!_hasAgreed && _attemptedSubmit)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.signupErrorAgreeRequired,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            CheckboxListTile(
              value: _hasAgreed,
              onChanged: (val) => setState(() => _hasAgreed = val ?? false),
              title: Text(
                l10n.signupPledgeAgree,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              activeColor: premiumGold,
              checkColor: premiumDark,
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        );
      },
    );
  }

  Widget _buildFieldContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  String _getDepartmentLabel(String dept, AppLocalizations l10n) {
    switch (dept) {
      case 'ትምህርት ክፍል':
        return l10n.deptEducation;
      case 'መዝሙር ክፍል':
        return l10n.deptMusic;
      case 'ኪነጥበብ ክፍል':
        return l10n.deptArt;
      case 'ልማት ክፍል':
        return l10n.deptDevelopment;
      case 'ቁጥጥር ክፍል':
        return l10n.deptAudit;
      case 'መብዓና መስተነግዶ':
        return l10n.deptOffering;
      case 'አባላት ጉዳይ':
        return l10n.deptMembers;
      case 'ሂሳብ ክፍል':
        return l10n.deptFinance;
      case 'ፅህፈት ቤት':
        return l10n.deptOffice;
      case 'ግንኙነት ክፍል':
        return l10n.deptRelation;
      case 'ቤተ መጻሕፍት ክፍል':
        return l10n.deptLibrary;
      case 'ንብረት ክፍል':
        return l10n.deptProperty;
      case 'ሚዲያ ክፍል':
        return l10n.deptMedia;
      case 'Other':
        return l10n.deptOther;
      default:
        return dept;
    }
  }

  String _getResponsibilityLabel(String resp, AppLocalizations l10n) {
    switch (resp) {
      case 'ተጠሪ':
        return l10n.respCoordinator;
      case 'ንዑስ':
        return l10n.respSub;
      case 'አባል':
        return l10n.respMember;
      case 'ሰብሳቢ':
        return l10n.respChair;
      case 'ምክትል ሰብሳቢ':
        return l10n.respViceChair;
      case 'ፀሀፊ':
        return l10n.respSecretary;
      case 'Other':
        return l10n.deptOther;
      default:
        return resp;
    }
  }

  String _getAcademicLevelLabel(String level, AppLocalizations l10n) {
    switch (level) {
      case 'Primary School':
        return l10n.academicLevelPrimary;
      case 'High School':
        return l10n.academicLevelHighSchool;
      case 'Preparatory':
        return l10n.academicLevelPreparatory;
      case 'Certificate':
        return l10n.academicLevelCertificate;
      case 'Diploma':
        return l10n.academicLevelDiploma;
      case 'Degree':
        return l10n.academicLevelDegree;
      case 'Masters':
        return l10n.academicLevelMasters;
      case 'PhD':
        return l10n.academicLevelPhD;
      case 'Other':
        return l10n.academicLevelOther;
      default:
        return level;
    }
  }

  String _getGenderLabel(String gender, AppLocalizations l10n) {
    switch (gender) {
      case 'Male':
        return l10n.genderMale;
      case 'Female':
        return l10n.genderFemale;
      default:
        return gender;
    }
  }
}
