import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/adoption_listing.dart';
import '../services/adoption_service.dart';
import '../services/pet_service.dart';
import '../services/profile_service.dart';
import '../utils/adoption_filters.dart';
import '../utils/app_breakpoints.dart';
import '../widgets/adoption_listing_card.dart';
import 'adoption_detail_screen.dart';
import 'adoption_listing_form.dart';

class AdoptionScreen extends StatefulWidget {
  const AdoptionScreen({super.key, required this.user});

  final User user;

  @override
  State<AdoptionScreen> createState() => _AdoptionScreenState();
}

class _AdoptionScreenState extends State<AdoptionScreen> {
  String _type = 'todos';
  AdoptionAgeFilter _age = AdoptionAgeFilter.any;
  final _location = TextEditingController();

  @override
  void dispose() {
    _location.dispose();
    super.dispose();
  }

  Future<void> _publishListing() async {
    final petService = context.read<PetService>();
    final profileService = context.read<ProfileService>();
    final adoptionService = context.read<AdoptionService>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final pets = await petService.watchPets(widget.user.uid).first;
      if (!mounted) return;
      if (pets.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Primero agregá una mascota desde Mi perfil.'),
          ),
        );
        return;
      }
      final profile = await profileService.watchProfile(widget.user).first;
      if (!mounted) return;
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => AdoptionListingForm(
            pets: pets,
            onSave: (pet, location) => adoptionService.createListing(
              user: widget.user,
              profile: profile,
              pet: pet,
              location: location,
            ),
          ),
        ),
      );
      if (saved == true && messenger.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Mascota publicada en adopción.')),
        );
      }
    } catch (_) {
      if (messenger.mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el formulario.')),
        );
      }
    }
  }

  void _openListing(AdoptionListing listing) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => AdoptionDetailScreen(
          listing: listing,
          user: widget.user,
          service: context.read<AdoptionService>(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adoption = context.read<AdoptionService>();
    final horizontalPadding = AppBreakpoints.pagePadding(context);
    final compact = MediaQuery.sizeOf(context).width < 380;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                12,
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(
                    'Mascotas en adopción',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (compact)
                    IconButton.filledTonal(
                      onPressed: _publishListing,
                      tooltip: 'Ofrecer mascota',
                      icon: const Icon(Icons.add),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _publishListing,
                      icon: const Icon(Icons.add),
                      label: const Text('Ofrecer mascota'),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                16,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final filterWidth = constraints.maxWidth < 600
                      ? constraints.maxWidth
                      : constraints.maxWidth < 840
                      ? (constraints.maxWidth - 12) / 2
                      : null;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: filterWidth ?? 175,
                        child: DropdownButtonFormField<String>(
                          initialValue: _type,
                          decoration: const InputDecoration(
                            labelText: 'Tipo',
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'todos',
                              child: Text('Todos'),
                            ),
                            DropdownMenuItem(
                              value: 'perro',
                              child: Text('Perros'),
                            ),
                            DropdownMenuItem(
                              value: 'gato',
                              child: Text('Gatos'),
                            ),
                          ],
                          onChanged: (value) => setState(() => _type = value!),
                        ),
                      ),
                      SizedBox(
                        width: filterWidth ?? 190,
                        child: DropdownButtonFormField<AdoptionAgeFilter>(
                          initialValue: _age,
                          decoration: const InputDecoration(
                            labelText: 'Edad',
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: AdoptionAgeFilter.any,
                              child: Text('Cualquier edad'),
                            ),
                            DropdownMenuItem(
                              value: AdoptionAgeFilter.young,
                              child: Text('0 a 1 año'),
                            ),
                            DropdownMenuItem(
                              value: AdoptionAgeFilter.adult,
                              child: Text('2 a 5 años'),
                            ),
                            DropdownMenuItem(
                              value: AdoptionAgeFilter.senior,
                              child: Text('6 años o más'),
                            ),
                          ],
                          onChanged: (value) => setState(() => _age = value!),
                        ),
                      ),
                      SizedBox(
                        width: filterWidth ?? 240,
                        child: TextField(
                          controller: _location,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Ciudad o zona',
                            prefixIcon: Icon(Icons.location_on_outlined),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<List<AdoptionListing>>(
                stream: adoption.watchListings(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('No se pudieron cargar las mascotas.'),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final filtered = filterAdoptionListings(
                    listings: snapshot.data!,
                    type: _type,
                    age: _age,
                    location: _location.text,
                  );
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No hay mascotas para esos filtros. Probá con otros o publicá una mascota para adopción.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth < 560
                          ? 1
                          : constraints.maxWidth < 900
                          ? 2
                          : 3;
                      return GridView.builder(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          20,
                        ),
                        itemCount: filtered.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisExtent: 340,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemBuilder: (context, index) => AdoptionListingCard(
                          listing: filtered[index],
                          onTap: () => _openListing(filtered[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
