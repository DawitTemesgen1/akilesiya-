import 'package:flutter/material.dart';
import 'package:amde_haymanot_abalat_guday/services/homepage_service.dart';

class HomepageProvider extends ChangeNotifier {
  Map<String, dynamic> _homepageData = {};
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic> get homepageData => _homepageData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetches homepage content and manages the loading/error state.
  Future<void> fetchContent() async {
    // Don't re-fetch if already loading
    if (_isLoading && _homepageData.isNotEmpty) return;

    _isLoading = true;
    _error = null;
    // Notify listeners immediately that we are starting to load
    notifyListeners();

    try {
      _homepageData = await HomepageService.getHomepageContent();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
