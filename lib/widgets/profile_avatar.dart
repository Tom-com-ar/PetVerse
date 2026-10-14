import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.photoUrl, this.radius = 44});

  final String photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: radius,
    backgroundColor: const Color(0xFFEAE3FF),
    child: photoUrl.isEmpty
        ? Icon(Icons.pets_rounded, size: radius, color: const Color(0xFF7455D3))
        : ClipOval(
            child: Image.network(
              photoUrl,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Icon(
                Icons.pets_rounded,
                size: radius,
                color: const Color(0xFF7455D3),
              ),
            ),
          ),
  );
}
