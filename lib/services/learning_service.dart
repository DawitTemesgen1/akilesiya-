import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart'; // Assuming you have this

class LearningService {
  static Future<Map<String, dynamic>> _processResponse(dynamic response) async {
    try {
      final body = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': body['data'] ?? body};
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'An API error occurred.'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to process server response.'
      };
    }
  }

  static Future<Map<String, dynamic>> getLearningContent() async {
    try {
      final response = await ApiService.get('learning');
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getComments(String contentId) async {
    try {
      final response = await ApiService.get('learning/$contentId/comments');
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> addComment(
      String contentId, String text) async {
    try {
      final response =
          await ApiService.post('learning/$contentId/comments', {'text': text});
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> toggleLike(String contentId) async {
    try {
      final response = await ApiService.post('learning/$contentId/like', {});
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> toggleBookmark(String contentId) async {
    try {
      final response =
          await ApiService.post('learning/$contentId/bookmark', {});
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  // --- Admin Methods ---
  static Future<Map<String, dynamic>> createContent(
      Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('learning', data);
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateContent(
      String contentId, Map<String, dynamic> data) async {
    try {
      final response = await ApiService.put('learning/$contentId', data);
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteContent(String contentId) async {
    try {
      final response = await ApiService.delete('learning/$contentId');
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }
}
