# arm-containers-protein-design

Apptainer / Docker images of common protein design and structure prediction
tools, built for **ARM64 / aarch64 HPC nodes** (e.g. the Jupiter cluster).

Images are built in GitHub Actions and published to the GitHub Container
Registry under [`AI4PDLab`](https://github.com/AI4PDLab/arm-containers-protein-design):

- Docker/OCI: `ghcr.io/ai4pdlab/<model>:<tag>`
- Apptainer SIF (via ORAS): `ghcr.io/ai4pdlab/<model>-sif:<tag>`

See [`registry.md`](./registry.md) for the full list of available models and
pull commands.

---

## Repository layout

```
arm-containers-protein-design/
├── models/
│   ├── boltz2/
│   │   ├── boltz2.def       # Apptainer definition file
│   │   ├── Dockerfile
│   │   └── README.md
│   ├── esm3/                # def-only build; needs the HF_TOKEN_ESM3 secret
│   ├── ligandmpnn/
│   ├── proteinmpnn/
│   └── rfdiffusion/
└── .github/
    └── workflows/
        ├── build-model.yml           # Docker-based build
        └── build-sif-from-def.yml    # Apptainer SIF from .def
```

---

## Building a SIF from a `.def` file via GitHub Actions

The `Build Apptainer SIF from def` workflow takes an Apptainer definition
file from this repo, builds it on an ARM64 runner, and pushes the resulting
`.sif` to GHCR with ORAS.

### 1. Trigger the workflow

1. Open the repo on GitHub → **Actions** tab.
2. Select **Build Apptainer SIF from def** in the left sidebar.
3. Click **Run workflow** (top right) and fill in the inputs:

   | Input          | Example                       | Notes                                        |
   |----------------|-------------------------------|----------------------------------------------|
   | `model`        | `boltz2`                      | Lowercased to form the image name.           |
   | `def_file`     | `models/boltz2/boltz2.def`    | Path inside the repo.                        |
   | `tag`          | `dev-arm64`                   | Becomes the image tag.                       |
   | `test_command` | `python3 --version`           | Smoke test run inside the built SIF.         |
   | `push_latest`  | `false`                       | If `true`, also pushes `:latest-arm64`.      |

4. Click **Run workflow**. The build runs on `ubuntu-24.04-arm` (timeout 4 h).

### 2. Result

On success the SIF is published to:

```
oras://ghcr.io/ai4pdlab/<model>-sif:<tag>
```

For the defaults above:

```
oras://ghcr.io/ai4pdlab/boltz2-sif:dev-arm64
```

The final workflow step prints the exact `apptainer pull` command for the
image you just built.

---

## Pulling the SIF on the Jupiter HPC

On a Jupiter login or compute node:

```bash
# 1. Make sure apptainer is available
module load apptainer    # or: which apptainer

# 2. (First time only) authenticate to GHCR with a GitHub PAT that has read:packages
echo "$GITHUB_TOKEN" | apptainer registry login \
    --username <github-user> --password-stdin docker://ghcr.io

# 3. Pull the SIF you just built
apptainer pull boltz2_dev-arm64.sif \
    oras://ghcr.io/ai4pdlab/boltz2-sif:dev-arm64

# 4. Run it
apptainer exec boltz2_dev-arm64.sif python3 --version
apptainer exec --nv boltz2_dev-arm64.sif boltz --help   # add --nv on GPU nodes
```

Tip: pull into a shared project directory (e.g. `/data/<project>/containers/`)
rather than `$HOME` so other users on Jupiter can reuse the same SIF.

### Submitting via SLURM

```bash
#!/bin/bash
#SBATCH --job-name=boltz2
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=02:00:00

module load apptainer

SIF=/data/<project>/containers/boltz2_dev-arm64.sif

apptainer exec --nv "$SIF" boltz predict --help
```

---

## Adding a new model

1. Create `models/<model>/<model>.def` (and optionally a `Dockerfile`).
2. Add a short `README.md` in the same directory.
3. Trigger **Build Apptainer SIF from def** with `def_file=models/<model>/<model>.def`.
4. Once the image is published, add a section to [`registry.md`](./registry.md).
