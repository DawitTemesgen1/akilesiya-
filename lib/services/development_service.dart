// lib/services/development_service.dart
import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';

class DevelopmentService {
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

  // GET all notes for a specific user
  static Future<Map<String, dynamic>> getDevelopmentNotes(String userId) {
    return _handleRequest(ApiService.get('/development/$userId'));
  }

  // POST a new note for a user
  static Future<Map<String, dynamic>> createDevelopmentNote({
    required String userId,
    required Map<String, dynamic> data,
  }) {
    return _handleRequest(ApiService.post('/development/$userId', data));
  }

  // PUT (update) an existing note
  static Future<Map<String, dynamic>> updateDevelopmentNote({
    required String noteId,
    required Map<String, dynamic> data,
  }) {
    return _handleRequest(ApiService.put('/development/notes/$noteId', data));
  }

  // PATCH the status of a note
  static Future<Map<String, dynamic>> updateNoteStatus({
    required String noteId,
    required bool isCompleted,
  }) {
    return _handleRequest(ApiService.patch(
      '/development/notes/$noteId/status',
      {'isCompleted': isCompleted},
    ));
  }

  // DELETE a note
  static Future<Map<String, dynamic>> deleteDevelopmentNote(String noteId) {
    return _handleRequest(ApiService.delete('/development/notes/$noteId'));
  }
}
