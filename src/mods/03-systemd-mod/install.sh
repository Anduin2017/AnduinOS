# we need to install systemd first, to configure machine id
print_ok "Installing systemd"

# Don't wait for network, because curl is not available
#waitNetwork
apt update
apt install -y libterm-readline-gnu-perl systemd-sysv curl locales resolvconf
judge "Install systemd"

print_ok "Configuring locales and resolvconf to $LANG..."
locale-gen $LANG
update-locale LANG=$LANG
judge "Configure locales and resolvconf"