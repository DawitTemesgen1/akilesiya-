import 'dart:io';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/services/tenant_service.dart';
import 'package:amde_haymanot_abalat_guday/services/auth_service.dart';
import 'package:amde_haymanot_abalat_guday/models/ethiopian_date_picker.dart';
import 'package:amde_haymanot_abalat_guday/providers/tenant_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';

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
  'אבאלאט ጉዳይ',
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

  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();
  final _step4FormKey = GlobalKey<FormState>();

  // Step 1
  String? _selectedTenantId;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Step 2
  final _fullNameController = TextEditingController();
  final _christianNameController = TextEditingController();
  final _confessionFatherController = TextEditingController();
  final _motherNameController = TextEditingController();
  String? _gender;
  final _ageController = TextEditingController();
  final _academicLevelController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  EthiopianDate? _selectedDob;
  XFile? _profileImageFile;

  // Step 3
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();

  // Step 4: Service History
  bool _hadPreviousService = false;
  String? _previousDepartment;
  final _otherDepartmentController = TextEditingController();
  String? _previousResponsibility;
  String? _previousServiceLevel;

  // Step 5: Agreement
  bool _hasAgreed = false;

  late Future<List<TenantSummary>> _tenantsFuture;
  List<String> _availableResponsibilities = generalResponsibilities;

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
    _phoneController.dispose();
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

  // --- FIX: THIS IS THE CORRECTED SUBMISSION LOGIC ---
  Future<void> _onFormSubmitted() async {
    // Validate all form steps before proceeding
    if (!(_step1FormKey.currentState?.validate() ?? false)) {
      _showError('Please complete all required fields in the Account step.');
      setState(() => _currentStep = 0); // Go back to the invalid step
      return;
    }
    if (!(_step2FormKey.currentState?.validate() ?? false)) {
      _showError('Please complete all required fields in the Personal step.');
      setState(() => _currentStep = 1);
      return;
    }
    // Note: Steps 3 and 4 (Guardian/Service) might not have required fields, so validation is optional
    // but good practice if they become mandatory.

    if (!_hasAgreed) {
      _showError('You must agree to the pledge to complete registration.');
      setState(() => _currentStep = 4);
      return;
    }

    setState(() => _isLoading = true);

    // Your backend's registerUser function expects the school's NAME, not its ID.
    // We must find the name from the list of tenants we fetched earlier.
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

    // This map contains all the fields your backend is expecting individually.
    final userProfileData = {
      'tenantName': selectedTenantName, // Crucially, send the name
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'fullName': _fullNameController.text.trim(),
      'christianName': _christianNameController.text.trim(),
      'confessionFatherName': _confessionFatherController.text.trim(),
      'motherName': _motherNameController.text.trim(),
      'gender': _gender,
      'age': _ageController.text.trim(),
      'academicLevel': _academicLevelController.text.trim(),
      'phoneNumber': _phoneController.text.trim(),
      'dob': _selectedDob?.toDatabaseString(),
      'parentName': _parentNameController.text.trim(),
      'parentPhoneNumber': _parentPhoneController.text.trim(),
      'hadPreviousService': _hadPreviousService,
      'previousDepartment': _previousDepartment == 'Other'
          ? _otherDepartmentController.text.trim()
          : _previousDepartment,
      'previousResponsibility': _previousResponsibility,
      'previousServiceLevel': _previousServiceLevel,
    };

    // This call now works because the (corrected) AuthService will send each field separately.
    final result = await AuthService.register(
      userProfileData: userProfileData,
      profileImageFile: _profileImageFile, // Pass the image file
    );

    if (mounted) {
      if (result['success']) {
        final data = result['data'];
        Provider.of<TenantProvider>(context, listen: false)
            .setTenant(data['tenant']);
        Provider.of<UserProvider>(context, listen: false)
            .handleSuccessfulAuth();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    bool showServiceLevel = _hadPreviousService &&
        _previousResponsibility != null &&
        !responsibilitiesWithoutLevel.contains(_previousResponsibility);

    return Scaffold(
      backgroundColor: primarySignupColor,
      appBar: AppBar(
          title: Text(l10n.signupCreateAccount),
          backgroundColor: Colors.transparent,
          elevation: 0),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        onStepContinue: () {
          bool isStepValid = false;
          if (_currentStep == 0)
            isStepValid = _step1FormKey.currentState?.validate() ?? false;
          if (_currentStep == 1)
            isStepValid = _step2FormKey.currentState?.validate() ?? false;
          if (_currentStep == 2)
            isStepValid = _step3FormKey.currentState?.validate() ?? false;
          if (_currentStep == 3)
            isStepValid = _step4FormKey.currentState?.validate() ?? false;
          if (_currentStep == 4) isStepValid = true;

          if (isStepValid) {
            if (_currentStep < 4) {
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
                ? const Center(
                    child: CircularProgressIndicator(color: accentSignupColor))
                : Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12.0,
                    children: [
                      if (_currentStep > 0)
                        TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('BACK')),
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        child: Text(_currentStep == 4 ? 'FINISH' : 'NEXT'),
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
        ],
      ),
    );
  }

  Step _buildStep1(AppLocalizations l10n) {
    return Step(
      title: const Text('Account'),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _step1FormKey,
        child: Column(
          children: [
            Text('First, select your school and create your login credentials.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70)),
            const SizedBox(height: 24),
            FutureBuilder<List<TenantSummary>>(
              future: _tenantsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: accentSignupColor));
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return Text('Could not load schools.',
                      style: GoogleFonts.poppins(color: Colors.redAccent));
                }
                return DropdownButtonFormField<String>(
                  value: _selectedTenantId,
                  hint: Text(l10n.loginSchoolName,
                      style: GoogleFonts.notoSansEthiopic()),
                  items: snapshot.data!
                      .map((school) => DropdownMenuItem(
                          value: school.id, child: Text(school.name)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedTenantId = val),
                  validator: (v) =>
                      v == null ? 'Please select your school' : null,
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: l10n.signupEmail),
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.errorRequiredField;
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v))
                  return l10n.errorInvalidEmail;
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: l10n.signupPassword),
                obscureText: true,
                validator: (v) =>
                    (v?.length ?? 0) < 6 ? l10n.errorPasswordTooShort : null),
            const SizedBox(height: 16),
            TextFormField(
                controller: _confirmPasswordController,
                decoration:
                    InputDecoration(labelText: l10n.signupConfirmPassword),
                obscureText: true,
                validator: (v) => v != _passwordController.text
                    ? l10n.errorPasswordsDoNotMatch
                    : null),
          ],
        ),
      ),
    );
  }

  Step _buildStep2(AppLocalizations l10n) {
    return Step(
      title: const Text('Personal'),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _step2FormKey,
        child: Column(
          children: [
            Text(
                'Please fill in your personal details as per the registration form.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70)),
            const SizedBox(height: 24),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white24,
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
                    color: accentSignupColor,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _pickProfileImage,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.camera_alt,
                            color: primarySignupColor, size: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                    labelText: '1. Full Name (with Grandfather)*'),
                validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            TextFormField(
                controller: _christianNameController,
                decoration:
                    const InputDecoration(labelText: '2. Christian Name')),
            const SizedBox(height: 16),
            TextFormField(
                controller: _confessionFatherController,
                decoration: const InputDecoration(
                    labelText: '3. Confession Father\'s Name')),
            const SizedBox(height: 16),
            TextFormField(
                controller: _motherNameController,
                decoration:
                    const InputDecoration(labelText: '4. Mother\'s Name')),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _gender,
                    hint: const Text('5. Gender'),
                    items: ['Male', 'Female']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) => setState(() => _gender = val),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
                controller: _academicLevelController,
                decoration:
                    const InputDecoration(labelText: '6. Academic Level')),
            const SizedBox(height: 16),
            TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: '8. Phone Number'),
                keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dobController,
              readOnly: true,
              decoration: const InputDecoration(
                  labelText: '10. Date of Birth (Ethiopian)',
                  suffixIcon: Icon(Icons.calendar_today)),
              onTap: () => _selectEthiopianDate(
                  _dobController, (date) => _selectedDob = date),
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
                decoration: const InputDecoration(
                    labelText: '1. Parent/Guardian\'s Name')),
            const SizedBox(height: 16),
            TextFormField(
                controller: _parentPhoneController,
                decoration: const InputDecoration(
                    labelText: '5. Parent/Guardian\'s Phone'),
                keyboardType: TextInputType.phone),
          ],
        ),
      ),
    );
  }

  Step _buildStep4(AppLocalizations l10n, {required bool showServiceLevel}) {
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
            SwitchListTile(
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
              activeColor: accentSignupColor,
            ),
            if (_hadPreviousService) ...[
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _previousDepartment,
                hint: Text('የሚያገለግሉበት ክፍል',
                    style: GoogleFonts.notoSansEthiopic()),
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
              ),
              if (_previousDepartment == 'Other') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _otherDepartmentController,
                  decoration: InputDecoration(
                      labelText: 'Please specify other department',
                      labelStyle: GoogleFonts.poppins()),
                  validator: (v) =>
                      _previousDepartment == 'Other' && (v == null || v.isEmpty)
                          ? 'Required'
                          : null,
                ),
              ],
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _previousResponsibility,
                hint: Text('የሚያገለግሉት ኃላፊነት',
                    style: GoogleFonts.notoSansEthiopic()),
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
              ),
              if (showServiceLevel) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _previousServiceLevel,
                  hint: Text('Service Level', style: GoogleFonts.poppins()),
                  items: serviceLevels
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _previousServiceLevel = val),
                  validator: (v) => showServiceLevel && v == null
                      ? 'Please select a level'
                      : null,
                ),
              ]
            ],
          ],
        ),
      ),
    );
  }

  Step _buildStep5(AppLocalizations l10n) {
    const pledgeText =
        "እኔ ... እውነተኛይቱ የኢትዮጵያ ኦርቶዶክስ ተዋህዶ ቤ/ያን እምነትና ስርዓት ተከታይ የሆንኩኝ ... በፍፁም ልብ ለማገልገል ... ቃል እየገባሁ ... የበኩሌን ሁሉ ለመወጣት ቃል እገባለሁ።";
    return Step(
      title: const Text('Agreement'),
      isActive: _currentStep >= 4,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Membership Pledge',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              border: Border.all(color: Colors.white30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              child: Text(pledgeText,
                  style: GoogleFonts.notoSansEthiopic(
                      height: 1.7, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('I have read and agree to the pledge.'),
            value: _hasAgreed,
            onChanged: (val) => setState(() => _hasAgreed = val ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: accentSignupColor,
          ),
        ],
      ),
    );
  }
}
