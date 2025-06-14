# -------------------------------------------------------------------
# Combined Dockerfile for xFormers + ComfyUI (CUDA 12.8.1)
# Optimized for RTX 50xx (compute capability 12.0)
# -------------------------------------------------------------------
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
    RUN pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128

    # Clone xFormers repository with submodules
    RUN git clone --recursive https://github.com/facebookresearch/xformers.git /xformers
    WORKDIR /xformers
    
    # Build xFormers with CUDA support
    RUN MAX_JOBS=4 pip install -v -e .

# Optional: Build xFormers as a wheel instead of installing in editable mode.
# To do this, replace the previous RUN MAX_JOBS=4 pip install -v -e . command with:
# RUN pip install build && \
#     python3 -m build --wheel && \
#     mkdir -p /wheels && \
#     cp dist/*.whl /wheels/


    # clone ComfyUI into the image (for installing dependencies)
    RUN git clone https://github.com/comfyanonymous/ComfyUI.git /opt/ComfyUI
    WORKDIR /opt/ComfyUI

    # install Python deps: torch nightly + all the rest (skip torchvision/torchaudio)
    RUN pip install --upgrade pip && \
        pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128 && \
        grep -vE 'torchvision|torchaudio' requirements.txt > reqs.tmp && \
        pip install -r reqs.tmp && \
        rm reqs.tmp

    CMD ["python3", "main.py", "--listen", "0.0.0.0"]

    EXPOSE 8188
