#!/bin/bash

export TARGET_UBUNTU_VERSION="jammy"
export TARGET_UBUNTU_MIRROR="http://mirror.aiursoft.cn/ubuntu/"
export TARGET_KERNEL_PACKAGE="linux-generic-hwe-22.04"
export TARGET_NAME="anduinos"
export TARGET_BUSINESS_NAME="AnduinOS"
export TARGET_BUILD_VERSION="0.0.4-alpha"
export GRUB_LIVEBOOT_LABEL="Try AnduinOS"
export GRUB_INSTALL_LABEL="Install AnduinOS"
export TARGET_PACKAGE_REMOVE="
    ubiquity \
    casper \
    discover \
    laptop-detect \
    os-prober \
"

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
    ca-certificates gpg apt-transport-https \
    plymouth plymouth-label plymouth-theme-spinner plymouth-theme-ubuntu-text plymouth-theme-ubuntu-logo \
    gnome-shell gir1.2-gmenu-3.0 gnome-menus gnome-shell-extensions \
    nautilus usb-creator-gtk cheese baobab file-roller gnome-sushi ffmpegthumbnailer \
    gnome-calculator gnome-disk-utility gnome-control-center software-properties-gtk gnome-logs \
    gnome-tweaks gnome-shell-extension-prefs gnome-shell-extension-desktop-icons-ng gnome-shell-extension-appindicator \
    gnome-screenshot \
    gnome-clocks \
    gnome-weather \
    gnome-text-editor \
    gnome-nettool \
    seahorse gdebi evince \
    ibus-rime \
    shotwell \
    remmina remmina-plugin-rdp \
    firefox \
    vlc \
    gnome-console nautilus-extension-gnome-console \
    python3-apt python3-pip python-is-python3 \
    git neofetch lsb-release coreutils \
    gnupg vim nano \
    wget curl \
    httping nethogs net-tools iftop traceroute dnsutils iperf3 \
    smartmontools \
    htop iotop iftop \
    tree ntp ntpdate ntpstat \
    w3m sysbench \
    zip unzip jq \
    cifs-utils \
    aisleriot \
    language-pack-gnome-zh-hans \
    dmz-cursor-theme

    # Redirect /usr/local/bin/gnome-terminal -> /usr/bin/kgx
    ln -s /usr/bin/kgx /usr/local/bin/gnome-terminal

    # Patch plymouth, use AnduinOS's logo at /opt/theme/logo.svg to replace the default ubuntu logo. Patch the text to show "AnduinOS"
    echo "Patch plymouth"
    cp /opt/theme/logo_128.png /usr/share/plymouth/themes/spinner/bgrt-fallback.png
    cp /opt/theme/anduinos_text.png /usr/share/plymouth/ubuntu-logo.png
    cp /opt/theme/anduinos_text.png /usr/share/plymouth/themes/spinner/watermark.png
    update-initramfs -u

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
        gnome-system-monitor \
        info

    # Edit default wallpaper
    echo "Downloading default wallpaper"
    wget -O /usr/share/backgrounds/Fluent-building-night.png https://github.com/vinceliuice/Fluent-gtk-theme/raw/Wallpaper/wallpaper-4k/Fluent-building-night.png

    echo "Installing Fluent icon theme"
    git clone https://git.aiursoft.cn/PublicVault/Fluent-icon-theme /opt/themes/Fluent-icon-theme
    /opt/themes/Fluent-icon-theme/install.sh
    rm /opt/themes/Fluent-icon-theme -rf

    echo "Installing Fluent theme"
    git clone https://git.aiursoft.cn/PublicVault/Fluent-gtk-theme /opt/themes/Fluent-gtk-theme
    apt install libsass1 sassc -y
    /opt/themes/Fluent-gtk-theme/install.sh -i ubuntu --tweaks noborder round
    rm /opt/themes/Fluent-gtk-theme -rf
    rm /opt/themes -rf

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
    touch /etc/skel/Templates/Markdown.md

    echo "Customization complete. Updating ls/os-release files"
    cat << EOF > /etc/lsb-release
DISTRIB_ID=$TARGET_BUSINESS_NAME
DISTIRB_RELEASE=$TARGET_BUILD_VERSION
DISTIRB_CODENAME=$TARGET_UBUNTU_VERSION
DISTIRB_DESCRIPTION="$TARGET_BUSINESS_NAME $TARGET_BUILD_VERSION based on Ubuntu $TARGET_UBUNTU_VERSION
EOF

    cat << EOF > /etc/os-release
PRETTY_NAME="$TARGET_BUSINESS_NAME $TARGET_BUILD_VERSION"
NAME="$TARGET_BUSINESS_NAME"
VERSION_ID="$TARGET_BUILD_VERSION"
VERSION="$TARGET_BUILD_VERSION ($TARGET_UBUNTU_VERSION)"
VERSION_CODENAME=$TARGET_UBUNTU_VERSION
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://github.com/Anduin2017/AnduinOS/discussions"
BUG_REPORT_URL="https://github.com/Anduin2017/AnduinOS/issues"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=$TARGET_UBUNTU_VERSION
EOF

    echo "Customization complete.  Rebooting in 10 seconds."
}
