import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class PrivateFeedService {
  static Future<Map<String, dynamic>> _processResponse(
      Future<http.Response> futureResponse) async {
    try {
      final response = await futureResponse;
      final dynamic body = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        dynamic responseData;
        String? message;

        if (body is Map) {
          responseData = body['data'] ?? body;
          message = body['message']?.toString() ?? 'Success';
        } else {
          responseData = body;
          message = 'Success';
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
    } catch (e) {
      return {'success': false, 'message': 'Network or parsing Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getTenantDetails(String tenantId) {
    return _processResponse(ApiService.get('private-feed/tenant/$tenantId'));
  }

  static Future<Map<String, dynamic>> getPrivatePosts(String tenantId) {
    return _processResponse(ApiService.get('private-feed/posts/$tenantId'));
  }

  static Future<Map<String, dynamic>> createPrivatePost(
      Map<String, dynamic> postData) {
    if (postData['targetGroups'] != null && postData['targetGroups'] is List) {
      postData['targetGroups'] = json.encode(postData['targetGroups']);
    }
    return _processResponse(ApiService.post('private-feed/posts', postData));
  }

  static Future<Map<String, dynamic>> createPostWithImage({
    required Map<String, String> fields,
    required XFile file,
    List<String>? targetGroups,
  }) async {
    try {
      if (targetGroups != null && targetGroups.isNotEmpty) {
        fields['targetGroups'] = json.encode(targetGroups);
      }
      final streamedResponse = await ApiService.upload(
        'private-feed/posts',
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

  static Future<Map<String, dynamic>> updatePostWithImage({
    required String postId,
    required Map<String, String> fields,
    required XFile file,
    List<String>? targetGroups,
  }) async {
    try {
      if (targetGroups != null && targetGroups.isNotEmpty) {
        fields['targetGroups'] = json.encode(targetGroups);
      }
      final streamedResponse = await ApiService.upload(
        'private-feed/posts/$postId',
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

  static Future<Map<String, dynamic>> updatePrivatePost(
      String postId, Map<String, dynamic> postData) {
    if (postData['targetGroups'] != null && postData['targetGroups'] is List) {
      postData['targetGroups'] = json.encode(postData['targetGroups']);
    }
    return _processResponse(
        ApiService.put('private-feed/posts/$postId', postData));
  }

  static Future<Map<String, dynamic>> deletePrivatePost(String postId) {
    return _processResponse(ApiService.delete('private-feed/posts/$postId'));
  }

  // ==========================================================
  // --- NEW SERVICE METHODS ---
  // ==========================================================

  static Future<Map<String, dynamic>> updateTenantDetails(
      String tenantId, Map<String, dynamic> data) {
    return _processResponse(
        ApiService.put('private-feed/tenant/$tenantId', data));
  }

  static Future<Map<String, dynamic>> togglePostLike(String postId) {
    // Note: We use handlePost here because the body is empty and our helper is convenient.
    return _processResponse(
        ApiService.post('private-feed/posts/$postId/like', {}));
  }

  static Future<Map<String, dynamic>> getPostComments(String postId) {
    return _processResponse(
        ApiService.get('private-feed/posts/$postId/comments'));
  }

  static Future<Map<String, dynamic>> createPostComment(
      String postId, String text,
      {int? parentId}) {
    return _processResponse(
        ApiService.post('private-feed/posts/$postId/comments', {
      'text': text,
      if (parentId != null) 'parentId': parentId,
    }));
  }

  static Future<Map<String, dynamic>> updatePostComment(
      int commentId, String text) {
    return _processResponse(
        ApiService.put('private-feed/comments/$commentId', {'text': text}));
  }

  static Future<Map<String, dynamic>> deletePostComment(int commentId) {
    return _processResponse(
        ApiService.delete('private-feed/comments/$commentId'));
  }
}
