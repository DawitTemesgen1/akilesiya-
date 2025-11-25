import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:amde_haymanot_abalat_guday/services/offline_storage_service.dart';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';

/// Service for syncing pending operations when connectivity is restored
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;
  final List<VoidCallback> _syncListeners = [];

  /// Check if device is currently online
  Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.ethernet);
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  /// Start monitoring connectivity and auto-sync when online
  void startMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final isConnected = results.any((result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet);
        
        if (isConnected && !_isSyncing) {
          debugPrint('🌐 Connectivity restored, starting sync...');
          syncPendingOperations();
        }
      },
    );
  }

  /// Stop monitoring connectivity
  void stopMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Add a listener for sync status changes
  void addSyncListener(VoidCallback listener) {
    _syncListeners.add(listener);
  }

  /// Remove a sync listener
  void removeSyncListener(VoidCallback listener) {
    _syncListeners.remove(listener);
  }

  /// Notify all listeners
  void _notifyListeners() {
    for (final listener in _syncListeners) {
      listener();
    }
  }

  /// Sync all pending operations
  Future<SyncResult> syncPendingOperations() async {
    if (_isSyncing) {
      debugPrint('⏳ Sync already in progress...');
      return SyncResult(isSyncing: true, synced: 0, failed: 0);
    }

    final isConnected = await isOnline();
    if (!isConnected) {
      debugPrint('📴 No internet connection, cannot sync');
      return SyncResult(isSyncing: false, synced: 0, failed: 0, error: 'No internet connection');
    }

    _isSyncing = true;
    _notifyListeners();

    try {
      final operations = await OfflineStorageService.getPendingOperations();
      if (operations.isEmpty) {
        _isSyncing = false;
        _notifyListeners();
        return SyncResult(isSyncing: false, synced: 0, failed: 0);
      }

      debugPrint('🔄 Syncing ${operations.length} pending operations...');

      int synced = 0;
      int failed = 0;
      final List<String> failedIds = [];

      for (final operation in operations) {
        try {
          final success = await _syncOperation(operation);
          if (success) {
            await OfflineStorageService.removePendingOperation(operation.id);
            synced++;
            debugPrint('✅ Synced operation: ${operation.id}');
          } else {
            await OfflineStorageService.incrementRetryCount(operation.id);
            failed++;
            failedIds.add(operation.id);
            debugPrint('❌ Failed to sync operation: ${operation.id}');
          }
        } catch (e) {
          debugPrint('❌ Error syncing operation ${operation.id}: $e');
          await OfflineStorageService.incrementRetryCount(operation.id);
          failed++;
          failedIds.add(operation.id);
        }
      }

      _isSyncing = false;
      _notifyListeners();

      return SyncResult(
        isSyncing: false,
        synced: synced,
        failed: failed,
        failedIds: failedIds,
      );
    } catch (e) {
      _isSyncing = false;
      _notifyListeners();
      return SyncResult(
        isSyncing: false,
        synced: 0,
        failed: 0,
        error: e.toString(),
      );
    }
  }

  /// Sync a single operation
  Future<bool> _syncOperation(PendingOperation operation) async {
    try {
      switch (operation.type) {
        case OfflineOperationType.attendance:
          return await _syncAttendance(operation.data);
        case OfflineOperationType.grade:
          return await _syncGrade(operation.data);
      }
    } catch (e) {
      debugPrint('Error syncing ${operation.type.name}: $e');
      return false;
    }
  }

  /// Sync attendance data
  Future<bool> _syncAttendance(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post('/attendance/save', {
        'records': data['records'],
        'daily_topic': data['daily_topic'],
      });
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error syncing attendance: $e');
      return false;
    }
  }

  /// Sync grade data
  Future<bool> _syncGrade(Map<String, dynamic> data) async {
    try {
      final endpoint = data['endpoint'] as String;
      final payload = data['payload'] as Map<String, dynamic>;

      if (endpoint.contains('/grades/scores')) {
        final response = await ApiService.put(endpoint, payload);
        return response.statusCode == 200;
      } else if (endpoint.contains('/grades/assessments')) {
        final response = await ApiService.post(endpoint, payload);
        return response.statusCode == 201 || response.statusCode == 200;
      } else {
        debugPrint('Unknown grade endpoint: $endpoint');
        return false;
      }
    } catch (e) {
      debugPrint('Error syncing grade: $e');
      return false;
    }
  }

  bool get isSyncing => _isSyncing;
}

/// Result of a sync operation
class SyncResult {
  final bool isSyncing;
  final int synced;
  final int failed;
  final List<String>? failedIds;
  final String? error;

  SyncResult({
    required this.isSyncing,
    required this.synced,
    required this.failed,
    this.failedIds,
    this.error,
  });

  bool get hasError => error != null;
  bool get isSuccess => !hasError && failed == 0;
}

