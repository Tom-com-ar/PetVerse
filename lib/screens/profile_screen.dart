import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pet.dart';
import '../models/gamification_summary.dart';
import '../models/user_profile.dart';
import '../services/gamification_service.dart';
import '../services/pet_service.dart';
import '../services/profile_service.dart';
import '../utils/app_breakpoints.dart';
import '../widgets/pet_card.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_edit_form.dart';
import 'pet_form_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.user});

  final User user;

  Future<void> _edit(BuildContext context, UserProfile profile) async {
    final profiles = context.read<ProfileService>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => ProfileEditForm(
        profile: profile,
        onSave: (name, bio, photoUrl) => profiles.saveProfile(
          uid: user.uid,
          name: name,
          bio: bio,
          photoUrl: photoUrl,
        ),
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Perfil actualizado.')));
    }
  }

  Future<void> _openPetForm(BuildContext context, [Pet? pet]) async {
    final pets = context.read<PetService>();
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PetFormScreen(
          pet: pet,
          onSave: (value) => pet == null
              ? pets.createPet(user.uid, value)
              : pets.updatePet(user.uid, value),
        ),
      ),
    );
    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            pet == null ? 'Mascota agregada.' : 'Mascota actualizada.',
          ),
        ),
      );
    }
  }

  Future<void> _deletePet(BuildContext context, Pet pet) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<PetService>().deletePet(user.uid, pet.id);
      if (messenger.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('${pet.name} fue eliminada de tus mascotas.')),
        );
      }
    } catch (_) {
      if (messenger.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar la mascota.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profiles = context.read<ProfileService>();
    final pets = context.read<PetService>();
    return StreamBuilder<UserProfile>(
      stream: profiles.watchProfile(user),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'No se pudo cargar el perfil. Revisá Firestore y sus reglas.',
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final profile = snapshot.data!;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: EdgeInsets.all(AppBreakpoints.pagePadding(context)),
              children: [
                Card(
                  color: Colors.white,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        ProfileAvatar(photoUrl: profile.photoUrl),
                        const SizedBox(height: 14),
                        Text(
                          profile.name.isEmpty ? 'Tu perfil' : profile.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(profile.email),
                        const SizedBox(height: 12),
                        Text(
                          profile.bio.isEmpty
                              ? 'Contá algo sobre vos y tus mascotas.'
                              : profile.bio,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        OutlinedButton.icon(
                          onPressed: () => _edit(context, profile),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Editar perfil'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _GamificationPanel(userId: user.uid),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Text(
                      'Mis mascotas',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    FilledButton.icon(
                      onPressed: () => _openPetForm(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar mascota'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                StreamBuilder<List<Pet>>(
                  stream: pets.watchPets(user.uid),
                  builder: (context, petsSnapshot) {
                    if (petsSnapshot.hasError) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: Text(
                            'No se pudo cargar la lista de mascotas.',
                          ),
                        ),
                      );
                    }
                    if (!petsSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final pets = petsSnapshot.data!;
                    if (pets.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(22),
                          child: Text(
                            'Todavía no hay mascotas. Agregá la primera.',
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: pets
                          .map(
                            (pet) => PetCard(
                              pet: pet,
                              onEdit: () => _openPetForm(context, pet),
                              onDelete: () => _deletePet(context, pet),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GamificationPanel extends StatelessWidget {
  const _GamificationPanel({required this.userId});

  final String userId;

  static final _badges = <_BadgeDefinition>[
    _BadgeDefinition(
      title: 'Primera huella',
      description: 'Publicá por primera vez',
      icon: Icons.pets,
      goal: 1,
      progress: (summary) => summary.posts,
    ),
    _BadgeDefinition(
      title: 'Creador de patitas',
      description: 'Publicá 5 veces',
      icon: Icons.photo_camera_outlined,
      goal: 5,
      progress: (summary) => summary.posts,
    ),
    _BadgeDefinition(
      title: 'Buen vecino',
      description: 'Dá 10 likes',
      icon: Icons.favorite_outline,
      goal: 10,
      progress: (summary) => summary.likes,
    ),
    _BadgeDefinition(
      title: 'Voz de la manada',
      description: 'Escribí 10 comentarios',
      icon: Icons.chat_bubble_outline,
      goal: 10,
      progress: (summary) => summary.comments,
    ),
    _BadgeDefinition(
      title: 'Estrella PetVerse',
      description: 'Alcanzá 100 puntos',
      icon: Icons.star_outline,
      goal: 100,
      progress: (summary) => summary.points,
    ),
  ];

  @override
  Widget build(BuildContext context) => StreamBuilder<GamificationSummary>(
    stream: context.read<GamificationService>().watchSummary(userId),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Text('No se pudieron cargar tus logros.'),
          ),
        );
      }
      final summary = snapshot.data ?? const GamificationSummary.empty();
      return Card(
        color: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tus logros',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Icon(
                    Icons.stars_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${summary.points} puntos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _badges.map((badge) {
                  final progress = badge.progress(summary).clamp(0, badge.goal);
                  final unlocked = progress >= badge.goal;
                  return Container(
                    width: 205,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: unlocked
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: unlocked
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          badge.icon,
                          color: unlocked
                              ? Theme.of(context).colorScheme.primary
                              : Colors.black38,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                badge.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                unlocked
                                    ? 'Desbloqueada'
                                    : '${badge.description} ($progress/${badge.goal})',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _BadgeDefinition {
  const _BadgeDefinition({
    required this.title,
    required this.description,
    required this.icon,
    required this.goal,
    required this.progress,
  });

  final String title;
  final String description;
  final IconData icon;
  final int goal;
  final int Function(GamificationSummary) progress;
}
