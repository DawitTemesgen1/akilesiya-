// file: lib/models/review_models.dart

class BookReview {
  final String id;
  final String? comment;
  final int? rating;
  final DateTime createdAt; // NEW: To show when the review was posted.
  // final String? userName; // REMOVED: We no longer need this.

  BookReview({
    required this.id,
    this.comment,
    this.rating,
    required this.createdAt,
    // this.userName, // REMOVED
  });

  factory BookReview.fromMap(Map<String, dynamic> map) {
    return BookReview(
      id: map['id'] as String,
      comment: map['comment'] as String?,
      rating: map['rating'] as int?,
      // NEW: Parse the timestamp from the database.
      createdAt: DateTime.parse(map['created_at']),
      // REMOVED: The logic for parsing the nested profile is gone.
    );
  }
}
