import 'package:flutter/material.dart';
import 'post.dart';

class PostDetailScreen extends StatelessWidget {
  final Post post;

  const PostDetailScreen({required this.post});

  @override
  Widget build(BuildContext context) {
    try {
      String formattedDate = _formatDate(post.createdAt);

      return Scaffold(
        appBar: AppBar(
          title: Text(post.title, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepPurple,
          elevation: 2,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFF4F4F8),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 6,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      post.imageFilename.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                'https://std29.beaupeyrat.com/uploads/imagesclient/${post.imageFilename}',
                                fit: BoxFit.cover,
                                height: 220,
                                width: double.infinity,
                              ),
                            )
                          : Container(
                              height: 220,
                              decoration: BoxDecoration(
                                color: Colors.deepPurple[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(child: Text('Pas d’image', style: TextStyle(color: Colors.deepPurple))),
                            ),
                      const SizedBox(height: 22),
                      Text(
                        post.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category, size: 18, color: Colors.deepPurple[200]),
                          const SizedBox(width: 6),
                          Text(
                            post.category,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.deepPurple[300], fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time, size: 18, color: Colors.grey[500]),
                          const SizedBox(width: 6),
                          Text(
                            formattedDate,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          post.content,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18, color: Colors.black87),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e, stack) {
      print('Erreur dans PostDetailScreen:\nErreur: $e\nStacktrace: $stack');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erreur'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              'Erreur lors de l\'affichage du post :\n\n$e',
              style: const TextStyle(color: Colors.red, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
  }

  String _formatDate(dynamic dateInput) {
    try {
      DateTime date;
      if (dateInput is DateTime) {
        date = dateInput;
      } else if (dateInput is String) {
        date = DateTime.parse(dateInput);
      } else {
        return dateInput.toString();
      }
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateInput.toString();
    }
  }
}
