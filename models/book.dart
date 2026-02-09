// file: lib/models/book.dart

class Book {
  // MODIFIED: id is now an int to match your database's 'bigint' type.
  final int id;
  final String title;

  // MODIFIED: All these fields are now nullable (String?, int?, etc.)
  // because the error messages proved they do not exist in your database table.
  final String? author;
  final String? coverUrl;
  final String? genre;
  final int? publicationYear;
  final double? averageRating;
  final int? reviewCount;

  Book({
    required this.id,
    required this.title,
    this.author,
    this.coverUrl,
    this.genre,
    this.publicationYear,
    this.averageRating,
    this.reviewCount,
  });

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      // MODIFIED: Parsing an int, not a String.
      id: map['id'] as int,
      title: map['title'] as String,
      // MODIFIED: Safely parsing nullable fields.
      author: map['author'] as String?,
      coverUrl: map['cover_url'] as String?,
      genre: map['genre'] as String?,
      publicationYear: map['publication_year'] as int?,
      // MODIFIED: average_rating is a double, must be parsed correctly.
      averageRating: (map['average_rating'] as num?)?.toDouble(),
      reviewCount: map['review_count'] as int?,
    );
  }
}
