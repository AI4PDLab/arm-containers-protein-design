# RFdiffusion (https://github.com/RosettaCommons/RFdiffusion)
# linux/arm64 build. Upstream Dockerfile targets x86 + CUDA 11.6 with
# DGL cu116 wheels that are not published for aarch64, so on ARM we
# build a CPU stack: CPU PyTorch + CPU DGL + SE3-Transformer compiled
# from the vendored source under env/SE3Transformer.
FROM --platform=linux/arm64 python:3.9.21-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DGLBACKEND=pytorch

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        wget \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ARG RFDIFFUSION_COMMIT=2d0c003df46b9db41d119321f15403dec3716cd9
WORKDIR /app
RUN git clone https://github.com/RosettaCommons/RFdiffusion.git RFdiffusion \
    && git -C RFdiffusion checkout "${RFDIFFUSION_COMMIT}"

# CPU PyTorch wheels for aarch64.
RUN pip install --index-url https://download.pytorch.org/whl/cpu \
        torch==1.12.1

# DGL has no aarch64 GPU wheels; install the CPU build from the dgl index.
RUN pip install dgl==1.1.3 -f https://data.dgl.ai/wheels/repo.html

RUN pip install \
        e3nn==0.3.3 \
        wandb==0.12.0 \
        pynvml==11.0.0 \
        decorator==5.1.0 \
        hydra-core==1.3.2 \
        pyrsistent==0.19.3 \
        git+https://github.com/NVIDIA/dllogger@0478734ff7be75adde8d160e04872664d1c62e5f#egg=dllogger

RUN pip install /app/RFdiffusion/env/SE3Transformer \
    && pip install --no-deps /app/RFdiffusion

WORKDIR /app/RFdiffusion

# Model weights (mirrors the upstream download list).
RUN mkdir -p models && cd models && \
    for f in Base_ckpt.pt Complex_base_ckpt.pt Complex_Fold_base_ckpt.pt \
             InpaintSeq_ckpt.pt InpaintSeq_Fold_ckpt.pt ActiveSite_ckpt.pt \
             Base_epoch8_ckpt.pt Complex_beta_ckpt.pt; do \
        wget -q "http://files.ipd.uw.edu/pub/RFdiffusion/$f"; \
    done

ENTRYPOINT ["python", "scripts/run_inference.py"]
CMD ["--help"]
