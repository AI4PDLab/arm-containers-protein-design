# esm3

ESM3 ARM64 Apptainer image, built directly from `esm3.def`.

ESM3 (EvolutionaryScale) is a multimodal protein language model. This image
bakes the gated **esm3-open** small checkpoint (~1.4B params) into the
HuggingFace cache at build time, so the container runs **fully offline** on
compute nodes with no internet (e.g. the JUPITER booster).

## Files

- `esm3.def` — Apptainer definition file (CUDA 12.1 runtime base + `esm` 3.2.1).
- `test.sh` — smoke test script.

## Requirements

ESM3 weights are **gated** on HuggingFace. The build needs a HuggingFace token:

1. Accept the license at <https://huggingface.co/EvolutionaryScale/esm3-sm-open-v1>.
2. Add the token as a repository secret named **`HF_TOKEN_ESM3`**
   (Settings → Secrets and variables → Actions → New repository secret).

The `Build Apptainer SIF from def` workflow detects that `esm3.def` references
`HF_TOKEN` and passes the `HF_TOKEN_ESM3` secret to `apptainer build` as the
`HF_TOKEN` build-arg automatically. The token is used only at build time and
is scrubbed from the image before it is finalised.

## Build via GitHub Actions

Trigger the `Build Apptainer SIF from def` workflow with:

- `model`: `esm3`
- `def_file`: `models/esm3/esm3.def`
- `tag`: `0.1.0-arm64`
- `test_command`: `python -c "from esm.models.esm3 import ESM3; ESM3.from_pretrained('esm3-open'); print('esm3-open OK')"`
- `push_latest`: `true`

The resulting SIF is pushed to:

```
oras://ghcr.io/ai4pdlab/esm3-sif:0.1.0-arm64
```

## Build locally

```bash
export HF_TOKEN=hf_xxx
apptainer build --build-arg HF_TOKEN="$HF_TOKEN" \
    esm3_0.1.0-arm64.sif models/esm3/esm3.def
```

## Pull on the JUPITER HPC

```bash
apptainer pull esm3_0.1.0-arm64.sif oras://ghcr.io/ai4pdlab/esm3-sif:0.1.0-arm64
apptainer exec --nv esm3_0.1.0-arm64.sif python -c \
    "from esm.models.esm3 import ESM3; print('esm3 image ok')"
```
