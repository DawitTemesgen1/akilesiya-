import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Types of operations that can be stored offline
enum OfflineOperationType {
  attendance,
  grade,
}

/// Represents a pending operation stored offline
class PendingOperation {
  final String id;
  final OfflineOperationType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  PendingOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory PendingOperation.fromJson(Map<String, dynamic> json) {
    return PendingOperation(
      id: json['id'] as String,
      type: OfflineOperationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OfflineOperationType.attendance,
      ),
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  PendingOperation copyWith({int? retryCount}) {
    return PendingOperation(
      id: id,
      type: type,
      data: data,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Service for managing offline storage of pending operations
class OfflineStorageService {
  static const String _pendingOperationsKey = 'pending_operations';
  static const int _maxRetryCount = 3;

  /// Saves a pending operation to local storage
  static Future<void> savePendingOperation(PendingOperation operation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final operations = await getPendingOperations();
      
      // Check if operation with same ID already exists
      operations.removeWhere((op) => op.id == operation.id);
      operations.add(operation);
      
      final jsonList = operations.map((op) => op.toJson()).toList();
      await prefs.setString(_pendingOperationsKey, json.encode(jsonList));
      
      debugPrint('✅ Saved pending operation: ${operation.type.name} (${operation.id})');
    } catch (e) {
      debugPrint('❌ Error saving pending operation: $e');
      rethrow;
    }
  }

  /// Retrieves all pending operations
  static Future<List<PendingOperation>> getPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_pendingOperationsKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => PendingOperation.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error loading pending operations: $e');
      return [];
    }
  }

  /// Gets pending operations by type
  static Future<List<PendingOperation>> getPendingOperationsByType(
      OfflineOperationType type) async {
    final allOperations = await getPendingOperations();
    return allOperations.where((op) => op.type == type).toList();
  }

  /// Removes a pending operation after successful sync
  static Future<void> removePendingOperation(String operationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final operations = await getPendingOperations();
      operations.removeWhere((op) => op.id == operationId);
      
      final jsonList = operations.map((op) => op.toJson()).toList();
      await prefs.setString(_pendingOperationsKey, json.encode(jsonList));
      
      debugPrint('✅ Removed pending operation: $operationId');
    } catch (e) {
      debugPrint('❌ Error removing pending operation: $e');
    }
  }

  /// Increments retry count for an operation
  static Future<void> incrementRetryCount(String operationId) async {
    try {
      final operations = await getPendingOperations();
      final operation = operations.firstWhere(
        (op) => op.id == operationId,
        orElse: () => throw Exception('Operation not found'),
      );
      
      final updatedOperation = operation.copyWith(retryCount: operation.retryCount + 1);
      operations.removeWhere((op) => op.id == operationId);
      
      // Remove if max retries exceeded
      if (updatedOperation.retryCount < _maxRetryCount) {
        operations.add(updatedOperation);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final jsonList = operations.map((op) => op.toJson()).toList();
      await prefs.setString(_pendingOperationsKey, json.encode(jsonList));
      
      debugPrint('⚠️ Incremented retry count for operation: $operationId');
    } catch (e) {
      debugPrint('❌ Error incrementing retry count: $e');
    }
  }

  /// Clears all pending operations (use with caution)
  static Future<void> clearAllPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingOperationsKey);
      debugPrint('✅ Cleared all pending operations');
    } catch (e) {
      debugPrint('❌ Error clearing pending operations: $e');
    }
  }

  /// Gets count of pending operations
  static Future<int> getPendingOperationsCount() async {
    final operations = await getPendingOperations();
    return operations.length;
  }

  /// Generates a unique ID for a pending operation
  static String generateOperationId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}';
  }
}

