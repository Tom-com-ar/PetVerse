import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petverse/models/adoption_listing.dart';
import 'package:petverse/models/pet.dart';
import 'package:petverse/screens/adoption_listing_form.dart';
import 'package:petverse/utils/adoption_filters.dart';
import 'package:petverse/widgets/adoption_contact_form.dart';

void main() {
  const listings = [
    AdoptionListing(
      id: 'luna',
      ownerId: 'u1',
      ownerName: 'Ana',
      petName: 'Luna',
      type: 'perro',
      breed: 'Mestiza',
      ageYears: 0,
      photoUrl: '',
      description: '',
      location: 'Palermo, Buenos Aires',
      createdAt: null,
    ),
    AdoptionListing(
      id: 'michi',
      ownerId: 'u2',
      ownerName: 'Leo',
      petName: 'Michi',
      type: 'gato',
      breed: 'Atigrado',
      ageYears: 7,
      photoUrl: '',
      description: '',
      location: 'Córdoba',
      createdAt: null,
    ),
  ];

  test('filtra publicaciones por tipo, edad y ubicación', () {
    expect(
      filterAdoptionListings(
        listings: listings,
        type: 'perro',
        age: AdoptionAgeFilter.young,
        location: 'palermo',
      ).map((listing) => listing.id),
      ['luna'],
    );
    expect(
      filterAdoptionListings(
        listings: listings,
        type: 'gato',
        age: AdoptionAgeFilter.senior,
        location: '',
      ).map((listing) => listing.id),
      ['michi'],
    );
  });

  testWidgets('publica una mascota del perfil con ubicación', (tester) async {
    const pet = Pet(
      id: 'pet1',
      name: 'Luna',
      type: 'perro',
      breed: 'Mestiza',
      ageYears: 2,
      weightKg: 3.5,
      photoUrls: ['https://example.com/luna.jpg'],
      bio: 'Juguetona',
    );
    Pet? savedPet;
    String? savedLocation;
    await tester.pumpWidget(
      MaterialApp(
        home: AdoptionListingForm(
          pets: const [pet],
          onSave: (value, location) async {
            savedPet = value;
            savedLocation = location;
          },
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'Palermo, Buenos Aires');
    await tester.ensureVisible(find.text('Publicar mascota'));
    await tester.tap(find.text('Publicar mascota'));
    await tester.pumpAndSettle();
    expect(savedPet?.id, 'pet1');
    expect(savedLocation, 'Palermo, Buenos Aires');
  });

  testWidgets('valida y envía una consulta de adopción', (tester) async {
    Map<String, String>? sent;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AdoptionContactForm(
              initialName: '',
              initialEmail: '',
              onSend:
                  ({
                    required name,
                    required email,
                    required phone,
                    required message,
                  }) async {
                    sent = {
                      'name': name,
                      'email': email,
                      'phone': phone,
                      'message': message,
                    };
                  },
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'Tomás');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'tomas@example.com',
    );
    await tester.enterText(
      find.byType(TextFormField).at(3),
      'Me gustaría conocer a Luna.',
    );
    await tester.ensureVisible(find.text('Enviar consulta'));
    await tester.tap(find.text('Enviar consulta'));
    await tester.pumpAndSettle();
    expect(sent?['name'], 'Tomás');
    expect(sent?['email'], 'tomas@example.com');
    expect(sent?['phone'], '');
    expect(sent?['message'], 'Me gustaría conocer a Luna.');
  });
}
