import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/sync_service.dart';
import 'package:amde_haymanot_abalat_guday/services/offline_storage_service.dart';

/// Provider for managing sync state and pending operations
class SyncProvider extends ChangeNotifier {
  final SyncService _syncService = SyncService();
  bool _isOnline = true;
  int _pendingCount = 0;
  bool _isSyncing = false;

  bool get isOnline => _isOnline;
  int get pendingCount => _pendingCount;
  bool get isSyncing => _isSyncing;

  SyncProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _syncService.addSyncListener(_onSyncStatusChanged);
    await checkConnectivity();
    await updatePendingCount();
    _syncService.startMonitoring();
  }

  void _onSyncStatusChanged() {
    _isSyncing = _syncService.isSyncing;
    notifyListeners();
  }

  /// Check current connectivity status
  Future<void> checkConnectivity() async {
    final wasOnline = _isOnline;
    _isOnline = await _syncService.isOnline();
    
    if (wasOnline != _isOnline) {
      notifyListeners();
    }
  }

  /// Update the count of pending operations
  Future<void> updatePendingCount() async {
    final count = await OfflineStorageService.getPendingOperationsCount();
    if (_pendingCount != count) {
      _pendingCount = count;
      notifyListeners();
    }
  }

  /// Manually trigger sync
  Future<void> syncNow() async {
    await _syncService.syncPendingOperations();
    await updatePendingCount();
  }

  @override
  void dispose() {
    _syncService.removeSyncListener(_onSyncStatusChanged);
    _syncService.stopMonitoring();
    super.dispose();
  }
}

