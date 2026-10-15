import 'package:flutter/material.dart';

import '../models/pet.dart';
import '../utils/pet_validators.dart';
import '../utils/app_breakpoints.dart';

class PetFormScreen extends StatefulWidget {
  const PetFormScreen({super.key, this.pet, required this.onSave});

  final Pet? pet;
  final Future<void> Function(Pet pet) onSave;

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _breed;
  late final TextEditingController _age;
  late final TextEditingController _weight;
  late final TextEditingController _photos;
  late final TextEditingController _bio;
  late String _type;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final pet = widget.pet;
    _name = TextEditingController(text: pet?.name ?? '');
    _breed = TextEditingController(text: pet?.breed ?? '');
    _age = TextEditingController(text: pet == null ? '' : '${pet.ageYears}');
    _weight = TextEditingController(text: pet == null ? '' : '${pet.weightKg}');
    _photos = TextEditingController(text: pet?.photoUrls.join('\n') ?? '');
    _bio = TextEditingController(text: pet?.bio ?? '');
    _type = pet?.type == 'gato' ? 'gato' : 'perro';
  }

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    _age.dispose();
    _weight.dispose();
    _photos.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final pet = Pet(
        id: widget.pet?.id ?? '',
        name: _name.text.trim(),
        type: _type,
        breed: _breed.text.trim(),
        ageYears: int.parse(_age.text.trim()),
        weightKg: parsePetWeight(_weight.text)!,
        photoUrls: parsePetPhotoUrls(_photos.text),
        bio: _bio.text.trim(),
      );
      await widget.onSave(pet);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No se pudo guardar la mascota. Intentá de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.pet != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Editar mascota' : 'Agregar mascota'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
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
                        editing
                            ? 'Datos de ${widget.pet!.name}'
                            : 'Conocé a mi mascota',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        textCapitalization: TextCapitalization.words,
                        validator: validatePetName,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: const InputDecoration(labelText: 'Tipo'),
                        items: const [
                          DropdownMenuItem(
                            value: 'perro',
                            child: Text('Perro'),
                          ),
                          DropdownMenuItem(value: 'gato', child: Text('Gato')),
                        ],
                        onChanged: _saving
                            ? null
                            : (value) => setState(() => _type = value!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _breed,
                        decoration: const InputDecoration(labelText: 'Raza'),
                        textCapitalization: TextCapitalization.words,
                        validator: validatePetBreed,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: 185,
                            child: TextFormField(
                              controller: _age,
                              decoration: const InputDecoration(
                                labelText: 'Edad (años)',
                                helperText: '0 si tiene menos de un año',
                              ),
                              keyboardType: TextInputType.number,
                              validator: validatePetAge,
                            ),
                          ),
                          SizedBox(
                            width: 185,
                            child: TextFormField(
                              controller: _weight,
                              decoration: const InputDecoration(
                                labelText: 'Peso (kg)',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: validatePetWeight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _photos,
                        decoration: const InputDecoration(
                          labelText: 'Fotos',
                          helperText: 'Pegá una URL HTTPS por línea (hasta 6). La subida desde el dispositivo llegará en PV8.',
                          helperMaxLines: 2,
                        ),
                        keyboardType: TextInputType.url,
                        maxLines: 3,
                        validator: validatePetPhotoUrls,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bio,
                        decoration: const InputDecoration(
                          labelText: 'Biografía',
                        ),
                        maxLines: 4,
                        maxLength: 300,
                        validator: validatePetBio,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _saving ? null : _save,
                        icon: const Icon(Icons.save_outlined),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            _saving ? 'Guardando...' : 'Guardar mascota',
                          ),
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
}
