# ProteinMPNN (https://github.com/dauparas/ProteinMPNN)
# linux/arm64 CPU build. Pure Python + PyTorch; no native deps.
FROM --platform=linux/arm64 python:3.11.11-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ARG PROTEINMPNN_COMMIT=8907e6671bfbfc92303b5f79c4b5e6ce47cdef57
WORKDIR /app
RUN git clone https://github.com/dauparas/ProteinMPNN.git . \
    && git checkout "${PROTEINMPNN_COMMIT}"

RUN pip install --index-url https://download.pytorch.org/whl/cpu \
        torch==2.2.1

RUN pip install numpy==1.26.4

ENTRYPOINT ["python", "protein_mpnn_run.py"]
CMD ["--help"]
