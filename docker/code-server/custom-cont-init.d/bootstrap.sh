#!/bin/bash

# ============================================================================
# Bootstrap script for the code-server container.
# Downloads and runs the latest install-additional-tools.sh from GitHub.
# Only this file needs to be present on the host - the real script is
# fetched from the repository on every container start.
# ============================================================================

set -euo pipefail

GITHUB_RAW="https://raw.githubusercontent.com/locus313/homelab-gitops/main"
SCRIPT_PATH="docker/code-server/custom-cont-init.d/install-additional-tools.sh"

echo "**** Fetching install-additional-tools.sh from GitHub ****"
curl -fsSL "${GITHUB_RAW}/${SCRIPT_PATH}" | bash
