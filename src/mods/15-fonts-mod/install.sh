set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Patching fonts..."
cp ./local.conf /etc/fonts/
unzip ./fonts.zip -d /usr/share/fonts/
judge "Patch fonts"

print_ok "Updating font cache"
fc-cache -f
judge "Update font cache"