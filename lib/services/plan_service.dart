// lib/services/plan_service.dart

import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:flutter/material.dart';

class PlanService {
  static Future<Map<String, dynamic>> _handleRequest(
      Future<dynamic> request) async {
    try {
      final response = await request;
      debugPrint(
          'DEBUG PlanService: ${response.request?.url} - Status: ${response.statusCode}');
      final body = json.decode(response.body);

      if (response.statusCode >= 400) {
        debugPrint('DEBUG PlanService: Body: $body');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': body['data'] ?? body};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'An API error occurred.'
      };
    } catch (e) {
      // This is where the error you are seeing is caught.
      // We are returning a generic message, but the real error is in the 'e' variable.
      return {'success': false, 'message': 'Network Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getPlanData(
      {required int year, String? role}) {
    // Correct Route: /plans
    String route = '/plans?year=$year';
    if (role != null && role.isNotEmpty) {
      route += '&role=$role';
    }
    return _handleRequest(ApiService.get(route));
  }

  static Future<Map<String, dynamic>> createDepartment({
    required String name,
    String? description,
    required Color color,
  }) {
    // Correct Route: /plans/departments
    return _handleRequest(ApiService.post('/plans/departments', {
      'name': name,
      'description': description,
      'color':
          '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
    }));
  }

  static Future<Map<String, dynamic>> updateDepartment({
    required String departmentId,
    required String name,
    String? description,
    required Color color,
  }) {
    // Correct Route: /plans/departments/:deptId
    return _handleRequest(ApiService.put('/plans/departments/$departmentId', {
      'name': name,
      'description': description,
      'color':
          '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
    }));
  }

  static Future<Map<String, dynamic>> updateDepartmentMembers({
    required int departmentId,
    required List<Map<String, dynamic>> members,
  }) {
    // Correct Route: /plans/departments/:deptId/members
    return _handleRequest(
        ApiService.put('/plans/departments/$departmentId/members', {
      'members': members,
    }));
  }

  static Future<Map<String, dynamic>> deleteDepartment(String departmentId) {
    // Correct Route: /plans/departments/:deptId
    return _handleRequest(
        ApiService.delete('/plans/departments/$departmentId'));
  }

  static Future<Map<String, dynamic>> createPlan({
    required String title,
    String? description,
    DateTime? planDate,
    String? assigneeId,
    required String departmentId,
    required bool isHighPriority,
    required bool isRecurring,
    required int academicYear,
  }) {
    // ======================= FIX =======================
    // Corrected route from '/plans/plans' to just '/plans'
    return _handleRequest(ApiService.post('/plans', {
      'title': title,
      'description': description,
      'planDate': planDate?.toIso8601String(),
      'assigneeId': assigneeId,
      'departmentId': departmentId,
      'isHighPriority': isHighPriority,
      'isRecurring': isRecurring,
      'academicYear': academicYear,
    }));
  }

  static Future<Map<String, dynamic>> updatePlan({
    required String planId,
    required String title,
    String? description,
    DateTime? planDate,
    String? assigneeId,
    required String departmentId,
    required bool isDone,
    required bool isHighPriority,
    required bool isRecurring,
    required int academicYear,
  }) {
    // ======================= FIX =======================
    // Corrected route from '/plans/plans/:planId' to just '/plans/:planId'
    return _handleRequest(ApiService.put('/plans/$planId', {
      'title': title,
      'description': description,
      'planDate': planDate?.toIso8601String(),
      'assigneeId': assigneeId,
      'departmentId': departmentId,
      'isDone': isDone,
      'isHighPriority': isHighPriority,
      'isRecurring': isRecurring,
      'academicYear': academicYear,
    }));
  }

  static Future<Map<String, dynamic>> deletePlan(String planId) {
    // ======================= FIX =======================
    // Corrected route from '/plans/plans/:planId' to just '/plans/:planId'
    return _handleRequest(ApiService.delete('/plans/$planId'));
  }

  static Future<Map<String, dynamic>> togglePlanStatus(
      String planId, bool isDone) {
    // ======================= FIX =======================
    // Corrected route from '/plans/plans/:planId/status' to just '/plans/:planId/status'
    return _handleRequest(ApiService.patch('/plans/$planId/status', {
      'isDone': isDone,
    }));
  }

  static Future<Map<String, dynamic>> performRollover({
    required int sourceYear,
    required int destinationYear,
  }) {
    // Correct Route: /plans/rollover
    return _handleRequest(ApiService.post('/plans/rollover', {
      'sourceYear': sourceYear,
      'destinationYear': destinationYear,
    }));
  }

  static Future<Map<String, dynamic>> undoRollover({
    required int yearToDelete,
  }) {
    // Correct Route: /plans/undo-rollover
    return _handleRequest(ApiService.post('/plans/undo-rollover', {
      'yearToDelete': yearToDelete,
    }));
  }
}
