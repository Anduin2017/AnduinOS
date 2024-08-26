set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing gnome extensions"
/usr/bin/pip3 install --upgrade gnome-extensions-cli
/usr/local/bin/gext -F install arcmenu@arcmenu.com
/usr/local/bin/gext -F install audio-output-switcher@anduchs
/usr/local/bin/gext -F install proxyswitcher@flannaghan.com
/usr/local/bin/gext -F install blur-my-shell@aunetx
/usr/local/bin/gext -F install customize-ibus@hollowman.ml
/usr/local/bin/gext -F install dash-to-panel@jderose9.github.com
/usr/local/bin/gext -F install network-stats@gnome.noroadsleft.xyz
/usr/local/bin/gext -F install openweather-extension@jenslody.de
judge "Install gnome extensions"