set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error


# Automatically update /etc/casper.conf
# Mount /dev/nvme0n1 to /cow
mkdir -p /scripts/casper-premount
echo << EOF > /scripts/casper-premount/10-format.cow
#!/bin/sh
set -euo pipefail
mkfs.ext4 -F -L casper-rw /dev/nvme0n1p1
echo "We have formatted /dev/nvme0n1p1 as ext4!"
sleep 5
EOF
chmod +x /scripts/casper-premount/10-format.cow

# Update initramfs
update-initramfs -u -k all
judge "Update /etc/casper.conf"