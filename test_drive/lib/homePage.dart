import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'post.dart';
import 'postDetailScreen.dart';

class HomePage extends StatefulWidget {
  final String token;

  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateInput.toString();
    }
  }

  bool isLoading = true;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    print("Token envoyé : Bearer ${widget.token}");

    try {
      final response = await http.get(
        Uri.parse('https://std29.beaupeyrat.com/api/posts'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/ld+json',
        },
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> postList = jsonResponse['member'];

        setState(() {
          posts = postList.map((post) => Post.fromJson(post)).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur ${response.statusCode} : ${response.reasonPhrase}',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur réseau')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        backgroundColor: Colors.deepPurple,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Mon Profil',
            onPressed: () {
              // Extraction du userId et username depuis le token JWT
              String? userId;
              String? username;
              try {
                final parts = widget.token.split('.');
                if (parts.length == 3) {
                  final payload = parts[1];
                  String normalized = payload.padRight(payload.length + (4 - payload.length % 4) % 4, '=');
                  final decoded = base64Url.decode(normalized);
                  final payloadData = json.decode(utf8.decode(decoded));
                  userId = payloadData['sub']?.toString();
                  username = payloadData['username'];
                }
              } catch (e) {
                userId = null;
                username = null;
              }
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: {
                  'token': widget.token,
                  'userId': userId != null ? int.tryParse(userId) ?? 0 : 0,
                  'username': username ?? '',
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF4F4F8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? const Center(child: Text('Aucun post trouvé.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(24.0),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 18),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        leading: post.imageFilename.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'https://std29.beaupeyrat.com/uploads/imagesclient/${post.imageFilename}',
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(Icons.image, size: 60, color: Colors.deepPurple[200]),
                        title: Text(
                          post.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              'Catégorie : ${post.category}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 15, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(post.createdAt),
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailScreen(post: post, token: widget.token, postAuthor: post.author, postAuthorId: post.userId),
                              ),
                            );
                          },
                          child: const Text('Voir', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
