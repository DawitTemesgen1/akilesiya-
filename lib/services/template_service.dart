// lib/services/template_service.dart

import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:http/http.dart' as http;

class TemplateService {
  static Future<Map<String, dynamic>> _handleResponse(
      Future<http.Response> futureResponse) async {
    try {
      final response = await futureResponse;
      final body = json.decode(response.body);
      return body as Map<String, dynamic>;
    } catch (e) {
      return {
        'success': false,
        'message': 'Network Error or Invalid Server Response: $e'
      };
    }
  }

  // === Field Functions ===

  static Future<Map<String, dynamic>> getCustomFields() {
    return _handleResponse(ApiService.get('/template/fields'));
  }

  static Future<Map<String, dynamic>> createCustomField(
      String name, String managedBy, String profileTab, String fieldType) {
    final body = {
      'name': name,
      'managed_by': managedBy,
      'profile_tab': profileTab,
      'field_type': fieldType,
      'type': fieldType,
    };
    debugPrint('DEBUG: TemplateService.createCustomField body: $body');
    return _handleResponse(ApiService.post('/template/fields', body));
  }

  static Future<Map<String, dynamic>> deleteCustomField(int id) {
    return _handleResponse(ApiService.delete('/template/fields/$id'));
  }

  static Future<Map<String, dynamic>> updateCustomField(int id, String name,
      String managedBy, String profileTab, String fieldType) {
    final body = {
      'name': name,
      'managed_by': managedBy,
      'profile_tab': profileTab,
      'field_type': fieldType,
      'type': fieldType,
    };
    debugPrint('DEBUG: TemplateService.updateCustomField body: $body');
    return _handleResponse(ApiService.put('/template/fields/$id', body));
  }

  // === Option Functions ===

  static Future<Map<String, dynamic>> createFieldOption(
      int fieldId, String value) {
    return _handleResponse(ApiService.post('/template/options', {
      'field_id': fieldId,
      'value': value,
    }));
  }

  static Future<Map<String, dynamic>> deleteFieldOption(int id) {
    return _handleResponse(ApiService.delete('/template/options/$id'));
  }
}
