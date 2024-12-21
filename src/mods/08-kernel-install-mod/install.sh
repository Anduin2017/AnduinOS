set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing kernel package..."
waitNetwork
apt install -y \
    casper \
    discover \
    laptop-detect \
    os-prober \

apt install -y --no-install-recommends linux-generic-hwe-24.04
judge "Install kernel package"