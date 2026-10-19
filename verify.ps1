param(
    [switch]$Build
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$required = @("README.md", "CODEOWNERS", "SECURITY.md", "CONTRIBUTING.md", "CHANGELOG.md", "LICENSE", "NOTICE")
$errors = @()

Get-ChildItem -Directory -Force $root | ForEach-Object {
    $repo = $_.Name
    $dir = $_.FullName
    foreach ($file in $required) {
        $path = Join-Path $dir $file
        if ($file -eq "CODEOWNERS") { $path = Join-Path $dir ".github/CODEOWNERS" }
        if (-not (Test-Path $path)) { $errors += "$repo missing $file" }
    }

    if ($Build -and (Test-Path (Join-Path $dir "pom.xml"))) {
        Write-Host "BUILD $repo (Maven)"
        & mvn -B -ntp -f (Join-Path $dir "pom.xml") verify
        if ($LASTEXITCODE -ne 0) { $errors += "$repo Maven verification failed" }
    }

    if ($Build -and (Test-Path (Join-Path $dir "package.json"))) {
        Write-Host "BUILD $repo (Node)"
        Push-Location $dir
        try {
            if (Test-Path "package-lock.json") { & npm ci } else { & npm install }
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
