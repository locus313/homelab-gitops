#!/usr/bin/env bash
#
# setup-proxmox.sh
#
# Downloads a Proxmox VE ISO and extracts the PXE boot files (kernel +
# initrd.magic) into the netbootxyz assets directory so dh01 can be
# installed over the network.
#
# Proxmox VE 8.1+ supports fully unattended installation via an answer file
# passed as a kernel parameter.  Run generate-proxmox-answer.sh after this
# script to produce the answer file.
#
# Run on the Docker host as root (or with sudo). Requires: curl, sudo,
# mount or 7z.
#
# Usage:
#   sudo ./setup-proxmox.sh [VERSION]
#
# Examples:
#   sudo ./setup-proxmox.sh           # use default version (8.4-1)
#   sudo ./setup-proxmox.sh 8.3-1     # specific version
#
# After running, the following assets will be in place:
#   ${ASSETS_DIR}/proxmox-${MAJOR}/linux26
#   ${ASSETS_DIR}/proxmox-${MAJOR}/initrd.magic
#
# Then generate the answer file before booting:
#   1. cp docker/netbootxyz/assets/pve01-proxmox/.envrc.example \
#         docker/netbootxyz/assets/pve01-proxmox/.envrc
#   2. Edit .envrc — fill in DH01_FQDN, PROXMOX_ROOT_PASSWORD_HASH, PROXMOX_DISK
#   3. sudo ./generate-proxmox-answer.sh
#
# Find available ISOs at: http://download.proxmox.com/iso/

set -euo pipefail

VERSION="${1:-8.4-1}"
readonly MAJOR="${VERSION%%-*}"                 # "8.4" from "8.4-1"
readonly MAJOR_SHORT="${MAJOR%%.*}"             # "8" from "8.4"
readonly ISO_NAME="proxmox-ve_${VERSION}.iso"
readonly ISO_URL="http://download.proxmox.com/iso/${ISO_NAME}"
readonly ASSETS_DIR="${ASSETS_DIR:-/docker/netbootxyz/assets}"
readonly DEST="${ASSETS_DIR}/proxmox-${MAJOR_SHORT}"
readonly REPO_DIR="${REPO_DIR:-/opt/homelab-gitops}"

WORK="$(mktemp -d)"
MNT=""

cleanup() {
    [[ -n "${MNT}" ]] && mountpoint -q "${MNT}" && umount "${MNT}" 2>/dev/null || true
    rm -rf "${WORK}"
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# Download Proxmox VE ISO
# ---------------------------------------------------------------------------
readonly ISO_PATH="${WORK}/${ISO_NAME}"

echo "==> Downloading Proxmox VE ${VERSION}"
echo "    Source : ${ISO_URL}"
echo "    Dest   : ${ISO_PATH}"
curl -fL --progress-bar -o "${ISO_PATH}" "${ISO_URL}"

# ---------------------------------------------------------------------------
# Extract PXE boot files from the ISO
# ---------------------------------------------------------------------------
mkdir -p "${DEST}"
MNT="${WORK}/mnt"
mkdir -p "${MNT}"

# Proxmox VE ISOs place the PXE files in boot/ as linux26 + initrd.magic.
# Newer releases may use different names — we detect them automatically.
extract() {
    local src="$1"
    local kernel="" initrd=""

    # Kernel: prefer linux26, fall back to vmlinuz
    if [[ -f "${src}/boot/linux26" ]]; then
        kernel="${src}/boot/linux26"
    elif [[ -f "${src}/boot/vmlinuz" ]]; then
        kernel="${src}/boot/vmlinuz"
    else
        echo "ERROR: could not find boot/linux26 or boot/vmlinuz in ISO" >&2
        return 1
    fi

    # Initrd: always initrd.magic in Proxmox VE
    if [[ -f "${src}/boot/initrd.magic" ]]; then
        initrd="${src}/boot/initrd.magic"
    else
        echo "ERROR: could not find boot/initrd.magic in ISO" >&2
        return 1
    fi

    echo "==> Copying kernel from ${kernel}"
    cp -v "${kernel}" "${DEST}/linux26"
    echo "==> Copying initrd from ${initrd}"
    cp -v "${initrd}" "${DEST}/initrd.magic"
}

echo "==> Extracting PXE files from ISO"
if mount -o loop,ro "${ISO_PATH}" "${MNT}" 2>/dev/null; then
    extract "${MNT}"
    umount "${MNT}"
    MNT=""
elif command -v 7z >/dev/null 2>&1; then
    mkdir -p "${WORK}/iso/boot"
    7z x -o"${WORK}/iso" "${ISO_PATH}" 'boot/linux26' 'boot/vmlinuz' \
        'boot/initrd.magic' 2>/dev/null || true
    extract "${WORK}/iso"
else
    echo "ERROR: could not mount ISO (not root?) and 7z is not installed" >&2
    echo "  Install 7zip with: apt-get install -y 7zip" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Fix ownership so the netbootxyz nginx user can serve the files
# ---------------------------------------------------------------------------
NBXYZ_UID="$(docker exec netbootxyz id -u nbxyz 2>/dev/null || echo 1000)"
NBXYZ_GID="$(docker exec netbootxyz id -g nbxyz 2>/dev/null || echo 1000)"
chown -R "${NBXYZ_UID}:${NBXYZ_GID}" "${DEST}"
chmod -R a+r "${DEST}"

echo
echo "==> Done. PXE boot assets for Proxmox VE ${VERSION}:"
ls -lh "${DEST}"
echo
echo "Next step — generate the answer file before booting:"
echo "  1. cp ${REPO_DIR}/docker/netbootxyz/assets/pve01-proxmox/.envrc.example \\"
echo "        ${REPO_DIR}/docker/netbootxyz/assets/pve01-proxmox/.envrc"
echo "  2. Edit .envrc  (DH01_FQDN, PROXMOX_ROOT_PASSWORD_HASH, PROXMOX_DISK)"
echo "  3. sudo ${REPO_DIR}/docker/netbootxyz/scripts/generate-proxmox-answer.sh"
echo
echo "Verify HTTP serving (from any host on the LAN):"
echo "  curl -I http://<NETBOOTXYZ_HOST>:8080/proxmox-${MAJOR_SHORT}/linux26"
echo "  curl -I http://<NETBOOTXYZ_HOST>:8080/proxmox-${MAJOR_SHORT}/initrd.magic"
