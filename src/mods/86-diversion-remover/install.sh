set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Removing diversion..."
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl
judge "Remove diversion"