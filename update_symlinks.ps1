# update_symlinks.ps1
# Updates symlinks for both ComfyUI and Forge WebUI model directories

Write-Host "`n🔄 Updating symlinks for ComfyUI..."
docker run --rm `
  -v sd-comfyui:/opt/ComfyUI `
  -v sd-shared-models:/opt/ComfyUI/models `
  python:3.10-slim `
  bash -c 'set -e; for d in VAE Lora ControlNet ESRGAN Stable-diffusion embedding; do [ -d "/opt/ComfyUI/models/$d" ] && find "/opt/ComfyUI/models/$d" -type l -delete 2>/dev/null; done; mkdir -p /opt/ComfyUI/models/{checkpoints,vae,loras,controlnet,upscale_models,embeddings,VAE,Lora,ControlNet,ESRGAN,Stable-diffusion,embedding,clip,text_encoder,diffusion_models,unet}; for pair in vae:VAE loras:Lora controlnet:ControlNet upscale_models:ESRGAN checkpoints:Stable-diffusion embeddings:embedding; do src=${pair%:*}; dst=${pair#*:}; for f in /opt/ComfyUI/models/$src/*; do [ -e "$f" ] && [ ! -L "/opt/ComfyUI/models/$dst/${f##*/}" ] && ln -sf "$f" "/opt/ComfyUI/models/$dst/${f##*/}"; done; done; for f in /opt/ComfyUI/models/text_encoder/*; do [ -e "$f" ] && [ ! -L "/opt/ComfyUI/models/clip/${f##*/}" ] && ln -sf "$f" "/opt/ComfyUI/models/clip/${f##*/}"; done; for f in /opt/ComfyUI/models/checkpoints/*; do [ -e "$f" ] && [ ! -L "/opt/ComfyUI/models/diffusion_models/${f##*/}" ] && ln -sf "$f" "/opt/ComfyUI/models/diffusion_models/${f##*/}"; done; for f in /opt/ComfyUI/models/checkpoints/*.gguf; do [ -e "$f" ] && [ ! -L "/opt/ComfyUI/models/unet/${f##*/}" ] && ln -sf "$f" "/opt/ComfyUI/models/unet/${f##*/}"; done'

Write-Host "`n🔄 Updating symlinks for Forge WebUI..."
docker run --rm `
  -v sd-forge:/opt/sd-webui-forge `
  -v sd-shared-models:/opt/sd-webui-forge/models `
  python:3.10-slim `
  bash -c 'set -e; for d in VAE Lora ControlNet ESRGAN Stable-diffusion embeddings embedding; do [ -d "/opt/sd-webui-forge/models/$d" ] && find "/opt/sd-webui-forge/models/$d" -type l -delete 2>/dev/null; done; mkdir -p /opt/sd-webui-forge/models/{VAE,Lora,ControlNet,ESRGAN,Stable-diffusion,BLIP,Codeformer,GFPGAN,RealESRGAN,hypernetworks,embeddings,vae,loras,controlnet,upscale_models,checkpoints,clip,clip_vision,configs,consistency_models,diffusers,diffusion_models,embedding,gligen,ip_adapter,karlo,motion_lora,other,photomaker,style_models,svd,t2i_adapter,text_encoder,text_encoders,unet,vae_approx,z123,VAE-approx,ControlNetPreprocessor}; for pair in vae:VAE loras:Lora controlnet:ControlNet upscale_models:ESRGAN checkpoints:Stable-diffusion embeddings:embedding; do src=${pair%:*}; dst=${pair#*:}; for f in /opt/sd-webui-forge/models/$src/*; do [ -e "$f" ] && [ ! -L "/opt/sd-webui-forge/models/$dst/${f##*/}" ] && ln -sf "$f" "/opt/sd-webui-forge/models/$dst/${f##*/}"; done; done; for f in /opt/sd-webui-forge/models/text_encoder/*; do [ -e "$f" ] && [ ! -L "/opt/sd-webui-forge/models/clip/${f##*/}" ] && ln -sf "$f" "/opt/sd-webui-forge/models/clip/${f##*/}"; done; for f in /opt/sd-webui-forge/models/checkpoints/*; do [ -e "$f" ] && [ ! -L "/opt/sd-webui-forge/models/diffusion_models/${f##*/}" ] && ln -sf "$f" "/opt/sd-webui-forge/models/diffusion_models/${f##*/}"; done; for f in /opt/sd-webui-forge/models/checkpoints/*.gguf; do [ -e "$f" ] && [ ! -L "/opt/sd-webui-forge/models/unet/${f##*/}" ] && ln -sf "$f" "/opt/sd-webui-forge/models/unet/${f##*/}"; done'

Write-Host "`n✅ Symlinks updated for both UIs!"
