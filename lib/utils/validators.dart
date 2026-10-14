String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Ingresá tu correo electrónico.';
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
    return 'Ingresá un correo válido.';
  }
  return null;
}

String? validatePassword(String? value) {
  if ((value ?? '').isEmpty) return 'Ingresá tu contraseña.';
  if (value!.length < 6) return 'Usá al menos 6 caracteres.';
  return null;
}

String? validateName(String? value) {
  if ((value ?? '').trim().isEmpty) return 'Ingresá tu nombre.';
  if (value!.trim().length > 60) return 'Máximo 60 caracteres.';
  return null;
}

String? validatePhotoUrl(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return null;
  final uri = Uri.tryParse(text);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
    return 'Usá un enlace HTTPS a una imagen.';
  }
  return null;
}
