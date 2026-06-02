# progen2

ProGen2 ARM64 Apptainer image, built directly from `progen2.def`.

ProGen2 ([salesforce/progen](https://github.com/salesforce/progen)) is an
autoregressive protein language model for sequence generation and likelihood
scoring. This image bakes one ProGen2 checkpoint into the container at build
time from the **public** Google Cloud Storage bucket, so it runs **fully
offline** on compute nodes with no internet (e.g. the JUPITER booster).

## Files

- `progen2.def` — Apptainer definition file (Ubuntu 22.04 + Python 3.10 +
  `torch==2.7.1` cu128 + ProGen2 from source, `transformers==4.16.2` /
  `tokenizers==0.13.3`).

## Weights

The default baked checkpoint is **`progen2-base`** (764M params), downloaded
from the public bucket `sfr-progen-research` — no token or repo secret is
needed. It lands at `/opt/progen/progen2/checkpoints/progen2-base`.

To bake a different checkpoint, edit `PROGEN2_MODEL` in both `%environment` and
`%post` before building:

| Checkpoint       | Params |
|------------------|--------|
| `progen2-small`  | 151M   |
| `progen2-medium` | 764M   |
| `progen2-oas`    | 764M   |
| `progen2-base`   | 764M   |
| `progen2-large`  | 2.7B   |
| `progen2-BFD90`  | 2.7B   |
| `progen2-xlarge` | 6.4B   |

## Build via GitHub Actions

Trigger the `Build Apptainer SIF from def` workflow with:

- `model`: `progen2`
- `def_file`: `models/progen2/progen2.def`
- `tag`: `0.1.0-arm64`
- `test_command`: `python3 -c "from models.progen.modeling_progen import ProGenForCausalLM; print('progen2 image ok')"`
- `push_latest`: `true`

The resulting SIF is pushed to:

```
oras://ghcr.io/ai4pdlab/progen2-sif:0.1.0-arm64
```

## Build locally

```bash
apptainer build progen2_0.1.0-arm64.sif models/progen2/progen2.def
```

## Pull and run on the JUPITER HPC

```bash
apptainer pull progen2_0.1.0-arm64.sif oras://ghcr.io/ai4pdlab/progen2-sif:0.1.0-arm64

# sample sequences (add --nv on GPU nodes)
apptainer run --nv progen2_0.1.0-arm64.sif sample \
    --model progen2-base --t 0.8 --p 0.9 \
    --max-length 256 --num-samples 2 --context "1"

# score log-likelihood
apptainer run --nv progen2_0.1.0-arm64.sif likelihood \
    --model progen2-base --context "1MSEQUENCEHERE2"
```
