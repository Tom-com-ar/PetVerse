import 'package:flutter/material.dart';

import '../models/pet.dart';
import 'profile_avatar.dart';

class PetCard extends StatefulWidget {
  const PetCard({
    super.key,
    required this.pet,
    required this.onEdit,
    required this.onDelete,
  });

  final Pet pet;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  bool _deleting = false;

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('¿Eliminar a ${widget.pet.name}?'),
        content: const Text(
          'Se borrará la ficha de esta mascota. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    setState(() => _deleting = true);
    try {
      await widget.onDelete();
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    final placeholder = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Card(
      color: Colors.white,
      elevation: 0,
      child: ExpansionTile(
        leading: ProfileAvatar(photoUrl: pet.mainPhotoUrl, radius: 23),
        title: Text(pet.name),
        subtitle: Text(
          '${pet.type == 'gato' ? 'Gato' : 'Perro'} · ${pet.breed}',
        ),
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
                    color: placeholder,
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
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: _deleting ? null : widget.onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar mascota'),
                ),
                TextButton.icon(
                  onPressed: _deleting ? null : _confirmDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(_deleting ? 'Eliminando...' : 'Eliminar mascota'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
