import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/adoption_listing.dart';
import '../models/pet.dart';
import '../models/user_profile.dart';

class AdoptionService {
  AdoptionService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _listings =>
      _firestore.collection('adoption_listings');

  Stream<List<AdoptionListing>> watchListings() => _listings
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map(AdoptionListing.fromDocument).toList(),
      );

  Future<void> createListing({
    required User user,
    required UserProfile profile,
    required Pet pet,
    required String location,
  }) async {
    final place = location.trim();
    if (place.length < 2 || place.length > 100) {
      throw ArgumentError('La ubicación debe tener entre 2 y 100 caracteres.');
    }
    await _listings.add({
      'ownerId': user.uid,
      'ownerName': profile.name,
      'petId': pet.id,
      'petName': pet.name,
      'type': pet.type,
      'breed': pet.breed,
      'ageYears': pet.ageYears,
      'photoUrl': pet.mainPhotoUrl,
      'description': pet.bio,
      'location': place,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AdoptionInquiry>> watchInquiries(String listingId) => _listings
      .doc(listingId)
      .collection('inquiries')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.map(AdoptionInquiry.fromDocument).toList(),
      );

  Future<void> sendInquiry({
    required AdoptionListing listing,
    required User user,
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim();
    final cleanPhone = phone.trim();
    final cleanMessage = message.trim();
    if (cleanName.isEmpty || cleanEmail.isEmpty || cleanMessage.length < 10) {
      throw ArgumentError(
        'Completá tus datos y escribí un mensaje de 10 caracteres o más.',
      );
    }
    await _listings.doc(listing.id).collection('inquiries').add({
      'senderId': user.uid,
      'senderName': cleanName,
      'senderEmail': cleanEmail,
      'phone': cleanPhone,
      'message': cleanMessage,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteInquiry(String listingId, String inquiryId) =>
      _listings.doc(listingId).collection('inquiries').doc(inquiryId).delete();
}
