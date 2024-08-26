set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing ubiquity (Ubuntu installer)..."
waitNetwork
apt install -y \
    ubiquity \
    ubiquity-casper \
    ubiquity-frontend-gtk \
    ubiquity-slideshow-ubuntu \
    ubiquity-ubuntu-artwork
judge "Install ubiquity"