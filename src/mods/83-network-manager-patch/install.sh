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