set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Archiving GNOME extensions to system level"
mv /root/.local/share/gnome-shell/extensions/* /usr/share/gnome-shell/extensions/
judge "Archive GNOME extensions"