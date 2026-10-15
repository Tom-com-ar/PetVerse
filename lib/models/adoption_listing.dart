import 'package:cloud_firestore/cloud_firestore.dart';

class AdoptionListing {
  const AdoptionListing({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.petName,
    required this.type,
    required this.breed,
    required this.ageYears,
    required this.photoUrl,
    required this.description,
    required this.location,
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final String ownerName;
  final String petName;
  final String type;
  final String breed;
  final int ageYears;
  final String photoUrl;
  final String description;
  final String location;
  final DateTime? createdAt;

  factory AdoptionListing.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};
    return AdoptionListing(
      id: document.id,
      ownerId: (data['ownerId'] as String?) ?? '',
      ownerName: (data['ownerName'] as String?) ?? 'Usuario',
      petName: (data['petName'] as String?) ?? '',
      type: (data['type'] as String?) ?? '',
      breed: (data['breed'] as String?) ?? '',
      ageYears: (data['ageYears'] as num?)?.toInt() ?? 0,
      photoUrl: (data['photoUrl'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      location: (data['location'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class AdoptionInquiry {
  const AdoptionInquiry({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderEmail,
    required this.phone,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String senderEmail;
  final String phone;
  final String message;
  final DateTime? createdAt;

  factory AdoptionInquiry.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};
    return AdoptionInquiry(
      id: document.id,
      senderId: (data['senderId'] as String?) ?? '',
      senderName: (data['senderName'] as String?) ?? 'Usuario',
      senderEmail: (data['senderEmail'] as String?) ?? '',
      phone: (data['phone'] as String?) ?? '',
      message: (data['message'] as String?) ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
