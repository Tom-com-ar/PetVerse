import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_config.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/pet_service.dart';
import 'services/post_service.dart';
import 'services/profile_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!FirebaseConfig.isConfigured) {
    runApp(const MaterialApp(home: SetupScreen()));
    return;
  }

  try {
    await Firebase.initializeApp(options: FirebaseConfig.options);
    await FirebaseAuth.instance.setLanguageCode('es');
    final profiles = ProfileService(FirebaseFirestore.instance);
    final pets = PetService(FirebaseFirestore.instance);
    final posts = PostService(FirebaseFirestore.instance);
    runApp(
      MultiProvider(
        providers: [
          Provider<ProfileService>.value(value: profiles),
          Provider<PetService>.value(value: pets),
          Provider<PostService>.value(value: posts),
          ChangeNotifierProvider(
            create: (_) =>
                AuthProvider(AuthService(FirebaseAuth.instance, profiles)),
          ),
        ],
        child: const PetVerseApp(),
      ),
    );
  } catch (_) {
    runApp(const MaterialApp(home: SetupScreen(hasError: true)));
  }
}

class PetVerseApp extends StatelessWidget {
  const PetVerseApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PetVerse',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF7455D3),
        surface: const Color(0xFFF9F7FF),
      ),
      scaffoldBackgroundColor: const Color(0xFFF9F7FF),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    ),
    home: const AuthGate(),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return user == null ? const AuthScreen() : HomeScreen(user: user);
  }
}

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key, this.hasError = false});
  final bool hasError;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.pets_rounded,
                    size: 60,
                    color: Color(0xFF7455D3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PetVerse',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hasError
                        ? 'No se pudo conectar con Firebase. Revisá la configuración y volvé a ejecutar la app.'
                        : 'Falta conectar el proyecto de Firebase. Seguí los pasos del README para habilitar el registro y el perfil.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
