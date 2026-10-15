import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../services/pet_service.dart';
import '../services/post_service.dart';
import '../services/profile_service.dart';
import '../utils/app_breakpoints.dart';
import '../widgets/post_card.dart';
import 'post_form_screen.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key, required this.user});

  final User user;

  Future<void> _createPost(BuildContext context) async {
    final petService = context.read<PetService>();
    final profileService = context.read<ProfileService>();
    final postService = context.read<PostService>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final pets = await petService.watchPets(user.uid).first;
      if (!context.mounted) return;
      if (pets.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Primero agregá una mascota desde Mi perfil.'),
          ),
        );
        return;
      }
      final profile = await profileService.watchProfile(user).first;
      if (!context.mounted) return;
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => PostFormScreen(
            pets: pets,
            onSave: (draft) => postService.createPost(user, profile, draft),
          ),
        ),
      );
      if (saved == true && messenger.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Publicación creada.')),
        );
      }
    } catch (_) {
      if (messenger.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el formulario.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postService = context.read<PostService>();
    final profileService = context.read<ProfileService>();
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
                      'Publicaciones',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  if (compact)
                    IconButton.filledTonal(
                      onPressed: () => _createPost(context),
                      tooltip: 'Publicar',
                      icon: const Icon(Icons.add),
                    )
                  else
                    FilledButton.icon(
                      onPressed: () => _createPost(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Publicar'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Post>>(
                stream: postService.watchPosts(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No se pudo cargar el feed. Revisá Firestore y sus reglas.',
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final posts = snapshot.data!;
                  if (posts.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Todavía no hay publicaciones. Compartí la primera foto o video de tu mascota.',
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
                    itemCount: posts.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) => PostCard(
                      key: ValueKey(posts[index].id),
                      post: posts[index],
                      currentUserId: user.uid,
                      onToggleLike: () =>
                          postService.toggleLike(posts[index].id, user.uid),
                      comments: postService.watchComments(posts[index].id),
                      onAddComment: (text) async {
                        final profile = await profileService
                            .watchProfile(user)
                            .first;
                        await postService.addComment(
                          posts[index].id,
                          user,
                          profile,
                          text,
                        );
                      },
                      onDeleteComment: (commentId) =>
                          postService.deleteComment(posts[index].id, commentId),
                    ),
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
