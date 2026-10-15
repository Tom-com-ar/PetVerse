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

## PV12: PWA instalable

PetVerse incluye un manifiesto web con íconos propios, un service worker y un botón visible **Instalar PetVerse**. En Chrome o Edge, la PWA se abre en una ventana independiente; en iPhone/iPad se agrega desde Safari → Compartir → Agregar a pantalla de inicio. El proyecto también genera `desktop/output/PetVerse.exe`, un acceso de escritorio que abre PetVerse en modo app de Microsoft Edge. El EXE requiere Edge e internet; la app móvil se instala desde la URL HTTPS publicada.

Para generar el EXE en Windows, ejecutá `desktop/build-launcher.ps1` después de publicar PV14. El archivo final queda en `desktop/output/PetVerse.exe`.

## PV13: Responsive y colores

La navegación inferior se usa en pantallas menores a 840 px y pasa a una barra lateral en tablet horizontal y escritorio. El catálogo de adopción muestra una, dos o tres columnas según el ancho disponible; formularios y contenido conservan un ancho cómodo en pantallas grandes y se ajustan al móvil. La identidad visual usa verde bosque, coral y crema.

## PV14: Despliegue y prueba para el profesor

**URL que ya está publicada:** https://petverse-db30c.web.app

**URL corta solicitada:** https://petverse.web.app

Firebase asigna la URL corta cuando el sitio `petverse` está disponible globalmente. `publicar_petverse.bat` verifica si existe, intenta crearlo si falta, publica la app y actualiza el EXE de la carpeta **Ejecutable**. Si el nombre ya está ocupado por otro proyecto, la URL actual sigue funcionando y se puede compartir con el profesor.

### Cómo probar PetVerse

1. Abrí la URL confirmada al terminar la publicación e iniciá sesión con Google o con tu correo.
2. En **Mi perfil**, completá el perfil y agregá una mascota.
3. En **Publicaciones**, subí una foto, probá dar like y dejar un comentario.
4. En **Adopción**, revisá las mascotas y probá las opciones de contacto o consulta.
5. En **Mensajes**, iniciá un chat. Para comprobar el intercambio entre usuarios hacen falta dos cuentas distintas.
6. En **Mi perfil**, revisá los puntos y las insignias que se desbloquean al usar la app.
7. En un celular, elegí **Instalar PetVerse** en el navegador para agregarla a la pantalla de inicio. En Windows, abrí el EXE de la carpeta **Ejecutable**.

Si Google muestra “dominio no autorizado” con la URL corta, agregá `petverse.web.app` en Firebase Console → Authentication → Settings → Authorized domains.
