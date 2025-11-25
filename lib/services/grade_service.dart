// lib/services/grade_service.dart

import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:amde_haymanot_abalat_guday/services/offline_storage_service.dart';
import 'package:amde_haymanot_abalat_guday/services/sync_service.dart';
import 'package:flutter/foundation.dart';

class GradeService {
  static Future<List<dynamic>> getStudentsWithGrades({
    required String spiritualClass,
    required int year,
  }) async {
    try {
      final response = await ApiService.get(
          '/grades?spiritual_class=$spiritualClass&year=$year');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load students and grades');
      }
    } catch (e) {
      debugPrint('Error in GradeService.getStudentsWithGrades: $e');
      rethrow;
    }
  }

  // --- Course Management ---
  static Future<List<dynamic>> getCourses(String spiritualClass) async {
    final response =
        await ApiService.get('/grades/courses?spiritual_class=$spiritualClass');
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to load courses');
  }

  static Future<Map<String, dynamic>> addCourse(
      {required String spiritualClass, required String courseName}) async {
    final response = await ApiService.post('/grades/courses',
        {'spiritual_class': spiritualClass, 'course_name': courseName});
    if (response.statusCode == 201) return json.decode(response.body);
    throw Exception('Failed to add course');
  }

  static Future<void> deleteCourse(int courseId) async {
    final response = await ApiService.delete('/grades/courses/$courseId');
    if (response.statusCode != 200) throw Exception('Failed to delete course');
  }

  // --- Assessment Management ---
  static Future<List<dynamic>> getAssessmentsForCourse(int courseId) async {
    final response =
        await ApiService.get('/grades/assessments?course_id=$courseId');
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to get assessments');
  }

  static Future<List<dynamic>> saveAssessmentsForCourse(
      {required int courseId,
      required List<Map<String, dynamic>> assessments}) async {
    // Check if we're online
    final syncService = SyncService();
    final isOnline = await syncService.isOnline();

    if (isOnline) {
      // Try to save online
      try {
        final response = await ApiService.post('/grades/assessments',
            {'course_id': courseId, 'assessments': assessments});
        if (response.statusCode == 201 || response.statusCode == 200) {
          debugPrint('✅ Assessments saved online successfully');
          return json.decode(response.body);
        } else {
          throw Exception('Failed to save assessments');
        }
      } catch (e) {
        // If online save fails, fall back to offline storage
        debugPrint('⚠️ Online save failed, saving offline: $e');
        await _saveGradesOffline('/grades/assessments', {
          'course_id': courseId,
          'assessments': assessments,
        });
        return assessments; // Return local data for offline mode
      }
    } else {
      // Save offline
      debugPrint('📴 No internet, saving assessments offline');
      await _saveGradesOffline('/grades/assessments', {
        'course_id': courseId,
        'assessments': assessments,
      });
      return assessments; // Return local data for offline mode
    }
  }

  // --- Score Management ---
// lib/services/grade_service.dart

  static Future<Map<String, dynamic>> saveStudentScores({
    required String studentId,
    required int year,
    required List<Map<String, dynamic>> scores,
  }) async {
    // Check if we're online
    final syncService = SyncService();
    final isOnline = await syncService.isOnline();

    if (isOnline) {
      // Try to save online
      try {
        final response = await ApiService.put('/grades/scores', {
          'student_id': studentId,
          'year': year,
          'scores': scores,
        });

        final data = json.decode(response.body);
        if (response.statusCode == 200) {
          debugPrint('✅ Grades saved online successfully');
          return data;
        } else {
          throw Exception(data['message'] ?? 'Failed to save scores');
        }
      } catch (e) {
        // If online save fails, fall back to offline storage
        debugPrint('⚠️ Online save failed, saving offline: $e');
        await _saveGradesOffline('/grades/scores', {
          'student_id': studentId,
          'year': year,
          'scores': scores,
        });
        // Return a mock response for offline mode
        return {
          'success': true,
          'message': 'Saved offline, will sync when online',
          'data': {'student_id': studentId, 'scores': scores}
        };
      }
    } else {
      // Save offline
      debugPrint('📴 No internet, saving grades offline');
      await _saveGradesOffline('/grades/scores', {
        'student_id': studentId,
        'year': year,
        'scores': scores,
      });
      // Return a mock response for offline mode
      return {
        'success': true,
        'message': 'Saved offline, will sync when online',
        'data': {'student_id': studentId, 'scores': scores}
      };
    }
  }

  /// Saves grade data offline
  static Future<void> _saveGradesOffline(
    String endpoint,
    Map<String, dynamic> payload,
  ) async {
    try {
      final operationId = OfflineStorageService.generateOperationId();
      final operation = PendingOperation(
        id: operationId,
        type: OfflineOperationType.grade,
        data: {
          'endpoint': endpoint,
          'payload': payload,
        },
        createdAt: DateTime.now(),
      );

      await OfflineStorageService.savePendingOperation(operation);
      debugPrint('💾 Grades saved offline with ID: $operationId');
    } catch (e) {
      debugPrint('❌ Error saving grades offline: $e');
      throw Exception('Failed to save grades offline');
    }
  }

  static Future saveAssessments(
      {required String spiritualClass,
      required List<Map<String, dynamic>> assessments}) async {}
}
