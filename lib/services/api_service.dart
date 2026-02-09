// lib/services/api_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  static late String _baseUrl;
  static const _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';
  static const Duration _timeoutDuration = Duration(seconds: 90);

  static String get baseUrl => _baseUrl;

  static void initialize({String? baseUrl}) {
    _baseUrl = baseUrl ?? _getDefaultBaseUrl();
    debugPrint("ApiService Initialized with URL: $_baseUrl");
  }

  static String _getDefaultBaseUrl() {
    if (kIsWeb) return 'http://localhost:3000/api';

    // For local dev on Android Emulator
    if (kDebugMode && Platform.isAndroid) return 'http://10.0.2.2:3000/api';

    // Default/iOS
    return 'http://localhost:3000/api';
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<http.StreamedResponse> uploadImage(XFile imageFile) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in again.');
    }
    final formattedEndpoint = '/upload';
    final uri = Uri.parse('$_baseUrl$formattedEndpoint');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );
    }
    debugPrint('📤 Uploading image (uploadImage) to: $uri');
    return request.send();
  }

  static Future<http.StreamedResponse> upload(
    String endpoint, {
    required Map<String, String> fields,
    required XFile file,
    required String fieldName,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }
    final formattedEndpoint =
        endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final uri = Uri.parse('$_baseUrl$formattedEndpoint');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: file.name,
      ));
    } else {
      request.files.add(await http.MultipartFile.fromPath(
        fieldName,
        file.path,
      ));
    }
    debugPrint('📤 Uploading image (upload) to: $uri');
    return request.send().timeout(_timeoutDuration);
  }

  // ==========================================================
  // --- CORE HTTP GET METHOD: UPGRADED FOR FILTERS ---
  // ==========================================================
  static Future<http.Response> get(String endpoint,
      {Map<String, String>? queryParams, int retryCount = 0}) async {
    final formattedEndpoint =
        endpoint.startsWith('/') ? endpoint : '/$endpoint';
    try {
      final headers = await _getHeaders();
      var uri = Uri.parse('$_baseUrl$formattedEndpoint');

      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      debugPrint('🌐 GET Request to: $uri');
      final response =
          await http.get(uri, headers: headers).timeout(_timeoutDuration);
      debugPrint('✅ GET Response: ${response.statusCode} for $uri');
      return response;
    } catch (e) {
      debugPrint('❌ GET Exception: $e');
      if (retryCount < 2 &&
          (e is http.ClientException ||
              e is SocketException ||
              e is TimeoutException)) {
        debugPrint('🔄 Retrying GET request (Attempt ${retryCount + 1})...');
        await Future.delayed(Duration(seconds: 1 * (retryCount + 1)));
        return get(endpoint,
            queryParams: queryParams, retryCount: retryCount + 1);
      }
      throw http.ClientException('Network error: $e');
    }
  }

  static Future<http.Response> post(
      String endpoint, Map<String, dynamic> body) async {
    final formattedEndpoint =
        endpoint.startsWith('/') ? endpoint : '/$endpoint';
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl$formattedEndpoint');
      debugPrint('🌐 POST Request to: $url');
      final response = await http
          .post(url, headers: headers, body: json.encode(body))
          .timeout(_timeoutDuration);
      debugPrint('✅ POST Response: ${response.statusCode} for $url');
      return response;
    } catch (e) {
      debugPrint('❌ POST Exception: $e');
      throw http.ClientException('Network error: $e');
    }
  }

  static Future<http.Response> put(
      String endpoint, Map<String, dynamic> body) async {
    final formattedEndpoint =
        endpoint.startsWith('/') ? endpoint : '/$endpoint';
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl$formattedEndpoint');
      debugPrint('🌐 PUT Request to: $url');
      final response = await http
          .put(url, headers: headers, body: json.encode(body))
          .timeout(_timeoutDuration);
      debugPrint('✅ PUT Response: ${response.statusCode} for $url');
      return response;
    } catch (e) {
      debugPrint('❌ PUT Exception: $e');
      throw http.ClientException('Network error: $e');
    }
  }

  static Future<http.Response> patch(
      String endpoint, Map<String, dynamic> body) async {
    final formattedEndpoint =
        endpoint.startsWith('/') ? endpoint : '/$endpoint';
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl$formattedEndpoint');
      debugPrint('🌐 PATCH Request to: $url');
      final response = await http
          .patch(url, headers: headers, body: json.encode(body))
          .timeout(_timeoutDuration);
      debugPrint('✅ PATCH Response: ${response.statusCode} for $url');
      return response;
    } catch (e) {
      debugPrint('❌ PATCH Exception: $e');
      throw http.ClientException('Network error: $e');
    }
  }

  static Future<http.Response> delete(String endpoint) async {
    final formattedEndpoint =
        endpoint.startsWith('/') ? endpoint : '/$endpoint';
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl$formattedEndpoint');
      debugPrint('🌐 DELETE Request to: $url');
      final response =
          await http.delete(url, headers: headers).timeout(_timeoutDuration);
      debugPrint('✅ DELETE Response: ${response.statusCode} for $url');
      return response;
    } catch (e) {
      debugPrint('❌ DELETE Exception: $e');
      throw http.ClientException('Network error: $e');
    }
  }

  static Future<http.Response> getWithUri(String endpoint) async {
    final formattedEndpoint =
        endpoint.startsWith('/') ? endpoint : '/$endpoint';
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl$formattedEndpoint');
      debugPrint('🌐 GET [Uri] Request to: $url');
      final response =
          await http.get(url, headers: headers).timeout(_timeoutDuration);
      debugPrint('✅ GET [Uri] Response: ${response.statusCode} for $url');
      return response;
    } catch (e) {
      debugPrint('❌ GET [Uri] Exception: $e');
      throw http.ClientException('Network error: $e');
    }
  }
}
