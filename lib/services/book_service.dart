// lib/services/book_service.dart

import 'dart:convert';
import 'package:amde_haymanot_abalat_guday/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:amde_haymanot_abalat_guday/models/comment.dart';

//==============================================================================
// --- DATA MODELS (SINGLE SOURCE OF TRUTH) ---
//==============================================================================

enum BookAvailability { siteLibrary, online, unavailable }

class Book {
  final String id;
  final int assignmentId;
  final String title;
  final String author;
  final String coverUrl;
  final String description;
  final double rating;
  final List<String> genres;
  final BookAvailability availability;
  final String pullQuote;
  final String fullReview;
  final List<String> perfectFor;
  final bool isFeatured;
  final DateTime? deadline;
  int likes;
  bool isLiked;
  bool isRead;
  List<Comment> comments;

  Book({
    required this.id,
    required this.assignmentId,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.description,
    required this.rating,
    required this.genres,
    required this.availability,
    required this.pullQuote,
    required this.fullReview,
    required this.perfectFor,
    required this.isFeatured,
    this.deadline,
    this.likes = 0,
    this.isLiked = false,
    this.isRead = false,
    this.comments = const [],
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    BookAvailability availabilityFromString(String? avail) {
      switch (avail) {
        case 'siteLibrary':
          return BookAvailability.siteLibrary;
        case 'online':
          return BookAvailability.online;
        default:
          return BookAvailability.unavailable;
      }
    }

    String fullCoverUrl = json['cover_url'] ?? '';
    if (fullCoverUrl.isNotEmpty && !fullCoverUrl.startsWith('http')) {
      final baseUrl = ApiService.baseUrl.replaceAll('/api', '');
      fullCoverUrl = '$baseUrl/uploads/$fullCoverUrl';
    }

    List<String> parseJsonStringList(dynamic jsonField) {
      if (jsonField == null) return [];
      if (jsonField is List) return List<String>.from(jsonField);
      if (jsonField is String) {
        try {
          final decoded = jsonDecode(jsonField);
          if (decoded is List) return List<String>.from(decoded);
        } catch (e) {
          return jsonField
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
      }
      return [];
    }

    return Book(
      id: json['id'].toString(),
      assignmentId: (json['assignmentId'] as num?)?.toInt() ?? 0,
      title: json['title'] ?? 'Untitled',
      author: json['author'] ?? 'Unknown Author',
      coverUrl: fullCoverUrl,
      description: json['description'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
      likes: int.tryParse(json['likes']?.toString() ?? '0') ?? 0,
      isLiked: json['isLiked'] == 1 || json['isLiked'] == true,
      genres: parseJsonStringList(json['genres']),
      availability: availabilityFromString(json['availability']),
      pullQuote: json['pull_quote'] ?? '',
      fullReview: json['full_review'] ?? '',
      perfectFor: parseJsonStringList(json['perfect_for']),
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      deadline:
          json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
    );
  }
}

//==============================================================================
// --- BOOK SERVICE CLASS ---
//==============================================================================

class BookService {
  static Future<Map<String, dynamic>> _handleRequest(
      Future<dynamic> request) async {
    try {
      final response = await request;
      if (response.body.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return {'success': true, 'data': {}};
        } else {
          return {
            'success': false,
            'message': 'Request failed with status: ${response.statusCode}'
          };
        }
      }
      final body = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': body['data'] ?? body};
      }
      return {
        'success': false,
        'message': body['message'] ?? 'An API error occurred.'
      };
    } catch (e) {
      return {'success': false, 'message': 'Network or parsing Error: $e'};
    }
  }

  static Future<List<Book>> getBooks() async {
    final result = await _handleRequest(ApiService.get('books'));
    if (result['success']) {
      final List<dynamic> data = result['data'];
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception(result['message']);
    }
  }

  static Future<List<Comment>> getComments(String bookId) async {
    final result =
        await _handleRequest(ApiService.get('books/$bookId/comments'));
    if (result['success']) {
      final List<dynamic> data = result['data'];
      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception(result['message']);
    }
  }

  static Future<Comment> addComment(
      {required String bookId, required String text, int? parentId}) async {
    final result =
        await _handleRequest(ApiService.post('books/$bookId/comments', {
      'text': text,
      if (parentId != null) 'parentId': parentId,
    }));
    if (result['success']) {
      return Comment.fromJson(result['data']);
    } else {
      throw Exception(result['message']);
    }
  }

  static Future<Map<String, dynamic>> updateComment({
    required int commentId,
    required String text,
  }) {
    return _handleRequest(
        ApiService.put('books/comments/$commentId', {'text': text}));
  }

  static Future<Map<String, dynamic>> deleteComment(int commentId) {
    return _handleRequest(ApiService.delete('books/comments/$commentId'));
  }

  static Future<Map<String, dynamic>> toggleLikeStatus(
      {required int assignmentId}) async {
    final result = await _handleRequest(
        ApiService.post('books/assignments/$assignmentId/like', {}));
    if (result['success']) {
      return result['data'];
    } else {
      throw Exception(result['message']);
    }
  }

  static Future<void> updateAssignmentStatus(
      {required int assignmentId, required bool isRead}) async {
    final result = await _handleRequest(ApiService.patch(
        'books/assignments/$assignmentId/status', {'isRead': isRead}));
    if (!result['success']) {
      throw Exception(result['message']);
    }
  }

  static Future<Map<String, dynamic>> createMasterBook(
      Map<String, dynamic> bookData) {
    return _handleRequest(ApiService.post('books/master-list', bookData));
  }

  static Future<Map<String, dynamic>> assignBook(
      {required String userId,
      required String bookTitle,
      required DateTime finishBy}) {
    return _handleRequest(ApiService.post('books/assign', {
      'userId': userId,
      'bookTitle': bookTitle,
      'finishBy': DateFormat('yyyy-MM-dd').format(finishBy),
      'availability': 'siteLibrary',
    }));
  }
}
