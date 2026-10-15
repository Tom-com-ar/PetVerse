String? validateChatMessage(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Escribí un mensaje.';
  if (text.length > 2000) return 'El mensaje no puede superar 2000 caracteres.';
  return null;
}
