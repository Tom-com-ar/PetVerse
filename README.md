# PetVerse

Red social de mascotas hecha con Flutter Web y Firebase.

## PV9: Chats

El chat es privado entre dos cuentas y guarda las conversaciones y mensajes en Firestore. Para iniciar un chat, abrí la sección **Mensajes** y elegí un perfil.

### Configurar Firestore

Publicá el archivo `firestore.rules` desde Firebase Console → Firestore Database → Reglas. Las reglas habilitan perfiles públicos con nombre y foto, conversaciones privadas e historial de mensajes.

### Ejecutar en la web

Copiá `firebase_config.json.example` como `firebase_config.json`, completá los valores de tu aplicación web de Firebase y ejecutá Flutter usando `--dart-define-from-file=firebase_config.json`.

## PV11: Gamificación

PetVerse suma 10 puntos por publicación, 1 punto por dar like a otra cuenta y 3 puntos por comentario. Cada acción se registra una sola vez; quitar y volver a dar like a la misma publicación no suma puntos otra vez. El perfil muestra el puntaje y el progreso de estas insignias: Primera huella, Creador de patitas, Buen vecino, Voz de la manada y Estrella PetVerse.

Para habilitarlo en Firebase, publicá el `firestore.rules` actualizado desde Firebase Console → Firestore Database → Reglas.
