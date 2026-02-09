import 'package:amde_haymanot_abalat_guday/providers/user_provider.dart';
import 'package:amde_haymanot_abalat_guday/providers/tenant_provider.dart';
import 'package:amde_haymanot_abalat_guday/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

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

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      setState(() => _errorMessage = "Please enter a valid 6-digit code.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.verifyOtp(email: widget.email, otp: otp);

      if (result['success'] == true) {
        if (mounted) {
          if (widget.isRegistration && widget.password != null) {
            // For registration with password from signup, automatically set password
            await _handleSetPassword();
          } else if (widget.isRegistration) {
            // For registration without password, show password input
            setState(() {
              _otpVerified = true;
              _isLoading = false;
            });
          } else {
            // For password reset, go directly to home
            context.read<TenantProvider>().setTenant(result['data']['tenant']);
            await context.read<UserProvider>().handleSuccessfulAuth();
            context.go('/home');
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = result['message'] ?? "Verification failed.";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "An unexpected error occurred.");
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
        setState(() => _errorMessage = "Please fill in all fields.");
        return;
      }

      if (password.length < 6) {
        setState(
            () => _errorMessage = "Password must be at least 6 characters.");
        return;
      }

      if (password != confirmPassword) {
        setState(() => _errorMessage = "Passwords do not match.");
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.setPassword(
        email: widget.email,
        password: password,
      );

      if (result['success'] == true) {
        if (mounted) {
          // Now login with the new password
          final loginResult = await AuthService.login(
            email: widget.email,
            password: password,
            tenantName: '', // Will be set from login response
          );

          if (loginResult['success'] == true) {
            final data = loginResult['data'];
            context.read<TenantProvider>().setTenant(data['tenant']);
            await context.read<UserProvider>().handleSuccessfulAuth();
            context.go('/home');
          } else {
            setState(() => _errorMessage =
                "Login failed. Please try logging in manually.");
          }
        }
      } else {
        if (mounted) {
          setState(() =>
              _errorMessage = result['message'] ?? "Failed to set password.");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "An unexpected error occurred.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResend() async {
    setState(() => _isLoading = true);
    final result = await AuthService.resendOtp(email: widget.email);
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['message'] ?? 'OTP Resent'),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color.fromARGB(255, 1, 37, 100);
    const accentColor = Color(0xFFFFD700);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _otpVerified ? Iconsax.lock : Iconsax.message_text,
                size: 64,
                color: accentColor,
              ),
              const SizedBox(height: 24),
              Text(
                _otpVerified ? 'Set Your Password' : 'Verify Email Address',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _otpVerified
                    ? 'Create a secure password for your account'
                    : 'Enter the code sent to ${widget.email}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),

              // DEV MODE: Show OTP for testing
              if (kDebugMode && !_otpVerified) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    border: Border.all(color: Colors.orange, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.developer_mode,
                              color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'DEV MODE',
                            style: GoogleFonts.poppins(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check backend console for OTP code',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 16),
              if (!_otpVerified) ...[
                // OTP Input Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold),
                    maxLength: 6,
                    decoration: const InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      hintText: "------",
                      hintStyle: TextStyle(color: Colors.white24),
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ] else ...[
                // Password Input Fields
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Colors.white54),
                      contentPadding: const EdgeInsets.all(16),
                      prefixIcon: const Icon(Iconsax.lock, color: accentColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                          color: Colors.white70,
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
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Confirm Password",
                      hintStyle: const TextStyle(color: Colors.white54),
                      contentPadding: const EdgeInsets.all(16),
                      prefixIcon: const Icon(Iconsax.lock, color: accentColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Iconsax.eye_slash
                              : Iconsax.eye,
                          color: Colors.white70,
                        ),
                        onPressed: () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                  ),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_otpVerified ? _handleSetPassword : _handleVerify),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    disabledBackgroundColor: accentColor.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: primaryColor),
                        )
                      : Text(
                          _otpVerified ? 'Complete Registration' : 'Verify',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                ),
              ),
              if (!_otpVerified) ...[
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _isLoading ? null : _handleResend,
                  child: Text(
                    'Didn\'t receive code? Resend',
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
