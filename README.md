# SD-Comfy-Forge

A unified Docker-based environment for running [ComfyUI](https://github.com/comfyanonymous/ComfyUI) and [Stable Diffusion WebUI Forge](https://github.com/lllyasviel/stable-diffusion-webui-forge) with shared models and outputs. Optimized for NVIDIA RTX 50xx GPUs (CUDA 12.8) and includes built-in [xformers](https://github.com/facebookresearch/xformers) support for improved performance.

## Screenshots

### ComfyUI
![ComfyUI Screenshot](content/comfyui-docker-log.png)

### Forge WebUI
![Forge WebUI Screenshot](content/forge-docker-log1.png)
![Forge WebUI Screenshot](content/forge-docker-log2.png)

## Structure

```
sd-comfy-forge/
├── comfyui/                 # ComfyUI container configuration
│   ├── Dockerfile          # CUDA 12.8 + xformers optimized build
│   ├── docker-compose.yml  # Container orchestration
│   └── setup_comfyui_volumes.ps1
├── webui-forge/            # Forge WebUI container configuration
│   ├── Dockerfile         # CUDA 12.8 + xformers optimized build
│   ├── docker-compose.yml
│   └── setup_forge_volumes.ps1
├── filebrowser/           # Web-based file management UI
│   ├── docker-compose.yml
│   └── setup_filebrowser.ps1
├── deploy.ps1            # Interactive deployment menu
├── install_comfyui_manager.ps1
└── update_symlinks.ps1   # Model directory symlink maintenance
```

## Features

- **Isolated Containers**: ComfyUI and Forge WebUI run in separate containers
- **Shared Resources**: Docker volumes for models and outputs
- **Optimized Performance**: CUDA 12.8 builds with xformers acceleration
- **Easy Management**: PowerShell scripts for setup and deployment
- **File Management**: Built-in web file browser for models and outputs
- **Model Organization**: Automatic symlink management for model compatibility
- **ComfyUI Manager**: Optional node/model manager installation support

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) with NVIDIA Container Toolkit
- PowerShell (Windows PowerShell or PowerShell Core)
- NVIDIA RTX 40xx/50xx GPU (or other GPU compatible with CUDA 12.8)

## Quick Start

1. **Clone the Repository**:
   ```powershell
   git clone https://github.com/yourusername/sd-comfy-forge.git
   cd sd-comfy-forge
   ```

2. **Start Desired UI(s)**:

   Run the deployment menu:
   ```powershell
   .\deploy.ps1
   ```
   
   Choose options to start/stop:
   - ComfyUI (Options 1-2)
   - Forge WebUI (Options 3-4) 
   - File Browser (Options 5-6)

3. **Access the UIs**:
   - ComfyUI: [http://localhost:8188](http://localhost:8188)
   - Forge WebUI: [http://localhost:7860](http://localhost:7860)
   - File Browser: [http://localhost:8080/filebrowser](http://localhost:8080/filebrowser)

## Managing Models and Outputs

### Shared Volumes

- `sd-shared-models`: Central storage for all model files
- `sd-shared-output`: Generated images and outputs
- `sd-comfyui` / `sd-forge`: UI-specific code and configs

### File Browser

The included web-based file browser provides easy access to manage your models and outputs:

1. Start File Browser using `deploy.ps1` (Option 5)
2. Access at [http://localhost:8080/filebrowser](http://localhost:8080/filebrowser)
3. Default credentials: username `admin` / password `admin`

### Model Directory Structure

Both UIs maintain compatible model directory structures through automatic symlinks:

```
models/
├── checkpoints/        # Main model files (.safetensors, .ckpt)
├── vae/               # VAE models
├── loras/            # LoRA adapters
├── controlnet/       # ControlNet models
├── upscale_models/   # Upscalers (ESRGAN, etc.)
└── embeddings/       # Textual Inversion embeddings
```

## Additional Tools

### ComfyUI Manager

Install the optional ComfyUI Manager for easy node/model management:

```powershell
.\install_comfyui_manager.ps1
```

### Symlink Maintenance

If model directories get out of sync, update symlinks with:

```powershell
.\update_symlinks.ps1
```

## License

This project provides Docker orchestration and setup scripts under the MIT License. The bundled UIs ([ComfyUI](https://github.com/comfyanonymous/ComfyUI) and [Forge WebUI](https://github.com/lllyasviel/stable-diffusion-webui-forge)) are under their respective upstream licenses.