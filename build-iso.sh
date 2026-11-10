#!/bin/bash
set -e

# ==============================================================================
# Aluminium OS - Debian Edition ISO Builder
# Builds a bootable, installable live Debian system styled identically to
# Googlebook OS / Aluminium OS (Material 3 windows, floating shelf, controls).
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/dist"
ISO_NAME="aluminium-os-debian-amd64.iso"

echo "=========================================================="
echo "      Building Aluminium OS (Debian Edition Live ISO)     "
echo "=========================================================="

mkdir -p "${OUTPUT_DIR}"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "[!] live-build requires root privileges (or sudo)."
    echo "    Re-running with sudo..."
    exec sudo bash "$0" "$@"
fi

# Check for required tools
MISSING_PKGS=""
for pkg in live-build debootstrap squashfs-tools xorriso syslinux syslinux-common isolinux; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        MISSING_PKGS="${MISSING_PKGS} ${pkg}"
    fi
done

if [ -n "${MISSING_PKGS}" ]; then
    echo "[*] Installing required build dependencies:${MISSING_PKGS}..."
    apt-get update -y
    apt-get install -y ${MISSING_PKGS}
fi

cd "${SCRIPT_DIR}"

echo "[1/4] Cleaning previous build artifacts..."
lb clean --purge

echo "[2/4] Initializing live-build configuration..."
lb config

echo "[3/4] Building Debian Live ISO with Aluminium OS customizations..."
lb build

echo "[4/4] Finalizing image..."
if [ -f live-image-amd64.hybrid.iso ]; then
    mv live-image-amd64.hybrid.iso "${OUTPUT_DIR}/${ISO_NAME}"
    echo "[+] SUCCESS! Aluminium OS ISO created:"
    echo "    Path: ${OUTPUT_DIR}/${ISO_NAME}"
    echo "    Size: $(du -h "${OUTPUT_DIR}/${ISO_NAME}" | cut -f1)"
else
    echo "[-] Error: Output ISO file not found."
    exit 1
fi
