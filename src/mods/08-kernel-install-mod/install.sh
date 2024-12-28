set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing kernel package $TARGET_KERNEL_PACKAGE..."
waitNetwork
apt install -y \
    casper \
    discover \
    laptop-detect \
    os-prober \

apt install -y --no-install-recommends $TARGET_KERNEL_PACKAGE
judge "Install kernel package"