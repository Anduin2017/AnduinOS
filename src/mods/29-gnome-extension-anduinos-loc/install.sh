set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Install Gnome Extension Anduinos Location Switcher"
cp ./loc@anduinos.com /usr/share/gnome-shell/extensions/loc@anduinos.com -rf
judge "Install Gnome Extension Anduinos Location Switcher"