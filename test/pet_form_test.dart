import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petverse/models/pet.dart';
import 'package:petverse/screens/pet_form_screen.dart';
import 'package:petverse/utils/pet_validators.dart';
import 'package:petverse/widgets/pet_card.dart';

void main() {
  test('valida edad, peso con coma y enlaces de fotos', () {
    expect(validatePetAge('-1'), isNotNull);
    expect(validatePetAge('0'), isNull);
    expect(validatePetWeight('2,5'), isNull);
    expect(parsePetWeight('2,5'), 2.5);
    expect(validatePetPhotoUrls(''), isNotNull);
    expect(validatePetPhotoUrls('http://ejemplo.com/foto.jpg'), isNotNull);
    expect(
      validatePetPhotoUrls(
        'https://ejemplo.com/uno.jpg\nhttps://ejemplo.com/dos.jpg',
      ),
      isNull,
    );
  });

  testWidgets('registra una mascota con todos los datos', (tester) async {
    Pet? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      PetFormScreen(onSave: (pet) async => saved = pet),
                ),
              ),
              child: const Text('Abrir formulario'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir formulario'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre'),
      'Luna',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Raza'),
      'Mestiza',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Edad (años)'),
      '2',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Peso (kg)'),
      '3,5',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Fotos'),
      'https://ejemplo.com/luna1.jpg\nhttps://ejemplo.com/luna2.jpg',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Biografía'),
      'Muy juguetona.',
    );
    await tester.ensureVisible(find.text('Guardar mascota'));
    await tester.tap(find.text('Guardar mascota'));
    await tester.pumpAndSettle();

    expect(saved?.name, 'Luna');
    expect(saved?.type, 'perro');
    expect(saved?.breed, 'Mestiza');
    expect(saved?.ageYears, 2);
    expect(saved?.weightKg, 3.5);
    expect(saved?.photoUrls, hasLength(2));
    expect(saved?.bio, 'Muy juguetona.');
  });

  testWidgets('eliminar una mascota requiere confirmación', (tester) async {
    var deleted = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PetCard(
            pet: const Pet(
              id: 'pet1',
              name: 'Luna',
              type: 'perro',
              breed: 'Mestiza',
              ageYears: 2,
              weightKg: 3.5,
              photoUrls: [],
              bio: 'Muy juguetona.',
            ),
            onEdit: () {},
            onDelete: () async {
              deleted++;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Luna'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar mascota'));
    await tester.pumpAndSettle();
    expect(find.text('¿Eliminar a Luna?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(deleted, 0);

    await tester.tap(find.text('Eliminar mascota'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    expect(deleted, 1);
  });
}
