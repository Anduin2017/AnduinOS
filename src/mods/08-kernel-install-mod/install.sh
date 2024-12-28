set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing live-boot..."
waitNetwork
apt install -y \
    casper \
    discover \
    laptop-detect \
    os-prober
judge "Install live-boot"

print_ok "Installing kernel package $TARGET_KERNEL_PACKAGE..."
apt install -y --no-install-recommends $TARGET_KERNEL_PACKAGE
judge "Install kernel package"