<# run-onetrainer.ps1

   Builds the OneTrainer image from the local Dockerfile,
   creates/seed a named volume for /OneTrainer,
   and runs the container with GPU support.
#>

param(
  [string]$VolumeName     = "onetrainer",
  [string]$ImageName      = "onetrainer",
  [string]$ContainerName  = "onetrainer_container"
)

$ErrorActionPreference = "Stop"

# 1) Check Docker CLI + daemon
Write-Host "🔍 Checking Docker CLI..."
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Docker not found. Install Docker Desktop: https://docs.docker.com/get-docker/"
    exit 1
}
Write-Host "🛠️ Testing Docker daemon connection..."
try { docker info | Out-Null } catch {
    Write-Error "❌ Can't connect to Docker daemon. Is Docker running?"
    exit 1
}

# 2) Verify Dockerfile is here
Write-Host "`n📄 Verifying Dockerfile exists..."
if (-not (Test-Path (Join-Path $PSScriptRoot "Dockerfile"))) {
    Write-Error "🚫 Dockerfile not found in $PSScriptRoot. Run this from OneTrainer's root."
    exit 1
}

# 3) Ensure the volume exists
Write-Host "`n🟢 Ensuring Docker volume '$VolumeName'..."
if (docker volume inspect $VolumeName 2>$null) {
    Write-Host " • Volume '$VolumeName' already exists."
} else {
    Write-Host " • Creating volume '$VolumeName'..."
    docker volume create $VolumeName | Out-Null
    Write-Host "   → Created."
}

# 4) Seed the volume (clone your local code into it) if empty
Write-Host "`n🟢 Checking if '$VolumeName' is seeded with code..."
docker run --rm `
    --mount "type=volume,source=${VolumeName},target=/OneTrainer" `
    busybox sh -c "test -d /OneTrainer/.git"

if ($LASTEXITCODE -ne 0) {
    Write-Host " • Copying project into volume..."
    docker run --rm `
      --mount "type=volume,source=${VolumeName},target=/OneTrainer" `
      --mount "type=bind,source=${PSScriptRoot},target=/src" `
      busybox sh -c "cp -a /src/. /OneTrainer/"
    Write-Host "   → Seed complete."
} else {
    Write-Host " • Volume already contains a clone."
}

# 5) Build the Docker image from local Dockerfile
Write-Host "`n📦 Building Docker image '$ImageName'..."
docker build -t $ImageName $PSScriptRoot
Write-Host "   → Image '$ImageName' built."

# 6) Clean up old container & run a new one with GPU support
Write-Host "`n🔄 Cleaning up any old container named '$ContainerName'..."
$old = docker ps -aq -f "name=^${ContainerName}$"
if ($old) { docker rm -f $old | Out-Null }

Write-Host "🚀 Launching container '$ContainerName' (with GPUs)..."
docker run -d `
  --gpus all `
  --name $ContainerName `
  --mount "type=volume,source=${VolumeName},target=/OneTrainer" `
  -p 7860:7860 `
  $ImageName

Write-Host "✅ Container is up — UI at http://localhost:7860"
