set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Adding new command to this OS: do_anduinos_upgrade..."
cat <<"EOF" > /usr/local/bin/do_anduinos_upgrade
#!/bin/bash
echo "Upgrading AnduinOS..."

VERSION=$(grep -oP "VERSION_ID=\"\\K\\d+\\.\\d+" /etc/os-release)

echo "Current fork version is: $VERSION, running upgrade script..."

curl -sSL "https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/$VERSION/src/upgrade.sh" | bash
EOF
chmod +x /usr/local/bin/do_anduinos_upgrade
judge "Add new command do_anduinos_upgrade"

print_ok "Adding new command to this OS: toggle_network_stats..."
cat << EOF > /usr/local/bin/toggle_network_stats
#!/bin/bash
status=\$(gnome-extensions show "network-stats@gnome.noroadsleft.xyz" | grep "State" | awk '{print \$2}')
if [ "\$status" == "ENABLED" ] || [ "\$status" == "ACTIVE" ]; then
    gnome-extensions disable network-stats@gnome.noroadsleft.xyz
    echo "Disabled network state display"
else
    gnome-extensions enable network-stats@gnome.noroadsleft.xyz
    echo "Enabled network state display"
fi
EOF
chmod +x /usr/local/bin/toggle_network_stats
judge "Add new command toggle_network_stats"
