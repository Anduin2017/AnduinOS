set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Cleaning up apt cache..."
apt clean -y
rm -rf /var/cache/apt/archives/*
rm -rf /var/lib/apt/lists/*
rm -v /var/cache/debconf/*.dat-old
judge "Clean up apt cache"