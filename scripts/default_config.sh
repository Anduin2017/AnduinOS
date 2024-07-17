#!/bin/bash

# This script provides common customization options for the ISO
# 
# Usage: Copy this file to config.sh and make changes there.  Keep this file (default_config.sh) as-is
#   so that subsequent changes can be easily merged from upstream.  Keep all customiations in config.sh

# The version of Ubuntu to generate.  Successfully tested: bionic, cosmic, disco, eoan, focal, groovy, jammy
# See https://wiki.ubuntu.com/DevelopmentCodeNames for details
export TARGET_UBUNTU_VERSION="jammy"

# The Ubuntu Mirror URL. It's better to change for faster download.
# More mirrors see: https://launchpad.net/ubuntu/+archivemirrors
export TARGET_UBUNTU_MIRROR="http://mirror.aiursoft.cn/ubuntu/"

# The packaged version of the Linux kernel to install on target image.
# See https://wiki.ubuntu.com/Kernel/LTSEnablementStack for details
export TARGET_KERNEL_PACKAGE="linux-generic-hwe-22.04"

# The file (no extension) of the ISO containing the generated disk image,
# the volume id, and the hostname of the live environment are set from this name.
export TARGET_NAME="anduinos"

# The text label shown in GRUB for booting into the live environment
export GRUB_LIVEBOOT_LABEL="Try AnduinOS without installing"

# The text label shown in GRUB for starting installation
export GRUB_INSTALL_LABEL="Install AnduinOS"

# Packages to be removed from the target system after installation completes succesfully
export TARGET_PACKAGE_REMOVE="
    ubiquity \
    casper \
    discover \
    laptop-detect \
    os-prober \
"

# Package customisation function.  Update this function to customize packages
# present on the installed system.
function customize_image() {
    echo "Installing gnome-shell and other packages"
    # install graphics and desktop
    apt install -y \
    ca-certificates gpg apt-transport-https software-properties-common\
    plymouth-theme-ubuntu-logo \
    gnome-shell gir1.2-gmenu-3.0 gnome-menus gnome-shell-extensions\
    nautilus usb-creator-gtk cheese baobab file-roller gnome-sushi ffmpegthumbnailer\
    gnome-calculator gnome-system-monitor gnome-disk-utility gnome-control-center software-properties-gtk\
    gnome-tweaks gnome-shell-extension-prefs gnome-shell-extension-desktop-icons-ng gnome-shell-extension-appindicator\
    gnome-clocks\
    gnome-weather\
    gnome-text-editor\
    gnome-nettool\
    seahorse gdebi evince\
    firefox\
    ibus-rime\
    shotwell\
    remmina remmina-plugin-rdp\
    vlc\
    gnome-console nautilus-extension-gnome-console\
    python3-apt python3-pip python-is-python3\
    git neofetch lsb-release coreutils\
    gnupg vim nano\
    wget curl\
    httping nethogs net-tools iftop traceroute dnsutils iperf3\
    smartmontools\
    htop iotop iftop\
    tree ntp ntpdate ntpstat\
    w3m sysbench\
    zip unzip jq\
    cifs-utils\
    aisleriot

    # Remove snap
    echo "Removing snap packages"
    snap remove firefox || true
    snap remove snap-store || true
    snap remove gtk-common-themes || true
    snap remove snapd-desktop-integration || true
    snap remove bare || true
    apt purge -y snapd
    rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd ~/snap
    cat << EOF > /etc/apt/preferences.d/no-snap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
    chown root:root /etc/apt/preferences.d/no-snap.pref

    # purge
    apt purge -y \
    transmission-gtk \
    transmission-common \
    gnome-mahjongg \
    gnome-mines \
    gnome-sudoku \
    aisleriot \
    hitori \
    gnome-initial-setup \
    gnome-maps \
    gnome-photos \
    eog \
    tilix \
    totem totem-plugins \
    rhythmbox \
    gnome-contacts \
    gnome-terminal \
    gedit \
    gnome-shell-extension-ubuntu-dock \
    libreoffice-*
}

# Used to version the configuration.  If breaking changes occur, manual
# updates to this file from the default may be necessary.
export CONFIG_FILE_VERSION="0.4"
