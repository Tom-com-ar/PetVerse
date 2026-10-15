import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chat_conversation.dart';
import '../models/user_profile.dart';
import '../services/chat_service.dart';
import '../services/profile_service.dart';
import '../utils/app_breakpoints.dart';
import '../widgets/profile_avatar.dart';
import 'chat_conversation_screen.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.user});

  final User user;

  Future<void> _newChat(BuildContext context) async {
    final viewport = MediaQuery.sizeOf(context);
    final profiles = context.read<ProfileService>();
    final ownProfile = await profiles.watchProfile(user).first;
    if (!context.mounted) return;
    final other = await showDialog<UserProfile>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: const Text('Nuevo mensaje'),
        content: SizedBox(
          width: viewport.width < 480 ? viewport.width - 64 : 420,
          height: (viewport.height - 220).clamp(120.0, 380.0),
          child: StreamBuilder<List<UserProfile>>(
            stream: profiles.watchPublicProfiles(user.uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('No se pudieron cargar usuarios.'),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Todavía no hay otros usuarios registrados.'),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final profile = snapshot.data![index];
                  return ListTile(
                    leading: ProfileAvatar(
                      photoUrl: profile.photoUrl,
                      radius: 21,
                    ),
                    title: Text(
                      profile.name.isEmpty ? 'Usuario' : profile.name,
                    ),
                    subtitle: profile.bio.isEmpty ? null : Text(profile.bio),
                    onTap: () => Navigator.pop(dialogContext, profile),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
    if (other == null || !context.mounted) return;
    try {
      final chatId = await context.read<ChatService>().startConversation(
        user: user,
        ownProfile: ownProfile,
        otherProfile: other,
      );
      if (!context.mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => ChatConversationScreen(
            user: user,
            chatId: chatId,
            otherUserId: other.uid,
            otherName: other.name,
            otherPhotoUrl: other.photoUrl,
          ),
        ),
      );
    } on FirebaseException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(_chatErrorMessage(error))));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo iniciar el chat.')),
        );
      }
    }
  }

  void _openConversation(BuildContext context, ChatConversation chat) {
    final otherId = chat.otherUserId(user.uid);
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ChatConversationScreen(
          user: user,
          chatId: chat.id,
          otherUserId: otherId,
          otherName: chat.participantNames[otherId] ?? 'Usuario',
          otherPhotoUrl: chat.participantPhotos[otherId] ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chats = context.read<ChatService>();
    final horizontalPadding = AppBreakpoints.pagePadding(context);
    final compact = MediaQuery.sizeOf(context).width < 380;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mensajes',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  if (compact)
                    IconButton.filledTonal(
                      onPressed: () => _newChat(context),
                      tooltip: 'Nuevo chat',
                      icon: const Icon(Icons.edit_square),
                    )
                  else
                    FilledButton.icon(
                      onPressed: () => _newChat(context),
                      icon: const Icon(Icons.edit_square),
                      label: const Text('Nuevo chat'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ChatConversation>>(
                stream: chats.watchConversations(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'No se pudieron cargar los mensajes. Revisá las reglas de Firestore.',
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final conversations = snapshot.data!;
                  if (conversations.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Todavía no hay chats. Tocá “Nuevo chat” para escribirle a otra persona.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      20,
                    ),
                    itemCount: conversations.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final chat = conversations[index];
                      final otherId = chat.otherUserId(user.uid);
                      return Card(
                        color: Colors.white,
                        elevation: 0,
                        child: ListTile(
                          leading: ProfileAvatar(
                            photoUrl: chat.participantPhotos[otherId] ?? '',
                            radius: 23,
                          ),
                          title: Text(
                            chat.participantNames[otherId] ?? 'Usuario',
                          ),
                          subtitle: Text(
                            chat.lastMessage.isEmpty
                                ? 'Iniciá la conversación'
                                : chat.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openConversation(context, chat),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _chatErrorMessage(FirebaseException error) =>
    error.code == 'permission-denied'
    ? 'Firebase rechazó el acceso. Publicá el firestore.rules actualizado.'
    : 'No se pudo iniciar el chat (${error.code}).';
