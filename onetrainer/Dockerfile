FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04
ENV DEBIAN_FRONTEND=noninteractive PYTHONIOENCODING=utf-8

# 1) Install OS deps and Python
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python3.10 python3-pip git ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    python3.10 -m pip install --upgrade pip

# 2) Copy your entire project into the image
WORKDIR /OneTrainer
COPY . /OneTrainer

# 3) Install GPU deps from the repo
RUN pip install --no-cache-dir -r requirements-cuda.txt \
    && pip install --no-cache-dir -r requirements-global.txt

# 4) Expose port and launch UI
EXPOSE 7860
ENTRYPOINT ["python3.10"]
CMD ["scripts/train_ui.py"]
