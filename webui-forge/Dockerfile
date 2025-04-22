# ------------------------------------------------------------
# Combined Dockerfile for xFormers + WebUI Forge (CUDA 12.8.1)
# Optimized for RTX 50xx (compute capability 12.0)
# ------------------------------------------------------------
    FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04

    ENV DEBIAN_FRONTEND=noninteractive
    ENV PYTHON_VERSION=3.10.12
    ENV TORCH_CUDA_ARCH_LIST="12.0"
    ENV FORCE_CUDA=1
    
    # Install system dependencies
    RUN apt-get update && apt-get install -y \
        build-essential \
        git \
        curl \
        ca-certificates \
        python3-pip \
        python3-dev \
        python3-venv \
        libgl1 \
        libglib2.0-0 \
        ninja-build \
        cmake \
        && rm -rf /var/lib/apt/lists/*
    
    # Upgrade pip and tools
    RUN python3 -m pip install --upgrade pip setuptools wheel
    
    # Install PyTorch nightly with CUDA 12.8 support
    RUN pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128
    
    # Clone xFormers repository with submodules
    RUN git clone --recursive https://github.com/facebookresearch/xformers.git /xformers
    WORKDIR /xformers
    
    # Build xFormers with CUDA support
    RUN MAX_JOBS=4 pip install -v -e .
    
    # Clone WebUI Forge
    RUN git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git /opt/sd-webui-forge
    WORKDIR /opt/sd-webui-forge
    
    # Install WebUI Forge dependencies
    RUN pip install -r requirements_versions.txt
    
    # Expose WebUI port
    EXPOSE 7860
    
    # Launch command with xFormers enabled
    CMD ["python3", "launch.py", "--listen", "--port", "7860", "--enable-insecure-extension-access", "--xformers"]
    