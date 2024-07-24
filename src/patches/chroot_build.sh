#!/bin/bash

#==========================
# Set up the environment
#==========================
set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

#==========================
# Basic Information
#==========================
export LC_ALL=C
export LANG=en_US.UTF-8
export DEBIAN_FRONTEND=noninteractive
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
export HOME=/root

#==========================
# Color
#==========================
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
OK="${Green}[  OK  ]${Font}"
ERROR="${Red}[FAILED]${Font}"
WARNING="${Yellow}[ WARN ]${Font}"

#==========================
# Print Colorful Text
#==========================
function print_ok() {
  echo -e "${OK} ${Blue} $1 ${Font}"
}

function print_error() {
  echo -e "${ERROR} ${Red} $1 ${Font}"
}

function print_warn() {
  echo -e "${WARNING} ${Yellow} $1 ${Font}"
}

#==========================
# Judge function
#==========================
function judge() {
  if [[ 0 -eq $? ]]; then
    print_ok "$1 succeeded"
    sleep 1
  else
    print_error "$1 failed"
    exit 1
  fi
}

#==========================
# Are you sure function
#==========================
function areYouSure() {
  print_error "This script found some issue and failed to run. Continue may cause system unstable."
  print_error "Are you sure to continue the installation? Enter [y/N] to continue"
  read -r install
  case $install in
  [yY][eE][sS] | [yY])
    print_ok "Continue the installation"
    ;;
  *)
    print_error "Installation terminated"
    exit 1
    ;;
  esac
}

# Load configuration values from file
function load_config() {
    print_ok "Loading configuration from $SCRIPT_DIR/customize.sh..."
    . "$SCRIPT_DIR/customize.sh"
    judge "Load configuration"
}

function check_host() {
    print_ok "Checking host environment..."
    if [ $(id -u) -ne 0 ]; then
        print_error "This script should be run as 'root'"
        exit 1
    fi
    judge "Check host environment"
}

function setup_host() {
    print_ok "Setting up host environment..."

    print_ok "Setting up apt sources..."
   cat << EOF > /etc/apt/sources.list
deb $TARGET_UBUNTU_MIRROR $TARGET_UBUNTU_VERSION main restricted universe multiverse
deb $TARGET_UBUNTU_MIRROR $TARGET_UBUNTU_VERSION-updates main restricted universe multiverse
deb $TARGET_UBUNTU_MIRROR $TARGET_UBUNTU_VERSION-backports main restricted universe multiverse
deb $TARGET_UBUNTU_MIRROR $TARGET_UBUNTU_VERSION-security main restricted universe multiverse
EOF
    judge "Set up apt sources to $TARGET_UBUNTU_MIRROR"

    print_ok "Setting up hostname..."
    echo "$TARGET_NAME" > /etc/hostname
    hostname "$TARGET_NAME"
    judge "Set up hostname to $TARGET_NAME"

    # we need to install systemd first, to configure machine id
    print_ok "Installing systemd..."
    apt update
    apt install -y libterm-readline-gnu-perl systemd-sysv
    judge "Install systemd"

    #configure machine id
    print_ok "Configuring machine id..."
    dbus-uuidgen > /etc/machine-id
    ln -fs /etc/machine-id /var/lib/dbus/machine-id
    judge "Configure machine id"

    # don't understand why, but multiple sources indicate this
    print_ok "Setting up initctl..."
    dpkg-divert --local --rename --add /sbin/initctl
    ln -s /bin/true /sbin/initctl
    judge "Set up initctl"
}

function install_kernel_ubiquity() {
    print_ok "Updating packages. Sleep 10 seconds to wait for network..."
    sleep 10
    apt -y upgrade
    judge "Upgrade packages"

    # install live packages
    print_ok "Installing live packages. Sleep 10 seconds to wait for network..."
    sleep 10
    apt install -y \
        coreutils \
        sudo \
        ubuntu-standard \
        casper \
        discover \
        laptop-detect \
        os-prober \
        network-manager \
        resolvconf \
        net-tools \
        wireless-tools \
        grub-common \
        grub-gfxpayload-lists \
        grub-pc \
        grub-pc-bin \
        grub2-common \
        locales
    judge "Install live packages"

    print_ok "Installing kernel package..."
    apt install -y --no-install-recommends $TARGET_KERNEL_PACKAGE
    judge "Install kernel package"

    # graphic installer - ubiquity
    print_ok "Installing ubiquity (Ubuntu installer)..."
    apt install -y \
        ubiquity \
        ubiquity-casper \
        ubiquity-frontend-gtk \
        ubiquity-slideshow-ubuntu \
        ubiquity-ubuntu-artwork
    judge "Install ubiquity"
}

