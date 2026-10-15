import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../utils/validators.dart';
import 'profile_avatar.dart';

class ProfileEditForm extends StatefulWidget {
  const ProfileEditForm({
    super.key,
    required this.profile,
    required this.onSave,
  });

  final UserProfile profile;
  final Future<void> Function(String name, String bio, String photoUrl) onSave;

  @override
  State<ProfileEditForm> createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _bio;
  late final TextEditingController _photoUrl;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _bio = TextEditingController(text: widget.profile.bio);
    _photoUrl = TextEditingController(text: widget.profile.photoUrl);
    _photoUrl.addListener(_refreshPreview);
  }

  void _refreshPreview() => setState(() {});

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _photoUrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onSave(
        _name.text.trim(),
        _bio.text.trim(),
        _photoUrl.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'No se pudieron guardar los cambios. Intentá de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    title: const Text('Editar perfil'),
    content: SizedBox(
      width: MediaQuery.sizeOf(context).width < 480
          ? MediaQuery.sizeOf(context).width - 64
          : 420,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfileAvatar(
                photoUrl: validatePhotoUrl(_photoUrl.text) == null
                    ? _photoUrl.text.trim()
                    : '',
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: validateName,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _bio,
                decoration: const InputDecoration(labelText: 'Biografía'),
                maxLines: 3,
                maxLength: 160,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _photoUrl,
                decoration: const InputDecoration(
                  labelText: 'Enlace de la foto',
                  helperText: 'Pegá una URL HTTPS de una imagen',
                ),
                keyboardType: TextInputType.url,
                validator: validatePhotoUrl,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _busy ? null : () => Navigator.of(context).pop(false),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: _busy ? null : _save,
        child: Text(_busy ? 'Guardando...' : 'Guardar'),
      ),
    ],
  );
}
