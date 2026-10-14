import 'package:flutter/material.dart';

import '../models/pet.dart';
import 'profile_avatar.dart';

class PetCard extends StatelessWidget {
  const PetCard({super.key, required this.pet, required this.onEdit});

  final Pet pet;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    elevation: 0,
    child: ExpansionTile(
      leading: ProfileAvatar(photoUrl: pet.mainPhotoUrl, radius: 23),
      title: Text(pet.name),
      subtitle: Text('${pet.type == 'gato' ? 'Gato' : 'Perro'} · ${pet.breed}'),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: pet.photoUrls.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                pet.photoUrls[index],
                width: 190,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 190,
                  height: 150,
                  color: const Color(0xFFEAE3FF),
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            pet.ageYears == 0
                ? 'Menos de un año · ${pet.weightKg.toStringAsFixed(1)} kg'
                : '${pet.ageYears} ${pet.ageYears == 1 ? 'año' : 'años'} · ${pet.weightKg.toStringAsFixed(1)} kg',
          ),
        ),
        const SizedBox(height: 8),
        Align(alignment: Alignment.centerLeft, child: Text(pet.bio)),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar mascota'),
          ),
        ),
      ],
    ),
  );
}
