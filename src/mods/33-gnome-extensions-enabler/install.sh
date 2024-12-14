set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Enabling gnome extensions for root..."
/usr/local/bin/gext -F enable arcmenu@arcmenu.com
/usr/local/bin/gext -F enable sound-output-device-chooser@kgshank.net
/usr/local/bin/gext -F enable proxyswitcher@flannaghan.com
/usr/local/bin/gext -F enable blur-my-shell@aunetx
/usr/local/bin/gext -F enable customize-ibus@hollowman.ml
/usr/local/bin/gext -F enable dash-to-panel@jderose9.github.com
/usr/local/bin/gext -F enable network-stats@gnome.noroadsleft.xyz
/usr/local/bin/gext -F enable openweather-extension@jenslody.de
/usr/local/bin/gext -F enable switcher@anduinos
/usr/local/bin/gext -F enable rounded-window-corners@yilozt
/usr/local/bin/gext -F enable lockkeys@vaina.lt
/usr/local/bin/gext -F enable tiling-assistant@leleat-on-github
judge "Enable gnome extensions"