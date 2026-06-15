#!/usr/bin/env bash
set -euo pipefail

# Smoke test for the Genie 2 ARM64 SIF. Verifies torch is CUDA-linked, the
# genie package + the sample_scaffold.py entry script import/resolve, and the
# pretrained checkpoint is baked in at the path the loader expects.
python - <<'PY'
import sys
print("Python:", sys.version)

import torch
print("torch:", torch.__version__, "cuda:", torch.version.cuda)
assert torch.version.cuda is not None, "torch is CPU-only — rebuild on aarch64"

import importlib
importlib.import_module("genie")
print("genie import OK")

import os
home = os.environ.get("GENIE2_HOME", "/opt/genie2")
assert os.path.isfile(os.path.join(home, "genie", "sample_scaffold.py")), \
    "genie/sample_scaffold.py missing"
print("sample_scaffold.py present")

ckpt = os.environ.get(
    "GENIE2_CHECKPOINT",
    os.path.join(home, "results", "base", "checkpoints", "epoch=30.ckpt"),
)
assert os.path.isfile(ckpt) and os.path.getsize(ckpt) > 0, \
    "pretrained checkpoint missing: {}".format(ckpt)
print("checkpoint present:", ckpt, "({} MB)".format(os.path.getsize(ckpt) >> 20))

cfg = os.path.join(home, "results", "base", "configuration")
assert os.path.isfile(cfg), "model configuration missing: {}".format(cfg)
print("configuration present:", cfg)
PY

cd "${GENIE2_HOME:-/opt/genie2}"
python genie/sample_scaffold.py --help >/dev/null && echo "sample_scaffold.py CLI OK"
