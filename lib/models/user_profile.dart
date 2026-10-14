class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.bio,
    required this.photoUrl,
  });

  final String uid;
  final String email;
  final String name;
  final String bio;
  final String photoUrl;

  factory UserProfile.fromMap(String uid, Map<String, dynamic> data) =>
      UserProfile(
        uid: uid,
        email: (data['email'] as String?) ?? '',
        name: (data['name'] as String?) ?? '',
        bio: (data['bio'] as String?) ?? '',
        photoUrl: (data['photoUrl'] as String?) ?? '',
      );
}

class PetSummary {
  const PetSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.photoUrl,
  });

  final String id;
  final String name;
  final String type;
  final String photoUrl;

  factory PetSummary.fromMap(String id, Map<String, dynamic> data) =>
      PetSummary(
        id: id,
        name: (data['name'] as String?) ?? 'Mascota',
        type: (data['type'] as String?) ?? '',
        photoUrl: (data['photoUrl'] as String?) ?? '',
      );
}
