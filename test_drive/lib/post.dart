import 'comment.dart';

class Post {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;
  final String imageFilename; // Utilisé pour le nom de l'image
  final String slug; // Identifiant unique pour chaque post
  final String author;
  final int userId;
  final List<Comment> comments;

  // Constructeur
  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.imageFilename,
    required this.slug,
    required this.author,
    required this.userId,
    required this.comments,
  });

  // Constructeur pour générer une instance à partir d'un objet JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    String? createdAtStr = json['createdAt'];
    String? updatedAtStr = json['updatedAt'];
    List<Comment> commentsList = [];
    if (json['comments'] != null && json['comments'] is List) {
      commentsList = (json['comments'] as List)
          .map((c) => c is Map<String, dynamic>
              ? Comment.fromJson(c)
              : null)
          .whereType<Comment>()
          .toList();
    }
    return Post(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: (createdAtStr != null && createdAtStr.isNotEmpty)
          ? DateTime.tryParse(createdAtStr) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: (updatedAtStr != null && updatedAtStr.isNotEmpty)
          ? DateTime.tryParse(updatedAtStr) ?? DateTime.now()
          : DateTime.now(),
      category: json['category'] ?? '',
      imageFilename: json['imageFilename'] ?? '',
      slug: json['slug'] ?? '',
      author: json['author'] ?? '',
      userId: _extractUserId(json['users']),
      comments: commentsList,
    );
  }

  // Helper pour extraire l'ID de l'URL utilisateur
  static int _extractUserId(dynamic usersField) {
    if (usersField is String && usersField.startsWith('/api/users/')) {
      final idStr = usersField.split('/').last;
      return int.tryParse(idStr) ?? 0;
    }
    return 0;
  }
}
