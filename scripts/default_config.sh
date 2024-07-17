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
    apt-get install -y \
    plymouth-theme-ubuntu-logo \
    gnome-shell \
    tee

    # Remove snap
    echo "Removing snap"
    sudo killall -9 firefox > /dev/null 2>&1
    snap remove firefox > /dev/null 2>&1
    snap remove snap-store > /dev/null 2>&1
    snap remove gtk-common-themes > /dev/null 2>&1
    snap remove snapd-desktop-integration > /dev/null 2>&1
    snap remove bare > /dev/null 2>&1
    systemctl disable --now snapd
    apt purge -y snapd
    rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd ~/snap
    echo "Pin snapd to prevent it from being installed again"
    cat << EOF > /etc/apt/preferences.d/no-snap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
    chown root:root /etc/apt/preferences.d/no-snap.pref

    # useful tools
    apt-get install -y \
    clamav-daemon \
    terminator \
    apt-transport-https \
    curl \
    vim \
    nano \
    less

    # purge
    apt-get purge -y \
    transmission-gtk \
    transmission-common \
    gnome-mahjongg \
    gnome-mines \
    gnome-sudoku \
    aisleriot \
    hitori
}

# Used to version the configuration.  If breaking changes occur, manual
# updates to this file from the default may be necessary.
export CONFIG_FILE_VERSION="0.4"
