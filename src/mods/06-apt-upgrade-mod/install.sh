set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Updating packages...(This is because debootstrap may not have the latest package list)"
waitNetwork
apt -y upgrade
judge "Upgrade packages"