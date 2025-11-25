// lib/users screen/login.dart

import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';
import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/auth_service.dart';
import 'package:amde_haymanot_abalat_guday/services/tenant_service.dart';
import 'package:amde_haymanot_abalat_guday/providers/tenant_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// ... (Your color constants and StatefulWidget definition)
const Color primaryLoginColor = Color.fromARGB(255, 1, 37, 100);
const Color accentLoginColor = Color(0xFFFFD700);

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
// ... (Your state variables and initState method)
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _selectedTenantId;
  String? _selectedTenantName;
  List<TenantSummary> _tenants = [];
  bool _tenantsLoading = true;
  String? _tenantsError;

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

  // This is your original _signIn method
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

    final result = await AuthService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      tenantName: _selectedTenantName!,
    );

    if (!mounted) return;

    if (result['success']) {
      final data = result['data'];
      Provider.of<TenantProvider>(context, listen: false)
          .setTenant(data['tenant']);
      await Provider.of<UserProvider>(context, listen: false)
          .handleSuccessfulAuth();
      if (mounted) context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${l10n.loginFailedPrefix}${result['message']}'),
            backgroundColor: Colors.red),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // ... (Rest of your original login.dart file)
  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  Widget _buildLanguageToggle(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isAmharic = languageProvider.currentLocale.languageCode == 'am';
        return OutlinedButton.icon(
          onPressed: () => languageProvider.toggleLocale(),
          icon: const Icon(Icons.translate, size: 20),
          label: Text(isAmharic ? 'English' : 'አማርኛ'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            side: const BorderSide(color: Colors.white30),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: primaryLoginColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 16,
              right: 16,
              child: _buildLanguageToggle(context),
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
                        const Icon(Icons.lock_open_rounded,
                            size: 80, color: accentLoginColor),
                        const SizedBox(height: 24),
                        Text(l10n.loginWelcome,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSansEthiopic(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(l10n.loginPrompt,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSansEthiopic(
                                fontSize: 16, color: Colors.white70)),
                        const SizedBox(height: 32),
                        _buildTenantsDropdown(),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: _buildInputDecoration(
                              labelText: l10n.loginEmail,
                              prefixIcon: Icons.email),
                          style: const TextStyle(color: Colors.black87),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return l10n.errorRequiredField;
                            if (!value.contains('@'))
                              return l10n.errorInvalidEmail;
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: _buildInputDecoration(
                              labelText: l10n.loginPassword,
                              prefixIcon: Icons.lock,
                              isPassword: true),
                          style: const TextStyle(color: Colors.black87),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return l10n.errorRequiredField;
                            if (value.length < 6)
                              return l10n.loginPasswordLengthError;
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {/* Forgot password logic */},
                            child: Text(l10n.loginForgotPassword,
                                style: TextStyle(color: accentLoginColor)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentLoginColor,
                            foregroundColor: primaryLoginColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 3, color: primaryLoginColor))
                              : Text(l10n.loginButton,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.loginNoAccount,
                                style: GoogleFonts.notoSansEthiopic(
                                    color: Colors.white70)),
                            TextButton(
                              onPressed: () => context.go('/signup'),
                              child: Text(l10n.signupButton,
                                  style: GoogleFonts.notoSansEthiopic(
                                      color: accentLoginColor,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
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
    );
  }

  InputDecoration _buildInputDecoration(
      {required String labelText,
      required IconData prefixIcon,
      bool isPassword = false}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.black54),
      prefixIcon: Icon(prefixIcon, color: Colors.black54),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black54),
              onPressed: _togglePasswordVisibility,
            )
          : null,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLoginColor, width: 2)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildTenantsDropdown() {
    final l10n = AppLocalizations.of(context)!;
    final dropdownDecoration = _buildInputDecoration(
        labelText: l10n.loginSchoolName, prefixIcon: Icons.school);

    if (_tenantsLoading) {
      return DropdownButtonFormField<String>(
        hint: Text(l10n.loginLoadingSchools,
            style: TextStyle(color: Colors.black54)),
        decoration: dropdownDecoration,
        items: const [],
        onChanged: null,
        icon: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_tenantsError != null || _tenants.isEmpty) {
      return Column(
        children: [
          DropdownButtonFormField<String>(
            hint: Text(l10n.loginNoSchoolsAvailable,
                style: TextStyle(color: Colors.black54)),
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
                        style: TextStyle(color: accentLoginColor))),
              ],
            ),
          )
        ],
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedTenantId,
      hint: Text(l10n.loginSchoolName,
          style: const TextStyle(color: Colors.black54)),
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
      icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
      style: const TextStyle(color: Colors.black87),
      validator: (value) => value == null ? l10n.errorRequiredField : null,
      decoration: dropdownDecoration,
    );
  }
}
