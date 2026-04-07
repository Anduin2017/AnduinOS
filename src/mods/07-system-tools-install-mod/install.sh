set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

wait_network
print_ok "Installing basic system tool packages..."
apt install $INTERACTIVE \
    apparmor \
    bash-completion \
    bind9-dnsutils \
    bolt \
    busybox-static \
    command-not-found \
    coreutils \
    cpio \
    crash \
    cron \
    debconf-i18n \
    dmidecode \
    dosfstools \
    ed \
    ethtool \
    fdisk \
    file \
    firmware-sof-signed \
    ftp \
    grub-common \
    grub2-common \
    hdparm \
    hwdata \
    init \
    iproute2 \
    iptables \
    libpam-systemd \
    libpam-cap \
    libpam-fprintd \
    libpam-modules \
    libpam-modules-bin \
    libpam-pwquality \
    libpam-sss \
    libpam-systemd \
    linux-firmware \
    locales \
    logrotate \
    lshw \
    lsof \
    man-db \
    manpages \
    manpages-dev \
    dns-root-data \
    usb-modeswitch \
    libmbim-utils \
    media-types \
    mtr-tiny \
    network-manager \
    nftables \
    numactl \
    openssh-client \
    python3-systemd \
    parted \
    pciutils \
    psmisc \
    resolvconf \
    rsync \
    strace \
    sudo \
    sudo-rs \
    tcpdump \
    telnet \
    time \
    ufw \
    unzip \
    usbutils \
    uuid-runtime \
    wget \
    xz-utils \
    zstd \
    zip \
    powermgmt-base \
    modemmanager \
    dbus-user-session \
    dnsmasq-base \
    wpasupplicant \
    python3-rich \
    systemd-hwe-hwdb \
    efibootmgr \
    ibverbs-providers \
    xauth \
    busybox-initramfs \
    dhcpcd-base \
    kmod \
    linux-base \
    cifs-utils \
    eject \
    gettext \
    cracklib-runtime \
    libfuse2t64 \
    libfuse3-4 \
    libopengl0 \
    initramfs-tools \
    --no-install-recommends
judge "Install basic system tool packages"

print_ok "Fixing the package base-files to avoid system upgrading it..."
# Fix the package base-files to avoid system upgrading it. This is because Ubuntu may upgrade the package base-files and caused AnduinOS to be changed to Ubuntu.
# This will edit the file /var/lib/dpkg/status and change the status of the package base-files to hold.
apt-mark hold base-files
judge "Fix the package base-files to avoid system upgrading it"

print_ok "Marking base-files as held..."
cat << EOF > /etc/apt/preferences.d/no-upgrade-base-files
Package: base-files
Pin: release o=Ubuntu
Pin-Priority: -1
EOF
judge "Create PIN file for base-files"