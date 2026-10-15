import 'package:flutter/material.dart';

import '../models/post.dart';
import 'post_video.dart';
import 'profile_avatar.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onToggleLike,
  });

  final Post post;
  final String currentUserId;
  final Future<void> Function() onToggleLike;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _savingLike = false;

  Future<void> _toggleLike() async {
    if (_savingLike) return;
    setState(() => _savingLike = true);
    try {
      await widget.onToggleLike();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo cambiar el like.')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingLike = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final liked = post.likes.contains(widget.currentUserId);
    return Card(
      color: Colors.white,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: ProfileAvatar(photoUrl: post.authorPhotoUrl, radius: 20),
            title: Text(
              post.authorName.isEmpty ? 'Usuario' : post.authorName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${post.petName} · ${_formatDate(post.createdAt)}'),
          ),
          GestureDetector(
            onDoubleTap: _savingLike ? null : _toggleLike,
            child: post.mediaType == 'video'
                ? PostVideo(url: post.mediaUrl)
                : AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      post.mediaUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: Color(0xFFEAE3FF),
                        child: Center(
                          child: Text('No se pudo cargar la imagen.'),
                        ),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(post.caption),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                IconButton(
                  onPressed: _savingLike ? null : _toggleLike,
                  tooltip: liked ? 'Quitar me gusta' : 'Dar me gusta',
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      liked ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(liked),
                      color: liked ? Colors.redAccent : null,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  child: Text(
                    '${post.likes.length}',
                    key: ValueKey(post.likes.length),
                  ),
                ),
                const SizedBox(width: 18),
                const Icon(Icons.chat_bubble_outline, size: 20),
                const SizedBox(width: 5),
                Text('${post.commentCount}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime? value) {
  if (value == null) return 'Recién';
  final date = value.toLocal();
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} '
      '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
}
