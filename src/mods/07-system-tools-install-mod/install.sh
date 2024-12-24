set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing basic system tool packages..."
waitNetwork
apt install -y \
    apparmor \
    apt-utils \
    bash-completion \
    bind9-dnsutils \
    busybox-static \
    command-not-found \
    coreutils \
    cpio \
    cron \
    dmidecode \
    dosfstools \
    ed \
    file \
    firmware-sof-signed \
    ftp \
    grub-common \
    grub-gfxpayload-lists \
    grub-pc \
    grub-pc-bin \
    grub2-common \
    hdparm \
    info \
    iproute2 \
    iptables \
    iputils-ping \
    iputils-tracepath \
    irqbalance \
    libpam-systemd \
    linux-firmware \
    locales \
    logrotate \
    lshw \
    lsof \
    man-db \
    manpages \
    media-types \
    mtr-tiny \
    net-tools \
    network-manager \
    nftables \
    openssh-client \
    parted \
    pciutils \
    psmisc \
    resolvconf \
    rsync \
    strace \
    sudo \
    tcpdump \
    telnet \
    time \
    ufw \
    usbutils \
    uuid-runtime \
    wget \
    xz-utils
judge "Install basic system tool packages"

#wireless-tools \

print_ok "Fixing the package base-files to avoid system upgrading it..."
# Fix the package base-files to avoid system upgrading it. This is because Ubuntu may upgrade the package base-files and caused AnduinOS to be changed to Ubuntu.
# This will edit the file /var/lib/dpkg/status and change the status of the package base-files to hold.
apt-mark hold base-files
judge "Fix the package base-files to avoid system upgrading it"
