import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';

class BatchService {
  static Future<List<dynamic>> getUnregisteredUsers() async {
    final response = await ApiService.get('/batch/unregistered-users');
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to load users');
    }
  }

  static Future<void> registerStudentsToBatch({
    required List<String> studentIds,
    required String className,
    required int academicYear,
  }) async {
    final response = await ApiService.post('/batch/register', {
      'student_ids': studentIds,
      'class_name': className,
      'academic_year': academicYear,
    });
    if (response.statusCode != 201) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Failed to register students');
    }
  }

  static Future<Map<String, dynamic>> promoteStudents({
    required String fromClass,
    required int fromYear,
    required double passingScore,
  }) async {
    final response = await ApiService.post('/batch/promote', {
      'from_class': fromClass,
      'from_year': fromYear,
      'passing_score': passingScore,
    });
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      return data; // Return full response
    } else {
      throw Exception(data['message'] ?? 'Failed to promote students');
    }
  }

  // --- NEW METHODS ---

  static Future<List<dynamic>> getBatchSummary() async {
    final response = await ApiService.get('/batch/summary');
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to load batch summary');
    }
  }

  static Future<List<dynamic>> getStudentsInBatch({
    required String spiritualClass,
    required int academicYear,
  }) async {
    final response = await ApiService.get(
        '/batch/students?spiritual_class=$spiritualClass&academic_year=$academicYear');
    final data = json.decode(response.body);
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to load students in batch');
    }
  }

  static Future<void> removeStudentsFromBatch({
    required List<String> studentIds,
  }) async {
    final response =
        await ApiService.post('/batch/remove', {'student_ids': studentIds});
    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Failed to remove students');
    }
  }
}
