#!/usr/bin/env bash
#
# setup-fedora-live.sh
#
# Downloads a Fedora Workstation Live ISO and extracts the kernel, initrd,
# and squashfs.img into the netbootxyz assets directory so they can be
# served over HTTP for PXE live-booting.
#
# Run on the docker host (dh01). Requires: curl, sudo, mount, isoinfo or
# 7z (we try mount first, fall back to 7z).
#
# After running, ensure custom.ipxe is in place at:
#   ${ASSETS_PARENT}/../config/menus/custom/custom.ipxe
#
# Usage:
#   sudo ./setup-fedora-live.sh [VERSION] [BUILD]
#
# Examples:
#   sudo ./setup-fedora-live.sh 44
#   sudo ./setup-fedora-live.sh 44 1.5
#
set -euo pipefail

VERSION="${1:-44}"
BUILD="${2:-}"
ARCH="x86_64"
ASSETS_DIR="${ASSETS_DIR:-/docker/netbootxyz/assets}"
DEST="${ASSETS_DIR}/fedora-${VERSION}-live"
WORK="$(mktemp -d)"
trap 'rm -rf "${WORK}"; mountpoint -q "${MNT:-/nonexistent}" && umount "${MNT}" || true' EXIT

# Resolve ISO URL. If BUILD not given, scrape the directory listing.
BASE_URL="https://download.fedoraproject.org/pub/fedora/linux/releases/${VERSION}/Workstation/${ARCH}/iso"

if [[ -z "${BUILD}" ]]; then
    echo "==> Discovering latest build for Fedora ${VERSION} Workstation Live..."
    LISTING_URL="https://dl.fedoraproject.org/pub/fedora/linux/releases/${VERSION}/Workstation/${ARCH}/iso/"
    # Fedora 41+ naming: Fedora-Workstation-Live-<VER>-<BUILD>.<ARCH>.iso
    # Older naming:      Fedora-Workstation-Live-<ARCH>-<VER>-<BUILD>.iso
    ISO_NAME="$(curl -fsSL "${LISTING_URL}" \
        | grep -oE "Fedora-Workstation-Live-(${VERSION}-[0-9.]+\.${ARCH}|${ARCH}-${VERSION}-[0-9.]+)\.iso" \
        | sort -u | tail -1)"
    if [[ -z "${ISO_NAME}" ]]; then
        echo "ERROR: could not find a Fedora ${VERSION} Workstation Live ISO at ${LISTING_URL}" >&2
        exit 1
    fi
else
    # Try new naming first, fall back to old
    ISO_NAME="Fedora-Workstation-Live-${VERSION}-${BUILD}.${ARCH}.iso"
fi

ISO_URL="${BASE_URL}/${ISO_NAME}"
ISO_PATH="${WORK}/${ISO_NAME}"

echo "==> Downloading ${ISO_URL}"
curl -fL --progress-bar -o "${ISO_PATH}" "${ISO_URL}"

mkdir -p "${DEST}"
MNT="${WORK}/mnt"
mkdir -p "${MNT}"

echo "==> Extracting kernel/initrd/squashfs"
# Fedora 41+ moved boot files: /boot/x86_64/loader/{linux,initrd}
# Older releases used:          /images/pxeboot/{vmlinuz,initrd.img}
extract() {
    local src="$1"
    if [[ -f "${src}/boot/x86_64/loader/linux" ]]; then
        cp -v "${src}/boot/x86_64/loader/linux"  "${DEST}/vmlinuz"
        cp -v "${src}/boot/x86_64/loader/initrd" "${DEST}/initrd.img"
    elif [[ -f "${src}/images/pxeboot/vmlinuz" ]]; then
        cp -v "${src}/images/pxeboot/vmlinuz"    "${DEST}/vmlinuz"
        cp -v "${src}/images/pxeboot/initrd.img" "${DEST}/initrd.img"
    else
        echo "ERROR: could not find vmlinuz/initrd in ISO" >&2
        return 1
    fi
    cp -v "${src}/LiveOS/squashfs.img" "${DEST}/squashfs.img"
}

if mount -o loop,ro "${ISO_PATH}" "${MNT}" 2>/dev/null; then
    extract "${MNT}"
    umount "${MNT}"
elif command -v 7z >/dev/null 2>&1; then
    7z x -o"${WORK}/iso" "${ISO_PATH}" \
        'boot/x86_64/loader/linux' \
        'boot/x86_64/loader/initrd' \
        'images/pxeboot/vmlinuz' \
        'images/pxeboot/initrd.img' \
        'LiveOS/squashfs.img' 2>/dev/null || true
    extract "${WORK}/iso"
else
    echo "ERROR: could not mount ISO and 7z is not installed" >&2
    exit 1
fi

# Match netbootxyz container ownership. nginx runs as the nbxyz user
# (uid 1000 in this image — NOT 911 as in many other linuxserver images).
# We look it up dynamically to stay correct across image updates.
NBXYZ_UID="$(docker exec netbootxyz id -u nbxyz 2>/dev/null || echo 1000)"
NBXYZ_GID="$(docker exec netbootxyz id -g nbxyz 2>/dev/null || echo 1000)"
chown -R "${NBXYZ_UID}:${NBXYZ_GID}" "${DEST}"
chmod -R a+r "${DEST}"

echo
echo "==> Done. Files installed to ${DEST}:"
ls -lh "${DEST}"
echo
echo "Verify HTTP serving works (from any host on the LAN):"
echo "  curl -I http://<NETBOOTXYZ_HOST>:8080/fedora-${VERSION}-live/vmlinuz"
