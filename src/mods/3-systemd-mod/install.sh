# we need to install systemd first, to configure machine id
print_ok "Installing systemd..."
waitNetwork
apt update
apt install -y libterm-readline-gnu-perl systemd-sysv curl
judge "Install systemd"