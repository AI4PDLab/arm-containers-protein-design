#!/usr/bin/env bash
set -euo pipefail

python - <<'PY'
import sys
print("Python:", sys.version)
try:
    import boltz
    print("boltz import OK")
except Exception as e:
    print("boltz import failed:", e)
    raise
PY
