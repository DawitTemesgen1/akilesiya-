// lib/services/library_service.dart

import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:intl/intl.dart'; // <-- ADD THIS IMPORT

class LibraryService {
  static Future<Map<String, dynamic>> _handleRequest(
      Future<dynamic> request) async {
    try {
      final response = await request;
      final body = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (body is Map &&
            body.containsKey('success') &&
            body['success'] == true) {
          return {'success': true, 'data': body['data'] ?? body};
        }
        return {'success': true, 'data': body};
      }
      return {
        'success': false,
        'message': (body is Map && body.containsKey('message'))
            ? body['message']
            : 'An API error occurred.'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getReaders() async {
    return _handleRequest(ApiService.get('/library/readers'));
  }

  static Future<Map<String, dynamic>> getReadingHistory(String userId) async {
    return _handleRequest(ApiService.get('/library/history/$userId'));
  }

  // ======================= THE FIX =======================
  static Future<Map<String, dynamic>> assignBook({
    required String userId,
    required String bookTitle,
    required DateTime finishBy,
  }) async {
    // Format the DateTime object into a "YYYY-MM-DD" string.
    final formattedDate = DateFormat('yyyy-MM-dd').format(finishBy);

    return _handleRequest(ApiService.post('/library/assign', {
      'userId': userId,
      'bookTitle': bookTitle,
      'finishBy': formattedDate, // <-- SEND THE CORRECTLY FORMATTED STRING
    }));
  }
  // =======================================================
}
