import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_conversation.dart';
import '../models/chat_message.dart';
import '../models/user_profile.dart';
import '../utils/chat_validators.dart';

class ChatService {
  ChatService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  Stream<List<ChatConversation>> watchConversations(String userId) => _chats
      .where('participants', arrayContains: userId)
      .snapshots()
      .map((snapshot) {
        final conversations = snapshot.docs
            .map(ChatConversation.fromDocument)
            .toList();
        conversations.sort((a, b) {
          final aDate = a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
        return conversations;
      });

  Stream<List<ChatMessage>> watchMessages(String chatId) => _chats
      .doc(chatId)
      .collection('messages')
      .orderBy('createdAt')
      .snapshots()
      .map((snapshot) => snapshot.docs.map(ChatMessage.fromDocument).toList());

  Future<String> startConversation({
    required User user,
    required UserProfile ownProfile,
    required UserProfile otherProfile,
  }) async {
    if (user.uid == otherProfile.uid) {
      throw ArgumentError('No podés iniciar un chat con tu propia cuenta.');
    }
    final participants = [user.uid, otherProfile.uid]..sort();
    final chatId = '${participants.first}--${participants.last}';
    final reference = _chats.doc(chatId);
    await reference.set({
      'participants': participants,
      'participantNames': {
        user.uid: ownProfile.name,
        otherProfile.uid: otherProfile.name,
      },
      'participantPhotos': {
        user.uid: ownProfile.photoUrl,
        otherProfile.uid: otherProfile.photoUrl,
      },
    }, SetOptions(merge: true));
    return chatId;
  }

  Future<void> sendMessage({
    required String chatId,
    required User user,
    required UserProfile profile,
    required String text,
  }) async {
    final value = text.trim();
    final validationError = validateChatMessage(value);
    if (validationError != null) throw ArgumentError(validationError);
    final chat = _chats.doc(chatId);
    final message = {
      'senderId': user.uid,
      'senderName': profile.name.isEmpty ? 'Usuario' : profile.name,
      'text': value,
      'createdAt': FieldValue.serverTimestamp(),
    };
    final batch = _firestore.batch();
    batch.set(chat.collection('messages').doc(), message);
    batch.update(chat, {
      'lastMessage': value,
      'lastSenderId': user.uid,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}
