# LigandMPNN (https://github.com/dauparas/LigandMPNN)
# linux/arm64 CPU build. The upstream requirements.txt pins nvidia-*-cu12
# wheels that are not published for aarch64, so we install a CPU PyTorch
# from the PyTorch index and the remaining pure-Python deps explicitly.
FROM --platform=linux/arm64 python:3.11.11-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        git \
        wget \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ARG LIGANDMPNN_COMMIT=26ec57ac976ade5379920dbd43c7f97a91cf82de
WORKDIR /app
RUN git clone https://github.com/dauparas/LigandMPNN.git . \
    && git checkout "${LIGANDMPNN_COMMIT}"

RUN pip install --index-url https://download.pytorch.org/whl/cpu \
        torch==2.2.1

RUN pip install \
        biopython==1.79 \
        filelock==3.13.1 \
        fsspec==2024.3.1 \
        Jinja2==3.1.3 \
        MarkupSafe==2.1.5 \
        mpmath==1.3.0 \
        networkx==3.2.1 \
        numpy==1.23.5 \
        ProDy==2.4.1 \
        pyparsing==3.1.1 \
        scipy==1.12.0 \
        sympy==1.12 \
        typing_extensions==4.10.0 \
        ml-collections==0.1.1 \
        dm-tree==0.1.8

RUN bash get_model_params.sh ./model_params

ENTRYPOINT ["python", "run.py"]
CMD ["--help"]
