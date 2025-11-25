import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/activity_service.dart';
import 'package:amde_haymanot_abalat_guday/models/activity_models.dart';

/// A provider to manage the state for the activity dashboard.
class ActivityProvider extends ChangeNotifier {
  List<DailyActivitySummary> _dailySummaries = [];
  bool _isLoading = false;
  String? _error;

  List<DailyActivitySummary> get dailySummaries => _dailySummaries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetches the activity summary data from the service and updates the state.
  Future<void> fetchActivitySummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dailySummaries = await ActivityService.fetchMyActivitySummary();
    } catch (e) {
      _error = "Failed to load activity data: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
