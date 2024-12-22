set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Enabling gnome extensions for root..."
/root/.local/bin/gext -F enable arcmenu@arcmenu.com
/root/.local/bin/gext -F enable sound-output-device-chooser@kgshank.net # TODO: Not supported.
/root/.local/bin/gext -F enable ProxySwitcher@flannaghan.com # TODO: Not supported.
/root/.local/bin/gext -F enable customize-ibus@hollowman.ml
/root/.local/bin/gext -F enable dash-to-panel@jderose9.github.com
/root/.local/bin/gext -F enable network-stats@gnome.noroadsleft.xyz
/root/.local/bin/gext -F enable openweather-extension@penguin-teal.github.io
/root/.local/bin/gext -F enable switcher@anduinos # TODO: Not supported.
/root/.local/bin/gext -F enable rounded-window-corners@fxgn
/root/.local/bin/gext -F enable lockkeys@vaina.lt
/root/.local/bin/gext -F enable tiling-assistant@leleat-on-github
judge "Enable gnome extensions"
