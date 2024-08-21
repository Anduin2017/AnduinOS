print_ok "Updating packages..."
waitNetwork
apt -y upgrade
judge "Upgrade packages"