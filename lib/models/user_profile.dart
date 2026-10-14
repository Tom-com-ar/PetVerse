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
