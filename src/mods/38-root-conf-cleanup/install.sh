set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Cleaning up /root/.config/ and root's gnome-shell extensions"
rm /root/.config/mimeapps.list || true
rm /root/.config/dconf -rf || true
rm /root/.local/share/gnome-shell/extensions -rf || true
rm /root/.cache -rf || true
judge "Clean up /root/.config/ and root's gnome-shell extensions"