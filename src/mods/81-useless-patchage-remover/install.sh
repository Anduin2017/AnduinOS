# remove unused and clean up apt cache
print_ok "Removing unused packages..."
apt autoremove -y --purge
judge "Remove unused packages"