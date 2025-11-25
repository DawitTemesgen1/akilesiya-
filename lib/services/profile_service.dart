// lib/services/profile_service.dart

import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Assuming you might need this for profile picture uploads

class ProfileService {
  // This helper function ensures every response is a standard Map.
  static Future<Map<String, dynamic>> _handleResponse(
      Future<http.Response> futureResponse) async {
    try {
      final response = await futureResponse;
      debugPrint(
          "--- PROFILE SERVICE RAW RESPONSE ---\n${response.body}\n--------------------");

      if (response.body.isEmpty) {
        return {
          'success': false,
          'message': 'Server returned an empty response.'
        };
      }
      final body = json.decode(response.body);
      return body as Map<String, dynamic>;
    } catch (e) {
      debugPrint("API Service Error in ProfileService: $e");
      return {
        'success': false,
        'message':
            'Failed to communicate with the server or parse the response.'
      };
    }
  }

  // =======================================================
  // --- CORRECTED 'getMyProfile' FUNCTION ---
  // =======================================================
  /// Fetches the complete profile for the currently logged-in user.
  /// It now uses the same robust _handleResponse helper as your other methods.
  static Future<Map<String, dynamic>> getMyProfile() {
    return _handleResponse(ApiService.get('/profile/me'));
  }

  // --- YOUR EXISTING METHODS (UNCHANGED) ---

  static Future<Map<String, dynamic>> updateMyProfile(
      Map<String, dynamic> data) {
    return _handleResponse(ApiService.put('/profile/me', data));
  }

  static Future<Map<String, dynamic>> getMyAttendance() {
    return _handleResponse(ApiService.get('/profile/my-attendance'));
  }

  static Future<Map<String, dynamic>> getMyGrades() {
    return _handleResponse(ApiService.get('/profile/my-grades'));
  }

  static Future<Map<String, dynamic>> getMyBooks() {
    return _handleResponse(ApiService.get('/profile/my-books'));
  }

  static Future<Map<String, dynamic>> updateBookStatus(
      String assignedBookId, bool isRead) {
    return _handleResponse(ApiService.put(
      '/profile/my-books/$assignedBookId',
      {'isRead': isRead},
    ));
  }

  // Example of how you might handle profile picture uploads, consistent with your style
  static Future<Map<String, dynamic>> uploadProfilePicture(
      XFile imageFile) async {
    try {
      final streamedResponse = await ApiService.upload(
        '/profile/me/avatar',
        fields: {},
        file: imageFile,
        fieldName: 'profile_image',
      );

      final response = await http.Response.fromStream(streamedResponse);
      final body = json.decode(response.body);
      return body as Map<String, dynamic>;
    } catch (e) {
      debugPrint("API Service Error in ProfileService (upload): $e");
      return {'success': false, 'message': 'Image upload failed.'};
    }
  }
}
