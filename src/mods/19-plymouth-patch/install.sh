set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Patch plymouth"
cp ./logo_96.png      /usr/share/plymouth/themes/spinner/bgrt-fallback.png
cp ./anduinos_text.png /usr/share/plymouth/ubuntu-logo.png
cp ./anduinos_text.png /usr/share/plymouth/themes/spinner/watermark.png
#update-initramfs -u # We don't have to update initramfs here, because we did it in the end of this script
judge "Patch plymouth and update initramfs"

# hold theme spinner to be upgraded
print_ok "Marking plymouth-theme-spinner as held..."
apt-mark hold plymouth-theme-spinner
judge "Mark plymouth-theme-spinner as held"

print_ok "Marking plymouth-theme-spinner as not upgradeable..."
cat << EOF > /etc/apt/preferences.d/no-upgrade-plymouth-theme-spinner
Package: plymouth-theme-spinner
Pin: release o=Ubuntu
Pin-Priority: -1
EOF
judge "Create PIN file for plymouth-theme-spinner"
