#!/usr/bin/env bash
set -euo pipefail

# Smoke test for the Genie 3 ARM64 SIF. Verifies torch is CUDA-linked, the
# genie3 package + CLI import, and the pretrained weights are baked in.
python - <<'PY'
import sys
print("Python:", sys.version)

import torch
print("torch:", torch.__version__, "cuda:", torch.version.cuda)
assert torch.version.cuda is not None, "torch is CPU-only — rebuild on aarch64"

import genie3
print("genie3 import OK")

import os
p = os.path.join(os.environ.get("GENIE3_HOME", "/opt/genie3"), "pretrained")
assert os.path.isdir(p) and os.listdir(p), "pretrained weights missing"
print("pretrained weights present:", sorted(os.listdir(p)))
PY

genie3 --help >/dev/null && echo "genie3 CLI OK"
