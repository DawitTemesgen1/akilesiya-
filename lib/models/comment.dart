import 'package:amde_haymanot_abalat_guday/services/api_service.dart';

class Comment {
  final int id;
  final String userId;
  final int? parentId;
  final String author;
  final String? authorAvatar;
  final String text;
  final DateTime timestamp;
  final String? authorTenantId;

  Comment({
    required this.id,
    required this.userId,
    this.parentId,
    required this.author,
    this.authorAvatar,
    required this.text,
    required this.timestamp,
    this.authorTenantId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      userId: json['userId']?.toString() ?? '',
      parentId: json['parentId'] != null
          ? (json['parentId'] is String
              ? int.parse(json['parentId'])
              : json['parentId'])
          : null,
      author: json['author'] ?? json['userName'] ?? 'User',
      authorAvatar: ApiService.getImageUrl(
          json['authorAvatar'] ?? json['profileImageUrl']),
      text: json['text'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      authorTenantId: json['authorTenantId']?.toString(),
    );
  }
}
