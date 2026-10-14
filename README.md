# PetVerse

Red social para mascotas hecha con Flutter Web. Las etapas implementadas son PV1 (registro y acceso con correo o Google, y recuperación de contraseña), PV2 (perfil editable) y PV3 (registro y edición de mascotas con nombre, tipo, raza, edad, peso, fotos y biografía).

## Conectar Firebase

1. Entrá a [Firebase Console](https://console.firebase.google.com/) y creá un proyecto llamado PetVerse. El ID puede ser distinto si ese nombre ya está ocupado.
2. En la página inicial del proyecto, agregá una aplicación **Web** (`</>`). Elegí el nombre PetVerse y registrala. Firebase mostrará un objeto `firebaseConfig` con `apiKey`, `authDomain`, `projectId`, `storageBucket`, `messagingSenderId` y `appId`.
3. En esta computadora, `firebase_config.json` ya contiene la configuración de la app Web que registraste. Si clonás el repositorio en otra computadora, copiá `firebase_config.json.example` como `firebase_config.json` y completá los valores `FIREBASE_...`. El archivo real está excluido de Git.
4. En **Authentication → Sign-in method**, activá **Correo electrónico/contraseña** y **Google**. En Google, seleccioná un correo de asistencia para el proyecto y guardá.
5. En **Authentication → Settings → Authorized domains**, agregá `localhost` para probar en Chrome desde esta computadora.
6. En **Firestore Database**, creá una base de datos. Elegí una ubicación y el modo de producción. En la pestaña **Rules**, pegá el contenido de `firestore.rules` y publicá las reglas.

La foto del perfil y las fotos de las mascotas se agregan mediante enlaces HTTPS. La subida desde el dispositivo se implementará en PV8.

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

Después de conectar Firebase: registrá un usuario, cerrá sesión, volvé a ingresar con correo o con «Continuar con Google», probá «Olvidé mi contraseña» y editá el perfil. Luego, desde «Mis mascotas», pulsá «Agregar mascota», completá sus datos y al menos una URL HTTPS de foto. Expandí su tarjeta para ver los detalles y probá «Editar mascota». Confirmá en Firestore que existan `users/{uid}` y `users/{uid}/pets/{petId}` con los cambios guardados.

Si el navegador sigue mostrando «Las agregaremos en PV3», está abierta una versión anterior. Cerrá la pestaña y abrí de nuevo la dirección donde se está sirviendo `build/web`, o detené la ejecución anterior en VS Code y volvé a iniciar `flutter run` desde esta carpeta.

## Estructura

- `lib/models`: datos del usuario y las mascotas.
- `lib/services`: acceso a Firebase Auth y Firestore para usuarios y mascotas.
- `lib/providers`: sesión actual.
- `lib/screens`: acceso, perfil y formulario de mascota.
- `lib/widgets`: componentes del perfil y tarjetas de mascotas.
- `firestore.rules`: reglas de acceso para que cada usuario edite solo sus datos.

La instalación local de Flutter usa `C:\Users\tomas\Documents\Codex\flutter-sdk-ready`. En otra computadora hay que instalar Flutter y configurar su ruta.
