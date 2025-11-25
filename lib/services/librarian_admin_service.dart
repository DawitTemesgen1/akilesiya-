// lib/services/librarian_admin_service.dart

import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart'; // Ensure this path is correct

class LibrarianAdminService {
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
        'message': (body is Map && body.containsKey('message'))
            ? body['message']
            : 'An API error occurred.'
      };
    } catch (e) {
      // This is where your "DOCTYPE" error is being caught.
      print("Failed to decode JSON. Server likely sent HTML. Full error: $e");
      return {
        'success': false,
        'message': 'Network Error: Server response was not valid JSON.'
      };
    }
  }

  /// Fetches all users with their library roles.
  static Future<Map<String, dynamic>> getUsersWithLibraryRoles() async {
    // ======================= THE FIX =======================
    // The URL now correctly points to the route defined in adminRoutes.js
    return _handleRequest(ApiService.get('/admin/library-admins/users'));
    // =======================================================
  }

  /// Updates a user's library roles.
  static Future<Map<String, dynamic>> updateUserLibraryRoles({
    required String userId,
    required bool isLibrarian,
    required bool isLibraryAdmin,
  }) async {
    // ======================= THE FIX =======================
    // The URL now correctly points to the route defined in adminRoutes.js
    return _handleRequest(ApiService.put(
      '/admin/library-admins/users/$userId/roles', // <-- CORRECTED URL
      {
        'isLibrarian': isLibrarian,
        'isLibraryAdmin': isLibraryAdmin,
      },
    ));
    // =======================================================
  }
}
