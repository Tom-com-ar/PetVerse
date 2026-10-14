# PetVerse

Red social para mascotas hecha con Flutter Web. Las etapas implementadas son PV1 (registro y acceso con correo o Google, y recuperación de contraseña), PV2 (perfil editable), PV3 (registro, edición y eliminación de mascotas) y PV4 (feed de publicaciones con imagen o video, texto, autor y fecha).

## Conectar Firebase

1. Entrá a [Firebase Console](https://console.firebase.google.com/) y creá un proyecto llamado PetVerse. El ID puede ser distinto si ese nombre ya está ocupado.
2. En la página inicial del proyecto, agregá una aplicación **Web** (`</>`). Elegí el nombre PetVerse y registrala. Firebase mostrará un objeto `firebaseConfig` con `apiKey`, `authDomain`, `projectId`, `storageBucket`, `messagingSenderId` y `appId`.
3. En esta computadora, `firebase_config.json` ya contiene la configuración de la app Web que registraste. Si clonás el repositorio en otra computadora, copiá `firebase_config.json.example` como `firebase_config.json` y completá los valores `FIREBASE_...`. El archivo real está excluido de Git.
4. En **Authentication → Sign-in method**, activá **Correo electrónico/contraseña** y **Google**. En Google, seleccioná un correo de asistencia para el proyecto y guardá.
5. En **Authentication → Settings → Authorized domains**, agregá `localhost` para probar en Chrome desde esta computadora.
6. En **Firestore Database**, creá una base de datos. Elegí una ubicación y el modo de producción. En la pestaña **Rules**, pegá el contenido de `firestore.rules` y publicá las reglas. Al llegar a PV4, volvé a publicar este archivo porque incorpora la colección `posts`.

La foto del perfil, las fotos de las mascotas y los medios de las publicaciones se agregan mediante enlaces HTTPS. Para videos, usá un enlace directo a un archivo que el navegador pueda reproducir (por ejemplo, MP4). La subida desde el dispositivo se implementará en PV8. Los contadores de likes y comentarios se muestran en el feed; las acciones correspondientes se implementan en PV5 y PV6.

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

Después de conectar Firebase: registrá un usuario, cerrá sesión, volvé a ingresar con correo o con «Continuar con Google», probá «Olvidé mi contraseña» y editá el perfil. En «Mi perfil», pulsá «Agregar mascota», completá sus datos y al menos una URL HTTPS de foto. Expandí su tarjeta para editarla o eliminarla. En «Publicaciones», pulsá «Publicar», elegí una mascota, agregá un enlace HTTPS de imagen o video y escribí un texto. Confirmá en Firestore que existan `users/{uid}/pets/{petId}` y `posts/{postId}`; el feed debe mostrar primero la publicación más reciente.

Si el navegador sigue mostrando «Las agregaremos en PV3», está abierta una versión anterior. Cerrá la pestaña y abrí de nuevo la dirección donde se está sirviendo `build/web`, o detené la ejecución anterior en VS Code y volvé a iniciar `flutter run` desde esta carpeta.

## Estructura

- `lib/models`: datos del usuario, las mascotas y las publicaciones.
- `lib/services`: acceso a Firebase Auth y Firestore para usuarios, mascotas y publicaciones.
- `lib/providers`: sesión actual.
- `lib/screens`: acceso, feed, perfil y formularios de mascota y publicación.
- `lib/widgets`: componentes del perfil, tarjetas de mascotas y publicaciones, reproductor de video.
- `firestore.rules`: reglas de acceso para perfiles, mascotas y publicaciones.

La instalación local de Flutter usa `C:\Users\tomas\Documents\Codex\flutter-sdk-ready`. En otra computadora hay que instalar Flutter y configurar su ruta.
