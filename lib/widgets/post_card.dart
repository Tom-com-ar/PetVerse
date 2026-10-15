import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/post_comment.dart';
import 'post_video.dart';
import 'profile_avatar.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onToggleLike,
    required this.comments,
    required this.onAddComment,
    required this.onDeleteComment,
  });

  final Post post;
  final String currentUserId;
  final Future<void> Function() onToggleLike;
  final Stream<List<PostComment>> comments;
  final Future<void> Function(String text) onAddComment;
  final Future<void> Function(String commentId) onDeleteComment;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _savingLike = false;
  bool _commentsExpanded = false;
  bool _savingComment = false;
  final _commentController = TextEditingController();
  late Stream<List<PostComment>> _comments;

  @override
  void initState() {
    super.initState();
    _comments = widget.comments;
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) _comments = widget.comments;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

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

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _savingComment) return;
    setState(() => _savingComment = true);
    try {
      await widget.onAddComment(text);
      if (mounted) _commentController.clear();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo publicar el comentario.')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingComment = false);
    }
  }

  Future<void> _deleteComment(PostComment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar comentario'),
        content: const Text('¿Querés eliminar tu comentario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.onDeleteComment(comment.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar el comentario.')),
        );
      }
    }
  }

  Widget _commentTile(PostComment comment) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileAvatar(photoUrl: comment.authorPhotoUrl, radius: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.authorName.isEmpty ? 'Usuario' : comment.authorName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(comment.text),
              Text(
                _formatDate(comment.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (comment.authorId == widget.currentUserId)
          IconButton(
            onPressed: () => _deleteComment(comment),
            tooltip: 'Eliminar comentario',
            icon: const Icon(Icons.delete_outline),
          ),
      ],
    ),
  );

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
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Center(
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
          StreamBuilder<List<PostComment>>(
            stream: _comments,
            builder: (context, snapshot) {
              final comments = snapshot.data ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                        TextButton.icon(
                          onPressed: () => setState(
                            () => _commentsExpanded = !_commentsExpanded,
                          ),
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: Text('Comentarios (${comments.length})'),
                        ),
                      ],
                    ),
                  ),
                  if (_commentsExpanded) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (snapshot.hasError)
                            const Text('No se pudieron cargar los comentarios.')
                          else if (!snapshot.hasData)
                            const Center(child: CircularProgressIndicator())
                          else if (comments.isEmpty)
                            const Text('Todavía no hay comentarios.')
                          else
                            ...comments.map(_commentTile),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  onChanged: (_) => setState(() {}),
                                  maxLength: 500,
                                  minLines: 1,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    hintText: 'Escribí un comentario',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed:
                                    _savingComment ||
                                        _commentController.text.trim().isEmpty
                                    ? null
                                    : _addComment,
                                tooltip: 'Enviar comentario',
                                icon: const Icon(Icons.send),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
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
