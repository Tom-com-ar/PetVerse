import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petverse/models/pet.dart';
import 'package:petverse/models/post.dart';
import 'package:petverse/screens/post_form_screen.dart';
import 'package:petverse/utils/post_validators.dart';

void main() {
  test('valida el texto y el enlace de una publicación', () {
    expect(validatePostCaption('  '), isNotNull);
    expect(validatePostCaption('Luna jugando'), isNull);
    expect(validatePostMediaUrl('http://ejemplo.com/foto.jpg'), isNotNull);
    expect(validatePostMediaUrl('https://ejemplo.com/foto.jpg'), isNull);
  });

  testWidgets('publica un video asociado a una mascota', (tester) async {
    PostDraft? saved;
    const pet = Pet(
      id: 'pet1',
      name: 'Luna',
      type: 'perro',
      breed: 'Mestiza',
      ageYears: 2,
      weightKg: 3.5,
      photoUrls: [],
      bio: 'Juguetona',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PostFormScreen(
                    pets: const [pet],
                    onSave: (draft) async {
                      saved = draft;
                    },
                  ),
                ),
              ),
              child: const Text('Abrir publicación'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir publicación'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Video'));
    await tester.pump();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Enlace del video'),
      'https://ejemplo.com/luna.mp4',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Texto de la publicación'),
      'Luna corre en el parque.',
    );
    await tester.ensureVisible(find.text('Publicar'));
    await tester.tap(find.text('Publicar'));
    await tester.pumpAndSettle();

    expect(saved?.petId, 'pet1');
    expect(saved?.petName, 'Luna');
    expect(saved?.mediaType, 'video');
    expect(saved?.mediaUrl, 'https://ejemplo.com/luna.mp4');
    expect(saved?.caption, 'Luna corre en el parque.');
  });
}
