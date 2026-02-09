// lib/services/tenant_service.dart

import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'dart:developer' as developer;

class TenantSummary {
  final String id;
  final String name;
  TenantSummary({required this.id, required this.name});
}

class TenantService {
  /// Fetches the public list of all registered schools from your Node.js backend.
  static Future<List<TenantSummary>> getTenants() async {
    try {
      final response = await ApiService.get('/tenants');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) return [];

        final tenants = data
            .map((tenant) => TenantSummary(
                  id: tenant['id'].toString(),
                  name: tenant['name'].toString(),
                ))
            .toSet() // Use a Set to automatically handle duplicates
            .toList();

        return tenants;
      } else {
        developer.log(
            'API Error in getTenants: ${response.statusCode} ${response.body}',
            name: 'TenantService');
        throw Exception('Failed to load schools');
      }
    } catch (e, stackTrace) {
      developer.log(
        'CRITICAL ERROR in TenantService.getTenants()',
        name: 'TenantService',
        error: e,
        stackTrace: stackTrace,
      );
      // Return an empty list or rethrow to let the UI show an error.
      throw Exception('Could not connect to the server to get schools.');
    }
  }

  /// Creates a new school. Requires admin privileges on the backend.
  static Future<Map<String, dynamic>> createTenant({
    required String name,
    String? logoUrl,
    String? primaryColor,
    String? accentColor,
  }) async {
    try {
      final response = await ApiService.post('/tenants', {
        'name': name,
        'logoUrl': logoUrl,
        'primaryColor': primaryColor,
        'accentColor': accentColor,
      });

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        final errorMessage = data['message'] ?? 'Failed to create school';
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'success': false, 'message': 'Create tenant failed: $e'};
    }
  }
}
