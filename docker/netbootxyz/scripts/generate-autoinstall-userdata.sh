#!/usr/bin/env bash
# Renders user-data.tpl → user-data for dh01 Ubuntu autoinstall.
#
# Usage:
#   ./generate-autoinstall-userdata.sh [path/to/.envrc]
#
# If no argument is given, looks for .envrc in the repo seed dir.
# Copy .envrc.example → .envrc and fill in your values before running.
#
# The rendered user-data is written to ASSETS_DIR (default: /docker/netbootxyz/assets).
# Override: ASSETS_DIR=/custom/path ./generate-autoinstall-userdata.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Repo dir: where the template and .envrc live
REPO_SEED_DIR="${SCRIPT_DIR}/../assets/dh01-autoinstall"
# Assets dir: where netbootxyz nginx serves files from
ASSETS_DIR="${ASSETS_DIR:-/docker/netbootxyz/assets}"
OUT_SEED_DIR="${ASSETS_DIR}/dh01-autoinstall"

ENVRC="${1:-${REPO_SEED_DIR}/.envrc}"
TEMPLATE="${REPO_SEED_DIR}/user-data.tpl"
OUTPUT="${OUT_SEED_DIR}/user-data"

# ---- load .envrc ----
if [[ ! -f "${ENVRC}" ]]; then
  echo "ERROR: .envrc not found at ${ENVRC}" >&2
  echo "  Copy ${REPO_SEED_DIR}/.envrc.example to .envrc and fill in the values." >&2
  exit 1
fi

# shellcheck source=/dev/null
source "${ENVRC}"

# ---- apply defaults for optional vars ----
DH01_HOSTNAME="${DH01_HOSTNAME:-dh01}"
ADMIN_USER="${ADMIN_USER:-ubuntu}"
GITHUB_USER="${GITHUB_USER:-locus313}"
REPO_URL="${REPO_URL:-https://github.com/locus313/homelab-gitops.git}"

# ---- validate required vars ----
missing=()
for var in NAS_IP NAS_MEDIA_EXPORT NAS_SHARED_EXPORT NAS_BACKUPS_EXPORT PASSWORD_HASH; do
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
export NAS_IP NAS_MEDIA_EXPORT NAS_SHARED_EXPORT NAS_BACKUPS_EXPORT
export PASSWORD_HASH DH01_HOSTNAME ADMIN_USER GITHUB_USER REPO_URL

# ---- render template ----
# Only substitute our specific variables — leave ${distro_id}, ${distro_codename}, etc. untouched.
VARS='${NAS_IP}${NAS_MEDIA_EXPORT}${NAS_SHARED_EXPORT}${NAS_BACKUPS_EXPORT}${PASSWORD_HASH}${DH01_HOSTNAME}${ADMIN_USER}${GITHUB_USER}${REPO_URL}'

mkdir -p "${OUT_SEED_DIR}"
envsubst "${VARS}" < "${TEMPLATE}" > "${OUTPUT}"

echo "Generated: ${OUTPUT}"
echo "  DH01_HOSTNAME : ${DH01_HOSTNAME}"
echo "  ADMIN_USER    : ${ADMIN_USER}"
echo "  NAS_IP        : ${NAS_IP}"
echo "  GITHUB_USER   : ${GITHUB_USER}"
echo ""
echo "Serve this file via netbootxyz assets and then boot dh01."
