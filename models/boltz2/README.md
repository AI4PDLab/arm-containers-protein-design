# boltz2

Boltz2 ARM64 Apptainer image, built directly from `boltz2.def`.

## Files

- `boltz2.def` — Apptainer definition file (Ubuntu 24.04 + `boltz` from PyPI).
- `Dockerfile` — alternative Docker-based build.
- `test.sh` — smoke test script.

## Build locally

```bash
sudo apptainer build boltz2_dev-arm64.sif models/boltz2/boltz2.def
```

## Build via GitHub Actions

Trigger the `Build Apptainer SIF from def` workflow with:

- `model`: `boltz2`
- `def_file`: `models/boltz2/boltz2.def`
- `tag`: `dev-arm64`

The resulting SIF is pushed to:

```
oras://ghcr.io/<owner>/boltz2-sif:dev-arm64
```

## Pull on HPC

```bash
apptainer pull boltz2_dev-arm64.sif oras://ghcr.io/<owner>/boltz2-sif:dev-arm64
```

