#!/usr/bin/env bash
set -euo pipefail

python - <<'PY'
import sys
print("Python:", sys.version)
try:
    import torch, numpy
    print("torch:", torch.__version__)
    print("numpy:", numpy.__version__)
    print("proteinmpnn deps import OK")
except Exception as e:
    print("proteinmpnn deps import failed:", e)
    raise
PY

python /app/protein_mpnn_run.py --help > /dev/null
echo "proteinmpnn protein_mpnn_run.py --help OK"
