set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# we need to install systemd first, to configure machine id
print_ok "Installing systemd"

# Don't wait for network, because curl is not available
#waitNetwork
apt update
apt install -y libterm-readline-gnu-perl systemd-sysv curl
judge "Install systemd"
