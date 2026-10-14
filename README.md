# PetVerse

Red social para mascotas hecha con Flutter Web. Esta etapa implementa PV1 (registro, acceso y recuperación de contraseña con correo) y PV2 (perfil editable con foto por URL, nombre, biografía y lista de mascotas).

## Conectar Firebase

1. Entrá a [Firebase Console](https://console.firebase.google.com/) y creá un proyecto llamado PetVerse. El ID puede ser distinto si ese nombre ya está ocupado.
2. En la página inicial del proyecto, agregá una aplicación **Web** (`</>`). Elegí el nombre PetVerse y registrala. Firebase mostrará un objeto `firebaseConfig` con `apiKey`, `authDomain`, `projectId`, `storageBucket`, `messagingSenderId` y `appId`.
3. En esta computadora, `firebase_config.json` ya contiene la configuración de la app Web que registraste. Si clonás el repositorio en otra computadora, copiá `firebase_config.json.example` como `firebase_config.json` y completá los valores `FIREBASE_...`. El archivo real está excluido de Git.
4. En **Authentication → Sign-in method**, activá **Correo electrónico/contraseña**.
5. En **Authentication → Settings → Authorized domains**, agregá `localhost` para probar en Chrome desde esta computadora.
6. En **Firestore Database**, creá una base de datos. Elegí una ubicación y el modo de producción. En la pestaña **Rules**, pegá el contenido de `firestore.rules` y publicá las reglas.

La URL de la foto se puede cambiar desde el perfil. La subida desde el dispositivo se implementará en PV8. La lista de mascotas se llenará al implementar PV3.

## Ejecutar

Abrí esta carpeta en VS Code. En una terminal PowerShell:

```powershell
$env:Path = "C:\Users\tomas\Documents\Codex\flutter-sdk-ready\bin;" + $env:Path
flutter --no-version-check pub get
flutter --no-version-check run -d chrome --dart-define-from-file=firebase_config.json
```

Si ejecutás sin `firebase_config.json`, la aplicación muestra la pantalla que indica que falta conectar Firebase.

## Comprobar

```powershell
flutter --no-version-check analyze
flutter --no-version-check test
flutter --no-version-check build web --dart-define-from-file=firebase_config.json
```

Después de conectar Firebase: registrá un usuario, cerrá sesión, volvé a ingresar, probá «Olvidé mi contraseña» y editá el perfil. Confirmá en Firestore que exista `users/{uid}` y que el cambio de nombre o biografía quede guardado.

## Estructura

- `lib/models`: datos del usuario y resumen de mascota.
- `lib/services`: acceso a Firebase Auth y Firestore.
- `lib/providers`: sesión actual.
- `lib/screens`: acceso y perfil.
- `lib/widgets`: componentes del perfil.
- `firestore.rules`: reglas de acceso para que cada usuario edite solo sus datos.

La instalación local de Flutter usa `C:\Users\tomas\Documents\Codex\flutter-sdk-ready`. En otra computadora hay que instalar Flutter y configurar su ruta.
