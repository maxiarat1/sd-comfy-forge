# setup_filebrowser.ps1

Set-Location -Path $PSScriptRoot

# 1) Check Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Docker not found."
    exit 1
}
try { docker info | Out-Null } catch {
    Write-Error "❌ Can't connect to Docker daemon."
    exit 1
}

# 2) Ensure shared volumes
Write-Host "`n🟢 Ensuring Docker volumes..."
foreach ($vol in "sd-shared-models", "sd-shared-output") {
    if (docker volume inspect $vol 2>$null) {
        Write-Host " • '$vol' exists."
    } else {
        Write-Host " • Creating '$vol'..."
        docker volume create $vol | Out-Null
    }
}

# 3) Up
Write-Host "`n🟢 Starting File Browser..."
docker-compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ docker-compose up failed."
    exit 1
}

Write-Host "`n✅ File Browser is at http://localhost:8080/filebrowser"
