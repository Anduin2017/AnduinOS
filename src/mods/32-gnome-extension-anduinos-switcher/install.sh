set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Install Gnome Extension Anduinos Switcher"
cp ./switcher@anduinos /usr/share/gnome-shell/extensions/switcher@anduinos -rf
judge "Install Gnome Extension Anduinos Switcher"