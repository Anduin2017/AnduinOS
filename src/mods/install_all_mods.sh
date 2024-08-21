#!/bin/bash

#==========================
# Set up the environment
#==========================
set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error
source ./args.sh

#==========================
# Variables for mods
#==========================
print_ok "Building variables for mods:"
echo $TARGET_UBUNTU_VERSION
echo $BUILD_UBUNTU_MIRROR
echo $TARGET_UBUNTU_MIRROR
echo $TARGET_NAME
echo $TARGET_BUSINESS_NAME
echo $TARGET_BUILD_VERSION

#==========================
# Execute mods
#==========================
for mod in "$SCRIPT_DIR"/*; do
    if [[ -d "$mod" && -f "$mod/install.sh" ]]; then
        print_info "Processing mod: $mod"
        (
            cd "$mod" && \
            chmod +x install.sh && \
            bash "$mod/install.sh"
        )
    fi
done
