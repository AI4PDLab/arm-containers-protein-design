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
│   ├── genie3/              # def-only build (generation stage)
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

## Pulling a SIF on an HPC cluster

SIF images are stored as ORAS artifacts in GHCR. Pulling one onto a cluster
(e.g. Jupiter) takes three steps: create a GitHub token, register it once
with Apptainer, then `apptainer pull` from the `oras://` URL.

### 1. Create a GitHub token (PAT)

GHCR packages are **private by default**, so you need a Personal Access Token
to pull them. A **classic** PAT with the single `read:packages` scope is
enough:

1. github.com → top-right avatar → **Settings**
2. Bottom of the left sidebar → **Developer settings**
3. **Personal access tokens** → **Tokens (classic)** → **Generate new token (classic)**
4. Set a **Note** (e.g. `ghcr-pull-hpc`) and an **Expiration**.
5. Under **Scopes**, tick **only `read:packages`** — no `repo` scope is needed
   just to pull.
6. **Generate token** and copy it (`ghp_…`) — GitHub shows it only once.

Your GitHub account must be a member of the `AI4PDLab` org (or the package
must be shared with you / made public) for the token to see the image.

### 2. Register the token on the cluster (one-time)

On a login node, log Apptainer into GHCR. Read the token from a prompt so it
never lands in your shell history:

```bash
module load apptainer            # or: which apptainer

read -rsp "GitHub PAT: " GHCR_TOKEN && echo
echo "$GHCR_TOKEN" | apptainer registry login \
    --username YOUR_GITHUB_USERNAME --password-stdin docker://ghcr.io
unset GHCR_TOKEN
```

This caches the credential under `~/.apptainer/` — you only do it **once per
cluster** (and per account). The same login also covers `oras://ghcr.io`
pulls.

### 3. Pull the SIF from ORAS

```bash
apptainer pull <model>_<tag>.sif oras://ghcr.io/ai4pdlab/<model>-sif:<tag>
```

For example:

```bash
apptainer pull esm3_0.1.0-arm64.sif oras://ghcr.io/ai4pdlab/esm3-sif:0.1.0-arm64
```

Tip: pull into a shared project directory rather than `$HOME` so other users
on the cluster can reuse the same SIF:

```bash
apptainer pull /p/project/<account>/containers/esm3_0.1.0-arm64.sif \
    oras://ghcr.io/ai4pdlab/esm3-sif:0.1.0-arm64
```

### 4. Run it

```bash
apptainer exec esm3_0.1.0-arm64.sif python -c "from esm.models.esm3 import ESM3; print('ok')"
apptainer exec --nv esm3_0.1.0-arm64.sif ...   # add --nv on GPU nodes
```

### Making a package public (skip auth)

If an image is not sensitive, an `AI4PDLab` org owner can make its package
public: the package page → **Package settings** → **Change visibility** →
**Public**. Public packages need no `apptainer registry login` at all — any
node can `apptainer pull` them directly. Note the SIF embeds its build
definition, so keep packages private if that matters.

### Submitting via SLURM

```bash
#!/bin/bash
#SBATCH --job-name=esm3
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=02:00:00

module load apptainer

SIF=/p/project/<account>/containers/esm3_0.1.0-arm64.sif

apptainer exec --nv "$SIF" python -c "from esm.models.esm3 import ESM3; print('ok')"
```

---

## Adding a new model

1. Create `models/<model>/<model>.def` (and optionally a `Dockerfile`).
2. Add a short `README.md` in the same directory.
3. Trigger **Build Apptainer SIF from def** with `def_file=models/<model>/<model>.def`.
4. Once the image is published, add a section to [`registry.md`](./registry.md).
