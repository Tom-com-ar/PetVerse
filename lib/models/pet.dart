import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.ageYears,
    required this.weightKg,
    required this.photoUrls,
    required this.bio,
  });

  final String id;
  final String name;
  final String type;
  final String breed;
  final int ageYears;
  final double weightKg;
  final List<String> photoUrls;
  final String bio;

  String get mainPhotoUrl => photoUrls.isEmpty ? '' : photoUrls.first;

  Map<String, dynamic> toMap() => {
    'name': name.trim(),
    'type': type,
    'breed': breed.trim(),
    'ageYears': ageYears,
    'weightKg': weightKg,
    'photoUrls': photoUrls,
    'bio': bio.trim(),
  };

  factory Pet.fromDocument(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data() ?? {};
    return Pet(
      id: document.id,
      name: (data['name'] as String?) ?? '',
      type: (data['type'] as String?) ?? '',
      breed: (data['breed'] as String?) ?? '',
      ageYears: (data['ageYears'] as num?)?.toInt() ?? 0,
      weightKg: (data['weightKg'] as num?)?.toDouble() ?? 0,
      photoUrls: ((data['photoUrls'] as List<dynamic>?) ?? [])
          .whereType<String>()
          .toList(),
      bio: (data['bio'] as String?) ?? '',
    );
  }
}
