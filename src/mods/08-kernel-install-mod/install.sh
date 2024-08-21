print_ok "Installing kernel package..."
waitNetwork
apt install -y --no-install-recommends linux-generic-hwe-22.04
judge "Install kernel package"