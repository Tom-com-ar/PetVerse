import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.photoUrl, this.radius = 44});

  final String photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.primaryContainer,
      child: photoUrl.isEmpty
          ? Icon(Icons.pets_rounded, size: radius, color: colors.primary)
          : ClipOval(
              child: Image.network(
                photoUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  Icons.pets_rounded,
                  size: radius,
                  color: colors.primary,
                ),
              ),
            ),
    );
  }
}
