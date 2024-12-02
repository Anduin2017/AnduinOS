set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing kernel package..."
waitNetwork
apt install -y \
    discover \
    laptop-detect \
    os-prober \
    libc6 \
    libplymouth5 \
    initramfs-tools \
    dmsetup \
    user-setup \
    sudo \
    eject \
    uuid-runtime \
    util-linux \
    file \
    lzma \
    udev \
    cifs-utils \
    fdisk \
    bzip2 \
    cryptsetup-bin \
    dbus-x11 \
    liblocale-gettext-perl \
    cryptsetup dpkg-repack ntfs-3g policykit-1 python3-debconf python3-icu python3-pam rdate sbsigntool shim-signed accountsservice \
    gir1.2-gtk-3.0 gir1.2-nma-1.0 gir1.2-soup-2.4 gir1.2-timezonemap-1.0 gir1.2-vte-2.91 gir1.2-webkit2-4.0 gir1.2-xkl-1.0 gnome-shell python3-cairo python3-gi-cairo \
    xdg-utils dctrl-tools console-setup libdebian-installer4 bogl-bterm

installUbuntuPackage language-selector-common
installUbuntuPackage ubiquity-casper
installUbuntuPackage ubiquity-ubuntu-artwork 
installUbuntuPackage ubiquity-frontend-debconf true
installUbuntuPackage ubiquity
installUbuntuPackage ubiquity-frontend-gtk
installUbuntuPackage ubiquity-slideshow-ubuntu
installUbuntuPackage finalrd
installUbuntuPackage busybox-initramfs
installUbuntuPackage casper

print_info "Latest kernel info:"
apt-cache show linux-image-amd64

print_info "Installing kernel package..."
apt install -y --no-install-recommends -t bookworm-backports linux-image-amd64
judge "Install kernel package"