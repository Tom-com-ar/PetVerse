String? validatePostMediaUrl(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Pegá el enlace de la imagen o el video.';
  if (text.length > 2000) return 'El enlace es demasiado largo.';
  final uri = Uri.tryParse(text);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
    return 'Usá un enlace HTTPS válido.';
  }
  return null;
}

String? validatePostCaption(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return 'Escribí un texto para la publicación.';
  if (text.length > 500) return 'Usá hasta 500 caracteres.';
  return null;
}
