# setup_comfyui_volumes.ps1

# 0) cd into script folder
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

# 2) Ensure volumes
Write-Host "`n🟢 Ensuring Docker volumes..."
foreach ($vol in "sd-shared-models", "sd-shared-output", "sd-comfyui") {
    if (docker volume inspect $vol 2>$null) {
        Write-Host " • '$vol' exists."
    } else {
        Write-Host " • Creating '$vol'..."
        docker volume create $vol | Out-Null
    }
}

# 3) Seed sd-comfyui once
Write-Host "`n🟢 Seeding 'sd-comfyui' (if needed)..."
docker run --rm -v sd-comfyui:/opt/ComfyUI python:3.10-slim `
    bash -c "if [ -d /opt/ComfyUI/.git ]; then exit 0; else exit 1; fi"

if ($LASTEXITCODE -ne 0) {
    Write-Host " • Cloning ComfyUI into 'sd-comfyui'..."
    docker run --rm -v sd-comfyui:/opt/ComfyUI python:3.10-slim `
        bash -c "apt-get update && apt-get install -y git && \
                 git clone https://github.com/comfyanonymous/ComfyUI.git /tmp/ComfyUI && \
                 mkdir -p /opt/ComfyUI && \
                 cp -a /tmp/ComfyUI/. /opt/ComfyUI/"
    Write-Host " → Seed complete."
}

Write-Host "`n🛠 Cleaning up old symlinks and creating model directories/symlinks in 'sd-shared-models' for ComfyUI..."
docker run --rm `
  -v sd-comfyui:/opt/ComfyUI `
  -v sd-shared-models:/opt/ComfyUI/models `
  python:3.10-slim `
  bash -c 'set -e; for d in VAE Lora ControlNet ESRGAN Stable-diffusion embedding; do [ -d "/opt/ComfyUI/models/$d" ] && find "/opt/ComfyUI/models/$d" -type l -delete 2>/dev/null; done; mkdir -p /opt/ComfyUI/models/{checkpoints,vae,loras,controlnet,upscale_models,embeddings,VAE,Lora,ControlNet,ESRGAN,Stable-diffusion,embedding,clip,text_encoder}; for pair in vae:VAE loras:Lora controlnet:ControlNet upscale_models:ESRGAN checkpoints:Stable-diffusion embeddings:embedding; do src=${pair%:*}; dst=${pair#*:}; for f in /opt/ComfyUI/models/$src/*; do [ -e "$f" ] && [ ! -L "/opt/ComfyUI/models/$dst/${f##*/}" ] && ln -sf "$f" "/opt/ComfyUI/models/$dst/${f##*/}"; done; done'


Write-Host "`n🧹 Cleaning up seeding image..."
docker image rm python:3.10-slim -f

# 4) Build
Write-Host "`n🟢 Building Docker image..."
docker-compose build --pull
if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ Build failed."
    exit 1
}

# 5) Up
Write-Host "`n🟢 Starting ComfyUI..."
docker-compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ docker-compose up failed."
    exit 1
}

Write-Host "`n✅ Done!  ComfyUI is at http://localhost:8188 — it might take a little time to fully deploy the services."