/// ===========================================================================
/// FILE: lib/services/auth_service.dart
/// PURPOSE: Handles all authentication-related API calls, including login,
/// registration, and fetching the current user's profile.
/// ===========================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;

import 'package:amde_haymanot_abalat_guday/services/api_service.dart';

/// A service class responsible for communicating with the backend's authentication endpoints.
class AuthService {
  /// Authenticates a user with their email, password, and school name.
  ///
  /// On success, it saves the received JWT token and returns the user and tenant data.
  /// On failure, it returns a message detailing the error.
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
        final token = data['data']['token'];
        if (token != null) {
          await ApiService.saveToken(token);
        }
        // Return the full data payload which includes the token and tenant info
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Invalid credentials provided.'
        };
      }
    } catch (e) {
      developer.log('Login Exception: $e', name: 'AuthService');
      return {
        'success': false,
        'message': 'Could not connect to the server. Please check your network.'
      };
    }
  }

  /// Registers a new user with their profile data and an optional profile image.
  ///
  /// This method constructs a multipart request to send both form data and an image file.
  /// It correctly sends each piece of profile data as a separate field to match the backend's expectations.
  static Future<Map<String, dynamic>> register({
    required Map<String, dynamic> userProfileData,
    XFile? profileImageFile,
  }) async {
    try {
      final uri = Uri.parse('${ApiService.baseUrl}/auth/register');
      var request = http.MultipartRequest('POST', uri);

      // --- THE CRITICAL FIX ---
      // Instead of sending one large JSON string, this loop iterates through the
      // userProfileData map and adds each key-value pair as an individual field.
      // This is the format your Node.js backend is expecting.
      userProfileData.forEach((key, value) {
        // Ensure all values are sent as strings, handling nulls gracefully
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Handle the profile image file upload if one was selected
      if (profileImageFile != null) {
        // The field name 'profile_image' must match the name expected by multer on your backend.
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            profileImageFile.path,
          ),
        );
      }

      // Send the request and wait for the response
      var streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final data = json.decode(responseBody);

      // Check for a successful creation status code (201)
      if (streamedResponse.statusCode == 201 && data['success'] == true) {
        final token = data['data']['token'];
        if (token != null) {
          await ApiService.saveToken(token);
        }
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed. Please try again.'
        };
      }
    } catch (e) {
      developer.log('Register Exception: $e', name: 'AuthService');
      return {
        'success': false,
        'message': 'Could not connect to the server. Please check your network.'
      };
    }
  }

  /// Fetches the full profile of the currently authenticated user.
  ///
  /// This is called by the `UserProvider` during app initialization to verify the
  /// token and retrieve user data. Throws an exception on failure, which
  /// triggers the logout process in the provider.
  static Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await ApiService.get('/auth/me');
      final body = json.decode(response.body);

      // A robust check for both status code and the success flag from the API
      if (response.statusCode == 200 && body['success'] == true) {
        // The UserProvider expects the entire response map to check for 'success' itself.
        return body;
      } else {
        // If the server returns an error (e.g., 401, 404) or `success: false`,
        // throw an exception with the server's message.
        throw Exception(
            body['message'] ?? 'Failed to fetch user profile from server.');
      }
    } catch (e) {
      // Catches network errors, JSON parsing errors, or the exception thrown above.
      developer.log('GetMe Exception: $e', name: 'AuthService');
      // Re-throw the exception so the calling UserProvider knows something went wrong.
      throw Exception(
          'Could not fetch user profile. Your session may have expired.');
    }
  }
}
