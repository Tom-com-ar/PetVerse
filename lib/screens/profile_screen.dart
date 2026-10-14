import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_edit_form.dart';

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

  @override
  Widget build(BuildContext context) {
    final profiles = context.read<ProfileService>();
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
                  Text(
                    'Mis mascotas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<List<PetSummary>>(
                    stream: profiles.watchPets(user.uid),
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
                              'Todavía no hay mascotas. Las agregaremos en PV3.',
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: pets
                            .map(
                              (pet) => Card(
                                child: ListTile(
                                  leading: ProfileAvatar(
                                    photoUrl: pet.photoUrl,
                                    radius: 22,
                                  ),
                                  title: Text(pet.name),
                                  subtitle: Text(pet.type),
                                ),
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
