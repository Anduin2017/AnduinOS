print_ok "Updating packages...(This is because debootstrap may not have the latest package list)"
waitNetwork
apt -y upgrade
judge "Upgrade packages"