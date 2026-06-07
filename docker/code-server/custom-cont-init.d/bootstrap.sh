#!/bin/bash

# ============================================================================
# Bootstrap script for the code-server container.
# Pulls the latest homelab-gitops repo and runs install-additional-tools.sh
# from the local clone — no remote curl|bash required.
#
# Only this file needs to be present on the Docker host at:
#   /mnt/docker/code-server/custom-cont-init.d/bootstrap.sh
#
# Prerequisites on the Docker host (one-time setup):
#   git clone https://github.com/locus313/homelab-gitops.git /opt/homelab-gitops
#
# /opt/homelab-gitops must be mounted into the container (see docker-compose.yml).
#
# On every container start this script:
#   1. Runs git pull --ff-only to pick up any changes pushed to GitHub
#   2. Executes install-additional-tools.sh from the local clone
# ============================================================================

set -euo pipefail

REPO_DIR="${HOMELAB_REPO_DIR:-/opt/homelab-gitops}"
SCRIPT_REL="docker/code-server/custom-cont-init.d/install-additional-tools.sh"
SCRIPT="${REPO_DIR}/${SCRIPT_REL}"

if [[ ! -d "${REPO_DIR}/.git" ]]; then
    echo "ERROR: homelab-gitops repo not found at ${REPO_DIR}" >&2
    echo "  On the Docker host, run:" >&2
    echo "    git clone https://github.com/locus313/homelab-gitops.git ${REPO_DIR}" >&2
    exit 1
fi

echo "**** Pulling latest homelab-gitops ****"
# -c safe.directory bypasses git's ownership check (repo may be owned by root
# from cloud-init while this script runs under a different container UID).
if ! git -C "${REPO_DIR}" -c safe.directory="${REPO_DIR}" pull --ff-only --quiet 2>&1; then
    echo "WARNING: git pull failed — using existing local version" >&2
fi

if [[ ! -f "${SCRIPT}" ]]; then
    echo "ERROR: install-additional-tools.sh not found at ${SCRIPT}" >&2
    exit 1
fi

echo "**** Running install-additional-tools.sh from local repo ****"
bash "${SCRIPT}"
