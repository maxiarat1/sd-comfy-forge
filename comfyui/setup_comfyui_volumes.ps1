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

    Write-Host "`n🛠 Creating model directories and symlinks in 'sd-shared-models' for ComfyUI..."
    docker run --rm `
        -v sd-comfyui:/opt/ComfyUI `
        -v sd-shared-models:/opt/ComfyUI/models `
        python:3.10-slim bash -c "
            mkdir -p /opt/ComfyUI/models/{checkpoints,vae,loras,controlnet,clip,text_encoder,upscale_models,embeddings} && \
            ln -sf /opt/ComfyUI/models/vae/* /opt/ComfyUI/models/VAE/ 2>/dev/null || true && \
            ln -sf /opt/ComfyUI/models/loras/* /opt/ComfyUI/models/Lora/ 2>/dev/null || true && \
            ln -sf /opt/ComfyUI/models/controlnet/* /opt/ComfyUI/models/ControlNet/ 2>/dev/null || true && \
            ln -sf /opt/ComfyUI/models/upscale_models/* /opt/ComfyUI/models/ESRGAN/ 2>/dev/null || true && \
            ln -sf /opt/ComfyUI/models/checkpoints/* /opt/ComfyUI/models/Stable-diffusion/ 2>/dev/null || true && \
            ln -sf /opt/ComfyUI/models/embeddings/* /opt/ComfyUI/models/embedding/ 2>/dev/null || true
        "

    Write-Host "`n🧹 Cleaning up seeding image..."
    docker image rm python:3.10-slim -f
} else {
    Write-Host " • Already seeded."
    docker image rm python:3.10-slim -f
}

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
