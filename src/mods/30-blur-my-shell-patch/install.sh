#!/bin/bash
set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# https://raw.githubusercontent.com/Anduin2017/blur-my-shell/refs/heads/master/src/components/panel.js

print_ok "Downloading Blur My Shell patch"
URL="https://git.aiursoft.cn/Anduin/blur-my-shell/raw/branch/master/src/components/panel.js"
wget "$URL" -O /tmp/panel.js
judge "Download Blur My Shell patch"

print_ok "Installing Blur My Shell patch"
mv /tmp/panel.js /usr/share/gnome-shell/extensions/blur-my-shell@aunetx/components/panel.js
judge "Install Blur My Shell patch"
