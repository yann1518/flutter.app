import 'dart:convert';
import 'package:http/http.dart' as http;
import 'comment.dart';

class ApiService {
  final String baseUrl;
  final String token;

  ApiService({required this.baseUrl, required this.token});

  Future<List<Comment>> fetchComments(int postId) async {
    final url = Uri.parse('$baseUrl/api/comments?posts=/api/posts/$postId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/ld+json',
      },
    );
    if (response.statusCode == 200) {
      print('Réponse brute fetchComments: ${response.body}'); // <-- Copie cette ligne ici après test
      final decoded = json.decode(response.body);
      List<dynamic> data;
      if (decoded is Map<String, dynamic> && decoded.containsKey('member')) {
        data = decoded['member'];
      } else if (decoded is List) {
        data = decoded;
      } else {
        data = [];
      }
      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      print('Erreur fetchComments: ${response.statusCode}');
      print('Body: ${response.body}');
      throw Exception('Erreur lors du chargement des commentaires');
    }
  }

  Future<Comment> postComment(int postId, String content, String author) async {
    final url = Uri.parse('$baseUrl/api/comments');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/ld+json',
      },
      body: json.encode({
        'content': content,
        'author': author,
        'posts': '/api/posts/$postId',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Comment.fromJson(json.decode(response.body));
    } else {
      print('Erreur POST commentaire: ${response.statusCode}');
      print('Body: ${response.body}');
      throw Exception('Erreur lors de l\'envoi du commentaire');
    }
  }
}
