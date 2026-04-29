#!/usr/bin/env bash
set -euo pipefail

python - <<'PY'
import sys
print("Python:", sys.version)
try:
    import torch, prody, numpy
    print("torch:", torch.__version__)
    print("prody:", prody.__version__)
    print("numpy:", numpy.__version__)
    print("ligandmpnn deps import OK")
except Exception as e:
    print("ligandmpnn deps import failed:", e)
    raise
PY

# Smoke-test that run.py is reachable and prints help.
python /app/run.py --help > /dev/null
echo "ligandmpnn run.py --help OK"
