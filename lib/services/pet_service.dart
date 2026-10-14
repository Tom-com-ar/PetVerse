import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pet.dart';

class PetService {
  PetService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _pets(String userId) =>
      _firestore.collection('users').doc(userId).collection('pets');

  Stream<List<Pet>> watchPets(String userId) => _pets(userId).snapshots().map((
    snapshot,
  ) {
    final pets = snapshot.docs.map(Pet.fromDocument).toList();
    pets.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return pets;
  });

  Future<void> createPet(String userId, Pet pet) async {
    await _pets(userId).add({
      ...pet.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePet(String userId, Pet pet) async {
    if (pet.id.isEmpty) throw ArgumentError('La mascota necesita un ID.');
    await _pets(userId)
        .doc(pet.id)
        .update({...pet.toMap(), 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> deletePet(String userId, String petId) async {
    if (petId.isEmpty) throw ArgumentError('La mascota necesita un ID.');
    await _pets(userId).doc(petId).delete();
  }
}
