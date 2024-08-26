set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# Update initramfs
update-initramfs -u -k all
judge "Update /etc/casper.conf"