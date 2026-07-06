#!/bin/bash
set -e
set -o pipefail
set -u
export DEBIAN_FRONTEND=noninteractive

CURRENT_VERSION=$(grep DISTRIB_RELEASE /etc/lsb-release | cut -d "=" -f 2)

# Ensure the current OS is AnduinOS
if ! grep -q "DISTRIB_ID=AnduinOS" /etc/lsb-release; then
    echo "Error: This script can only be run on AnduinOS."
    exit 1
fi

echo "Current version: ${CURRENT_VERSION}"

# Already on 2.0.0, nothing to do
if [ "$CURRENT_VERSION" = "2.0.0" ]; then
    echo "Already on 2.0.0. Nothing to do."
    exit 0
fi

# Any 1.3.x: download and run the 2.0 upgrade script
echo "Upgrading from ${CURRENT_VERSION} to 2.0.0..."

UPGRADE_SCRIPT="/var/tmp/upgrade_13_to_20.sh"
wget -O "$UPGRADE_SCRIPT" "https://raw.githubusercontent.com/Anduin2017/AnduinOS/refs/heads/1.3/upgrade_13_to_20.sh"
chmod +x "$UPGRADE_SCRIPT"
ANDUINOS_AUTO_UPGRADE=Y bash "$UPGRADE_SCRIPT"
rm -f "$UPGRADE_SCRIPT"

echo "Upgrade complete. It is suggested to run \`do-anduinos-autorepair\` after rebooting."
