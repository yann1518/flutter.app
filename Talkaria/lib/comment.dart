class Comment {
  final int id;
  final String content;
  final DateTime createdAt;
  final String author;
  final int authorId;

  Comment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.author,
    required this.authorId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      author: json['author'] ?? '',
      authorId: _extractUserId(json['users']),
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

