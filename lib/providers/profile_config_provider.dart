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
    fetchConfig();
  }

  Future<void> fetchConfig() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        UserAdminService.getProfileSettings(),
        TemplateService.getCustomFields(),
      ]);

      final settingsResult = results[0];
      final fieldsResult = results[1];

      print('DEBUG ProfileConfig: Settings result = $settingsResult');
      print('DEBUG ProfileConfig: Fields result = $fieldsResult');

      if (settingsResult['success'] == true) {
        _widgetVisibility = Map<String, bool>.from(settingsResult['data']);
      } else {
        throw Exception(
            settingsResult['message'] ?? 'Failed to load profile settings.');
      }

      if (fieldsResult['success'] == true) {
        _customFields = fieldsResult['data'];
        print('DEBUG ProfileConfig: Loaded ${_customFields.length} custom fields');
      } else {
        print('DEBUG ProfileConfig: Fields API failed - ${fieldsResult['message']}');
        throw Exception(
            fieldsResult['message'] ?? 'Failed to load custom fields.');
      }
    } catch (e) {
      _error = e.toString();
      print("Error fetching profile config: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isWidgetVisible(String key) {
    return _widgetVisibility[key] ?? true;
  }
}
