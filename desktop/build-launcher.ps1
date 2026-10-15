param(
  [string] $AppUrl = 'https://petverse-db30c.web.app'
)

$ErrorActionPreference = 'Stop'
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$source = Join-Path $PSScriptRoot 'PetVerseLauncher.cs'
$icon = Join-Path $PSScriptRoot 'petverse.ico'
$outputDirectory = Join-Path $PSScriptRoot 'output'
$output = Join-Path $outputDirectory 'PetVerse.exe'

if (-not (Test-Path $compiler)) {
  throw "No se encontró el compilador de Windows: $compiler"
}

$uri = [Uri]::new($AppUrl)
if ($uri.Scheme -ne 'https') {
  throw 'PetVerse.exe necesita una dirección HTTPS publicada.'
}

New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$sourceText = Get-Content -LiteralPath $source -Raw
$escapedUrl = $AppUrl.Replace('\', '\\').Replace('"', '\"')
$compiledSource = Join-Path $env:TEMP 'PetVerseLauncher.compiled.cs'
Set-Content -LiteralPath $compiledSource -Value $sourceText.Replace('__PETVERSE_APP_URL__', $escapedUrl) -Encoding UTF8

$compilerArguments = @(
  '/nologo',
  '/target:winexe',
  "/out:$output",
  '/reference:System.Windows.Forms.dll'
)
if (Test-Path $icon) {
  $compilerArguments += "/win32icon:$icon"
}
$compilerArguments += $compiledSource

& $compiler @compilerArguments
if ($LASTEXITCODE -ne 0) {
  throw 'No se pudo compilar PetVerse.exe.'
}

Write-Output "Listo: $output"
