import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pet.dart';
import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../services/pet_service.dart';
import '../services/profile_service.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets_rounded),
            SizedBox(width: 8),
            Text('PetVerse'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.read<AuthProvider>().signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Salir'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: StreamBuilder<UserProfile>(
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
                padding: const EdgeInsets.all(20),
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
      ),
    );
  }
}
