// lib/services/user_admin_service.dart

import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class UserAdminService {
  // This is your original helper function. It correctly returns the full JSON map.
  static Future<Map<String, dynamic>> _handleResponse(
      Future<http.Response> futureResponse) async {
    try {
      final response = await futureResponse;
      final body = json.decode(response.body);
      return body as Map<String, dynamic>;
    } catch (e) {
      debugPrint("API Service Error in UserAdminService: $e");
      return {
        'success': false,
        'message': 'Failed to communicate with the server.'
      };
    }
  }

  // --- ALL YOUR ORIGINAL METHODS ARE PRESERVED UNCHANGED ---

  static Future<Map<String, dynamic>> getUsers({required bool isVerified}) {
    return _handleResponse(
        ApiService.get('/user-admin/users?verified=$isVerified'));
  }

  static Future<Map<String, dynamic>> getUserDetailsForAdmin(String userId) {
    return _handleResponse(ApiService.get('/user-admin/users/$userId'));
  }

  static Future<Map<String, dynamic>> getProfileSettings() {
    return _handleResponse(ApiService.get('/user-admin/profile-settings'));
  }

  static Future<Map<String, dynamic>> getAuditLogs() {
    return _handleResponse(ApiService.get('/user-admin/audit-logs'));
  }

  static Future<Map<String, dynamic>> getUsersWithUnreviewedChanges() {
    return _handleResponse(ApiService.get('/user-admin/change-logs/summary'));
  }

  static Future<Map<String, dynamic>> getChangeLogForUser(String userId) {
    return _handleResponse(ApiService.get('/user-admin/change-logs/$userId'));
  }

  static Future<Map<String, dynamic>> markLogsAsReviewed(String userId) {
    return _handleResponse(
        ApiService.put('/user-admin/change-logs/$userId/review', {}));
  }

  // This function has a custom implementation, so it is left as is.
  static Future<List<dynamic>> getAllUsers() async {
    final response = await ApiService.get('/user-admin/users');
    final data = json.decode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'] as List<dynamic>;
    } else {
      throw Exception(data['message'] ?? 'Failed to load users');
    }
  }

  // This function has a custom implementation, so it is left as is.
  static Future<void> updateUserRoles({
    required String userId,
    required bool shouldBeAdmin,
    required String role,
  }) async {
    final response = await ApiService.put('/user-admin/users/$userId/roles', {
      'shouldBeAdmin': shouldBeAdmin,
      'role': role,
    });
    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Failed to update user roles');
    }
  }

  static Future<Map<String, dynamic>> updateProfileSettings(
      Map<String, bool> settings) {
    return _handleResponse(
        ApiService.put('/user-admin/profile-settings', settings));
  }

  static Future<Map<String, dynamic>> verifyUser(String userId) {
    return _handleResponse(
        ApiService.put('/user-admin/users/$userId/verify', {}));
  }

  // This function has a custom implementation, so it is left as is.
  static Future<void> updateAttendanceAdminRole(
      {required String userId, required bool shouldBeAdmin}) async {
    final response = await ApiService.put(
        '/user-admin/users/$userId/roles/attendance-admin', {
      'shouldBeAdmin': shouldBeAdmin,
    });
    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(
          data['message'] ?? 'Failed to update attendance admin role');
    }
  }

  static Future<Map<String, dynamic>> updateUserByAdmin(
      {required String userId, required Map<String, dynamic> updates}) {
    return _handleResponse(
        ApiService.put('/user-admin/users/$userId', updates));
  }

  // =======================================================
  // --- NEW FUNCTIONS CORRECTED TO USE YOUR ESTABLISHED PATTERN ---
  // =======================================================

  /// Fetches high-level statistics about users and admins.
  static Future<Map<String, dynamic>> getUserStats() {
    // Corrected to use your existing _handleResponse method.
    return _handleResponse(ApiService.get('/admin/user-stats'));
  }

  /// Fetches a filterable list of all users for the cockpit.
  /// NOTE: This returns a Map because _handleResponse returns a Map.
  /// The calling UI will need to extract the 'data' key which contains the List.
  static Future<Map<String, dynamic>> getDetailedUsers({
    String? search,
    String? role,
    String? spiritualClass,
  }) {
    Map<String, String> queryParams = {};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (role != null && role.isNotEmpty) queryParams['role'] = role;
    if (spiritualClass != null && spiritualClass.isNotEmpty) {
      queryParams['spiritualClass'] = spiritualClass;
    }

    // Corrected to use your existing _handleResponse method.
    return _handleResponse(
        ApiService.get('/admin/detailed-users', queryParams: queryParams));
  }

  /// Fetches every detail about a single user for the detail/print screen.
  static Future<Map<String, dynamic>> getFullUserDetail(String userId) {
    // Corrected to use your existing _handleResponse method.
    return _handleResponse(ApiService.get('/admin/user-detail/$userId'));
  }
}
