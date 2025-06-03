import 'package:flutter/material.dart';
import 'api_service.dart';

class PostCard extends StatefulWidget {
  final int postId;
  final String title;
  final String imageUrl;
  final String category;
  final DateTime createdAt;
  final VoidCallback onViewMore;
  final ApiService apiService;
  final bool initialIsLiked;
  final int initialLikes;

  const PostCard({
    Key? key,
    required this.postId,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.createdAt,
    required this.onViewMore,
    required this.apiService,
    this.initialIsLiked = false,
    this.initialLikes = 0,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool isLiked;
  late int likes;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.initialIsLiked;
    likes = widget.initialLikes;
    _fetchLikes();
  }

  Future<void> _fetchLikes() async {
    try {
      final result = await widget.apiService.fetchLikes(widget.postId);
      setState(() {
        likes = result['likes'] ?? 0;
        isLiked = result['isLiked'] ?? false;
      });
    } catch (e) {
      // ignore erreur
    }
  }

  Future<void> _toggleLike() async {
    if (loading) return;
    setState(() { loading = true; });
    try {
      final result = await widget.apiService.toggleLike(widget.postId);
      setState(() {
        likes = result['likes'] ?? likes;
        isLiked = result['isLiked'] ?? isLiked;
      });
    } catch (e) {
      // ignore erreur
    }
    setState(() { loading = false; });
  }



  @override
  Widget build(BuildContext context) {
    final fullImageUrl = widget.imageUrl.startsWith('http')
        ? widget.imageUrl
        : 'https://std29.beaupeyrat.com/uploads/imagesclient/${widget.imageUrl}';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.imageUrl.isNotEmpty
              ? Image.network(
                  fullImageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: Icon(Icons.broken_image)),
                    );
                  },
                )
              : const SizedBox(
                  height: 200,
                  child: Center(child: Text('Pas d’image')),
                ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.category, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      widget.category,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(widget.createdAt),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: widget.onViewMore,
                  icon: const Icon(Icons.visibility),
                  label: const Text('Voir plus'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
                TextButton.icon(
                  onPressed: loading ? null : _toggleLike,
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  label: Text('$likes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
