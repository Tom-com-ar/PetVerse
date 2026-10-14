import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petverse/models/user_profile.dart';
import 'package:petverse/screens/auth_screen.dart';
import 'package:petverse/utils/validators.dart';
import 'package:petverse/widgets/profile_edit_form.dart';

void main() {
  test('valida los datos antes de enviarlos a Firebase', () {
    expect(validateEmail('mal'), isNotNull);
    expect(validateEmail('ana@ejemplo.com'), isNull);
    expect(validatePassword('12345'), isNotNull);
    expect(validatePassword('123456'), isNull);
    expect(validatePhotoUrl('http://ejemplo.com/foto.jpg'), isNotNull);
    expect(validatePhotoUrl('https://ejemplo.com/foto.jpg'), isNull);
  });

  testWidgets('registro y recuperación muestran sus campos', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));

    expect(find.text('Ingresar'), findsOneWidget);
    await tester.tap(find.text('Crear una cuenta'));
    await tester.pump();
    expect(find.text('Repetir contraseña'), findsOneWidget);

    await tester.tap(find.text('Ya tengo cuenta'));
    await tester.pump();
    await tester.tap(find.text('Olvidé mi contraseña'));
    await tester.pump();
    expect(find.text('Enviar enlace'), findsOneWidget);
  });

  testWidgets('el formulario de perfil guarda nombre y biografía', (
    tester,
  ) async {
    String? savedName;
    String? savedBio;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => ProfileEditForm(
                  profile: const UserProfile(
                    uid: 'u1',
                    email: 'ana@ejemplo.com',
                    name: 'Ana',
                    bio: '',
                    photoUrl: '',
                  ),
                  onSave: (name, bio, _) async {
                    savedName = name;
                    savedBio = bio;
                  },
                ),
              ),
              child: const Text('Abrir perfil'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir perfil'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre'),
      'Ana Gómez',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Biografía'),
      'Me gustan los perros.',
    );
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(savedName, 'Ana Gómez');
    expect(savedBio, 'Me gustan los perros.');
  });
}
