set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# remove unused and clean up apt cache
print_ok "Removing unused packages..."
apt autoremove -y --purge
judge "Remove unused packages"