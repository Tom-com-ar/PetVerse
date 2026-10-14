import 'package:flutter/material.dart';

import '../models/pet.dart';
import '../models/post.dart';
import '../utils/post_validators.dart';

class PostFormScreen extends StatefulWidget {
  const PostFormScreen({super.key, required this.pets, required this.onSave})
    : assert(pets.length > 0);

  final List<Pet> pets;
  final Future<void> Function(PostDraft draft) onSave;

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mediaUrl = TextEditingController();
  final _caption = TextEditingController();
  late String _petId;
  String _mediaType = 'image';
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _petId = widget.pets.first.id;
  }

  @override
  void dispose() {
    _mediaUrl.dispose();
    _caption.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final pet = widget.pets.firstWhere((item) => item.id == _petId);
      await widget.onSave(
        PostDraft(
          petId: pet.id,
          petName: pet.name,
          mediaType: _mediaType,
          mediaUrl: _mediaUrl.text.trim(),
          caption: _caption.text.trim(),
        ),
      );
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
    appBar: AppBar(title: const Text('Nueva publicación')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Compartí un momento',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _petId,
                      decoration: const InputDecoration(labelText: 'Mascota'),
                      items: widget.pets
                          .map(
                            (pet) => DropdownMenuItem(
                              value: pet.id,
                              child: Text(pet.name),
                            ),
                          )
                          .toList(),
                      onChanged: _saving
                          ? null
                          : (value) => setState(() => _petId = value!),
                    ),
                    const SizedBox(height: 20),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'image',
                          label: Text('Imagen'),
                          icon: Icon(Icons.image_outlined),
                        ),
                        ButtonSegment(
                          value: 'video',
                          label: Text('Video'),
                          icon: Icon(Icons.videocam_outlined),
                        ),
                      ],
                      selected: {_mediaType},
                      onSelectionChanged: _saving
                          ? null
                          : (selection) =>
                                setState(() => _mediaType = selection.first),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _mediaUrl,
                      decoration: InputDecoration(
                        labelText: _mediaType == 'video'
                            ? 'Enlace del video'
                            : 'Enlace de la imagen',
                        helperText: 'Pegá un enlace directo HTTPS. La subida desde el dispositivo llegará en PV8.',
                        helperMaxLines: 2,
                      ),
                      keyboardType: TextInputType.url,
                      validator: validatePostMediaUrl,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _caption,
                      decoration: const InputDecoration(
                        labelText: 'Texto de la publicación',
                      ),
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 500,
                      validator: validatePostCaption,
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
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: const Icon(Icons.send_outlined),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(_saving ? 'Publicando...' : 'Publicar'),
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
