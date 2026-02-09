// lib/services/family_service.dart

import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';

class FamilyService {
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

  // FOR PARENTS
  static Future<Map<String, dynamic>> getLinkedStudents() {
    return _handleRequest(ApiService.get('/family/linked-students'));
  }

  static Future<Map<String, dynamic>> getStudentDetails(String studentId) {
    return _handleRequest(ApiService.get('/family/student-details/$studentId'));
  }

  static Future<Map<String, dynamic>> toggleBookStatus(
      String bookId, bool isRead) {
    return _handleRequest(
        ApiService.patch('/family/books/$bookId/status', {'isRead': isRead}));
  }

  // FOR ADMINS
  static Future<Map<String, dynamic>> getAllFamilyLinks() {
    return _handleRequest(ApiService.get('/family/manage'));
  }

  static Future<Map<String, dynamic>> createFamilyLink({
    required String parentUserId,
    required String studentUserId,
  }) {
    return _handleRequest(ApiService.post('/family/manage', {
      'parent_user_id': parentUserId,
      'student_user_id': studentUserId,
    }));
  }

  static Future<Map<String, dynamic>> deleteFamilyLink(int linkId) {
    return _handleRequest(ApiService.delete('/family/manage/$linkId'));
  }
}
