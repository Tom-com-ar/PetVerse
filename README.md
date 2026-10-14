# PetVerse

Proyecto de red social para mascotas con Flutter Web y Firebase.

## Etapa 1: base Flutter Web

Proyecto creado y compilado para web. Firebase y las funciones de la actividad se agregarán por etapas.

## Abrir y ejecutar en VS Code

1. Abrir esta carpeta como proyecto en VS Code.
2. Las extensiones Flutter y Dart ya están instaladas en esta PC.
3. Abrir una terminal PowerShell en VS Code y ejecutar:

    $env:Path = "C:\Users\tomas\Documents\Codex\flutter-sdk-ready\bin;" + $env:Path
    flutter --no-version-check pub get
    flutter --no-version-check run -d chrome

La ruta del SDK es local a esta computadora. En otra computadora hay que instalar Flutter y agregar su carpeta bin al PATH.

## Comprobaciones

    flutter --no-version-check analyze
    flutter --no-version-check test
    flutter --no-version-check build web

El código inicial está en lib/main.dart.
