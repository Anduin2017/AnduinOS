set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Removing Ubuntu motd and update-manager"
rm /etc/update-manager/ -rvf
rm /etc/update-motd.d/ -rvf
judge "Remove Ubuntu motd and update-manager"