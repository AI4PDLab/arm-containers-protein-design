# Protein DL container registry

All containers are built for ARM64 / aarch64 HPC nodes.

Org: <https://github.com/AI4PDLab/arm-containers-protein-design>

Images live under `ghcr.io/ai4pdlab/<model>` (Docker/OCI) and
`ghcr.io/ai4pdlab/<model>-sif` (Apptainer SIF via ORAS). The version tag
below (`0.1.0-arm64`) is an example — replace with the tag you want.

## Boltz2

Docker/OCI image:

```bash
docker pull ghcr.io/ai4pdlab/boltz2:0.1.0-arm64
docker run --rm ghcr.io/ai4pdlab/boltz2:0.1.0-arm64 --help
```

Apptainer SIF:

```bash
apptainer pull boltz2_0.1.0-arm64.sif oras://ghcr.io/ai4pdlab/boltz2-sif:0.1.0-arm64
apptainer exec boltz2_0.1.0-arm64.sif boltz --help
```

## LigandMPNN

Docker/OCI image:

```bash
docker pull ghcr.io/ai4pdlab/ligandmpnn:0.1.0-arm64
docker run --rm ghcr.io/ai4pdlab/ligandmpnn:0.1.0-arm64 --help
```

Apptainer SIF:

```bash
apptainer pull ligandmpnn_0.1.0-arm64.sif oras://ghcr.io/ai4pdlab/ligandmpnn-sif:0.1.0-arm64
apptainer exec ligandmpnn_0.1.0-arm64.sif python /app/run.py --help
```

## RFdiffusion

Docker/OCI image:

```bash
docker pull ghcr.io/ai4pdlab/rfdiffusion:0.1.0-arm64
docker run --rm ghcr.io/ai4pdlab/rfdiffusion:0.1.0-arm64 --help
```

Apptainer SIF:

```bash
apptainer pull rfdiffusion_0.1.0-arm64.sif oras://ghcr.io/ai4pdlab/rfdiffusion-sif:0.1.0-arm64
apptainer exec rfdiffusion_0.1.0-arm64.sif python /app/RFdiffusion/scripts/run_inference.py --help
```

## ProteinMPNN

Docker/OCI image:

```bash
docker pull ghcr.io/ai4pdlab/proteinmpnn:0.1.0-arm64
docker run --rm ghcr.io/ai4pdlab/proteinmpnn:0.1.0-arm64 --help
```

Apptainer SIF:

```bash
apptainer pull proteinmpnn_0.1.0-arm64.sif oras://ghcr.io/ai4pdlab/proteinmpnn-sif:0.1.0-arm64
apptainer exec proteinmpnn_0.1.0-arm64.sif python /app/protein_mpnn_run.py --help
```

## Authenticating to GHCR

GHCR packages may require a token even when public the first time. Use a
GitHub PAT with `read:packages`:

```bash
echo "$GITHUB_TOKEN" | docker login ghcr.io -u <github-user> --password-stdin
echo "$GITHUB_TOKEN" | apptainer registry login --username <github-user> --password-stdin docker://ghcr.io
```
