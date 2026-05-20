# Build portable OpenRocket locally (Windows x64)
# Requirements: JDK 17+ in PATH (must include jpackage), Git in PATH
# Usage: .\build.ps1 [-Ref unstable]

param(
    [string]$Ref = "unstable"
)

$ErrorActionPreference = "Stop"

$workDir = "$PSScriptRoot\build-work"
$srcDir  = "$workDir\openrocket"
$outDir  = "$PSScriptRoot\dist"

# Clone or update
if (Test-Path "$srcDir\.git") {
    Write-Host "Updating OpenRocket ($Ref)..."
    git -C $srcDir fetch origin $Ref --depth=1 -q
    git -C $srcDir checkout FETCH_HEAD -q
} else {
    Write-Host "Cloning OpenRocket ($Ref)..."
    New-Item -ItemType Directory -Force $workDir | Out-Null
    git clone --depth=1 --branch $Ref https://github.com/openrocket/openrocket.git $srcDir -q
}

$sha = (git -C $srcDir rev-parse --short HEAD).Trim()
Write-Host "Building commit $sha..."

# Build shadow JAR
Push-Location $srcDir
try {
    & .\gradlew.bat shadowJar --no-daemon -q
    if ($LASTEXITCODE -ne 0) { throw "Gradle build failed" }
} finally {
    Pop-Location
}

$jar = Get-ChildItem "$srcDir\build\libs\OpenRocket-*.jar" | Select-Object -First 1
if (-not $jar) { throw "JAR not found after build" }

# Build app-image (portable folder with .exe + bundled JRE)
$appDir = "$workDir\app-image"
if (Test-Path $appDir) { Remove-Item -Recurse -Force $appDir }

jpackage `
    --type app-image `
    --input (Split-Path $jar.FullName) `
    --main-jar (Split-Path $jar.FullName -Leaf) `
    --name OpenRocket `
    --dest $appDir `
    --java-options "-Dsun.java2d.noddraw=true" `
    --java-options "-Dsun.java2d.d3d=false" `
    --java-options "-Djogl.disable.openglarbcontext=true" `
    --java-options "-Dsun.java2d.opengl=false"
if ($LASTEXITCODE -ne 0) { throw "jpackage failed" }

# Zip
New-Item -ItemType Directory -Force $outDir | Out-Null
$zipPath = "$outDir\OpenRocket-portable-win-x64-$sha.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath }
Compress-Archive -Path "$appDir\OpenRocket\*" -DestinationPath $zipPath

Write-Host ""
Write-Host "Done: $zipPath"
Write-Host "Unzip and run OpenRocket.exe — no Java required."
