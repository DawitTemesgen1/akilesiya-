import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class PublicFeedService {
  static Future<Map<String, dynamic>> _processResponse(
      Future<http.Response> futureResponse) async {
    try {
      final response = await futureResponse;
      final body = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': body['data'] ?? body,
          'message': body['message']
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'An API error occurred.'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network or parsing Error: $e'};
    }
  }

  // --- User-facing methods ---
  static Future<Map<String, dynamic>> getPublicPosts() {
    return _processResponse(ApiService.get('public-feed/posts'));
  }

  static Future<Map<String, dynamic>> togglePostLike(String postId) {
    return _processResponse(
        ApiService.post('public-feed/posts/$postId/like', {}));
  }

  static Future<Map<String, dynamic>> getPostComments(String postId) {
    return _processResponse(
        ApiService.get('public-feed/posts/$postId/comments'));
  }

  static Future<Map<String, dynamic>> createPostComment(
      String postId, String text) {
    return _processResponse(
        ApiService.post('public-feed/posts/$postId/comments', {'text': text}));
  }

  // ==========================================================
  // --- NEW ADMIN METHODS ---
  // ==========================================================

  static Future<Map<String, dynamic>> createPublicPostWithImage({
    required Map<String, String> fields,
    required XFile file,
  }) async {
    try {
      final streamedResponse = await ApiService.upload(
        'public-feed/admin/posts', // Use the new admin endpoint
        fields: fields,
        file: file,
        fieldName: 'image',
      );
      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(Future.value(response));
    } catch (e) {
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createPublicPost(
      Map<String, dynamic> postData) {
    return _processResponse(
        ApiService.post('public-feed/admin/posts', postData));
  }

  static Future<Map<String, dynamic>> updatePublicPost(
      String postId, Map<String, dynamic> postData) {
    return _processResponse(
        ApiService.put('public-feed/admin/posts/$postId', postData));
  }

  static Future<Map<String, dynamic>> deletePublicPost(String postId) {
    return _processResponse(
        ApiService.delete('public-feed/admin/posts/$postId'));
  }
}
