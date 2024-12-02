set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing plymouth..."
apt install -y \
    plymouth plymouth-label

judge "Install plymouth"

print_ok "Installing plymouth themes (from Ubuntu)..."
installUbuntuPackage plymouth-theme-spinner
installUbuntuPackage plymouth-theme-ubuntu-text
installUbuntuPackage plymouth-theme-ubuntu-logo
judge "Install plymouth themes (from Ubuntu)"

print_ok "Patch plymouth"
mkdir -p /usr/share/plymouth/themes/spinner

cp ./logo_128.png      /usr/share/plymouth/themes/spinner/bgrt-fallback.png
cp ./anduinos_text.png /usr/share/plymouth/ubuntu-logo.png
cp ./anduinos_text.png /usr/share/plymouth/themes/spinner/watermark.png
#update-initramfs -u # We don't have to update initramfs here, because we did it in the end of this script
judge "Patch plymouth and update initramfs"