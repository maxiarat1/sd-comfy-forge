# setup_sdforge_volumes.ps1

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
foreach ($vol in "sd-shared-models", "sd-shared-output", "sd-forge") {
    if ((docker volume inspect $vol) 2>$null) {
        Write-Host " • '$vol' exists."
    } else {
        Write-Host " • Creating '$vol'..."
        docker volume create $vol | Out-Null
    }
}

# 3) Seed sd-forge once
Write-Host "`n🟢 Seeding 'sd-forge' (if needed)..."
docker run --rm -v sd-forge:/opt/sd-webui-forge python:3.10-slim `
    bash -c "if [ -d /opt/sd-webui-forge/.git ]; then exit 0; else exit 1; fi"

if ($LASTEXITCODE -ne 0) {
    Write-Host " • Cloning Forge WebUI into 'sd-forge'..."
    docker run --rm -v sd-forge:/opt/sd-webui-forge python:3.10-slim `
        bash -c "apt-get update && apt-get install -y git && \
                 git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git /tmp/forge && \
                 mkdir -p /opt/sd-webui-forge && \
                 cp -a /tmp/forge/. /opt/sd-webui-forge/"
    Write-Host " → Seed complete."
}

Write-Host "`n🛠 Cleaning up old symlinks and creating model directories/symlinks in 'sd-shared-models'..."
docker run --rm `
  -v sd-forge:/opt/sd-webui-forge `
  -v sd-shared-models:/opt/sd-webui-forge/models `
  python:3.10-slim `
  bash -c 'set -e; for d in VAE Lora ControlNet ESRGAN Stable-diffusion embeddings embedding; do [ -d "/opt/sd-webui-forge/models/$d" ] && find "/opt/sd-webui-forge/models/$d" -type l -delete 2>/dev/null; done; mkdir -p /opt/sd-webui-forge/models/{VAE,Lora,ControlNet,ESRGAN,Stable-diffusion,BLIP,Codeformer,GFPGAN,RealESRGAN,hypernetworks,embeddings,vae,loras,controlnet,upscale_models,checkpoints,clip,clip_vision,configs,consistency_models,diffusers,diffusion_models,embedding,gligen,ip_adapter,karlo,motion_lora,other,photomaker,style_models,svd,t2i_adapter,text_encoder,text_encoders,unet,vae_approx,z123,VAE-approx,ControlNetPreprocessor}; for pair in vae:VAE loras:Lora controlnet:ControlNet upscale_models:ESRGAN checkpoints:Stable-diffusion embeddings:embedding; do src=${pair%:*}; dst=${pair#*:}; for f in /opt/sd-webui-forge/models/$src/*; do [ -e "$f" ] && [ ! -L "/opt/sd-webui-forge/models/$dst/${f##*/}" ] && ln -sf "$f" "/opt/sd-webui-forge/models/$dst/${f##*/}"; done; done'


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
Write-Host "`n🟢 Starting Forge UI..."
docker-compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Error "❌ docker-compose up failed."
    exit 1
}

Write-Host "`n✅ Done!  Forge WebUI is at http://localhost:7860 — it might take a little time to fully deploy the services."