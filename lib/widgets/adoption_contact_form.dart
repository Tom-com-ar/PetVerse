import 'package:flutter/material.dart';

class AdoptionContactForm extends StatefulWidget {
  const AdoptionContactForm({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.onSend,
  });

  final String initialName;
  final String initialEmail;
  final Future<void> Function({
    required String name,
    required String email,
    required String phone,
    required String message,
  })
  onSend;

  @override
  State<AdoptionContactForm> createState() => _AdoptionContactFormState();
}

class _AdoptionContactFormState extends State<AdoptionContactForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);
  late final _email = TextEditingController(text: widget.initialEmail);
  final _phone = TextEditingController();
  final _message = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await widget.onSend(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        message: _message.text.trim(),
      );
      if (mounted) {
        _message.clear();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Consulta enviada.')));
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'No se pudo enviar. Revisá los datos e intentá otra vez.',
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    elevation: 0,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Quiero conocer a esta mascota',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Tu nombre'),
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
                  value?.trim().isEmpty ?? true ? 'Escribí tu nombre.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Tu correo'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final email = value?.trim() ?? '';
                return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
                    ? null
                    : 'Escribí un correo válido.';
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(
                labelText: 'Teléfono (opcional)',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _message,
              decoration: const InputDecoration(
                labelText: 'Mensaje',
                hintText: 'Contale al responsable por qué te interesa adoptar.',
              ),
              minLines: 3,
              maxLines: 5,
              maxLength: 1000,
              validator: (value) => (value?.trim().length ?? 0) < 10
                  ? 'Escribí al menos 10 caracteres.'
                  : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _sending ? null : _submit,
              icon: const Icon(Icons.send_outlined),
              label: Text(_sending ? 'Enviando...' : 'Enviar consulta'),
            ),
          ],
        ),
      ),
    ),
  );
}
