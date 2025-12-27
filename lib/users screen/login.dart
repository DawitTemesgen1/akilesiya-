// lib/users screen/login.dart

import 'package:animate_do/animate_do.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:amde_haymanot_abalat_guday/providers/tenant_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/language_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/auth_service.dart';
import 'package:amde_haymanot_abalat_guday/services/tenant_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(); // Renamed from phone
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _selectedTenantId;
  String? _selectedTenantName;
  List<TenantSummary> _tenants = [];
  bool _tenantsLoading = true;
  String? _tenantsError;

  final Color premiumDark = const Color(0xFF0F0F1E);
  final Color premiumGold = const Color(0xFFFFD700);

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  Future<void> _loadTenants() async {
    setState(() {
      _tenantsLoading = true;
      _tenantsError = null;
    });
    try {
      final tenants = await TenantService.getTenants();
      if (!mounted) return;
      setState(() {
        _tenants = tenants;
        if (tenants.isNotEmpty) {
          _selectedTenantId = tenants.first.id;
          _selectedTenantName = tenants.first.name;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(
          () => _tenantsError = "Failed to load schools. Check connection.");
    } finally {
      if (mounted) setState(() => _tenantsLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTenantName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.loginSelectSchoolError),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Call Login API with password
    final result = await AuthService.login(
      email: email,
      password: password,
      tenantName: _selectedTenantName!,
    );

    if (!mounted) return;

    if (result['success']) {
      // Set tenant and authenticate
      final data = result['data'];
      if (data != null && data['tenant'] != null) {
        context.read<TenantProvider>().setTenant(data['tenant']);
      }
      await context.read<UserProvider>().handleSuccessfulAuth();
      if (mounted) context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${result['message']}'), // Use API message
            backgroundColor: Colors.red),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  Widget _buildLanguageToggle(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isAmharic = languageProvider.currentLocale.languageCode == 'am';
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white24),
          ),
          child: InkWell(
            onTap: () => languageProvider.toggleLocale(),
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language, size: 20, color: premiumGold),
                  const SizedBox(width: 8),
                  Text(
                    isAmharic ? 'English' : 'አማርኛ',
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              premiumDark,
              Colors.black,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 16,
                right: 16,
                child: FadeInDown(
                    duration: const Duration(milliseconds: 800),
                    child: _buildLanguageToggle(context)),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo Section
                          ZoomIn(
                            duration: const Duration(milliseconds: 1000),
                            child: Hero(
                              tag: 'app_logo',
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: premiumGold.withOpacity(0.3),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              l10n.loginWelcome,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.notoSansEthiopic(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FadeInUp(
                            delay: const Duration(milliseconds: 300),
                            child: Text(
                              "Login with Email",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.notoSansEthiopic(
                                  fontSize: 16, color: Colors.white70),
                            ),
                          ),
                          const SizedBox(height: 40),

                          FadeInUp(
                            delay: const Duration(milliseconds: 400),
                            child: _buildTenantsDropdown(),
                          ),
                          const SizedBox(height: 16),

                          FadeInUp(
                            delay: const Duration(milliseconds: 500),
                            child: TextFormField(
                              controller: _emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _buildInputDecoration(
                                  labelText: "Email Address",
                                  prefixIcon: Icons.email),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return l10n.errorRequiredField;
                                // Email validation
                                final emailRegex = RegExp(
                                    r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                                if (!emailRegex.hasMatch(value))
                                  return "Invalid email address";
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          FadeInUp(
                            delay: const Duration(milliseconds: 600),
                            child: TextFormField(
                              controller: _passwordController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _buildInputDecoration(
                                  labelText: "Password",
                                  prefixIcon: Icons.lock,
                                  isPassword: true),
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return l10n.errorRequiredField;
                                if (value.length < 6)
                                  return "Password must be at least 6 characters";
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 8),

                          FadeInUp(
                            delay: const Duration(milliseconds: 650),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    context.push('/forgot-password'),
                                child: Text("Forgot Password?",
                                    style: TextStyle(color: premiumGold)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          FadeInUp(
                            delay: const Duration(milliseconds: 700),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: premiumGold,
                                foregroundColor: premiumDark,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                elevation: 8,
                                shadowColor: premiumGold.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 3, color: premiumDark))
                                  : Text("Login",
                                      style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 24),

                          FadeInUp(
                            delay: const Duration(milliseconds: 800),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(l10n.loginNoAccount,
                                    style: GoogleFonts.notoSansEthiopic(
                                        color: Colors.white70)),
                                TextButton(
                                  onPressed: () => context.go('/signup'),
                                  child: Text(l10n.signupButton,
                                      style: GoogleFonts.notoSansEthiopic(
                                          color: premiumGold,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
      {required String labelText,
      required IconData prefixIcon,
      bool isPassword = false}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(prefixIcon, color: premiumGold),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70),
              onPressed: _togglePasswordVisibility,
            )
          : null,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: premiumGold, width: 1.5)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
    );
  }

  Widget _buildTenantsDropdown() {
    final l10n = AppLocalizations.of(context)!;
    final dropdownDecoration = _buildInputDecoration(
        labelText: l10n.loginSchoolName, prefixIcon: Icons.school);

    if (_tenantsLoading) {
      return DropdownButtonFormField<String>(
        hint: Text(l10n.loginLoadingSchools,
            style: TextStyle(color: Colors.white70)),
        decoration: dropdownDecoration,
        items: const [],
        onChanged: null,
        icon: const SizedBox(
            width: 20,
            height: 20,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
      );
    }

    if (_tenantsError != null || _tenants.isEmpty) {
      return Column(
        children: [
          DropdownButtonFormField<String>(
            hint: Text(l10n.loginNoSchoolsAvailable,
                style: TextStyle(color: Colors.white70)),
            decoration: dropdownDecoration.copyWith(
                prefixIcon:
                    const Icon(Icons.error_outline, color: Colors.orange)),
            items: const [],
            onChanged: null,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(_tenantsError ?? l10n.loginNoSchoolsFound,
                        style: const TextStyle(
                            color: Colors.orange, fontSize: 12))),
                TextButton(
                    onPressed: _loadTenants,
                    child: Text(l10n.retryButton,
                        style: TextStyle(color: premiumGold))),
              ],
            ),
          )
        ],
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedTenantId,
      hint: Text(l10n.loginSchoolName,
          style: const TextStyle(color: Colors.white70)),
      isExpanded: true,
      items: _tenants
          .map((tenant) => DropdownMenuItem(
              value: tenant.id,
              child: Text(tenant.name,
                  style: const TextStyle(color: Colors.black87))))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          final selectedTenant = _tenants.firstWhere((t) => t.id == value);
          setState(() {
            _selectedTenantId = value;
            _selectedTenantName = selectedTenant.name;
          });
        }
      },
      dropdownColor: Colors.white,
      icon: Icon(Icons.arrow_drop_down, color: premiumGold),
      style: const TextStyle(color: Colors.black87),
      validator: (value) => value == null ? l10n.errorRequiredField : null,
      decoration: dropdownDecoration,
    );
  }
}
