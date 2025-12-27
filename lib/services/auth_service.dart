/// ===========================================================================
/// FILE: lib/services/auth_service.dart
/// PURPOSE: Handles Phone + Password/OTP authentication API calls.
/// ===========================================================================

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:amde_haymanot_abalat_guday/services/api_service.dart';

class AuthService {
  /// LOGIN with Email + Password
  ///
  /// Traditional login with credentials.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String tenantName,
  }) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
        'tenantName': tenantName,
      });

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Save token
        final token = data['data']['token'];
        if (token != null) {
          await ApiService.saveToken(token);
        }
        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'data': data['data']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed.'
        };
      }
    } catch (e) {
      developer.log('Login Exception: $e', name: 'AuthService');
      return {
        'success': false,
        'message': 'Connection error. Please try again.'
      };
    }
  }

  /// REGISTER a new user
  ///
  /// Sends name, email, school to backend.
  /// Backend creates inactive user and sends OTP.
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String tenantName,
    String? christianName,
    String? confessionFatherName,
    String? motherName,
    String? gender,
    String? dob,
    String? academicLevel,
    String? parentName,
    String? parentPhone,
    String? spiritualClass,
    Map<String, dynamic>? customFields,
  }) async {
    try {
      final response = await ApiService.post('/auth/register', {
        'fullName': fullName,
        'email': email,
        'tenantName': tenantName,
        'christianName': christianName,
        'confessionFatherName': confessionFatherName,
        'motherName': motherName,
        'gender': gender,
        'dob': dob,
        'academicLevel': academicLevel,
        'parentName': parentName,
        'parentPhone': parentPhone,
        'spiritualClass': spiritualClass,
        'customFields': customFields,
      });

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful. Verify OTP.',
          'data': data['data']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed.'
        };
      }
    } catch (e) {
      developer.log('Register Exception: $e', name: 'AuthService');
      return {
        'success': false,
        'message': 'Connection error. Please try again.'
      };
    }
  }

  /// VERIFY OTP (for registration)
  ///
  /// Sends email + OTP.
  /// Backend verifies OTP.
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await ApiService.post('/auth/verify-otp', {
        'email': email,
        'otp': otp,
      });

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Invalid OTP.'};
      }
    } catch (e) {
      developer.log('Verify OTP Exception: $e', name: 'AuthService');
      return {'success': false, 'message': 'Verification failed.'};
    }
  }

  /// SET PASSWORD after OTP verification
  ///
  /// Completes registration by setting password.
  static Future<Map<String, dynamic>> setPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.post('/auth/set-password', {
        'email': email,
        'password': password,
      });

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to set password.'
        };
      }
    } catch (e) {
      developer.log('Set Password Exception: $e', name: 'AuthService');
      return {'success': false, 'message': 'Failed to set password.'};
    }
  }

  /// FORGOT PASSWORD - Request OTP
  static Future<Map<String, dynamic>> forgotPassword(
      {required String email}) async {
    try {
      final response = await ApiService.post('/auth/forgot-password', {
        'email': email,
      });
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'OTP sent',
          'data': data['data']
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to send OTP'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// RESET PASSWORD with OTP
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.post('/auth/reset-password', {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      });
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to reset password'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// RESEND OTP
  static Future<Map<String, dynamic>> resendOtp({required String email}) async {
    try {
      final response = await ApiService.post('/auth/resend-otp', {
        'email': email,
      });
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'OTP Resent'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to resend'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  /// Fetches the full profile of the currently authenticated user.
  static Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await ApiService.get('/auth/me');
      print("DEBUG AuthService: /auth/me response raw: ${response.body}");
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return body;
      } else {
        throw Exception(body['message'] ?? 'Failed to fetch user profile.');
      }
    } catch (e) {
      developer.log('GetMe Exception: $e', name: 'AuthService');
      throw Exception('Could not fetch user profile.');
    }
  }

  /// Fetch Custom Fields for a Tenant (Public)
  static Future<List<Map<String, dynamic>>> getTenantCustomFields(
      String tenantId) async {
    try {
      final response = await ApiService.get('/tenants/$tenantId/custom-fields');
      final body = json.decode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        return List<Map<String, dynamic>>.from(body['data']);
      } else {
        return [];
      }
    } catch (e) {
      developer.log('Get Custom Fields Exception: $e', name: 'AuthService');
      return [];
    }
  }
}
