# Boltz-2 (https://github.com/jwohlwend/boltz)
# CPU build for linux/arm64. The [cuda] extra pulls cuEquivariance kernels
# which are x86-only; on aarch64 we install the plain CPU package.
FROM --platform=linux/arm64 python:3.11.11-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# PyTorch aarch64 CPU wheels live on the default index.
RUN pip install --index-url https://download.pytorch.org/whl/cpu \
        torch==2.4.1 torchvision

RUN pip install boltz==2.2.1

WORKDIR /work
ENTRYPOINT ["boltz"]
CMD ["--help"]
