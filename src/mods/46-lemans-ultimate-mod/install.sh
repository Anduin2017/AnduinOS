#!/bin/bash
# Install custom Proton GE version for Le Mans Ultimate (LMU) with HID fixes
# Requires: curl, tar

set -e
source /root/mods/shared.sh

print_ok "Starting Le Mans Ultimate Proton Integration..."

# Define version and URL
PROTON_VERSION="GE-Proton10-25-LMU-hid_fixes"
PROTON_URL="https://github.com/JacKeTUs/proton-ge-custom/releases/download/${PROTON_VERSION}/${PROTON_VERSION}.tar.gz"
STEAM_COMPAT_DIR="/usr/share/steam/compatibilitytools.d"

print_ok "Creating system-wide Steam compatibility tools directory..."
mkdir -p "$STEAM_COMPAT_DIR"

print_ok "Downloading ${PROTON_VERSION}..."
curl -L -o "/tmp/${PROTON_VERSION}.tar.gz" "$PROTON_URL"

print_ok "Extracting ${PROTON_VERSION} to ${STEAM_COMPAT_DIR}..."
tar -xzf "/tmp/${PROTON_VERSION}.tar.gz" -C "$STEAM_COMPAT_DIR/"

print_ok "Cleaning up downloaded archive..."
rm -f "/tmp/${PROTON_VERSION}.tar.gz"

print_ok "Le Mans Ultimate Proton integration completed successfully."
judge "Install GE-Proton-LMU"
