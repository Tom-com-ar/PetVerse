import 'package:cloud_firestore/cloud_firestore.dart';

class PostDraft {
  const PostDraft({
    required this.petId,
    required this.petName,
    required this.mediaType,
    required this.mediaUrl,
    required this.caption,
  });

  final String petId;
  final String petName;
  final String mediaType;
  final String mediaUrl;
  final String caption;
}

class Post {
  const Post({
    required this.id,
    required this.ownerId,
    required this.authorName,
    required this.authorPhotoUrl,
    required this.petId,
    required this.petName,
    required this.mediaType,
    required this.mediaUrl,
    required this.caption,
    required this.likes,
    required this.commentCount,
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final String authorName;
  final String authorPhotoUrl;
  final String petId;
  final String petName;
  final String mediaType;
  final String mediaUrl;
  final String caption;
  final List<String> likes;
  final int commentCount;
  final DateTime? createdAt;

  factory Post.fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? {};
    return Post(
      id: document.id,
      ownerId: (data['ownerId'] as String?) ?? '',
      authorName: (data['authorName'] as String?) ?? '',
      authorPhotoUrl: (data['authorPhotoUrl'] as String?) ?? '',
      petId: (data['petId'] as String?) ?? '',
      petName: (data['petName'] as String?) ?? '',
      mediaType: (data['mediaType'] as String?) ?? 'image',
      mediaUrl: (data['mediaUrl'] as String?) ?? '',
      caption: (data['caption'] as String?) ?? '',
      likes: ((data['likes'] as List<dynamic>?) ?? [])
          .whereType<String>()
          .toList(),
      commentCount: (data['commentCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
