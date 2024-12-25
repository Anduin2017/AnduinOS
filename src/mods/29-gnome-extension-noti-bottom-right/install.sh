set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Install Gnome Extension Notification Bottom Right"
cp ./noti-bottom-right@anduinos /usr/share/gnome-shell/extensions/noti-bottom-right@anduinos -rf
judge "Install Gnome Extension Notification Bottom Right"