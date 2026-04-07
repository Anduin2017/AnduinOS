set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Cleaning up /root/.config/ and root's gnome-shell extensions"
/usr/bin/pipx uninstall gnome-extensions-cli
rm /root/.config/mimeapps.list
# Note: No longer cleaning up /root/.config/dconf as we now use system-level configuration
rm /root/.local/share/gnome-shell/extensions -rf
/usr/bin/pipx uninstall-all
PIPX_HOME=$(pipx environment --value PIPX_HOME)
rm "$PIPX_HOME" -rf
rm /root/.cache -rf
judge "Clean up /root/.config/ and root's gnome-shell extensions"