function customize_image() {
    print_ok "Installing gnome-shell and other packages... Sleep 10 seconds to wait for network..."
    sleep 10

    print_ok "Removing snap packages"
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
    judge "Remove snap packages"

    print_ok "Removing Ubuntu Pro advertisements"
    rm /etc/apt/apt.conf.d/20apt-esm-hook.conf || true
    touch /etc/apt/apt.conf.d/20apt-esm-hook.conf
    pro config set apt_news=false || true
    pro config set motd=false || true
    judge "Remove Ubuntu Pro advertisements"

    print_ok "Adding Mozilla Firefox PPA"
    apt install -y software-properties-common
    add-apt-repository -y ppa:mozillateam/ppa -n
    echo "deb https://mirror-ppa.aiursoft.cn/mozillateam/ppa/ubuntu/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/mozillateam-ubuntu-ppa-$(lsb_release -sc).list
    cat << EOF > /etc/apt/preferences.d/mozilla-firefox
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1002
EOF
    chown root:root /etc/apt/preferences.d/mozilla-firefox
    judge "Add Mozilla Firefox PPA"

    # install graphics and desktop
    print_ok "Updating package list"
    apt update
    judge "Update package list"

    print_ok "Installing gnome-shell and other gnome applications"
    apt install -y \
        ca-certificates gpg apt-transport-https \
        ubuntu-session yaru-theme-sound yaru-theme-gnome-shell \
        plymouth plymouth-label plymouth-theme-spinner plymouth-theme-ubuntu-text plymouth-theme-ubuntu-logo \
        gnome-shell gir1.2-gmenu-3.0 gnome-menus gnome-shell-extensions \
        nautilus usb-creator-gtk cheese baobab file-roller gnome-sushi ffmpegthumbnailer \
        gnome-calculator gnome-disk-utility gnome-control-center software-properties-gtk gnome-logs \
        gnome-tweaks gnome-shell-extension-prefs gnome-shell-extension-desktop-icons-ng gnome-shell-extension-appindicator \
        gnome-screenshot gnome-system-monitor gnome-sound-recorder \
        fonts-noto-cjk fonts-noto-core fonts-noto-mono fonts-noto-color-emoji \
        gnome-clocks \
        gnome-weather \
        gnome-text-editor \
        gnome-nettool \
        seahorse gdebi evince \
        ibus-rime \
        shotwell \
        remmina remmina-plugin-rdp \
        firefox \
        totem \
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
        libsass1 sassc \
        language-pack-zh-hans   language-pack-zh-hans-base language-pack-gnome-zh-hans \
        language-pack-zh-hant   language-pack-zh-hant-base language-pack-gnome-zh-hant \
        language-pack-en        language-pack-en-base      language-pack-gnome-en \
        dmz-cursor-theme
    judge "Install gnome-shell and other gnome applications"

    print_ok "Patching fonts..."
    cp $SCRIPT_DIR/fonts/local.conf /etc/fonts/
    unzip $SCRIPT_DIR/fonts/fonts.zip -d /usr/share/fonts/
    judge "Patch fonts"

    print_ok "Updating font cache"
    fc-cache -f -v
    judge "Update font cache"

    print_ok "Patching Shotwell localization..."
    sed -i '/^Name=/a Name[zh_CN]=图库' /usr/share/applications/shotwell.desktop
    sed -i '/^Name=/a Name[zh_TW]=圖庫' /usr/share/applications/shotwell.desktop
    sed -i '/^X-GNOME-FullName=/a X-GNOME-FullName[zh_CN]=图库' /usr/share/applications/shotwell.desktop
    sed -i '/^X-GNOME-FullName=/a X-GNOME-FullName[zh_TW]=圖庫' /usr/share/applications/shotwell.desktop

    # Redirect /usr/local/bin/gnome-terminal -> /usr/bin/kgx
    print_ok "Redirect /usr/local/bin/gnome-terminal -> /usr/bin/kgx"
    ln -s /usr/bin/kgx /usr/local/bin/gnome-terminal
    judge "Redirect /usr/local/bin/gnome-terminal -> /usr/bin/kgx"

    # Patch plymouth, use AnduinOS's logo at $SCRIPT_DIR/logo.svg to replace the default ubuntu logo. Patch the text to show "AnduinOS"
    print_ok "Patch plymouth"
    cp $SCRIPT_DIR/logo/logo_128.png      /usr/share/plymouth/themes/spinner/bgrt-fallback.png
    cp $SCRIPT_DIR/logo/anduinos_text.png /usr/share/plymouth/ubuntu-logo.png
    cp $SCRIPT_DIR/logo/anduinos_text.png /usr/share/plymouth/themes/spinner/watermark.png
    update-initramfs -u
    judge "Patch plymouth and update initramfs"

    print_ok "Patch Ubiquity installer"
    rsync -Aavx --update --delete $SCRIPT_DIR/slides/ /usr/share/ubiquity-slideshow/slides/
    #sed -i "s|background-color:#3C3B37;|background-color:#132F5E;|g" /usr/share/ubiquity-slideshow/slides/link/base.css
    judge "Patch Ubiquity installer"

    print_ok "Installing ibus-rime configuration"
    wget https://github.com/iDvel/rime-ice/archive/refs/heads/main.zip -O /tmp/main.zip
    unzip /tmp/main.zip -d /tmp/rime-ice-main
    mkdir -p /etc/skel/.config/ibus/rime
    mv /tmp/rime-ice-main/rime-ice-main/* /etc/skel/.config/ibus/rime/ -f
    rm -rf /tmp/rime-ice-main
    rm /tmp/main.zip
    judge "Install ibus-rime configuration"

    print_ok "Removing the hint for sudo"
    if grep -q "sudo hint" /etc/bash.bashrc; then
        sed -i '43,54d' /etc/bash.bashrc
        judge "Remove the hint for sudo"
    else
        print_error "Error: 'sudo hint' not found in /etc/bash.bashrc."
        exit 1
    fi

    print_ok "Purging unnecessary packages"
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
        update-manager-core \
        gnome-shell-extension-ubuntu-dock \
        libreoffice-* \
        yaru-theme-unity yaru-theme-icon yaru-theme-gtk \
        yelp \
        info > /dev/null
    # Above remove everything about yaru-theme but keeps yaru-theme-sound and yaru-theme-gnome-shell (Required by Ubuntu session)
    judge "Purge unnecessary packages"

    # Edit default wallpaper
    print_ok "Cleaning and reinstalling wallpaper"
    rm /usr/share/gnome-background-properties/* -rf
    rm /usr/share/backgrounds/* -rf
    mv $SCRIPT_DIR/wallpaper/Fluent-building-night.png /usr/share/backgrounds/
cat << EOF > /usr/share/gnome-background-properties/fluent.xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
  <wallpaper deleted="false">
    <name>Fluent Building Night</name>
    <filename>/usr/share/backgrounds/Fluent-building-night.png</filename>
    <filename-dark>/usr/share/backgrounds/Fluent-building-night.png</filename-dark>
    <options>zoom</options>
    <shade_type>solid</shade_type>
  </wallpaper>
</wallpapers>
EOF
    judge "Clean and reinstall wallpaper"

    print_ok "Installing Fluent icon theme"
    git clone https://git.aiursoft.cn/PublicVault/Fluent-icon-theme $SCRIPT_DIR/themes/Fluent-icon-theme
    $SCRIPT_DIR/themes/Fluent-icon-theme/install.sh standard
    judge "Install Fluent icon theme"

    print_ok "Installing Fluent theme"
    git clone https://git.aiursoft.cn/PublicVault/Fluent-gtk-theme $SCRIPT_DIR/themes/Fluent-gtk-theme
    $SCRIPT_DIR/themes/Fluent-gtk-theme/install.sh -i ubuntu --tweaks noborder round
    judge "Install Fluent theme"

    print_ok "Installing gnome extensions"
    /usr/bin/pip3 install --upgrade gnome-extensions-cli
    /usr/local/bin/gext -F install arcmenu@arcmenu.com
    /usr/local/bin/gext -F install blur-my-shell@aunetx
    /usr/local/bin/gext -F install customize-ibus@hollowman.ml
    /usr/local/bin/gext -F install dash-to-panel@jderose9.github.com
    /usr/local/bin/gext -F install network-stats@gnome.noroadsleft.xyz
    /usr/local/bin/gext -F install openweather-extension@jenslody.de
    judge "Install gnome extensions"

    print_ok "Moving root's gnome extensions to /usr/share/gnome-shell/extensions"
    rm /usr/share/gnome-shell/extensions/apps-menu* -rf
    rm /usr/share/gnome-shell/extensions/auto-move-windows* -rf
    rm /usr/share/gnome-shell/extensions/launch-new-instance* -rf
    rm /usr/share/gnome-shell/extensions/native-window-placement* -rf
    rm /usr/share/gnome-shell/extensions/places-menu* -rf
    rm /usr/share/gnome-shell/extensions/screenshot-window-sizer* -rf
    rm /usr/share/gnome-shell/extensions/window-list* -rf
    rm /usr/share/gnome-shell/extensions/windowsNavigator* -rf
    rm /usr/share/gnome-shell/extensions/workspace-indicator* -rf
    mv /root/.local/share/gnome-shell/extensions/* /usr/share/gnome-shell/extensions/
    mv $SCRIPT_DIR/logo/logo.svg /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/icons/anduinos-logo.svg
    judge "Move root's gnome extensions"

    print_ok "Patching Arc Menu..."
    sed -i 's/Unpin from ArcMenu/Unpin from Start menu/g' /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/appMenu.js
    sed -i 's/Pin to ArcMenu/Pin to Start menu/g' /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/appMenu.js
    judge "Patch Arc Menu"

    # print_ok "Patching localization..."
    # msgunfmt /usr/share/locale/zh_CN/LC_MESSAGES/gnome-shell-extensions.mo -o gnome-shell.po
    # sed -i 's/收藏/任务栏/g' gnome-shell.po
    # msgfmt gnome-shell.po -o /usr/share/locale/zh_CN/LC_MESSAGES/gnome-shell-extensions.mo

    print_ok "Enabling gnome extensions for root"
    /usr/local/bin/gext -F enable arcmenu@arcmenu.com
    /usr/local/bin/gext -F enable blur-my-shell@aunetx
    /usr/local/bin/gext -F enable customize-ibus@hollowman.ml
    /usr/local/bin/gext -F enable dash-to-panel@jderose9.github.com
    /usr/local/bin/gext -F enable network-stats@gnome.noroadsleft.xyz
    /usr/local/bin/gext -F enable openweather-extension@jenslody.de
    judge "Enable gnome extensions"

    print_ok "Loading dconf settings"
    export $(dbus-launch)
    dconf load /org/gnome/ < $SCRIPT_DIR/dconf/dconf.ini
    dconf write /org/gtk/settings/file-chooser/sort-directories-first true
    judge "Load dconf settings"

    print_ok "Copying root's dconf settings to /etc/skel"
    mkdir -p /etc/skel/.config/dconf
    cp /root/.config/dconf/user /etc/skel/.config/dconf/user
    judge "Copy root's dconf settings to /etc/skel"

    print_ok "Cleaning up"
    /usr/bin/pip3 uninstall gnome-extensions-cli -y
    rm /root/.config/dconf -rf
    rm /root/.local/share/gnome-shell/extensions -rf
    judge "Clean up"

    print_ok "Configuring templates..."
    mkdir -p /etc/skel/Templates
    touch /etc/skel/Templates/Text.txt
    touch /etc/skel/Templates/Markdown.md
    judge "Configure templates"

    print_ok "Customization complete. Updating ls/os-release files"
    cat << EOF > /etc/lsb-release
DISTRIB_ID=$TARGET_BUSINESS_NAME
DISTIRB_RELEASE=$TARGET_BUILD_VERSION
DISTIRB_CODENAME=$TARGET_UBUNTU_VERSION
DISTIRB_DESCRIPTION="$TARGET_BUSINESS_NAME $TARGET_BUILD_VERSION based on Ubuntu $TARGET_UBUNTU_VERSION
EOF
    judge "Update lsb-release"

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
    judge "Update os-release"
}

function clean_up() {
    # remove unused and clean up apt cache
    print_ok "Removing unused packages..."
    apt autoremove -y
    judge "Remove unused packages"

    # final touch
    print_ok "Configuring locales and resolvconf..."
    dpkg-reconfigure locales
    dpkg-reconfigure resolvconf
    judge "Configure locales and resolvconf"

    print_ok "Configuring network manager..."
    cat << EOF > /etc/NetworkManager/NetworkManager.conf
[main]
rc-manager=resolvconf
plugins=ifupdown,keyfile
dns=dnsmasq

[ifupdown]
managed=false
EOF
    dpkg-reconfigure network-manager
    judge "Configure network manager"

    print_ok "Cleaning up apt cache..."
    apt clean -y
    judge "Clean up apt cache"
}

function finish_up() { 

    # truncate machine id (why??)
    print_ok "Truncating machine id..."
    truncate -s 0 /etc/machine-id
    truncate -s 0 /var/lib/dbus/machine-id

    # remove diversion (why??)
    print_ok "Removing diversion..."
    rm /sbin/initctl
    dpkg-divert --rename --remove /sbin/initctl
    judge "Remove diversion"

    # remove bash history
    print_ok "Removing bash history and temporary files..."
    rm -rf /tmp/* ~/.bash_history
    judge "Remove bash history and temporary files"
}

# =============   main  ================
load_config
check_host
setup_host
install_kernel_ubiquity
customize_image
clean_up
finish_up
echo "$0 - Initial build is done!"

