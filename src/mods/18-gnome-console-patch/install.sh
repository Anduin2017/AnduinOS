set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Redirect /usr/local/bin/gnome-terminal -> /usr/bin/kgx"
ln -s /usr/bin/kgx /usr/local/bin/gnome-terminal
judge "Redirect /usr/local/bin/gnome-terminal -> /usr/bin/kgx"