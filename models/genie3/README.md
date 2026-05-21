# genie3

Genie 3 ARM64 Apptainer image, built directly from `genie3.def`.

Genie 3 ([aqlaboratory/genie3](https://github.com/aqlaboratory/genie3)) is a
de novo protein design model that equivariantly diffuses oriented residue
clouds. This image builds the **generation stage** — unconditional generation
and motif scaffolding via `genie3 generate`.

## Scope

This is a **generation-only** image. It deliberately omits the upstream
evaluation stack — ColabFold / AlphaFold / JAX and the bioconda alignment
tools (hhsuite, mmseqs2, kalign2, foldseek):

- That stack drives Genie 3's *own* evaluation; bioconda has little to no
  aarch64 coverage, so a native ARM build of it is not reliable.
- The generation workflow imports none of those packages (verified against
  upstream `main`).
- In a staged benchmark, structure prediction and evaluation run as separate
  steps with their own containers.

If you need Genie 3's built-in evaluation, run it from an x86 environment with
the upstream `scripts/setup/setup.sh` conda environment instead.

## Files

- `genie3.def` — Apptainer definition file (Ubuntu 22.04 + Python 3.10 +
  `torch==2.7.1` cu128 + genie3 from source).
- `test.sh` — smoke test script.

## Weights

Pretrained weights (~0.7 GB) are baked into the image at build time from the
**public** HuggingFace repo [`yeqinglin/genie3`](https://huggingface.co/yeqinglin/genie3)
— no token or repo secret is needed. They land at `/opt/genie3/pretrained`,
matching the layout upstream `download.sh` produces.

## Build via GitHub Actions

Trigger the `Build Apptainer SIF from def` workflow with:

- `model`: `genie3`
- `def_file`: `models/genie3/genie3.def`
- `tag`: `0.1.0-arm64`
- `test_command`: `genie3 --help`
- `push_latest`: `true`

The resulting SIF is pushed to:

```
oras://ghcr.io/ai4pdlab/genie3-sif:0.1.0-arm64
```

## Build locally

```bash
apptainer build genie3_0.1.0-arm64.sif models/genie3/genie3.def
```

## Pull and run on the JUPITER HPC

```bash
apptainer pull genie3_0.1.0-arm64.sif oras://ghcr.io/ai4pdlab/genie3-sif:0.1.0-arm64

# bundled example configs use paths relative to the repo root
apptainer exec --nv genie3_0.1.0-arm64.sif sh -lc \
    'cd $GENIE3_HOME && genie3 generate -c examples/unconditional/experiment.yaml'
```
