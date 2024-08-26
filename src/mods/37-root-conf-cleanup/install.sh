set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Cleaning up /root/.config/ and root's gnome-shell extensions"
/usr/bin/pip3 uninstall gnome-extensions-cli -y
rm /root/.config/mimeapps.list
rm /root/.config/dconf -rf
rm /root/.local/share/gnome-shell/extensions -rf
judge "Clean up /root/.config/ and root's gnome-shell extensions"