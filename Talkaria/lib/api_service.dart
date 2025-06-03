import 'dart:convert';
import 'package:http/http.dart' as http;
import 'comment.dart';

class ApiService {
  // ... (constructeur et champs déjà présents)

  /// Like ou unlike un post. Retourne un Map avec 'likes' (int) et 'isLiked' (bool)
  Future<Map<String, dynamic>> toggleLike(int postId) async {
    final url = Uri.parse('$baseUrl/post/$postId/like');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'X-Requested-With': 'XMLHttpRequest',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return {
        'likes': decoded['likes'] ?? 0,
        'isLiked': decoded['isLiked'] ?? false,
        'message': decoded['message'] ?? '',
      };
    } else {
      print('Erreur toggleLike: ${response.statusCode}');
      print('Body: ${response.body}');
      throw Exception('Erreur lors du like/unlike du post');
    }
  }

  /// Récupère le nombre de likes et l'état like pour un post (même endpoint, sans modifier l'UI)
  Future<Map<String, dynamic>> fetchLikes(int postId) async {
    final url = Uri.parse('$baseUrl/post/$postId/like');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'X-Requested-With': 'XMLHttpRequest',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      return {
        'likes': decoded['likes'] ?? 0,
        'isLiked': decoded['isLiked'] ?? false,
      };
    } else {
      print('Erreur fetchLikes: ${response.statusCode}');
      print('Body: ${response.body}');
      throw Exception('Erreur lors de la récupération des likes');
    }
  }
  final String baseUrl;
  final String token;

  ApiService({required this.baseUrl, required this.token});

  Future<List<Comment>> fetchComments(int postId) async {
    final url = Uri.parse('$baseUrl/api/comments?posts=/api/posts/$postId');
    print('URL appelée : $url');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/ld+json',
      },
    );
    if (response.statusCode == 200) {
      print('Réponse brute fetchComments: ${response.body}'); // <-- Copie cette ligne ici après test
      // DEBUG : Affiche le nombre de commentaires retournés
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded.containsKey('member')) {
          print('Nombre de commentaires (member) : ${decoded['member']?.length}');
        } else if (decoded is List) {
          print('Nombre de commentaires (list) : ${decoded.length}');
        }
      } catch (e) {
        print('Erreur lors du décodage JSON pour debug : $e');
      }
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
   Future<void> deleteComment(int commentId) async {
    final url = Uri.parse('$baseUrl/api/comments/$commentId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/ld+json',
      },
    );
    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression du commentaire');
    }
  }
}
