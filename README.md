# PetVerse

Red social de mascotas hecha con Flutter Web y Firebase.

## PV9: Chats

El chat es privado entre dos cuentas y guarda las conversaciones y mensajes en Firestore. Para iniciar un chat, abrí la sección **Mensajes** y elegí un perfil.

### Configurar Firestore

Publicá el archivo `firestore.rules` desde Firebase Console → Firestore Database → Reglas. Las reglas habilitan perfiles públicos con nombre y foto, conversaciones privadas e historial de mensajes.

### Ejecutar en la web

Copiá `firebase_config.json.example` como `firebase_config.json`, completá los valores de tu aplicación web de Firebase y ejecutá Flutter usando `--dart-define-from-file=firebase_config.json`.
