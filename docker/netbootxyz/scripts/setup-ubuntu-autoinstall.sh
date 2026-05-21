#!/bin/bash
#
# setup-ubuntu-autoinstall.sh
#
# Downloads the Ubuntu 26.04 Live Server ISO and extracts the kernel and
# initrd needed to PXE-boot the Ubuntu installer with autoinstall, then
# copies the dh01 autoinstall meta-data seed file into the netbootxyz assets
# directory.  user-data is generated separately from a template+envrc —
# run generate-autoinstall-userdata.sh after this script.
#
# Run on the Docker host as root (or with sudo). Requires: curl, sudo,
# mount or 7z.
#
# Usage:
#   sudo ./setup-ubuntu-autoinstall.sh [POINT_RELEASE]
#
# Examples:
#   sudo ./setup-ubuntu-autoinstall.sh        # auto-discover latest 26.04.x
#   sudo ./setup-ubuntu-autoinstall.sh 2      # force 26.04.2
#
# After running, the following assets will be in place:
#   ${ASSETS_DIR}/ubuntu-26.04-server/vmlinuz
#   ${ASSETS_DIR}/ubuntu-26.04-server/initrd
#   ${ASSETS_DIR}/dh01-autoinstall/meta-data   (copied from repo)
#
# Then generate user-data before booting:
#   1. cp docker/netbootxyz/assets/dh01-autoinstall/.envrc.example \
#         docker/netbootxyz/assets/dh01-autoinstall/.envrc
#   2. Edit .envrc — fill in NAS_IP, PASSWORD_HASH, etc.
#   3. sudo ./generate-autoinstall-userdata.sh

set -euo pipefail

POINT="${1:-}"
readonly UBUNTU_MAJOR="26.04"
readonly ARCH="amd64"
readonly ASSETS_DIR="${ASSETS_DIR:-/docker/netbootxyz/assets}"
readonly DEST="${ASSETS_DIR}/ubuntu-${UBUNTU_MAJOR}-server"
readonly SEED_DEST="${ASSETS_DIR}/dh01-autoinstall"

# Repo seed files — adjust REPO_DIR if the clone is in a different location
readonly REPO_DIR="${REPO_DIR:-/opt/homelab-gitops}"
readonly SEED_SRC="${REPO_DIR}/docker/netbootxyz/assets/dh01-autoinstall"

WORK="$(mktemp -d)"
MNT=""

cleanup() {
    [[ -n "${MNT}" ]] && mountpoint -q "${MNT}" && umount "${MNT}" 2>/dev/null || true
    rm -rf "${WORK}"
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Download Ubuntu live server ISO
# ---------------------------------------------------------------------------
readonly BASE_URL="https://releases.ubuntu.com/${UBUNTU_MAJOR}"

if [[ -z "${POINT}" ]]; then
    echo "==> Discovering latest Ubuntu ${UBUNTU_MAJOR} Live Server ISO..."
    LISTING="$(curl -fsSL "${BASE_URL}/")"
    # Point release is optional: matches 26.04-live-server and 26.04.2-live-server
    ISO_NAME="$(echo "${LISTING}" \
        | grep -oE "ubuntu-${UBUNTU_MAJOR//./\\.}(\.[0-9]+)?-live-server-${ARCH}\.iso" \
        | sort -V | tail -1 || true)"
    if [[ -z "${ISO_NAME}" ]]; then
        echo "ERROR: could not find a Ubuntu ${UBUNTU_MAJOR} Live Server ISO at ${BASE_URL}" >&2
        exit 1
    fi
else
    ISO_NAME="ubuntu-${UBUNTU_MAJOR}.${POINT}-live-server-${ARCH}.iso"
fi

readonly ISO_URL="${BASE_URL}/${ISO_NAME}"
readonly ISO_PATH="${WORK}/${ISO_NAME}"

echo "==> Downloading ${ISO_URL}"
curl -fL --progress-bar -o "${ISO_PATH}" "${ISO_URL}"

# ---------------------------------------------------------------------------
# Extract kernel + initrd from the ISO
# ---------------------------------------------------------------------------
mkdir -p "${DEST}"
MNT="${WORK}/mnt"
mkdir -p "${MNT}"

extract() {
    local src="$1"
    if [[ -f "${src}/casper/vmlinuz" && -f "${src}/casper/initrd" ]]; then
        cp -v "${src}/casper/vmlinuz" "${DEST}/vmlinuz"
        cp -v "${src}/casper/initrd"  "${DEST}/initrd"
    else
        echo "ERROR: could not find casper/vmlinuz or casper/initrd in ISO" >&2
        return 1
    fi
}

echo "==> Extracting kernel/initrd from ISO"
if mount -o loop,ro "${ISO_PATH}" "${MNT}" 2>/dev/null; then
    extract "${MNT}"
    umount "${MNT}"
    MNT=""
elif command -v 7z >/dev/null 2>&1; then
    7z x -o"${WORK}/iso" "${ISO_PATH}" \
        'casper/vmlinuz' \
        'casper/initrd' 2>/dev/null || true
    extract "${WORK}/iso"
else
    echo "ERROR: could not mount ISO (not root?) and 7z is not installed" >&2
    echo "  Install 7zip with: apt-get install -y 7zip" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Copy meta-data seed file from the repo (safe to commit; no secrets)
# user-data is generated separately via generate-autoinstall-userdata.sh
# ---------------------------------------------------------------------------
echo "==> Copying meta-data from ${SEED_SRC}"
if [[ ! -d "${SEED_SRC}" ]]; then
    echo "WARNING: repo seed directory not found at ${SEED_SRC}" >&2
    echo "  Clone the repo to /opt/homelab-gitops or set REPO_DIR." >&2
    echo "  Skipping meta-data copy — create ${SEED_DEST}/meta-data manually." >&2
else
    mkdir -p "${SEED_DEST}"
    cp -v "${SEED_SRC}/meta-data" "${SEED_DEST}/meta-data"
fi

# ---------------------------------------------------------------------------
# Fix ownership for the netbootxyz nginx user
# ---------------------------------------------------------------------------
NBXYZ_UID="$(docker exec netbootxyz id -u nbxyz 2>/dev/null || echo 1000)"
NBXYZ_GID="$(docker exec netbootxyz id -g nbxyz 2>/dev/null || echo 1000)"
chown -R "${NBXYZ_UID}:${NBXYZ_GID}" "${DEST}"
chmod -R a+r "${DEST}"

if [[ -d "${SEED_DEST}" ]]; then
    chown -R "${NBXYZ_UID}:${NBXYZ_GID}" "${SEED_DEST}"
    chmod -R a+r "${SEED_DEST}"
fi

echo
echo "==> Done. Installer assets:"
ls -lh "${DEST}"
echo
echo "==> Autoinstall seed files:"
ls -lh "${SEED_DEST}" 2>/dev/null || echo "  (not installed — see warning above)"
echo
echo "Next step — generate user-data before booting:"
echo "  1. cp ${SEED_SRC}/.envrc.example ${SEED_SRC}/.envrc"
echo "  2. Edit ${SEED_SRC}/.envrc  (NAS_IP, PASSWORD_HASH, etc.)"
echo "  3. sudo ${REPO_DIR}/docker/netbootxyz/scripts/generate-autoinstall-userdata.sh"
echo
echo "Verify HTTP serving (from any host on the LAN):"
echo "  curl -I http://<NETBOOTXYZ_HOST>:8080/ubuntu-${UBUNTU_MAJOR}-server/vmlinuz"
echo "  curl -I http://<NETBOOTXYZ_HOST>:8080/dh01-autoinstall/user-data"
