import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

import '../models/adoption_listing.dart';
import '../services/adoption_service.dart';
import '../utils/app_breakpoints.dart';
import '../widgets/adoption_contact_form.dart';

class AdoptionDetailScreen extends StatelessWidget {
  const AdoptionDetailScreen({
    super.key,
    required this.listing,
    required this.user,
    required this.service,
  });

  final AdoptionListing listing;
  final User user;
  final AdoptionService service;

  @override
  Widget build(BuildContext context) {
    final isOwner = listing.ownerId == user.uid;
    final placeholder = Theme.of(context).colorScheme.surfaceContainerHighest;
    final initialName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : (user.email?.split('@').first ?? '');
    return Scaffold(
      appBar: AppBar(title: Text(listing.petName)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: EdgeInsets.all(AppBreakpoints.pagePadding(context)),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: listing.photoUrl.isEmpty
                      ? ColoredBox(
                          color: placeholder,
                          child: const Center(
                            child: Icon(Icons.pets_rounded, size: 72),
                          ),
                        )
                      : Image.network(
                          listing.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => ColoredBox(
                            color: placeholder,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 56,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.white,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.petName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${listing.type == 'gato' ? 'Gato' : 'Perro'} · ${listing.breed} · ${_formatAge(listing.ageYears)}',
                      ),
                      const SizedBox(height: 8),
                      _LabelValue(
                        icon: Icons.location_on_outlined,
                        text: listing.location,
                      ),
                      const SizedBox(height: 14),
                      Text(listing.description),
                      const SizedBox(height: 12),
                      Text('Publicado por ${listing.ownerName}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (isOwner)
                _OwnerInquiries(listing: listing, service: service)
              else
                AdoptionContactForm(
                  initialName: initialName,
                  initialEmail: user.email ?? '',
                  onSend:
                      ({
                        required name,
                        required email,
                        required phone,
                        required message,
                      }) => service.sendInquiry(
                        listing: listing,
                        user: user,
                        name: name,
                        email: email,
                        phone: phone,
                        message: message,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OwnerInquiries extends StatelessWidget {
  const _OwnerInquiries({required this.listing, required this.service});

  final AdoptionListing listing;
  final AdoptionService service;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<AdoptionInquiry>>(
    stream: service.watchInquiries(listing.id),
    builder: (context, snapshot) {
      final inquiries = snapshot.data ?? [];
      return Card(
        color: Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consultas recibidas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (snapshot.hasError)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('No se pudieron cargar las consultas.'),
                )
              else if (!snapshot.hasData)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(),
                )
              else if (inquiries.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text('Todavía no hay consultas.'),
                )
              else
                ...inquiries.map(
                  (inquiry) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(inquiry.senderName),
                    subtitle: Text(
                      '${inquiry.senderEmail}${inquiry.phone.isEmpty ? '' : ' · ${inquiry.phone}'}\n${inquiry.message}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      tooltip: 'Eliminar consulta',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Eliminar consulta'),
                            content: const Text(
                              '¿Querés eliminar esta consulta recibida?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await service.deleteInquiry(listing.id, inquiry.id);
                        }
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 19),
      const SizedBox(width: 6),
      Expanded(child: Text(text)),
    ],
  );
}

String _formatAge(int age) {
  if (age == 0) return 'menos de un año';
  return '$age ${age == 1 ? 'año' : 'años'}';
}
