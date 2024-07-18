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

    export DEBIAN_FRONTEND=noninteractive
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

    echo "Removing Ubuntu Pro advertisements"
    rm /etc/apt/apt.conf.d/20apt-esm-hook.conf || true
    touch /etc/apt/apt.conf.d/20apt-esm-hook.conf
    pro config set apt_news=false || true
    pro config set motd=false || true

    echo "Adding Mozilla Firefox PPA"
    apt install -y software-properties-common
    add-apt-repository -y ppa:mozillateam/ppa -n
    echo "deb https://mirror-ppa.aiursoft.cn/mozillateam/ppa/ubuntu/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/mozillateam-ubuntu-ppa-$(lsb_release -sc).list
    cat << EOF > /etc/apt/preferences.d/mozilla-firefox
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1002
EOF
    chown root:root /etc/apt/preferences.d/mozilla-firefox

    # install graphics and desktop
    apt update
    apt install -y \
    ca-certificates gpg apt-transport-https\
    plymouth plymouth-label plymouth-theme-spinner plymouth-theme-ubuntu-text plymouth-theme-ubuntu-logo \
    gnome-shell gir1.2-gmenu-3.0 gnome-menus gnome-shell-extensions\
    nautilus usb-creator-gtk cheese baobab file-roller gnome-sushi ffmpegthumbnailer\
    gnome-calculator gnome-system-monitor gnome-disk-utility gnome-control-center software-properties-gtk gnome-logs\
    gnome-tweaks gnome-shell-extension-prefs gnome-shell-extension-desktop-icons-ng gnome-shell-extension-appindicator\
    gnome-clocks\
    gnome-weather\
    gnome-text-editor\
    gnome-nettool\
    seahorse gdebi evince\
    ibus-rime\
    shotwell\
    remmina remmina-plugin-rdp\
    firefox\
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

    # Redirect /usr/local/bin/gnome-terminal -> /usr/bin/kgx
    ln -s /usr/bin/kgx /usr/local/bin/gnome-terminal

    echo "Installing fonts to fix CJKT display issue"
    wget https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/master/Config/fonts.conf -O /etc/fonts/local.conf
    wget -P /tmp https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/master/Assets/fonts.zip
    unzip -o /tmp/fonts.zip -d /usr/share/fonts/
    rm -f /tmp/fonts.zip
    fc-cache -fv

    echo "Installing ibus-rime configuration"
    wget https://github.com/iDvel/rime-ice/archive/refs/heads/main.zip -O /tmp/main.zip
    unzip /tmp/main.zip -d /tmp/rime-ice-main
    mkdir -p /etc/skel/.config/ibus/rime
    mv /tmp/rime-ice-main/rime-ice-main/* /etc/skel/.config/ibus/rime/ -f
    rm -rf /tmp/rime-ice-main
    rm /tmp/main.zip

    echo "Installing MissionCenter..."
    if ! test -f /opt/missioncenter/AppRun; then
        # This link requires to be updated manually regularly.
        APPIMAGE_URL="https://gitlab.com/mission-center-devs/mission-center/-/jobs/7109267599/artifacts/raw/MissionCenter-x86_64.AppImage"
        LOGO_URL="https://dl.flathub.org/media/io/missioncenter/MissionCenter/224cb83cac6b6e56f793a0163bcca7aa/icons/128x128/io.missioncenter.MissionCenter.png"
        APPIMAGE_PATH="/opt/missioncenter.appimage"
        APPBIN_PATH="/opt/missioncenter/AppRun"
        LOGO_PATH="/usr/share/icons/missioncenter.png"
        DESKTOP_FILE="/usr/share/applications/missioncenter.desktop"
        wget -O $APPIMAGE_PATH $APPIMAGE_URL
        wget -O $LOGO_PATH $LOGO_URL
        chmod +x $APPIMAGE_PATH
        $APPIMAGE_PATH --appimage-extract
        mv ./squashfs-root /opt/missioncenter
        rm $APPIMAGE_PATH
        echo "[Desktop Entry]
        Name=MissionCenter
        Comment=Monitor overall system and application performance
        Exec=$APPBIN_PATH
        Icon=$LOGO_PATH
        Terminal=false
        Type=Application
        Categories=System;Monitor;" | sudo tee $DESKTOP_FILE
    else
        print_ok "MissionCenter is already installed"
    fi

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
        libreoffice-* \
        yelp \
        info

    # Edit default wallpaper
    echo "Downloading default wallpaper"
    wget -O /usr/share/backgrounds/Fluent-building-night.png https://github.com/vinceliuice/Fluent-gtk-theme/raw/Wallpaper/wallpaper-4k/Fluent-building-night.png

    echo "Downloading default distributor logo"
    mkdir -p /opt/themes
    wget -O /opt/themes/distributor-logo-ubuntu.svg https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/master/Assets/distributor-logo-ubuntu.svg

    echo "Installing Fluent icon theme"
    git clone https://git.aiursoft.cn/PublicVault/Fluent-icon-theme /opt/themes/Fluent-icon-theme
    /opt/themes/Fluent-icon-theme/install.sh
    rm /opt/themes/Fluent-icon-theme -rf

    echo "Installing Fluent theme"
    git clone https://git.aiursoft.cn/PublicVault/Fluent-gtk-theme /opt/themes/Fluent-gtk-theme
    apt install libsass1 sassc -y
    /opt/themes/Fluent-gtk-theme/install.sh -i ubuntu --tweaks noborder round
    rm /opt/themes/Fluent-gtk-theme -rf

    echo "Installing gnome extensions"
    /usr/bin/pip3 install --upgrade gnome-extensions-cli
    /usr/local/bin/gext -F install arcmenu@arcmenu.com
    /usr/local/bin/gext -F install blur-my-shell@aunetx
    /usr/local/bin/gext -F install customize-ibus@hollowman.ml
    /usr/local/bin/gext -F install dash-to-panel@jderose9.github.com
    /usr/local/bin/gext -F install network-stats@gnome.noroadsleft.xyz
    /usr/local/bin/gext -F install openweather-extension@jenslody.de
    #/usr/local/bin/gext -F install drive-menu@gnome-shell-extensions.gcampax.github.com
    #/usr/local/bin/gext -F install user-theme@gnome-shell-extensions.gcampax.github.com

    echo "Moving gnome extensions to /usr/share/gnome-shell/extensions"
    mv /root/.local/share/gnome-shell/extensions/* /usr/share/gnome-shell/extensions/

    # Enable extensions
    /usr/local/bin/gext -F enable arcmenu@arcmenu.com
    /usr/local/bin/gext -F enable blur-my-shell@aunetx
    /usr/local/bin/gext -F enable customize-ibus@hollowman.ml
    /usr/local/bin/gext -F enable dash-to-panel@jderose9.github.com
    /usr/local/bin/gext -F enable network-stats@gnome.noroadsleft.xyz
    /usr/local/bin/gext -F enable openweather-extension@jenslody.de
    #/usr/local/bin/gext -F enable drive-menu@gnome-shell-extensions.gcampax.github.com
    #/usr/local/bin/gext -F enable user-theme@gnome-shell-extensions.gcampax.github.com

    echo "Apply root's default dconf settings to /etc/skel"
    export $(dbus-launch)
    dconf load /org/gnome/ < /opt/dconf.ini
    dconf write /org/gtk/settings/file-chooser/sort-directories-first true
    mkdir -p /etc/skel/.config/dconf
    cp /root/.config/dconf/user /etc/skel/.config/dconf/user

    echo "Cleaning up"
    /usr/bin/pip3 uninstall gnome-extensions-cli -y
    rm /root/.config/dconf -rf
    rm /root/.local/share/gnome-shell/extensions -rf
    rm /opt/dconf.ini

    echo "Configuring templates..."
    mkdir -p /etc/skel/Templates
    touch /etc/skel/Templates/Text.txt
    touh /etc/skel/Templates/Markdown.md

    echo "Customization complete. Updating ls/os-release files"
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
}

# Used to version the configuration.  If breaking changes occur, manual
# updates to this file from the default may be necessary.
export CONFIG_FILE_VERSION="0.4"
