@echo off
setlocal
cd /d "%~dp0"

set "FLUTTER=%USERPROFILE%\Documents\Codex\flutter-sdk-ready\bin\flutter.bat"
if not exist "%FLUTTER%" (
  echo No se encontro Flutter en: %FLUTTER%
  echo Revisa que el SDK de Flutter este en la carpeta Documents\Codex.
  pause
  exit /b 1
)
where.exe npm.cmd >nul 2>&1
if errorlevel 1 (
  echo No se encontro Node.js/npm. Hace falta para ejecutar Firebase CLI.
  pause
  exit /b 1
)

if not exist "%APPDATA%\configstore\firebase-tools.json" (
  echo Se abrira el navegador para iniciar sesion en Firebase.
  call npm.cmd exec --yes --package firebase-tools -- firebase login
  if errorlevel 1 goto error
)

call npm.cmd exec --yes --package firebase-tools -- firebase hosting:sites:get petverse --project petverse-db30c >nul 2>&1
if errorlevel 1 (
  echo Intentando reservar petverse.web.app en tu proyecto...
  call npm.cmd exec --yes --package firebase-tools -- firebase hosting:sites:create petverse --project petverse-db30c
  if errorlevel 1 (
    echo Firebase no pudo crear el sitio petverse. Puede estar ocupado o faltar conexion/permisos. La URL actual sigue funcionando: https://petverse-db30c.web.app
    goto error
  )
)

call npm.cmd exec --yes --package firebase-tools -- firebase target:apply hosting petverse petverse --project petverse-db30c
if errorlevel 1 goto error

call "%FLUTTER%" build web --release --base-href=/ --dart-define-from-file=firebase_config.json
if errorlevel 1 goto error

call npm.cmd exec --yes --package firebase-tools -- firebase deploy --only hosting:petverse --project petverse-db30c
if errorlevel 1 goto error

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0desktop\build-launcher.ps1"
if errorlevel 1 goto error

if exist "%USERPROFILE%\OneDrive\Escritorio\Ejecutable\" (
  copy /Y "%~dp0desktop\output\PetVerse.exe" "%USERPROFILE%\OneDrive\Escritorio\Ejecutable\PetVerse.exe" >nul
)

echo.
echo PetVerse ya esta publicada en https://petverse.web.app
echo En el celular, abri esa direccion y usa Instalar PetVerse.
pause
exit /b 0

:error
echo.
echo No se pudo completar la publicacion. Revisa el mensaje anterior y volve a ejecutar este archivo.
pause
exit /b 1
