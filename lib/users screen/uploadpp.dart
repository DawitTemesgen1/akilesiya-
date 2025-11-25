import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // ADD THIS IMPORT
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart'; // ADD THIS IMPORT

class ProfileUploadService {
  // Use XFile which is the universal type from image_picker
  static Future<Map<String, dynamic>> uploadAvatar(XFile imageFile) async {
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Authentication token not found.'};
      }

      final url = Uri.parse('${ApiService.baseUrl}/profile/avatar');

      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      // ======================= THE FIX =======================
      // This logic checks if the app is running on the web.
      // - If WEB: It reads the file's bytes into memory.
      // - If MOBILE: It reads the file from the storage path.
      // This is the definitive solution for cross-platform file uploads.
      // =======================================================
      if (kIsWeb) {
        // Web implementation
        request.files.add(
          http.MultipartFile.fromBytes(
            'avatar', // Must match backend key
            await imageFile.readAsBytes(),
            filename: imageFile.name, // Pass the original file name
            contentType:
                MediaType('image', 'jpeg'), // Adjust content type if needed
          ),
        );
      } else {
        // Mobile (iOS/Android) implementation
        request.files.add(
          await http.MultipartFile.fromPath(
            'avatar', // Must match backend key
            imageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final body = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Failed to upload image.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }
}
