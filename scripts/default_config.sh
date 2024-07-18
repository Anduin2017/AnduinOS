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
export GRUB_LIVEBOOT_LABEL="Try AnduinOS"

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

    sleep 10
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

    # Edit default wallpaper
    echo "Downloading default wallpaper"
    wget -O /usr/share/backgrounds/Fluent-building-night.png https://github.com/vinceliuice/Fluent-gtk-theme/raw/Wallpaper/wallpaper-4k/Fluent-building-night.png

    echo "Installing Fluent icon theme"
    git clone https://git.aiursoft.cn/PublicVault/Fluent-icon-theme /opt/themes/Fluent-icon-theme
    /opt/themes/Fluent-icon-theme/install.sh 

    echo "Installing Fluent theme"
    git clone https://git.aiursoft.cn/PublicVault/Fluent-gtk-theme /opt/themes/Fluent-gtk-theme
    apt install libsass1 sassc -y
    /opt/themes/Fluent-gtk-theme/install.sh -i ubuntu --tweaks noborder round

    echo "Configuring new users to load default dconf settings..."
    cat << EOF > /etc/profile.d/load-default-settings.sh
#!/bin/bash

if [ "\$XDG_CURRENT_DESKTOP" = "ubuntu:GNOME" ]; then
    if [ ! -f "\$HOME/.config/dconf/default-dconf-settings-loaded" ]; then
        # default file is: /etc/skel/.config/dconf/user.d/default
        dconf load /org/gnome/ < "\$HOME/.config/dconf/user.d/default"
        touch "\$HOME/.config/dconf/default-dconf-settings-loaded"
    fi
fi
EOF
    chmod +x /etc/profile.d/load-default-settings.sh

    cat << EOF > /etc/lsb-release
DISTRIB_ID=AnduinOS
DISTRIB_RELEASE=22.04
DISTRIB_CODENAME=jammy
DISTRIB_DESCRIPTION="AnduinOS 22.04.4 LTS"
EOF

    cat << EOF > /etc/os-release
PRETTY_NAME="AnduinOS 22.04.4 LTS"
NAME="AnduinOS"
VERSION_ID="22.04"
VERSION="22.04.4 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=jammy
EOF

    echo "Installing gnome extensions"
    git clone https://github.com/home-sweet-gnome/dash-to-panel.git /opt/gnome-extensions/dash-to-panel
    (
        cd /opt/gnome-extensions/dash-to-panel
        make install
    )
    git clone https://github.com/fishears/Arc-Menu.git /opt/gnome-extensions/Arc-Menu
    (
        cd /opt/gnome-extensions/Arc-Menu
        make install
    )


}

# Used to version the configuration.  If breaking changes occur, manual
# updates to this file from the default may be necessary.
export CONFIG_FILE_VERSION="0.4"
