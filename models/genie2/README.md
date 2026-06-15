# genie2

Genie 2 ARM64 Apptainer image, built directly from `genie2.def`.

Genie 2 ([aqlaboratory/genie2](https://github.com/aqlaboratory/genie2)) is an
SE(3)-equivariant diffusion model for de novo protein backbone design and
multi-motif scaffolding. This image builds the **generation stage** only —
`genie/sample_scaffold.py` — which is what the Stroma benchmark drives
(REMARK-999-annotated PDB in → scaffold backbones out).

## Scope

This is a **generation-only** image. It deliberately omits Genie 2's own
evaluation stack (ColabFold / TM-score tooling and the bioconda alignment
tools):

- bioconda has poor aarch64 coverage and a native ARM build of that stack is
  not reliable.
- In a staged benchmark, structure prediction and evaluation run as separate
  steps with their own containers, so Genie 2 only needs to emit backbones
  here.

If you need Genie 2's built-in evaluation, run it from an x86 environment using
the upstream [insilico_design_pipeline](https://github.com/aqlaboratory/insilico_design_pipeline)
instead.

## Files

- `genie2.def` — Apptainer definition file (Ubuntu 22.04 + Python 3.10 +
  `torch==2.7.1` cu128 + genie2 from source).
- `test.sh` — smoke test script.

## aarch64 + CUDA notes

The CUDA-linked aarch64 wheel (`torch-2.7.1+cu128-cp310-...-aarch64`) is
installed **first** from the cu128 index, then torch is stripped from Genie 2's
pins before `pip install -e .` so the good wheel is never downgraded to a
CPU-only PyPI wheel. A build-time smoke check asserts `torch.version.cuda` is
not `None`, so a CPU-only mismatch fails the build instead of silently running
on CPU on the cluster. The cu128 wheels bundle the CUDA + cuDNN userspace, so a
plain Ubuntu base + `--nv` at runtime is enough.

## Weights

The pretrained checkpoint (~0.19 GB) is baked into the image at build time from
the **public** GitHub [v1.0.0 release](https://github.com/aqlaboratory/genie2/releases/tag/v1.0.0)
— no token is needed. The release asset is named `epoch.30.ckpt`; the loader
(`genie/utils/model_io.py::load_pretrained_model`) globs for
`epoch=<epoch>.ckpt`, so it is saved as:

```
/opt/genie2/results/base/checkpoints/epoch=30.ckpt
```

This is the 30-epoch checkpoint used for motif scaffolding in the manuscript.
The matching `configuration` ships in the cloned repo at
`/opt/genie2/results/base/configuration`.

## Build via GitHub Actions

Trigger the `Build Apptainer SIF from def` workflow with:

- `model`: `genie2`
- `def_file`: `models/genie2/genie2.def`
- `tag`: `0.1.0-arm64`
- `test_command`: `python -c "import genie"`
- `push_latest`: `true`

The resulting SIF is pushed to:

```
oras://ghcr.io/ai4pdlab/genie2-sif:0.1.0-arm64
```

## Build locally

```bash
apptainer build genie2_0.1.0-arm64.sif models/genie2/genie2.def
```

## Run on the JUPITER HPC

Genie 2 is invoked as `python genie/sample_scaffold.py` with a **relative**
script path, so the container working directory must be the repo root
(`/opt/genie2`). Pass `--pwd /opt/genie2` on the exec:

```bash
apptainer pull genie2_0.1.0-arm64.sif oras://ghcr.io/ai4pdlab/genie2-sif:0.1.0-arm64

apptainer exec --nv --pwd /opt/genie2 \
    --bind <datadir>:/data:ro --bind <outdir>:/out genie2_0.1.0-arm64.sif \
    python genie/sample_scaffold.py --name base --epoch 30 \
        --scale 0.4 --strength 0 --rootdir /opt/genie2/results \
        --outdir /out --datadir /data --motif_name MB-1 \
        --num_samples 10 --batch_size 4 --num_devices 1
```

Or via the runscript, which `cd`s into the repo for you:

```bash
apptainer run --nv genie2_0.1.0-arm64.sif genie/sample_scaffold.py --name base --epoch 30 ...
```
