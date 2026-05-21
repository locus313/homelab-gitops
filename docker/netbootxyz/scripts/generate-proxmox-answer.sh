#!/usr/bin/env bash
# Renders answer.toml.tpl → answer.toml for dh01 Proxmox VE unattended install.
#
# Usage:
#   ./generate-proxmox-answer.sh [path/to/.envrc]
#
# If no argument is given, looks for .envrc in the repo seed dir.
# Copy .envrc.example → .envrc and fill in your values before running.
#
# The rendered answer.toml is written to ASSETS_DIR (default: /docker/netbootxyz/assets).
# Override: ASSETS_DIR=/custom/path ./generate-proxmox-answer.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_SEED_DIR="${SCRIPT_DIR}/../assets/pve01-proxmox"
ASSETS_DIR="${ASSETS_DIR:-/docker/netbootxyz/assets}"
OUT_DIR="${ASSETS_DIR}/pve01-proxmox"

ENVRC="${1:-${REPO_SEED_DIR}/.envrc}"
TEMPLATE="${REPO_SEED_DIR}/answer.toml.tpl"
OUTPUT="${OUT_DIR}/answer.toml"

# ---- load .envrc ----
if [[ ! -f "${ENVRC}" ]]; then
    echo "ERROR: .envrc not found at ${ENVRC}" >&2
    echo "  Copy ${REPO_SEED_DIR}/.envrc.example to .envrc and fill in the values." >&2
    exit 1
fi

# shellcheck source=/dev/null
source "${ENVRC}"

# ---- apply defaults for optional vars ----
TZ="${TZ:-America/Los_Angeles}"
PROXMOX_DISK="${PROXMOX_DISK:-sda}"

# ---- validate required vars ----
missing=()
for var in PVE01_FQDN PROXMOX_ROOT_PASSWORD_HASH; do
    if [[ -z "${!var:-}" ]]; then
        missing+=("${var}")
    fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
    echo "ERROR: the following required variables are not set in ${ENVRC}:" >&2
    for v in "${missing[@]}"; do echo "  - ${v}" >&2; done
    exit 1
fi

# ---- export all vars so envsubst can see them ----
export PVE01_FQDN TZ PROXMOX_ROOT_PASSWORD_HASH PROXMOX_DISK

# ---- render template ----
mkdir -p "${OUT_DIR}"
envsubst < "${TEMPLATE}" > "${OUTPUT}"

# ---- fix ownership for netbootxyz nginx ----
NBXYZ_UID="$(docker exec netbootxyz id -u nbxyz 2>/dev/null || echo 1000)"
NBXYZ_GID="$(docker exec netbootxyz id -g nbxyz 2>/dev/null || echo 1000)"
chown "${NBXYZ_UID}:${NBXYZ_GID}" "${OUTPUT}"
chmod a+r "${OUTPUT}"

echo "==> answer.toml written to ${OUTPUT}"
echo
echo "Verify HTTP serving (from any host on the LAN):"
echo "  curl http://<NETBOOTXYZ_HOST>:8080/pve01-proxmox/answer.toml"
