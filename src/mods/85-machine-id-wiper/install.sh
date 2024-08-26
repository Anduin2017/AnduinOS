set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Truncating machine id..."
truncate -s 0 /etc/machine-id
truncate -s 0 /var/lib/dbus/machine-id
judge "Truncate machine id"