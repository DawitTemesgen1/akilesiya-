// lib/services/audit_service.dart
import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:flutter/foundation.dart';

class AuditService {
  static Future<List<dynamic>> getAuditTrail({String? type}) async {
    try {
      String endpoint = '/audit/all';
      if (type != null && type.isNotEmpty) {
        endpoint += '?type=$type';
      }

      final response = await ApiService.get(endpoint);
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'] as List<dynamic>? ?? [];
      } else {
        throw Exception(data['message'] ?? 'Failed to load audit trail');
      }
    } catch (e) {
      debugPrint("API Service Error in AuditService: $e");
      throw Exception('Failed to communicate with the server.');
    }
  }
}
