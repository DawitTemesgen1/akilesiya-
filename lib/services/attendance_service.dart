import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/role%20based/attendance_manager.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:amde_haymanot_abalat_guday/services/offline_storage_service.dart';
import 'package:amde_haymanot_abalat_guday/services/sync_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AttendanceService {
  static Future<List<Student>> getStudents() async {
    try {
      final response = await ApiService.get('/attendance/students');
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // ======================== THE FIX IS HERE ========================
        // 1. Safely access the 'data' field.
        final studentData = data['data'];

        // 2. Check if the data is not null AND is a List.
        if (studentData is List) {
          // 3. If it is a valid list, map it to Student objects.
          return studentData.map((json) => Student.fromJson(json)).toList();
        } else {
          // 4. If it's null or not a list, return an empty list to prevent a crash.
          return [];
        }
        // ===============================================================
      } else {
        throw Exception(data['message'] ?? 'Failed to load students');
      }
    } catch (e) {
      debugPrint("API Service Error in getStudents: $e");
      throw Exception('Failed to communicate with the server to get students.');
    }
  }
  // Add this new function inside your AttendanceService class

  /// Fetches the detailed attendance history for a specific user by their ID.
  static Future<List<dynamic>> getAttendanceHistoryForUser(
      String userId) async {
    try {
      final response = await ApiService.get('/attendance/history/$userId');
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Safely handle null data by returning an empty list
        return data['data'] as List<dynamic>? ?? [];
      } else {
        throw Exception(
            data['message'] ?? 'Failed to load user attendance history');
      }
    } catch (e) {
      debugPrint("API Service Error in getAttendanceHistoryForUser: $e");
      throw Exception('Failed to communicate with the server.');
    }
  }

  static Future<Map<String, dynamic>> getAttendanceRecords(
      String date, String session, String attendanceType) async {
    try {
      final response = await ApiService.get(
          '/attendance?date=$date&session=$session&attendance_type=$attendanceType');
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load records from server');
      }
    } catch (e) {
      debugPrint('Error in AttendanceService.getAttendanceRecords: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getAttendanceSummary() async {
    try {
      final response = await ApiService.get(
          '/attendance/summary'); // Assumes a new endpoint '/api/attendance/summary'
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(data['message'] ?? 'Failed to load attendance summary');
      }
    } catch (e) {
      debugPrint("API Service Error in AttendanceService: $e");
      throw Exception(
          'Failed to communicate with the server to get attendance summary.');
    }
  }

  // In lib/services/attendance_service.dart

// ... (keep all your other methods like getStudents, saveAttendance, etc.)

  /// Fetches a detailed, filterable summary of attendance data.
  static Future<Map<String, dynamic>> getDetailedAttendanceSummary({
    // THIS IS THE FIX: The function now accepts individual strings.
    required String startDate,
    required String endDate,
    String? attendanceType,
    String? session,
    int? dynamicFilterFieldId,
    int? dynamicFilterOptionId,
  }) async {
    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'startDate': startDate,
        'endDate': endDate,
      };

      if (attendanceType != null) {
        queryParams['attendanceType'] = attendanceType;
      }
      if (session != null) {
        queryParams['session'] = session;
      }
      if (dynamicFilterFieldId != null) {
        queryParams['dynamicFilterFieldId'] = dynamicFilterFieldId.toString();
      }
      if (dynamicFilterOptionId != null) {
        queryParams['dynamicFilterOptionId'] = dynamicFilterOptionId.toString();
      }

      // Construct the URI with the query parameters
      final uri = Uri.parse('/attendance/detailed-summary')
          .replace(queryParameters: queryParams);

      final response = await ApiService.get(uri.toString());
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(data['message'] ?? 'Failed to load detailed summary');
      }
    } catch (e) {
      debugPrint("API Service Error in getDetailedAttendanceSummary: $e");
      throw Exception('Failed to communicate with the server.');
    }
  }

// ... (keep the rest of your service file)
  /// Fetches the detailed attendance history for the currently logged-in user.
  static Future<List<dynamic>> getMyAttendanceHistory() async {
    try {
      final response = await ApiService.get(
          '/attendance/my-history'); // Assumes a new endpoint '/api/attendance/my-history'
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'] as List<dynamic>;
      } else {
        throw Exception(data['message'] ?? 'Failed to load attendance history');
      }
    } catch (e) {
      debugPrint("API Service Error in AttendanceService: $e");
      throw Exception(
          'Failed to communicate with the server to get attendance history.');
    }
  }

  static Future<void> saveAttendance({
    required List<Map<String, dynamic>> records,
    required Map<String, dynamic>? dailyTopic,
  }) async {
    try {
      // Check if we're online
      final syncService = SyncService();
      final isOnline = await syncService.isOnline();

      if (isOnline) {
        // Try to save online
        try {
          final response = await ApiService.post('/attendance/save', {
            'records': records,
            'dailyTopic': dailyTopic,
          });
          if (response.statusCode == 200) {
            debugPrint('✅ Attendance saved online successfully');
            return;
          } else {
            final data = json.decode(response.body);
            throw Exception(data['message'] ?? 'Failed to save attendance');
          }
        } catch (e) {
          // If online save fails, fall back to offline storage
          debugPrint('⚠️ Online save failed, saving offline: $e');
          await _saveOffline(records, dailyTopic);
        }
      } else {
        // Save offline
        debugPrint('📴 No internet, saving attendance offline');
        await _saveOffline(records, dailyTopic);
      }
    } catch (e) {
      debugPrint('Error in AttendanceService.saveAttendance: $e');
      rethrow;
    }
  }

  /// Saves attendance data offline
  static Future<void> _saveOffline(
    List<Map<String, dynamic>> records,
    Map<String, dynamic>? dailyTopic,
  ) async {
    try {
      final operationId = OfflineStorageService.generateOperationId();
      final operation = PendingOperation(
        id: operationId,
        type: OfflineOperationType.attendance,
        data: {
          'records': records,
          'dailyTopic': dailyTopic,
        },
        createdAt: DateTime.now(),
      );

      await OfflineStorageService.savePendingOperation(operation);
      debugPrint('💾 Attendance saved offline with ID: $operationId');
    } catch (e) {
      debugPrint('❌ Error saving attendance offline: $e');
      throw Exception('Failed to save attendance offline');
    }
  }
}
