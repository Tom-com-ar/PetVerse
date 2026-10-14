import 'package:flutter/material.dart';

import '../models/post.dart';
import 'post_video.dart';
import 'profile_avatar.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) => Card(
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
        post.mediaType == 'video'
            ? PostVideo(url: post.mediaUrl)
            : AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  post.mediaUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: Color(0xFFEAE3FF),
                    child: Center(child: Text('No se pudo cargar la imagen.')),
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
              const Icon(Icons.favorite_border, size: 20),
              const SizedBox(width: 5),
              Text('${post.likes.length}'),
              const SizedBox(width: 20),
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

String _formatDate(DateTime? value) {
  if (value == null) return 'Recién';
  final date = value.toLocal();
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year} '
      '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
}
