import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/tenant_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/auth_service.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:amde_haymanot_abalat_guday/l10n/app_localizations.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final String? password; // Optional password from signup
  final bool isRegistration; // Flag to determine if this is registration flow

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.password,
    this.isRegistration = true, // Default to registration flow
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _otpVerified = false; // Track if OTP has been verified
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String? _loadingStatus; // Specific status for long loads

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      setState(() => _errorMessage = "INVALID_CODE");
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _loadingStatus = l10n.otpVerifyButton; // "Verifying..."
      _errorMessage = null;
    });

    try {
      final result = await AuthService.verifyOtp(email: widget.email, otp: otp);

      if (result['success'] == true) {
        if (!mounted) return;
        if (widget.isRegistration && widget.password != null) {
          // For registration with password from signup, automatically set password
          await _handleSetPassword();
        } else {
          // Both Registration (no password) and Forgot Password should show password fields
          setState(() {
            _otpVerified = true;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = result['message'] ?? "VERIFICATION_FAILED";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "UNKNOWN_ERROR");
      }
    } finally {
      if (mounted && !_otpVerified) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSetPassword() async {
    // Use password from signup if available, otherwise use input fields
    final password = widget.password ?? _passwordController.text.trim();
    final confirmPassword =
        widget.password ?? _confirmPasswordController.text.trim();

    // Only validate input fields if password wasn't provided from signup
    if (widget.password == null) {
      if (password.isEmpty || confirmPassword.isEmpty) {
        setState(() => _errorMessage = "FILL_ALL_FIELDS");
        return;
      }

      if (password.length < 6) {
        setState(() => _errorMessage = "PASSWORD_TOO_SHORT");
        return;
      }

      if (password != confirmPassword) {
        setState(() => _errorMessage = "PASSWORDS_DONT_MATCH");
        return;
      }
    }

    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _loadingStatus = l10n.otpSetPasswordTitle; // "Saving password..."
      _errorMessage = null;
    });

    try {
      if (widget.isRegistration) {
        final result = await AuthService.setPassword(
          email: widget.email,
          password: password,
        );

        if (result['success'] == true) {
          await _performLogin(password);
        } else {
          if (mounted) {
            setState(() =>
                _errorMessage = result['message'] ?? "SET_PASSWORD_FAILED");
          }
        }
      } else {
        // FORGOT PASSWORD FLOW
        final otp = _otpController.text.trim();
        final result = await AuthService.resetPassword(
          email: widget.email,
          otp: otp,
          newPassword: password,
        );

        if (result['success'] == true) {
          await _performLogin(password);
        } else {
          if (mounted) {
            setState(() =>
                _errorMessage = result['message'] ?? "SET_PASSWORD_FAILED");
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "UNKNOWN_ERROR");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _performLogin(String password) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loadingStatus = l10n.loginButton); // "Signing in..."
    try {
      final loginResult = await AuthService.login(
        email: widget.email,
        password: password,
        tenantName: '', // Backend handles tenant lookup by email
      );

      if (!mounted) return;
      if (loginResult['success'] == true) {
        final data = loginResult['data'];
        final tenantProvider = context.read<TenantProvider>();
        final userProvider = context.read<UserProvider>();
        tenantProvider.setTenant(data['tenant']);

        // OPTIMIZATION: Pass profile data directly to skip /auth/me call
        await userProvider.handleSuccessfulAuth(data['user']);
        if (mounted) context.go('/home');
      } else {
        setState(() => _errorMessage = "LOGIN_FAILED");
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = "LOGIN_FAILED");
    }
  }

  Future<void> _handleResend() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    final result = await AuthService.resendOtp(email: widget.email);
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? l10n.otpResentSuccess),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
      ));
    }
  }

  String _getLocalizedError(AppLocalizations l10n, String error) {
    switch (error) {
      case "INVALID_CODE":
        return l10n.otpInvalidCode;
      case "VERIFICATION_FAILED":
        return l10n.otpVerificationFailed;
      case "UNKNOWN_ERROR":
        return l10n.unknownError;
      case "FILL_ALL_FIELDS":
        return l10n.errorRequiredField;
      case "PASSWORD_TOO_SHORT":
        return l10n.errorPasswordTooShort;
      case "PASSWORDS_DONT_MATCH":
        return l10n.errorPasswordsDoNotMatch;
      case "LOGIN_FAILED":
        return l10n.otpLoginFailed;
      case "SET_PASSWORD_FAILED":
        return l10n.otpSetPasswordFailed;
      default:
        return error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const primaryColor = Color.fromARGB(255, 1, 37, 100);
    const accentColor = Color(0xFFFFD700);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _otpVerified ? Iconsax.lock_1 : Iconsax.sms_tracking,
                size: 80,
                color: accentColor,
              ),
              const SizedBox(height: 32),
              Text(
                _otpVerified ? l10n.otpSetPasswordTitle : l10n.otpVerifyTitle,
                style: GoogleFonts.notoSansEthiopic(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _otpVerified
                      ? l10n.otpSetPasswordSubtitle
                      : l10n.otpVerifySubtitle(widget.email),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansEthiopic(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              if (!_otpVerified) ...[
                // OTP Input Field with Glassmorphism
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSansEthiopic(
                      color: Colors.white,
                      fontSize: 32,
                      letterSpacing: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLength: 6,
                    decoration: const InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      hintText: "------",
                      hintStyle: TextStyle(color: Colors.white12),
                      contentPadding: EdgeInsets.symmetric(vertical: 24),
                    ),
                  ),
                ),
              ] else ...[
                // Password Input Fields with Glassmorphism
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.notoSansEthiopic(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: l10n.loginPassword,
                      hintStyle:
                          TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      contentPadding: const EdgeInsets.all(20),
                      prefixIcon: const Icon(Iconsax.lock,
                          color: accentColor, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: GoogleFonts.notoSansEthiopic(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: l10n.signupConfirmPassword,
                      hintStyle:
                          TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      contentPadding: const EdgeInsets.all(20),
                      prefixIcon: const Icon(Iconsax.lock,
                          color: accentColor, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Iconsax.eye_slash
                              : Iconsax.eye,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        onPressed: () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                  ),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getLocalizedError(l10n, _errorMessage!),
                    style: GoogleFonts.notoSansEthiopic(
                        color: Colors.redAccent.shade100, fontSize: 13),
                  ),
                ),
              ],
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_otpVerified ? _handleSetPassword : _handleVerify),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: primaryColor,
                    disabledBackgroundColor: accentColor.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: primaryColor),
                            ),
                            if (_loadingStatus != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _loadingStatus!,
                                style: GoogleFonts.notoSansEthiopic(
                                  fontSize: 10,
                                  color: primaryColor.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ],
                        )
                      : Text(
                          _otpVerified
                              ? l10n.otpCompleteRegistration
                              : l10n.otpVerifyButton,
                          style: GoogleFonts.notoSansEthiopic(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              if (!_otpVerified) ...[
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _isLoading ? null : _handleResend,
                  child: Text(
                    l10n.forgotPasswordResendOtpText,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
