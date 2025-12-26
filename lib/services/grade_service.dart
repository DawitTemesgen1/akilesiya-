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

  /// Get grades for the currently logged-in user
  /// This fetches the user's profile to get their spiritual_class and year,
  /// then fetches their grades using the existing grades endpoint
  static Future<Map<String, dynamic>> getMyGrades() async {
    try {
      // First, get the user's profile to know their spiritual class and current year
      final profileResponse = await ApiService.get('/profile/me');

      if (profileResponse.statusCode != 200) {
        return {'success': false, 'message': 'Failed to fetch user profile'};
      }

      var profileData = json.decode(profileResponse.body);

      // Unwrap if wrapped in 'data'
      if (profileData['data'] != null && profileData['success'] == true) {
        profileData = profileData['data'];
      }

      final userId = profileData['id']?.toString();
      final user_id = profileData['user_id']?.toString();
      final studentIdKey = profileData['student_id']?.toString();
      final fullName = profileData['full_name']?.toString() ??
          profileData['name']?.toString();
      final spiritualClass = profileData['spiritual_class']?.toString();

      debugPrint(
          "DEBUG GradeService: Fetched profile. Spiritual Class: '$spiritualClass'");

      if (userId == null && user_id == null && studentIdKey == null) {
        debugPrint("DEBUG GradeService: No user identifier found");
        return {
          'success': false,
          'message': 'No user identifier found in profile'
        };
      }

      final List<String> possibleUserIds = [
        if (userId != null) userId,
        if (user_id != null) user_id,
        if (studentIdKey != null) studentIdKey,
      ];

      // If no spiritual class assigned, return empty
      if (spiritualClass == null || spiritualClass.isEmpty) {
        debugPrint(
            "DEBUG GradeService: No spiritual class assigned, returning empty result");
        return {
          'success': true,
          'data': {'grades': []},
          'message': 'No spiritual class assigned'
        };
      }

      // Get current Ethiopian year
      final currentYear = EthiopianDate.now().year;

      // Fetch grades for current and previous years
      final years = [currentYear, currentYear - 1];
      final Map<String, List<dynamic>> gradesByYear = {};

      for (final year in years) {
        try {
          debugPrint(
              'DEBUG: Fetching grades for spiritualClass: $spiritualClass, year: $year');
          final studentsData = await getStudentsWithGrades(
            spiritualClass: spiritualClass,
            year: year,
          );

          debugPrint(
              'DEBUG: Received ${studentsData.length} students for year $year');

          // Find the current user's grades in the response
          final userGrades = studentsData.firstWhere(
            (student) {
              final sId = student['student_id']?.toString();
              final id = student['id']?.toString();
              final uId = student['user_id']?.toString();
              final sName = student['full_name']?.toString() ??
                  student['name']?.toString();

              // Check if any of the student's ID matches any of our possible IDs
              final isIdMatch = possibleUserIds
                  .any((pId) => pId == sId || pId == id || pId == uId);

              // Fallback to name match if IDs don't work and we have a name
              final isNameMatch =
                  fullName != null && sName != null && fullName == sName;

              final isMatch = isIdMatch || isNameMatch;

              if (isMatch) {
                debugPrint(
                    'DEBUG: Found match for user - isIdMatch: $isIdMatch, isNameMatch: $isNameMatch');
              }
              return isMatch;
            },
            orElse: () => null,
          );

          if (userGrades != null && userGrades['grades'] != null) {
            final gradesList = userGrades['grades'] as List<dynamic>;
            debugPrint(
                'DEBUG: User has ${gradesList.length} grades for year $year');
            gradesByYear[year.toString()] = gradesList;
          } else {
            debugPrint(
                'DEBUG: No grades found for userId $userId in year $year');
          }
        } catch (e) {
          debugPrint('Error fetching grades for year $year: $e');
        }
      }

      debugPrint(
          'DEBUG: Finished fetching all years. gradesByYear keys: ${gradesByYear.keys}');

      // If we have grades, return them
      if (gradesByYear.isNotEmpty) {
        return {
          'success': true,
          'data': gradesByYear,
        };
      } else if (gradesByYear.length == 1) {
        // Single year, return just the grades array
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
