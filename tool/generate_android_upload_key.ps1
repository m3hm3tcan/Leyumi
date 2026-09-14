param(
    [string]$Publisher = "Leyumi Studio",
    [string]$Alias = "upload"
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$androidDir = Join-Path $projectRoot "android"
$keystorePath = Join-Path $androidDir "leyumi-upload-key.jks"
$propertiesPath = Join-Path $androidDir "key.properties"
$keytoolPath = Join-Path $env:JAVA_HOME "bin\keytool.exe"

if (-not (Test-Path -LiteralPath $keytoolPath)) {
    $keytoolPath = "keytool.exe"
}

if ((Test-Path -LiteralPath $keystorePath) -or
    (Test-Path -LiteralPath $propertiesPath)) {
    throw "Upload key files already exist. Refusing to overwrite them."
}

$bytes = New-Object byte[] 32
$generator = [System.Security.Cryptography.RandomNumberGenerator]::Create()
try {
    $generator.GetBytes($bytes)
} finally {
    $generator.Dispose()
}
$password = [Convert]::ToBase64String($bytes).Replace("/", "_").Replace("+", "-")

& $keytoolPath `
    -genkeypair `
    -v `
    -keystore $keystorePath `
    -storetype JKS `
    -keyalg RSA `
    -keysize 4096 `
    -validity 10000 `
    -alias $Alias `
    -storepass $password `
    -keypass $password `
    -dname "CN=$Publisher, OU=Mobile, O=$Publisher, C=HU"

if ($LASTEXITCODE -ne 0) {
    throw "keytool failed with exit code $LASTEXITCODE."
}

$content = @(
    "storePassword=$password"
    "keyPassword=$password"
    "keyAlias=$Alias"
    "storeFile=../leyumi-upload-key.jks"
) -join [Environment]::NewLine

[System.IO.File]::WriteAllText($propertiesPath, $content + [Environment]::NewLine)

Write-Output "Created Android upload keystore and signing configuration."
Write-Output "Back up android/leyumi-upload-key.jks and android/key.properties securely."
