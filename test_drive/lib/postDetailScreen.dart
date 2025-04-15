import 'package:flutter/material.dart';
import 'post.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({required this.post});

  @override
  Widget build(BuildContext context) {
    // Formater la date de création du post
    String formattedDate = _formatDate(post.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Affichage de l'image du post
              post.imageFilename.isNotEmpty
                  ? Image.network(
                      'https://std29.beaupeyrat.com/uploads/imagesclient/${post.imageFilename}',
                      fit: BoxFit.cover,
                      height: 250,
                    )
                  : const SizedBox(
                      height: 250, child: Center(child: Text('Pas d’image'))),

              // Affichage du titre du post
              const SizedBox(height: 16),
              Text(
                post.title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              // Affichage de la catégorie
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.category, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    post.category,
                    style: const TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ],
              ),

              // Affichage de la date de création
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),

              // Affichage du contenu du post
              const SizedBox(height: 16),
              Text(
                post.content,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Formater la date pour l'afficher de manière lisible
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
