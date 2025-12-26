// lib/providers/profile_config_provider.dart

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
    print('DEBUG ProfileConfig: Constructor called');
    fetchConfig();
  }

  Future<void> fetchConfig() async {
    print('DEBUG ProfileConfig: fetchConfig() called');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('DEBUG ProfileConfig: Starting API calls...');
      final results = await Future.wait([
        UserAdminService.getProfileSettings(),
        TemplateService.getCustomFields(),
      ]);

      print('DEBUG ProfileConfig: API calls completed');
      final settingsResult = results[0];
      final fieldsResult = results[1];

      print('DEBUG ProfileConfig: Settings result = $settingsResult');
      print('DEBUG ProfileConfig: Fields result = $fieldsResult');

      // Profile settings are optional - use defaults if they fail
      if (settingsResult['success'] == true) {
        _widgetVisibility = Map<String, bool>.from(settingsResult['data']);
        print('DEBUG ProfileConfig: Loaded widget visibility settings');
      } else {
        print(
            'DEBUG ProfileConfig: Profile settings failed (${settingsResult['message']}), using defaults');
        _widgetVisibility =
            {}; // Empty map means all widgets visible by default
      }

      // Custom fields are critical - throw if they fail
      if (fieldsResult['success'] == true) {
        _customFields = fieldsResult['data'] ?? [];
        print(
            'DEBUG ProfileConfig: Loaded ${_customFields.length} custom fields');
        print('DEBUG ProfileConfig: Custom fields: $_customFields');
      } else {
        print(
            'DEBUG ProfileConfig: Fields API failed - ${fieldsResult['message']}');
        _customFields = []; // Use empty list if fields fail
      }
    } catch (e, stackTrace) {
      _error = e.toString();
      print("ERROR fetching profile config: $_error");
      print("Stack trace: $stackTrace");
    } finally {
      _isLoading = false;
      notifyListeners();
      print(
          'DEBUG ProfileConfig: fetchConfig() completed, isLoading=$_isLoading, error=$_error');
    }
  }

  bool isWidgetVisible(String key) {
    return _widgetVisibility[key] ?? true;
  }
}
