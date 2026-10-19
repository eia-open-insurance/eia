param(
    [switch]$Build
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$required = @("README.md", "CODEOWNERS", "SECURITY.md", "CONTRIBUTING.md", "CHANGELOG.md", "LICENSE", "NOTICE")
$errors = @()

Get-ChildItem -Directory -Force $root | Where-Object { Test-Path (Join-Path $_.FullName ".git") } | ForEach-Object {
    $repo = $_.Name
    $dir = $_.FullName
    foreach ($file in $required) {
        $path = Join-Path $dir $file
        if ($file -eq "CODEOWNERS") { $path = Join-Path $dir ".github/CODEOWNERS" }
        if (-not (Test-Path $path)) { $errors += "$repo missing $file" }
    }

    if ($Build -and ((Test-Path (Join-Path $dir "build.gradle.kts")) -or (Test-Path (Join-Path $dir "build.gradle")))) {
        Write-Host "BUILD $repo (Gradle)"
        $gradle = "gradle"
        if (Test-Path (Join-Path $dir "gradlew.bat")) { $gradle = Join-Path $dir "gradlew.bat" }
        & $gradle -p $dir build
        if ($LASTEXITCODE -ne 0) { $errors += "$repo Gradle verification failed" }
    }

    if ($Build -and (Test-Path (Join-Path $dir "package.json"))) {
        Write-Host "BUILD $repo (Node)"
        Push-Location $dir
        try {
            if (-not (Test-Path "node_modules")) { if (Test-Path "package-lock.json") { & npm ci } else { & npm install } }
            & npm run build --if-present
            & npm test --if-present
            if ($LASTEXITCODE -ne 0) { $errors += "$repo Node verification failed" }
        } finally { Pop-Location }
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host "Repository baseline verified. No hosted pipeline used."



