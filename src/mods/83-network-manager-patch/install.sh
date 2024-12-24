set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing network manager vpn packages..."
apt install -y \
    wireless-tools \
    openvpn \
    network-manager-openvpn \
    network-manager-openvpn-gnome \
    network-manager-pptp-gnome
judge "Install network manager vpn packages"

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
