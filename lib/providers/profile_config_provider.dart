// lib/providers/profile_config_provider.dart
import 'dart:developer' as developer;

import 'package:amde_haymanot_abalat_guday/services/template_service.dart';
import 'package:amde_haymanot_abalat_guday/services/user_admin_service.dart';
import 'package:flutter/material.dart';

class ProfileConfigProvider with ChangeNotifier {
  Map<String, bool> _widgetVisibility = {};
  List<dynamic> _customFields = [];
  bool _isLoading = true;
  String? _error;

  Map<String, bool> get widgetVisibility => _widgetVisibility;
  List<dynamic> get customFields => _customFields;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProfileConfigProvider() {
    developer.log('DEBUG ProfileConfig: Constructor called',
        name: 'ProfileConfig');
    fetchConfig();
  }

  Future<void> fetchConfig() async {
    developer.log('DEBUG ProfileConfig: fetchConfig() called',
        name: 'ProfileConfig');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      developer.log('DEBUG ProfileConfig: Starting API calls...',
          name: 'ProfileConfig');
      final results = await Future.wait([
        UserAdminService.getProfileSettings(),
        TemplateService.getCustomFields(),
      ]);

      developer.log('DEBUG ProfileConfig: API calls completed',
          name: 'ProfileConfig');
      final settingsResult = results[0];
      final fieldsResult = results[1];

      developer.log('DEBUG ProfileConfig: Settings result = $settingsResult',
          name: 'ProfileConfig');
      developer.log('DEBUG ProfileConfig: Fields result = $fieldsResult',
          name: 'ProfileConfig');

      // Profile settings are optional - use defaults if they fail
      if (settingsResult['success'] == true) {
        _widgetVisibility = Map<String, bool>.from(settingsResult['data']);
        developer.log('DEBUG ProfileConfig: Loaded widget visibility settings',
            name: 'ProfileConfig');
      } else {
        developer.log(
            'DEBUG ProfileConfig: Profile settings failed (${settingsResult['message']}), using defaults',
            name: 'ProfileConfig');
        _widgetVisibility =
            {}; // Empty map means all widgets visible by default
      }

      // Custom fields are critical - throw if they fail
      if (fieldsResult['success'] == true) {
        _customFields = fieldsResult['data'] ?? [];
        developer.log(
            'DEBUG ProfileConfig: Loaded ${_customFields.length} custom fields',
            name: 'ProfileConfig');
        developer.log('DEBUG ProfileConfig: Custom fields: $_customFields',
            name: 'ProfileConfig');
      } else {
        developer.log(
            'DEBUG ProfileConfig: Fields API failed - ${fieldsResult['message']}',
            name: 'ProfileConfig');
        _customFields = []; // Use empty list if fields fail
      }
    } catch (e, stackTrace) {
      _error = e.toString();
      developer.log("ERROR fetching profile config: $_error",
          name: 'ProfileConfig', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
      developer.log(
          'DEBUG ProfileConfig: fetchConfig() completed, isLoading=$_isLoading, error=$_error',
          name: 'ProfileConfig');
    }
  }

  bool isWidgetVisible(String key) {
    return _widgetVisibility[key] ?? true;
  }
}
