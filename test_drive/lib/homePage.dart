import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'postCard.dart';
import 'post.dart';

class HomePage extends StatefulWidget {
  final String token;

  const HomePage({super.key, required this.token});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        print("Requête réussie !");
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          posts = data.map((post) => Post.fromJson(post)).toList();
          isLoading = false;
        });
      } else {
        print("Erreur ${response.statusCode}: ${response.body}");
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Erreur ${response.statusCode} : ${response.body}')),
        );
      }
    } catch (e) {
      print("Erreur lors de la requête : $e");
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur réseau')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? const Center(child: Text('Aucun post trouvé.'))
              : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostCard(
                      title: post.title,
                      description: post.content,
                      imageUrl: post.imageFilename,
                      category: post.category,
                      createdAt: post.createdAt,
                    );
                  },
                ),
    );
  }
}
