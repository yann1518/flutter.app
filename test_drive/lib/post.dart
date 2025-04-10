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
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      category: json['category'],
      imageFilename: json['imageFilename'],
      slug: json['slug'],
    );
  }
}
