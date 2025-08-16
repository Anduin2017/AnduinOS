# ==================== (Final Workaround) ====================

# Define the exact kernel ABI version we want to install.
# This corresponds to the versioned packages that are still available.
OLDER_KERNEL_ABI="6.14.0-27-generic"

print_ok "Installing specific kernel packages for version ${OLDER_KERNEL_ABI}..."
wait_network
apt-get update

# Install the specific, versioned kernel packages directly, bypassing the meta-package.
apt-get install -y --allow-downgrades \
    casper \
    discover \
    laptop-detect \
    os-prober \
    keyutils \
    thermald \
    linux-image-${OLDER_KERNEL_ABI} \
    linux-headers-${OLDER_KERNEL_ABI} \
    linux-modules-extra-${OLDER_KERNEL_ABI} \
    --no-install-recommends

judge "Install live-boot and specific kernel packages"

# Verification step to confirm the correct version was installed
installed_kernel_image=$(dpkg -l | grep 'linux-image-[0-9]' | awk '{print $2}')
print_ok "Verified installed kernel package: ${installed_kernel_image}"
if [[ ! "${installed_kernel_image}" == "linux-image-${OLDER_KERNEL_ABI}" ]]; then
    print_err "Kernel package mismatch! Expected linux-image-${OLDER_KERNEL_ABI}, but got ${installed_kernel_image}."
    exit 1
fi
# ==================== (End of Workaround) ====================