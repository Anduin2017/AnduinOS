set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Patching network-stats extension for GNOME Shell 47..."
jq '.["shell-version"] += ["47"]' \
    /usr/share/gnome-shell/extensions/network-stats@gnome.noroadsleft.xyz/metadata.json > /tmp/metadata_tmp.json \
    && mv /tmp/metadata_tmp.json \
    /usr/share/gnome-shell/extensions/network-stats@gnome.noroadsleft.xyz/metadata.json
judge "Patch network-stats extension for GNOME Shell 47"
