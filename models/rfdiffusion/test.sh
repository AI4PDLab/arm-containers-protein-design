#!/usr/bin/env bash
set -euo pipefail

python - <<'PY'
import sys
print("Python:", sys.version)
try:
    import torch, dgl, e3nn, hydra
    print("torch:", torch.__version__)
    print("dgl:", dgl.__version__)
    print("e3nn:", e3nn.__version__)
    import se3_transformer
    print("se3_transformer import OK")
    import rfdiffusion
    print("rfdiffusion import OK")
except Exception as e:
    print("rfdiffusion deps import failed:", e)
    raise
PY

python /app/RFdiffusion/scripts/run_inference.py --help > /dev/null || true
echo "rfdiffusion run_inference.py invoked"
