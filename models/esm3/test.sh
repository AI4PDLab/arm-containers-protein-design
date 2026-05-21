#!/usr/bin/env bash
set -euo pipefail

# Smoke test for the ESM3 ARM64 SIF. Verifies torch is CUDA-linked, esm
# imports, and the esm3-open checkpoint loads from the baked offline cache.
python - <<'PY'
import sys
print("Python:", sys.version)

import torch
print("torch:", torch.__version__, "cuda:", torch.version.cuda)
assert torch.version.cuda is not None, "torch is CPU-only — rebuild on aarch64"

from esm.models.esm3 import ESM3
print("esm.models.esm3 import OK")

# Loads from the HF cache baked in at build time (HF_HUB_OFFLINE=1).
ESM3.from_pretrained("esm3-open")
print("esm3-open loaded OK from baked offline cache")
PY
