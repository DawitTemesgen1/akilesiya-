import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:flutter/foundation.dart';

class HomepageService extends ApiService {
  /// Fetches all dynamic content for the homepage from the backend.
  static Future<Map<String, dynamic>> getHomepageContent() async {
    try {
      final response = await ApiService.get('/homepage');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        // Provide a more specific error message
        final errorData = json.decode(response.body);
        throw Exception(
            'Failed to load homepage content: ${errorData['message'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint("Error in HomepageService.getHomepageContent: $e");
      // Rethrow the exception to be caught by the provider
      throw Exception(
          'Failed to connect to the server. Please check your network.');
    }
  }
}
