set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Removing default GNOME extensions"
rm /usr/share/gnome-shell/extensions/apps-menu* -rf
rm /usr/share/gnome-shell/extensions/auto-move-windows* -rf
rm /usr/share/gnome-shell/extensions/launch-new-instance* -rf
rm /usr/share/gnome-shell/extensions/native-window-placement* -rf
rm /usr/share/gnome-shell/extensions/places-menu* -rf
rm /usr/share/gnome-shell/extensions/screenshot-window-sizer* -rf
rm /usr/share/gnome-shell/extensions/window-list* -rf
rm /usr/share/gnome-shell/extensions/windowsNavigator* -rf
rm /usr/share/gnome-shell/extensions/workspace-indicator* -rf
rm /usr/share/gnome-shell/extensions/light-style* -rf
rm /usr/share/gnome-shell/extensions/system-monitor* -rf
judge "Remove GNOME extensions"

# TODO FIXED PENDING CONFIRM: Remove more useless GNOME extensions