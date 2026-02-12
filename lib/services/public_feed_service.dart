import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class PublicFeedService {
  static Future<Map<String, dynamic>> _processResponse(
      Future<http.Response> futureResponse) async {
    try {
      final response = await futureResponse;

      // Check if response is HTML instead of JSON
      final contentType = response.headers['content-type'] ?? '';
      if (contentType.contains('text/html') ||
          response.body.trim().startsWith('<!DOCTYPE') ||
          response.body.trim().startsWith('<html')) {
        debugPrint(
            '❌ Server returned HTML instead of JSON. Status: ${response.statusCode}');

        String errorMessage = 'Server error occurred';
        if (response.statusCode == 401) {
          errorMessage = 'Authentication required. Please log in again.';
        } else if (response.statusCode == 403) {
          errorMessage =
              'Access denied. You may not have permission for this action.';
        } else if (response.statusCode == 404) {
          errorMessage =
              'Resource not found. The API endpoint may have changed.';
        } else if (response.statusCode >= 500) {
          errorMessage = 'Server error. Please try again later.';
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      }

      final dynamic body = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        dynamic responseData;
        String? message;

        if (body is Map) {
          responseData = body['data'] ?? body;
          message = body['message']?.toString();
        } else {
          // If it's a list or something else, handle it directly
          responseData = body;
        }

        return {
          'success': true,
          'data': responseData,
          'message': message,
        };
      } else {
        String errorMessage = 'An API error occurred.';
        if (body is Map && body['message'] != null) {
          errorMessage = body['message'].toString();
        }
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } on FormatException catch (e) {
      debugPrint('❌ JSON parsing error: $e');
      return {
        'success': false,
        'message':
            'Invalid response from server. Please check your connection and try again.',
      };
    } catch (e) {
      debugPrint('❌ Network error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
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
      String postId, String text,
      {int? parentId}) {
    return _processResponse(
        ApiService.post('public-feed/posts/$postId/comments', {
      'text': text,
      if (parentId != null) 'parentId': parentId,
    }));
  }

  static Future<Map<String, dynamic>> updatePostComment(
      int commentId, String text) {
    return _processResponse(
        ApiService.put('public-feed/comments/$commentId', {'text': text}));
  }

  static Future<Map<String, dynamic>> deletePostComment(int commentId) {
    return _processResponse(
        ApiService.delete('public-feed/comments/$commentId'));
  }

  // ==========================================================
  // --- NEW ADMIN METHODS ---
  // ==========================================================

  static Future<Map<String, dynamic>> createPublicPostWithImage({
    required Map<String, String> fields,
    required XFile file,
    List<String>? targetGroups,
  }) async {
    try {
      debugPrint('📝 Creating public post with image');
      debugPrint('📄 Fields: $fields');
      debugPrint('🖼️ Image: ${file.name}');

      if (targetGroups != null && targetGroups.isNotEmpty) {
        fields['targetGroups'] = json.encode(targetGroups);
      }

      debugPrint('📤 Final fields being sent: $fields');

      final streamedResponse = await ApiService.upload(
        'public-feed/admin/posts', // Use the new admin endpoint
        fields: fields,
        file: file,
        fieldName: 'image',
      );
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response headers: ${response.headers}');
      debugPrint(
          '📥 Response body preview: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      return _processResponse(Future.value(response));
    } catch (e) {
      debugPrint('❌ Error in createPublicPostWithImage: $e');
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createPublicPost(
      Map<String, dynamic> postData) {
    debugPrint('📝 Creating public post with data: $postData');

    if (postData['targetGroups'] != null && postData['targetGroups'] is List) {
      postData['targetGroups'] = json.encode(postData['targetGroups']);
    }

    // Log the final data being sent
    debugPrint('📤 Final post data being sent to API: $postData');

    return _processResponse(
        ApiService.post('public-feed/admin/posts', postData));
  }

  static Future<Map<String, dynamic>> updatePublicPost(
      String postId, Map<String, dynamic> postData) {
    if (postData['targetGroups'] != null && postData['targetGroups'] is List) {
      postData['targetGroups'] = json.encode(postData['targetGroups']);
    }
    return _processResponse(
        ApiService.put('public-feed/admin/posts/$postId', postData));
  }

  static Future<Map<String, dynamic>> deletePublicPost(String postId) {
    return _processResponse(
        ApiService.delete('public-feed/admin/posts/$postId'));
  }
}
