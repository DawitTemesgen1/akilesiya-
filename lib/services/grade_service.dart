// lib/services/grade_service.dart

import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:amde_haymanot_abalat_guday/services/offline_storage_service.dart';
import 'package:amde_haymanot_abalat_guday/services/sync_service.dart';
import 'package:amde_haymanot_abalat_guday/models/etcalendar.dart';
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
  static Future<List<dynamic>> getCourses(String spiritualClass,
      {int? year}) async {
    String url = '/grades/courses?spiritual_class=$spiritualClass';
    if (year != null) {
      url += '&year=$year';
    }
    final response = await ApiService.get(url);
    if (response.statusCode == 200) return json.decode(response.body);
    throw Exception('Failed to load courses');
  }

  static Future<Map<String, dynamic>> addCourse(
      {required String spiritualClass,
      required String courseName,
      int? year}) async {
    final body = {
      'spiritual_class': spiritualClass,
      'course_name': courseName,
      if (year != null) 'year': year
    };
    final response = await ApiService.post('/grades/courses', body);
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

  /// Get grades for the currently logged-in user
  /// This fetches the user's profile to get their spiritual_class and year,
  /// then fetches their grades using the existing grades endpoint
  static Future<Map<String, dynamic>> getMyGrades({
    String? spiritualClassOverride,
    int? yearOverride,
  }) async {
    try {
      // First, get the user's profile to know their ID (and default class/year)
      // We still need this to determine the 'current' class for showing empty course lists
      final profileResponse = await ApiService.get('/profile/me');

      if (profileResponse.statusCode != 200) {
        return {'success': false, 'message': 'Failed to fetch user profile'};
      }

      var profileData = json.decode(profileResponse.body);

      // Unwrap if wrapped in 'data'
      if (profileData['data'] != null && profileData['success'] == true) {
        profileData = profileData['data'];
      }

      // Use override if provided, otherwise fallback to profile
      final spiritualClass =
          spiritualClassOverride ?? profileData['spiritual_class']?.toString();

      debugPrint(
          "DEBUG GradeService: Fetched profile. Current Spiritual Class: '$spiritualClass'");

      // Get current Ethiopian year
      final currentYear = EthiopianDate.now().year;

      // Fetch grades for requested year(s)
      final years = yearOverride != null
          ? [yearOverride]
          : [currentYear, currentYear - 1];
      final Map<String, List<dynamic>> gradesByYear = {};

      for (final year in years) {
        try {
          debugPrint('DEBUG: Fetching grades for year: $year');

          // Use the new, robust endpoint that fetches by User ID + Year
          // This ignores the user's current class, preserving history.
          final response = await ApiService.get('/grades/my-grades?year=$year');

          if (response.statusCode == 200) {
            final jsonResponse = json.decode(response.body);
            if (jsonResponse['success'] == true &&
                jsonResponse['data'] != null) {
              final grades = jsonResponse['data']['grades'];
              if (grades is List && grades.isNotEmpty) {
                gradesByYear[year.toString()] = grades;
                debugPrint(
                    'DEBUG: Found ${grades.length} grades for year $year');
              }
            }
          }
        } catch (e) {
          debugPrint('Error fetching grades for year $year: $e');
        }
      }

      debugPrint(
          'DEBUG: Finished fetching all years. gradesByYear keys: ${gradesByYear.keys}');

      // IF no grades found for current year, try to fetch COURSES to show empty state
      // This relies on the CURRENT spiritual class.
      if (!gradesByYear.containsKey(currentYear.toString()) &&
          spiritualClass != null &&
          spiritualClass.isNotEmpty) {
        try {
          final courses = await getCourses(spiritualClass);
          if (courses.isNotEmpty) {
            final emptyGrades = courses
                .map((c) => {
                      'course_name': c['course_name'],
                      'course_id': c['id'],
                      'scores': [], // No assessments
                      'total': 0.0,
                      'score': 0.0
                    })
                .toList();
            gradesByYear[currentYear.toString()] = emptyGrades;
            debugPrint(
                'DEBUG: Added empty course list for year $currentYear (Class: $spiritualClass)');
          }
        } catch (e) {
          debugPrint('DEBUG: Failed to fetch courses for empty state: $e');
        }
      }

      // If we have grades, return them
      if (gradesByYear.isNotEmpty) {
        return {
          'success': true,
          'data': gradesByYear,
        };
      } else if (gradesByYear.length == 1) {
        // Single year, return just the grades array (legacy support if needed)
        return {
          'success': true,
          'data': {
            'grades': gradesByYear.values.first,
          },
        };
      } else {
        // No grades found
        return {
          'success': true,
          'data': {'grades': []},
          'message': 'No grades found'
        };
      }
    } catch (e) {
      debugPrint('Error in GradeService.getMyGrades: $e');
      return {
        'success': false,
        'message': 'Failed to fetch grades: ${e.toString()}'
      };
    }
  }
}
