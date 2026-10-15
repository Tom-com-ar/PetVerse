import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.participantPhotos,
    required this.lastMessage,
    required this.updatedAt,
  });

  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final Map<String, String> participantPhotos;
  final String lastMessage;
  final DateTime? updatedAt;

  String otherUserId(String currentUserId) =>
      participants.firstWhere((id) => id != currentUserId);

  factory ChatConversation.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};
    return ChatConversation(
      id: document.id,
      participants: ((data['participants'] as List<dynamic>?) ?? [])
          .whereType<String>()
          .toList(),
      participantNames: _stringMap(data['participantNames']),
      participantPhotos: _stringMap(data['participantPhotos']),
      lastMessage: (data['lastMessage'] as String?) ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

Map<String, String> _stringMap(Object? value) => value is Map
    ? value.map((key, value) => MapEntry(key.toString(), value.toString()))
    : {};
