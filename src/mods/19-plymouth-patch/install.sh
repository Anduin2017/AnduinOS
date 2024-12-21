set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# TODO: Plymouth is not working properly

print_ok "Patch plymouth"
cp ./logo_128.png      /usr/share/plymouth/themes/spinner/bgrt-fallback.png
cp ./anduinos_text.png /usr/share/plymouth/ubuntu-logo.png
cp ./anduinos_text.png /usr/share/plymouth/themes/spinner/watermark.png
#update-initramfs -u # We don't have to update initramfs here, because we did it in the end of this script
judge "Patch plymouth and update initramfs"