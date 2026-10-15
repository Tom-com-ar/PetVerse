import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../utils/app_breakpoints.dart';

enum AuthMode { login, register, reset }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  AuthMode _mode = AuthMode.login;
  bool _busy = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _switchMode(AuthMode mode) {
    setState(() {
      _mode = mode;
      _message = null;
    });
    _formKey.currentState?.reset();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final auth = context.read<AuthProvider>();
      switch (_mode) {
        case AuthMode.login:
          await auth.signIn(_email.text, _password.text);
        case AuthMode.register:
          await auth.register(_name.text, _email.text, _password.text);
        case AuthMode.reset:
          await auth.sendPasswordReset(_email.text);
      }
      if (!mounted) return;
      if (_mode == AuthMode.reset) {
        setState(() {
          _isError = false;
          _message = 'Te enviamos un enlace para restablecer la contraseña.';
        });
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _isError = true;
        _message = _authErrorMessage(error.code);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isError = true;
        _message = 'No se pudo completar la operación. Intentá de nuevo.';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await context.read<AuthProvider>().signInWithGoogle();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _isError = true;
        _message = _authErrorMessage(error.code);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isError = true;
        _message = 'No se pudo ingresar con Google. Intentá de nuevo.';
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRegister = _mode == AuthMode.register;
    final isReset = _mode == AuthMode.reset;
    final horizontalPadding = AppBreakpoints.pagePadding(context);
    final compact = AppBreakpoints.isMobile(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(horizontalPadding),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              elevation: 0,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(compact ? 20 : 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.pets_rounded,
                        size: 54,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'PetVerse',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isReset
                            ? 'Recuperá tu contraseña'
                            : isRegister
                            ? 'Creá tu cuenta'
                            : 'Entrá a tu mundo de mascotas',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 26),
                      if (isRegister) ...[
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: validateName,
                        ),
                        const SizedBox(height: 14),
                      ],
                      TextFormField(
                        controller: _email,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: validateEmail,
                      ),
                      if (!isReset) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _password,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                          ),
                          obscureText: true,
                          autofillHints: [
                            isRegister
                                ? AutofillHints.newPassword
                                : AutofillHints.password,
                          ],
                          validator: validatePassword,
                        ),
                      ],
                      if (isRegister) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _confirmPassword,
                          decoration: const InputDecoration(
                            labelText: 'Repetir contraseña',
                          ),
                          obscureText: true,
                          validator: (value) => value != _password.text
                              ? 'Las contraseñas no coinciden.'
                              : null,
                        ),
                      ],
                      if (_message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _message!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isError
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      FilledButton(
                        onPressed: _busy ? null : _submit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: _busy
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isReset
                                      ? 'Enviar enlace'
                                      : isRegister
                                      ? 'Crear cuenta'
                                      : 'Ingresar',
                                ),
                        ),
                      ),
                      if (!isReset) ...[
                        const SizedBox(height: 16),
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('o'),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _signInWithGoogle,
                          icon: const Text(
                            'G',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          label: const Text('Continuar con Google'),
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (!isReset)
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => _switchMode(
                                  isRegister
                                      ? AuthMode.login
                                      : AuthMode.register,
                                ),
                          child: Text(
                            isRegister ? 'Ya tengo cuenta' : 'Crear una cuenta',
                          ),
                        ),
                      if (!isRegister)
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => _switchMode(
                                  isReset ? AuthMode.login : AuthMode.reset,
                                ),
                          child: Text(
                            isReset
                                ? 'Volver al inicio de sesión'
                                : 'Olvidé mi contraseña',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _authErrorMessage(String code) => switch (code) {
  'email-already-in-use' => 'Ese correo ya está registrado.',
  'invalid-email' => 'El correo no es válido.',
  'weak-password' => 'Elegí una contraseña más segura.',
  'invalid-credential' ||
  'wrong-password' ||
  'user-not-found' => 'Correo o contraseña incorrectos.',
  'too-many-requests' => 'Demasiados intentos. Probá más tarde.',
  'network-request-failed' => 'No hay conexión. Revisá Internet.',
  'operation-not-allowed' => 'Falta activar Google en Firebase Authentication.',
  'unauthorized-domain' =>
    'Este dominio no está autorizado en Firebase Authentication.',
  'popup-blocked' => 'El navegador bloqueó la ventana de Google. Permití las ventanas emergentes.',
  'popup-closed-by-user' => 'Se canceló el ingreso con Google.',
  'account-exists-with-different-credential' =>
    'Ya existe una cuenta con ese correo. Ingresá con el método original.',
  _ => 'No se pudo completar la operación. Intentá de nuevo.',
};
