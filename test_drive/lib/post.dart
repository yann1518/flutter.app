class Post {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;
  final String imageFilename; // Utilisé pour le nom de l'image
  final String slug; // Identifiant unique pour chaque post

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
  });

  // Constructeur pour générer une instance à partir d'un objet JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    String? createdAtStr = json['createdAt'];
    String? updatedAtStr = json['updatedAt'];
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
    );
  }
}
