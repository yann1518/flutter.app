import 'package:flutter/material.dart';
import 'post.dart';
import 'comment.dart';
import 'api_service.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  final String token;
  final String postAuthor;
  final int postAuthorId;
  final int currentUserId;
  final List<String> roles;
  final String username;

  const PostDetailScreen({required this.post, required this.token, required this.postAuthor, required this.postAuthorId, required this.currentUserId, required this.roles, required this.username});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late ApiService apiService;
  List<Comment> comments = [];
  bool isLoadingComments = true;
  final TextEditingController _controller = TextEditingController();
  bool isPosting = false;

  @override
  void initState() {
    super.initState();
    // Remplace par l'URL de base de ton API et le token utilisateur
    apiService = ApiService(baseUrl: 'https://std29.beaupeyrat.com', token: widget.token);
    fetchComments();
  }

  Future<void> fetchComments() async {
    setState(() {
      isLoadingComments = true;
    });
    try {
      // Toujours charger les commentaires depuis l'API pour avoir la liste à jour
      comments = await apiService.fetchComments(widget.post.id);
    } catch (e) {
      comments = [];
    }
    setState(() {
      isLoadingComments = false;
    });
  }

  Future<void> postComment() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      isPosting = true;
    });
    try {
      // Remplace 'Auteur' par le vrai nom de l'utilisateur si tu l'as
      final newComment = await apiService.postComment(widget.post.id, _controller.text, widget.username);
      setState(() {
        comments.insert(0, newComment);
        _controller.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi du commentaire')),
      );
    }
    setState(() {
      isPosting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      String formattedDate = _formatDate(widget.post.createdAt);

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.post.title, style: const TextStyle(color: Colors.white)),
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
                      widget.post.imageFilename.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                'https://std29.beaupeyrat.com/uploads/imagesclient/${widget.post.imageFilename}',
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
                        widget.post.title,
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
                            widget.post.category,
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
                          widget.post.content,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18, color: Colors.black87),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Commentaires',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                        ),
                      ),
                      const SizedBox(height: 10),
                      isLoadingComments
                          ? const Center(child: CircularProgressIndicator())
                          : comments.isEmpty
                              ? const Text('Aucun commentaire pour ce post.')
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: comments.length,
                                  itemBuilder: (context, index) {
                                    final comment = comments[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 6),
                                      child: ListTile(
                                        leading: const Icon(Icons.comment, color: Colors.deepPurple),
                                        title: Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                comment.author +
                                                    (comment.author == widget.postAuthor ? ' (Auteur du post)' : '') +
                                                    (comment.author == widget.username ? ' (Moi)' : ''),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: comment.author == widget.postAuthor
                                                      ? Colors.deepPurple
                                                      : (comment.author == widget.username ? Colors.green : Colors.black),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(comment.content),
                                            Row(
                                              children: [
                                                const Icon(Icons.email, size: 14, color: Colors.blueGrey),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    comment.author,
                                                    style: TextStyle(
                                                      color: comment.author == widget.postAuthor
                                                          ? Colors.deepPurple
                                                          : (comment.author == widget.roles.join(',') ? Colors.green : Colors.blueGrey),
                                                      fontSize: 12,
                                                      fontStyle: comment.author == widget.roles.join(',') ? FontStyle.italic : FontStyle.normal,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (comment.author == widget.roles.join(','))
                                                  const Padding(
                                                    padding: EdgeInsets.only(left: 4),
                                                    child: Text('(Moi)', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(_formatDate(comment.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                          ],
                                        ),
                                        trailing: (widget.roles.contains('ROLE_ADMIN') || comment.author == widget.username)
                                            ? IconButton(
                                                icon: Icon(Icons.delete, color: Colors.red),
                                                onPressed: () async {
                                                  // Si utilisateur lambda, il ne peut supprimer que ses propres commentaires
                                                  if (!widget.roles.contains('ROLE_ADMIN') && comment.author != widget.username) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Vous ne pouvez supprimer que vos propres commentaires.')),
                                                    );
                                                    return;
                                                  }
                                                  try {
                                                    await apiService.deleteComment(comment.id);
                                                    setState(() {
                                                      comments.removeAt(index);
                                                    });
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Commentaire supprimé')),
                                                    );
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Erreur lors de la suppression')),
                                                    );
                                                  }
                                                },
                                              )
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                labelText: 'Ajouter un commentaire...',
                                border: OutlineInputBorder(),
                              ),
                              minLines: 1,
                              maxLines: 3,
                            ),
                          ),
                          const SizedBox(width: 10),
                          isPosting
                              ? const CircularProgressIndicator()
                              : IconButton(
                                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                                  onPressed: postComment,
                                ),
                        ],
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
