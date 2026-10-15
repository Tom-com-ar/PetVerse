import 'package:flutter/material.dart';

import '../models/adoption_listing.dart';

class AdoptionListingCard extends StatelessWidget {
  const AdoptionListingCard({
    super.key,
    required this.listing,
    required this.onTap,
  });

  final AdoptionListing listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final placeholder = Theme.of(context).colorScheme.surfaceContainerHighest;
    final ageLabel = listing.ageYears == 0
        ? 'Menos de un año'
        : '${listing.ageYears} ${listing.ageYears == 1 ? 'año' : 'años'}';
    return Card(
      color: Colors.white,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: listing.photoUrl.isEmpty
                  ? ColoredBox(
                      color: placeholder,
                      child: const Center(
                        child: Icon(Icons.pets_rounded, size: 56),
                      ),
                    )
                  : Image.network(
                      listing.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => ColoredBox(
                        color: placeholder,
                        child: const Center(
                          child: Icon(Icons.broken_image_outlined),
                        ),
                      ),
                    ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.petName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${listing.type == 'gato' ? 'Gato' : 'Perro'} · ${listing.breed}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$ageLabel · ${listing.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Icon(Icons.arrow_forward_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
