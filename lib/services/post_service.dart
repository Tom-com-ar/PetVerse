import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/post.dart';
import '../models/post_comment.dart';
import '../models/user_profile.dart';

class PostService {
  PostService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection('posts');

  Stream<List<Post>> watchPosts() => _posts
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(Post.fromDocument).toList());

  Stream<List<PostComment>> watchComments(String postId) => _posts
      .doc(postId)
      .collection('comments')
      .orderBy('createdAt')
      .snapshots()
      .map((snapshot) => snapshot.docs.map(PostComment.fromDocument).toList());

  Future<void> createPost(
    User user,
    UserProfile profile,
    PostDraft draft,
  ) async {
    if (draft.petId.isEmpty) throw ArgumentError('Seleccioná una mascota.');
    await _posts.add({
      'ownerId': user.uid,
      'authorName': profile.name.isNotEmpty
          ? profile.name
          : (user.displayName ?? 'Usuario'),
      'authorPhotoUrl': profile.photoUrl,
      'petId': draft.petId,
      'petName': draft.petName,
      'mediaType': draft.mediaType,
      'mediaUrl': draft.mediaUrl.trim(),
      'caption': draft.caption.trim(),
      'likes': <String>[],
      'commentCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleLike(String postId, String userId) async {
    final reference = _posts.doc(postId);
    await _firestore.runTransaction<void>((transaction) async {
      final snapshot = await transaction.get(reference);
      if (!snapshot.exists) throw StateError('La publicación ya no existe.');
      final likes = ((snapshot.data()?['likes'] as List<dynamic>?) ?? [])
          .whereType<String>()
          .toList();
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }
      transaction.update(reference, {'likes': likes});
    });
  }

  Future<void> addComment(
    String postId,
    User user,
    UserProfile profile,
    String text,
  ) async {
    final value = text.trim();
    if (value.isEmpty || value.length > 500) {
      throw ArgumentError('El comentario debe tener entre 1 y 500 caracteres.');
    }
    await _posts.doc(postId).collection('comments').add({
      'authorId': user.uid,
      'authorName': profile.name,
      'authorPhotoUrl': profile.photoUrl,
      'text': value,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteComment(String postId, String commentId) =>
      _posts.doc(postId).collection('comments').doc(commentId).delete();
}
