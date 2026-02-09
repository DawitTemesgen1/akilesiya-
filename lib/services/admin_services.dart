// lib/services/admin_service.dart

import 'package:amde_haymanot_abalat_guday/services/api_service.dart';

import 'dart:convert';

class AdminService {
  // This helper function is used by all methods for consistent error handling.
  static Future<Map<String, dynamic>> _handleRequest(
      Future<dynamic> request) async {
    try {
      final response = await request;
      final body = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': body['data'] ?? body};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'An API error occurred.'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  // Fetches all users for various admin screens.
  static Future<Map<String, dynamic>> getAllUsers() {
    return _handleRequest(ApiService.get('/admin/users'));
  }

  // Fetches users who are eligible to become Plan Admins.
  static Future<Map<String, dynamic>> getPlanAdminCandidates() {
    return _handleRequest(ApiService.get('/admin/plan-admin-candidates'));
  }

  // Fetches users who are eligible to become Development Admins.
  static Future<Map<String, dynamic>> getDevelopmentAdminCandidates() {
    return _handleRequest(
        ApiService.get('/admin/development-admin-candidates'));
  }

  // The single, unified function to add or remove any role from a user.
  static Future<Map<String, dynamic>> updateUserRoles({
    required String userId,
    required String role,
    required String action, // 'add' or 'remove'
  }) {
    return _handleRequest(ApiService.post('/admin/update-user-roles', {
      'userId': userId,
      'role': role,
      'action': action,
    }));
  }

  // This function is included for completeness if you have a general user update feature.
  static Future<Map<String, dynamic>> updateUser(
      String userId, Map<String, dynamic> data) {
    return _handleRequest(ApiService.put('/admin/users/$userId', data));
  }
}
