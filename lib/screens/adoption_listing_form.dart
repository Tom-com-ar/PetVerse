import 'package:flutter/material.dart';

import '../models/pet.dart';
import '../utils/app_breakpoints.dart';

class AdoptionListingForm extends StatefulWidget {
  const AdoptionListingForm({
    super.key,
    required this.pets,
    required this.onSave,
  });

  final List<Pet> pets;
  final Future<void> Function(Pet pet, String location) onSave;

  @override
  State<AdoptionListingForm> createState() => _AdoptionListingFormState();
}

class _AdoptionListingFormState extends State<AdoptionListingForm> {
  final _formKey = GlobalKey<FormState>();
  final _location = TextEditingController();
  late Pet? _selectedPet = widget.pets.isEmpty ? null : widget.pets.first;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _location.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _selectedPet == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(_selectedPet!, _location.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No se pudo publicar. Intentá de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Publicar en adopción')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppBreakpoints.pagePadding(context)),
          child: Card(
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(
                AppBreakpoints.isMobile(context) ? 16 : 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Encontrémosle un hogar',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Elegí una mascota de tu perfil y agregá la ciudad o zona. Sus fotos y datos aparecerán en la publicación.',
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<Pet>(
                      initialValue: _selectedPet,
                      decoration: const InputDecoration(labelText: 'Mascota'),
                      items: widget.pets
                          .map(
                            (pet) => DropdownMenuItem(
                              value: pet,
                              child: Text(
                                '${pet.name} · ${pet.breed}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _saving
                          ? null
                          : (pet) => setState(() => _selectedPet = pet),
                      validator: (pet) =>
                          pet == null ? 'Elegí una mascota.' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _location,
                      decoration: const InputDecoration(
                        labelText: 'Ciudad o zona',
                        hintText: 'Ej.: Palermo, Buenos Aires',
                      ),
                      textCapitalization: TextCapitalization.words,
                      maxLength: 100,
                      validator: (value) {
                        final place = value?.trim() ?? '';
                        if (place.length < 2) return 'Indicá una ubicación.';
                        return null;
                      },
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: const Icon(Icons.volunteer_activism_outlined),
                      label: Text(
                        _saving ? 'Publicando...' : 'Publicar mascota',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
