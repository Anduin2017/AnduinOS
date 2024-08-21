print_ok "Installing ubiquity (Ubuntu installer)..."
waitNetwork
apt install -y \
    ubiquity \
    ubiquity-casper \
    ubiquity-frontend-gtk \
    ubiquity-slideshow-ubuntu \
    ubiquity-ubuntu-artwork
judge "Install ubiquity"