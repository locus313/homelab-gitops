#!/usr/bin/env bash
#
# setup-proxmox.sh
#
# Downloads a Proxmox VE ISO and extracts the PXE boot files (kernel +
# initrd) into the netbootxyz assets directory so dh01 can be installed
# over the network.
#
# For PXE boot, the automated installation is triggered by the kernel cmdline
# parameter proxmox-answer-file=URL (see HOSTNAME-pve01.ipxe).  The ISO does
# not need to be "prepared" first — that step is only required when burning a
# USB/CD where you cannot control kernel parameters.
#
# Run on the Docker host as root (or with sudo).
# Requires: curl, mount or 7z.
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
#   2. Edit .envrc — fill in PVE01_FQDN, PROXMOX_ROOT_PASSWORD_HASH, PROXMOX_DISK
#   3. sudo ./generate-proxmox-answer.sh
#
# Find available ISOs at: http://download.proxmox.com/iso/

set -euo pipefail

VERSION="${1:-8.4-1}"
readonly MAJOR="${VERSION%%-*}"                 # "8.4" from "8.4-1"
readonly MAJOR_SHORT="${MAJOR%%.*}"             # "8" from "8.4"
readonly ISO_NAME="proxmox-ve_${VERSION}.iso"
readonly ISO_URL="https://download.proxmox.com/iso/${ISO_NAME}"
readonly CHECKSUM_URL="https://download.proxmox.com/iso/SHA256SUMS"
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
# Verify ISO integrity before use
# ---------------------------------------------------------------------------
echo "==> Verifying ISO integrity..."
CHECKSUM_FILE="${WORK}/SHA256SUMS"
curl -fsSL "${CHECKSUM_URL}" -o "${CHECKSUM_FILE}"
EXPECTED=$(grep "${ISO_NAME}" "${CHECKSUM_FILE}" | awk '{print $1}')
ACTUAL=$(sha256sum "${ISO_PATH}" | awk '{print $1}')
if [[ -z "${EXPECTED}" ]]; then
    echo "ERROR: ${ISO_NAME} not found in SHA256SUMS — cannot verify integrity" >&2
    exit 1
fi
if [[ "${EXPECTED}" != "${ACTUAL}" ]]; then
    echo "ERROR: Checksum mismatch — ISO may be corrupt or tampered" >&2
    echo "  expected: ${EXPECTED}" >&2
    echo "  actual:   ${ACTUAL}" >&2
    exit 1
fi
echo "==> Checksum OK: ${ACTUAL}"

# ---------------------------------------------------------------------------
# Extract PXE boot files from the ISO
# ---------------------------------------------------------------------------
mkdir -p "${DEST}"
MNT="${WORK}/mnt"
mkdir -p "${MNT}"

# Try multiple kernel/initrd names — the exact names vary across PVE versions.
# Whatever we find, save with canonical names (linux26 / initrd.magic) so the
# iPXE menu file never needs updating between PVE releases.
extract() {
    local src="$1"
    local kernel="" initrd=""

    for kname in linux26 vmlinuz linux; do
        if [[ -f "${src}/boot/${kname}" ]]; then
            kernel="${src}/boot/${kname}"
            break
        fi
    done

    for iname in initrd.magic initrd.img initrd; do
        if [[ -f "${src}/boot/${iname}" ]]; then
            initrd="${src}/boot/${iname}"
            break
        fi
    done

    if [[ -z "${kernel}" || -z "${initrd}" ]]; then
        echo "ERROR: Could not identify kernel/initrd in ISO boot directory." >&2
        echo "       Files found in boot/:" >&2
        ls -lh "${src}/boot/" 2>/dev/null >&2 || true
        echo "" >&2
        echo "       All boot-related files (max depth 3):" >&2
        find "${src}" -maxdepth 3 \( -name 'linux*' -o -name 'vmlinuz*' \
            -o -name 'initrd*' -o -name '*.magic' \) 2>/dev/null | head -20 >&2
        return 1
    fi

    echo "==> Copying kernel : $(basename "${kernel}") → ${DEST}/linux26"
    cp -v "${kernel}" "${DEST}/linux26"
    echo "==> Copying initrd : $(basename "${initrd}") → ${DEST}/initrd.magic"
    cp -v "${initrd}" "${DEST}/initrd.magic"
}

echo "==> Extracting PXE files from ISO"
if mount -o loop,ro "${ISO_PATH}" "${MNT}" 2>/dev/null; then
    extract "${MNT}"
    umount "${MNT}"
    MNT=""
elif command -v 7z >/dev/null 2>&1; then
    mkdir -p "${WORK}/iso/boot"
    7z x -o"${WORK}/iso" "${ISO_PATH}" \
        'boot/linux26' 'boot/vmlinuz' 'boot/linux' \
        'boot/initrd.magic' 'boot/initrd.img' 'boot/initrd' \
        2>/dev/null || true
    extract "${WORK}/iso"
else
    echo "ERROR: could not mount ISO (not root?) and 7z is not installed" >&2
    echo "  Install 7zip with: apt-get install -y 7zip" >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# Copy the full ISO — the installer searches for /proxmox.iso in the
# initramfs (loaded as a second initrd by iPXE) to find its package data.
# Without this, the installer fails with "no device with valid ISO found".
# ---------------------------------------------------------------------------
echo "==> Copying full ISO to ${DEST}/proxmox.iso"
cp -v "${ISO_PATH}" "${DEST}/proxmox.iso"

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
echo "  2. Edit .envrc  (PVE01_FQDN, PROXMOX_ROOT_PASSWORD_HASH, PROXMOX_DISK)"
echo "  3. sudo ${REPO_DIR}/docker/netbootxyz/scripts/generate-proxmox-answer.sh"
echo
echo "Verify HTTP serving (from any host on the LAN):"
echo "  curl -I http://<NETBOOTXYZ_HOST>:8080/proxmox-${MAJOR_SHORT}/linux26"
echo "  curl -I http://<NETBOOTXYZ_HOST>:8080/proxmox-${MAJOR_SHORT}/initrd.magic"
echo "  curl -I http://<NETBOOTXYZ_HOST>:8080/proxmox-${MAJOR_SHORT}/proxmox.iso"
