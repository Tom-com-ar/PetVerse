import 'validators.dart';

String? validatePetName(String? value) {
  if ((value ?? '').trim().isEmpty) return 'Ingresá el nombre de tu mascota.';
  if (value!.trim().length > 60) return 'Máximo 60 caracteres.';
  return null;
}

String? validatePetBreed(String? value) {
  if ((value ?? '').trim().isEmpty) return 'Ingresá la raza.';
  if (value!.trim().length > 60) return 'Máximo 60 caracteres.';
  return null;
}

String? validatePetAge(String? value) {
  final age = int.tryParse((value ?? '').trim());
  if (age == null || age < 0 || age > 50) {
    return 'Ingresá una edad entre 0 y 50 años.';
  }
  return null;
}

double? parsePetWeight(String? value) =>
    double.tryParse((value ?? '').trim().replaceAll(',', '.'));

String? validatePetWeight(String? value) {
  final weight = parsePetWeight(value);
  if (weight == null || weight <= 0 || weight > 200) {
    return 'Ingresá un peso mayor a 0 y hasta 200 kg.';
  }
  return null;
}

List<String> parsePetPhotoUrls(String? value) => (value ?? '')
    .split('\n')
    .map((url) => url.trim())
    .where((url) => url.isNotEmpty)
    .toList();

String? validatePetPhotoUrls(String? value) {
  final urls = parsePetPhotoUrls(value);
  if (urls.isEmpty) return 'Agregá al menos una foto.';
  if (urls.length > 6) return 'Podés agregar hasta 6 fotos.';
  if (urls.any((url) => validatePhotoUrl(url) != null)) {
    return 'Cada foto necesita un enlace HTTPS válido.';
  }
  return null;
}

String? validatePetBio(String? value) {
  if ((value ?? '').trim().isEmpty) return 'Contá algo sobre tu mascota.';
  if (value!.trim().length > 300) return 'Máximo 300 caracteres.';
  return null;
}
