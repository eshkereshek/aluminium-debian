#!/bin/bash
# ==============================================================================
# Aluminium OS - QEMU Test Runner
# Launches the built Debian Live ISO in QEMU with UEFI, sound, and 3D acceleration.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISO_PATH="${SCRIPT_DIR}/dist/aluminium-os-debian-amd64.iso"

if [ ! -f "${ISO_PATH}" ]; then
    echo "[-] ISO not found at: ${ISO_PATH}"
    echo "    Please run ./build-iso.sh first."
    exit 1
fi

echo "[*] Launching Aluminium OS in QEMU..."

qemu-system-x86_64 \
    -enable-kvm \
    -m 4096 \
    -smp 4 \
    -cpu host \
    -vga virtio \
    -display gtk,gl=on \
    -device intel-hda \
    -device hda-duplex \
    -device nec-usb-xhci \
    -device usb-tablet \
    -cdrom "${ISO_PATH}" \
    -boot d
