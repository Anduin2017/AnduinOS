set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Configuring network manager..."
cat << EOF > /etc/NetworkManager/NetworkManager.conf
[main]
rc-manager=resolvconf
plugins=ifupdown,keyfile
dns=dnsmasq

[ifupdown]
managed=false
EOF
dpkg-reconfigure network-manager
judge "Configure network manager"

print_ok "Configuring netplan..."
cat << EOF > /etc/netplan/01-network-manager-all.yaml
network:
  version: 2
  renderer: NetworkManager
EOF
judge "Configure netplan"

print_ok "Enabling auto Wi-Fi connect service..."
cat << EOF > /usr/local/bin/auto-wifi-connect.sh
#!/usr/bin/env bash
set -euo pipefail

SSID="802.11_5G"
PASS="bingzhang"
PROFILE_NAME="\$SSID"

# 自动发现 Wi-Fi 接口（第一个 type=wifi 的）
iface=\$(nmcli -t -f DEVICE,TYPE device status | awk -F: '\$2=="wifi"{print \$1; exit}')
[ -z "\$iface" ] && { echo "No Wi-Fi interface found"; exit 1; }

# 开启 Wi-Fi
nmcli radio wifi on

# 检查连接 profile 是否已存在
if ! nmcli -t -f NAME connection show | grep -Fxq "\$PROFILE_NAME"; then
    echo "Creating Wi-Fi connection for SSID: \$SSID"
    nmcli connection add \
      type wifi \
      ifname "\$iface" \
      con-name "\$PROFILE_NAME" \
      ssid "\$SSID"

    nmcli connection modify "\$PROFILE_NAME" \
      wifi-sec.key-mgmt wpa-psk \
      wifi-sec.psk "\$PASS" \
      connection.autoconnect yes
fi

# 激活连接（冪等）
nmcli connection up "\$PROFILE_NAME" ifname "\$iface"
EOF

chmod +x /usr/local/bin/auto-wifi-connect.sh

cat << EOF > /etc/systemd/system/auto-wifi-connect.service
[Unit]
Description=Auto Wi-Fi Connect Service
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/auto-wifi-connect.sh
RemainAfterExit=yes
TimeoutStartSec=30

[Install]
WantedBy=multi-user.target
EOF

systemctl enable auto-wifi-connect.service
