#!/bin/bash
#==========================
# Set up the environment
#==========================
set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error
export DEBIAN_FRONTEND=noninteractive
export LATEST_VERSION="1.0.4"
export CURRENT_VERSION=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -d "=" -f 2)

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
    sleep 0.2
  else
    print_error "$1 failed"
    exit 1
  fi
}

function ensureCurrentOsAnduinOs() {
    # Ensure the current OS is AnduinOS
    if ! grep -q "DISTRIB_ID=AnduinOS" /etc/lsb-release; then
        print_error "This script can only be run on AnduinOS."
        exit 1
    fi
}

function upgrade_010_to_011() {
    # Add your upgrade steps from 0.1.0 to 0.1.1 here
    print_ok "Upgrading from 0.1.0 to 0.1.1"

    print_ok "Adding do_anduinos_upgrade command"
    sudo bash -c 'cat << EOF > /usr/local/bin/do_anduinos_upgrade
#!/bin/bash
echo "Upgrading AnduinOS..."
curl -sSL https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/master/src/upgrade.sh | bash
EOF
'
    sudo chmod +x /usr/local/bin/do_anduinos_upgrade
    judge "Add do_anduinos_upgrade command"

    print_ok "Adding new app called AnduinOS Software..."
    sudo bash -c 'cat << EOF > /usr/share/applications/anduinos-software.desktop
[Desktop Entry]
Name=Apps Store
GenericName=Apps Store
Name[zh_CN]=应用商店
Name[zh_TW]=應用商店
Comment=Browse AnduinOS software collection and install our verified applications
Comment[zh_CN]=浏览 AnduinOS 的软件商店并安装我们验证过的应用
Comment[zh_TW]=瀏覽 AnduinOS 的軟體商店並安裝我們驗證過的應用
Categories=System;
Exec=xdg-open https://docs.anduinos.com/Applications/Introduction.html
Terminal=false
Type=Application
Icon=system-software-install
StartupNotify=true
EOF
'
    judge "Add new app called AnduinOS Software"
    sleep 5
}

function upgrade_011_to_012() {
    # Add your upgrade steps from 0.1.1 to 0.1.2 here
    print_ok "Upgrading from 0.1.1 to 0.1.2"

    print_ok "Installing ubuntu-drivers-common"
    sudo apt install ubuntu-drivers-common -y
    judge "Install ubuntu-drivers-common"

    print_ok "Removing /etc/update-manager/, /etc/update-motd.d/"
    sudo rm /etc/update-manager/ -rf
    sudo rm /etc/update-motd.d/ -rf
    judge "Removing /etc/update-manager/, /etc/update-motd.d/"

    print_ok "Upgrade to 0.1.2-beta succeeded"
    sleep 5
}

function upgrade_012_to_013() {
    # Add your upgrade steps from 0.1.2 to 0.1.3 here
    print_ok "Upgrading from 0.1.2 to 0.1.3"

    print_ok "Installing fluent-cursor-theme"
    (
        cd /tmp
        sudo rm -rf /tmp/Fluent-icon-theme || true
        git clone https://git.aiursoft.cn/PublicVault/Fluent-icon-theme.git
        cd /tmp/Fluent-icon-theme/cursors
        mkdir -p /usr/share/icons
        sudo bash -c /tmp/Fluent-icon-theme/cursors/install.sh
        gsettings set org.gnome.desktop.interface cursor-theme 'Fluent-dark-cursors'
        rm -rf /tmp/Fluent-icon-theme
    )
    judge "Install fluent-cursor-theme"

    print_ok "Installing new plugin..."
    (
        cd /tmp
        sudo rm -rf /tmp/repo || true
        mkdir -p /tmp/repo
        git clone -b 0.1.3 https://gitlab.aiursoft.cn/anduin/anduinos.git /tmp/repo
        sudo rsync -Aavx --update --delete /tmp/repo/src/patches/switcher@anduinos/* /usr/share/gnome-shell/extensions/switcher@anduinos

        sudo cp /tmp/repo/src/patches/wallpaper/Fluent-building-light.png /usr/share/backgrounds/
        sudo cp /tmp/repo/src/patches/wallpaper/Fluent-building-night.png /usr/share/backgrounds/

        dconf load /org/gnome/ < /tmp/repo/src/patches/dconf/dconf.ini
        gnome-extensions enable switcher@anduinos || true

        sudo mkdir -p /etc/skel/.config/gtk-3.0/
        mkdir -p ~/.config/gtk-3.0/
        sudo cp /tmp/repo/src/patches/gtk-3.0/gtk.css /etc/skel/.config/gtk-3.0/
        sudo cp /tmp/repo/src/patches/gtk-3.0/gtk.css ~/.config/gtk-3.0/
        rm -rf /tmp/repo
    )
    judge "Install new plugin"

    print_ok "Patching /etc/os-release"
    # Replace HOME_URL="https://www.ubuntu.com/" to HOME_URL="https://www.anduinos.com/"
    sudo sed -i "s/HOME_URL=.*/HOME_URL=\"https:\/\/www.anduinos.com\/\"/" /etc/os-release
    judge "Patch /etc/os-release"

    print_ok "Upgrade to 0.1.3-beta succeeded"
    sleep 5
}

function upgrade_013_to_014() {
    # Add your upgrade steps from 0.1.3 to 0.1.4 here
    print_ok "Upgrading from 0.1.3 to 0.1.4"

    print_ok "Loading new dconf settings..."
    (
        cd /tmp
        sudo rm -rf /tmp/repo || true
        mkdir -p /tmp/repo
        git clone -b 0.1.4 https://gitlab.aiursoft.cn/anduin/anduinos.git /tmp/repo
        sudo rsync -Aavx --update --delete /tmp/repo/src/patches/switcher@anduinos/* /usr/share/gnome-shell/extensions/switcher@anduinos

        dconf load /org/gnome/ < /tmp/repo/src/patches/dconf/dconf.ini
        gnome-extensions disable switcher@anduinos || true
        gnome-extensions enable switcher@anduinos || true

        print_ok "Patching Arc Menu..."
        sudo sed -i 's/Unpin from ArcMenu/Unpin from Start menu/g' /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/appMenu.js
        sudo sed -i 's/Pin to ArcMenu/Pin to Start menu/g' /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/appMenu.js
        sudo sed -i "s/_('Log Out...')/_('Log Out')/" /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/constants.js
        sudo sed -i "s/_('Restart...')/_('Restart')/" /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/constants.js
        sudo sed -i "s/_('Power Off...')/_('Power Off')/" /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/constants.js

        msgunfmt /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/locale/zh_CN/LC_MESSAGES/arcmenu.mo -o /tmp/arcmenu.po
        if grep_result=$(grep -q "Pin to Start menu" /tmp/arcmenu.po); then
            print_warn "The string 'Pin to Start menu' is already present in /tmp/arcmenu.po"
        else
            cat /tmp/repo/src/patches/arcmenu/arcmenu.po >> /tmp/arcmenu.po
        fi

        sed -i "s/新建/新增/g" /tmp/arcmenu.po
        sudo msgfmt /tmp/arcmenu.po -o /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/locale/zh_CN/LC_MESSAGES/arcmenu.mo
        rm /tmp/arcmenu.po
        judge "Patch Arc Menu"

        print_ok "Patching Dash-to-panel"
        msgunfmt /usr/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/locale/zh_CN/LC_MESSAGES/dash-to-panel.mo -o /tmp/dash-to-panel.po
        sudo sed -i "s/Dash to Panel 设置/任务栏设置/g" /tmp/dash-to-panel.po
        sudo msgfmt /tmp/dash-to-panel.po -o /usr/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/locale/zh_CN/LC_MESSAGES/dash-to-panel.mo
        rm /tmp/dash-to-panel.po
        judge "Patch Dash-to-panel"

        print_ok "Patching Gnome Shell..."
        msgunfmt /usr/share/locale-langpack/zh_CN/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
        sed -i "s/收藏夹/任务栏/g" /tmp/gnome-shell.po
        sudo msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/zh_CN/LC_MESSAGES/gnome-shell.mo
        rm /tmp/gnome-shell.po
        judge "Patch Gnome Shell"
        rm -rf /tmp/repo
    )
    judge "Load new dconf settings"

    print_ok "Installing cups and system-config-printer"
    sudo apt install cups system-config-printer -y
    judge "Install cups and system-config-printer"

    print_ok "Upgrade to 0.1.4-beta succeeded"
    sleep 5
}

function upgrade_014_to_020() {
    # Add your upgrade steps from 0.1.4 to 0.2.0 here
    print_ok "Upgrading from 0.1.4 to 0.2.0"

    print_ok "Installing new plugin..."
    (
        cd /tmp
        sudo rm -rf /tmp/repo || true
        mkdir -p /tmp/repo
        git clone -b 0.2.0 https://gitlab.aiursoft.cn/anduin/anduinos.git /tmp/repo
        sudo rsync -Aavx --update --delete /tmp/repo/src/patches/switcher@anduinos/* /usr/share/gnome-shell/extensions/switcher@anduinos
        dconf load /org/gnome/ < /tmp/repo/src/patches/dconf/dconf.ini
    )
    judge "Install new plugin"

    print_ok "Installing new kernel..."
    sudo apt update
    sudo apt install -y \
        linux-headers-generic-hwe-22.04 \
        linux-image-generic-hwe-22.04
    judge "Install new kernel"

    print_ok "Installing new packages..."
    sudo apt install -y alsa-utils apparmor apt-utils bash-completion bind9-dnsutils busybox-static command-not-found \
                        coreutils cpio cron dmidecode dosfstools ed file firmware-sof-signed ftp grub-common \
                        grub-gfxpayload-lists grub-pc grub-pc-bin grub2-common hdparm iproute2 iptables \
                        iputils-ping iputils-tracepath irqbalance laptop-detect libpam-systemd linux-firmware \
                        locales logrotate lshw lsof man-db manpages media-types mtr-tiny net-tools network-manager \
                        nftables openssh-client os-prober parted pciutils plymouth plymouth-theme-ubuntu-text psmisc \
                        resolvconf rsync strace sudo tcpdump telnet time ufw usbutils uuid-runtime wget wireless-tools xz-utils
    judge "Install new packages"
    
    print_ok "Setting up /usr/share/gnome-sessions/sessions..."
    sudo sed -i 's/Ubuntu/AnduinOS/g' /usr/share/gnome-session/sessions/ubuntu.session
    judge "Set up /usr/share/gnome-sessions/sessions"

    print_ok "Setting up /usr/share/xsessions..."
    sudo rm /usr/share/xsessions/gnome* || print_warn "No gnome* files found"
    sudo mv /usr/share/xsessions/ubuntu.desktop /usr/share/xsessions/anduinos.desktop || print_warn "No ubuntu.desktop file found"
    sudo mv /usr/share/xsessions/ubuntu-xorg.desktop /usr/share/xsessions/anduinos-xorg.desktop || print_warn "No ubuntu-xorg.desktop file found"
    sudo sed -i 's/Name=Ubuntu/Name=AnduinOS/g' /usr/share/xsessions/anduinos.desktop
    sudo sed -i 's/Name=Ubuntu/Name=AnduinOS/g' /usr/share/xsessions/anduinos-xorg.desktop
    judge "Set up /usr/share/xsessions"

    print_ok "Setting up /usr/share/wayland-sessions..."
    sudo rm /usr/share/wayland-sessions/gnome* || print_warn "No gnome* files found"
    sudo mv /usr/share/wayland-sessions/ubuntu.desktop /usr/share/wayland-sessions/anduinos.desktop || print_warn "No ubuntu.desktop file found"
    sudo mv /usr/share/wayland-sessions/ubuntu-wayland.desktop /usr/share/wayland-sessions/anduinos-wayland.desktop || print_warn "No ubuntu-wayland.desktop file found"
    sudo sed -i 's/Name=Ubuntu/Name=AnduinOS/g' /usr/share/wayland-sessions/anduinos.desktop
    sudo sed -i 's/Name=Ubuntu/Name=AnduinOS/g' /usr/share/wayland-sessions/anduinos-wayland.desktop
    judge "Set up /usr/share/wayland-sessions"

    print_ok "Upgrade to 0.1.5-beta succeeded"
    sleep 5
}

function upgrade_020_to_021() {
    # Add your upgrade steps from 0.2.0 to 0.2.1 here
    print_ok "Upgrading from 0.2.0 to 0.2.1"

    sudo apt update
    sudo apt install gedit fprintd libpam-fprintd baobab -y

    print_ok "Installing new plugin..."
    (
        cd /tmp
        sudo rm -rf /tmp/repo || true
        mkdir -p /tmp/repo
        git clone -b 0.2.1 https://gitlab.aiursoft.cn/anduin/anduinos.git /tmp/repo
        dconf load /org/gnome/ < /tmp/repo/src/mods/34-dconf-patch/dconf.ini 
    )
    judge "Install new plugin"

    print_ok "Patching localization..."
    sudo sed -i '/^Name=/a Name[zh_CN]=磁盘分析' /usr/share/applications/org.gnome.baobab.desktop
    sudo sed -i '/^Name=/a Name[zh_TW]=磁碟分析' /usr/share/applications/org.gnome.baobab.desktop
    sudo sed -i '/^X-GNOME-FullName=/a X-GNOME-FullName[zh_CN]=磁盘分析' /usr/share/applications/org.gnome.baobab.desktop
    sudo sed -i '/^X-GNOME-FullName=/a X-GNOME-FullName[zh_TW]=磁碟分析' /usr/share/applications/org.gnome.baobab.desktop
    judge "Patch localization"

    # if have ibus-rime installed, then install anduinos-rime
    if dpkg -l | grep -q "ibus-rime"; then
        print_ok "Installing anduinos-rime..."
        zip=https://gitlab.aiursoft.cn/anduin/anduinos-rime/-/archive/master/anduinos-rime-master.zip
        wget $zip -O anduinos-rime.zip && unzip anduinos-rime.zip && rm anduinos-rime.zip
        rsync -Aavx --update --delete ./anduinos-rime-master/assets/ ~/.config/ibus/rime/
        rm -rf anduinos-rime-master
        ibus restart
        ibus engine rime
        echo "Please logout and login to start AnduinOS-Rime!"
    fi

    print_ok "Upgrade to 0.2.1-beta succeeded"
    sleep 5
}

function upgrade_021_to_022() {
    # Add your upgrade steps from 0.2.1 to 0.2.2 here
    print_ok "Upgrading from 0.2.1 to 0.2.2"
    print_ok "Upgrade to 0.2.2-beta succeeded"
    sleep 5
}

function upgrade_022_to_030() {
    # Add your upgrade steps from 0.2.2 to 0.3.0 here
    print_ok "Upgrading from 0.2.2 to 0.3.0"
    print_ok "Upgrade to 0.3.0-rc succeeded"
    sleep 5
}

function upgrade_030_to_031() {
    print_ok "Loading new dconf settings..."
    (
        cd /tmp
        sudo rm -rf /tmp/repo || true
        mkdir -p /tmp/repo
        git clone -b 0.3.1 https://gitlab.aiursoft.cn/anduin/anduinos.git /tmp/repo

        print_ok "Applying new dconf settings..."
        dconf load /org/gnome/ < /tmp/repo/src/mods/34-dconf-patch/dconf.ini
        judge "Apply new dconf settings"

        print_ok "Copying new files..."
        sudo cp /tmp/repo/src/mods/34-dconf-patch/anduinos_text_smaller.png /usr/share/pixmaps/anduinos_text_smaller.png
        sudo cp /tmp/repo/src/mods/34-dconf-patch/greeter.dconf-defaults.ini /etc/gdm3/greeter.dconf-defaults
        judge "Copy new files"

        print_ok "Updating dconf..."
        sudo dconf update
        judge "Update dconf"

        rm -rf /tmp/repo
    )

    print_ok "Installing new apps..."
    sudo apt install -y gnome-characters gnome-font-viewer gnome-chess
    judge "Install new apps"

    print_ok "Upgrade to 0.3.1-rc succeeded"
    sleep 5
}

function upgrade_031_to_100() {
    print_ok "Upgrading from 0.3.1 to 1.0.0"

    print_ok "Remove the default htop.desktop file"
    sudo rm /usr/share/applications/htop.desktop || print_warn "No htop.desktop file found"
    judge "Remove the default htop.desktop file"

    print_ok "Adding new command to this OS: toggle_network_stats..."
    sudo tee /usr/local/bin/toggle_network_stats > /dev/null << 'EOF'
#!/bin/bash
status=$(gnome-extensions show "network-stats@gnome.noroadsleft.xyz" | grep "State" | awk '{print $2}')
if [ "$status" == "ENABLED" ]; then
    gnome-extensions disable network-stats@gnome.noroadsleft.xyz
    echo "Disabled network state display"
else
    gnome-extensions enable network-stats@gnome.noroadsleft.xyz
    echo "Enabled network state display"
fi
EOF
    sudo chmod +x /usr/local/bin/toggle_network_stats
    judge "Add new command toggle_network_stats"

    (
        cd /tmp
        sudo rm -rf /tmp/repo || true
        mkdir -p /tmp/repo
        git clone -b 1.0.0 https://gitlab.aiursoft.cn/anduin/anduinos.git /tmp/repo

        print_ok "Applying new dconf settings..."
        dconf load /org/gnome/ < /tmp/repo/src/mods/34-dconf-patch/dconf.ini
        judge "Apply new dconf settings"

        print_ok "Updating dconf..."
        sudo dconf update
        judge "Update dconf"

        rm -rf /tmp/repo
    )

    print_ok "Upgrade to 1.0.0 succeeded"
    sleep 5
}

function upgrade_100_to_101() {
    # Add your upgrade steps from 1.0.0 to 1.0.1 here
    print_ok "Upgrading from 1.0.0 to 1.0.1"

    print_ok "Hold base-files"
    sudo apt-mark hold base-files
    judge "Hold base-files"

    print_ok "Upgrade to 1.0.1 succeeded"
    sleep 5
}

function upgrade_101_to_102() {
    # Add your upgrade steps from 1.0.1 to 1.0.2 here
    print_ok "Upgrading from 1.0.1 to 1.0.2"

    print_ok "Installing new apps..."
    sudo apt install -y qalculate-gtk
    judge "Install new apps"

    print_ok "Upgrade to 1.0.2 succeeded"
    sleep 5
}

function upgrade_102_to_103() {
    # Add your upgrade steps from 1.0.2 to 1.0.3 here
    print_ok "Upgrading from 1.0.2 to 1.0.3"

    print_ok "Installing new apps..."
    sudo apt install -y \
        gnome-bluetooth \
        gnome-power-manager \
        gnome-maps
    judge "Install new apps"

    print_ok "Upgrade to 1.0.3 succeeded"
    sleep 5
}

function upgrade_103_to_104() {
    # Add your upgrade steps from 1.0.3 to 1.0.4 here
    print_ok "Upgrading from 1.0.3 to 1.0.4"

    print_ok "Installing new apps..."
    sudo apt install -y \
        yelp gnome-user-docs
    judge "Install new apps"

    print_ok "Upgrade to 1.0.4 succeeded"
    sleep 5
}

function applyLsbRelease() {
    # Update /etc/lsb-release
    sudo sed -i "s/DISTRIB_RELEASE=.*/DISTRIB_RELEASE=${LATEST_VERSION}/" /etc/lsb-release
    sudo sed -i "s/DISTRIB_DESCRIPTION=.*/DISTRIB_DESCRIPTION=\"AnduinOS ${LATEST_VERSION}\"/" /etc/lsb-release
    
    # Update /etc/os-release
    sudo sed -i "s/VERSION_ID=.*/VERSION_ID=\"${LATEST_VERSION}\"/" /etc/os-release
    sudo sed -i "s/VERSION=.*/VERSION=\"${LATEST_VERSION} (jammy)\"/" /etc/os-release
    sudo sed -i "s/PRETTY_NAME=.*/PRETTY_NAME=\"AnduinOS ${LATEST_VERSION}\"/" /etc/os-release

    # Update /etc/issue
    echo "AnduinOS ${LATEST_VERSION} \n \l
" | sudo tee /etc/issue

    # Update /usr/lib/os-release
    sudo cp /etc/os-release /usr/lib/os-release
}

function main() {
    print_ok "Current version is: ${CURRENT_VERSION}. Checking for updates..."

    # Ensure the current OS is AnduinOS
    ensureCurrentOsAnduinOs

    # Compare current version with latest version
    if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
        print_ok "Your system is already up to date. No update available."
        exit 0
    fi

    print_ok "This script will upgrade your system to version ${LATEST_VERSION}..."
    print_ok "Please press CTRL+C to cancel... Countdown will start in 5 seconds..."
    sleep 5

    # Run necessary upgrades based on current version
    case "$CURRENT_VERSION" in
        "0.1.0-beta")
            upgrade_010_to_011
            upgrade_011_to_012
            upgrade_012_to_013
            upgrade_013_to_014
            upgrade_014_to_020
            upgrade_020_to_021
            upgrade_021_to_022
            upgrade_022_to_030
            upgrade_030_to_031
            upgrade_031_to_100
            upgrade_100_to_101
            upgrade_101_to_102
            upgrade_102_to_103
            upgrade_103_to_104
            ;;
        "0.1.1-beta")
            upgrade_011_to_012
            upgrade_012_to_013
            upgrade_013_to_014
            upgrade_014_to_020
            upgrade_020_to_021
            upgrade_021_to_022
            upgrade_022_to_030
            upgrade_030_to_031
            upgrade_031_to_100
            upgrade_100_to_101
            upgrade_101_to_102
            upgrade_102_to_103
            upgrade_103_to_104
            ;;
        "0.1.2-beta")
            upgrade_012_to_013
            upgrade_013_to_014
            upgrade_014_to_020
            upgrade_020_to_021
            upgrade_021_to_022
            upgrade_022_to_030
            upgrade_030_to_031
            upgrade_031_to_100
            upgrade_100_to_101
            upgrade_101_to_102
            upgrade_102_to_103
            upgrade_103_to_104
            ;;
        "0.1.3-beta")
            upgrade_013_to_014
            upgrade_014_to_020
            upgrade_020_to_021
            upgrade_021_to_022
            upgrade_022_to_030
            upgrade_030_to_031
            upgrade_031_to_100
            upgrade_100_to_101
            upgrade_101_to_102
            upgrade_102_to_103
            upgrade_103_to_104
            ;;
        "0.1.4-beta")
            upgrade_014_to_020
            upgrade_020_to_021
            upgrade_021_to_022
            upgrade_022_to_030
            upgrade_030_to_031
            upgrade_031_to_100
            upgrade_100_to_101
            upgrade_101_to_102
            upgrade_102_to_103
            upgrade_103_to_104
            ;;
        "0.2.0-beta")
            upgrade_020_to_021
            upgrade_021_to_022
            upgrade_022_to_030
            upgrade_030_to_031
            upgrade_031_to_100
            upgrade_100_to_101
            upgrade_101_to_102
            upgrade_102_to_103
            upgrade_103_to_104
            ;;
        "0.2.1-beta")
            upgrade_021_to_022
            upgrade_022_to_030
            upgrade_030_to_031
            upgrade_031_to_100
            upgrade_100_to_101
            upgrade_101_to_102
            upgrade_102_to_103
            upgrade_103_to_104
            ;;
        "0.2.2-beta")
            upgrade_022_to_030
            upgrade_030_to_031
            upgrade_031_to_100
            upgrade_100_to_101
            upgrade_101_to_102
            upgrade_102_to_103
            upgrade_103_to_104
            ;;
        "0.3.0-rc")
            upgrade_030_to_031
            upgrade_031_to_100
            upgrade_100_to_101
            upgrade_101_to_102
            upgrade_102_to_103
            upgrade_103_to_104
            ;;
        "0.3.1-rc")
            upgrade_031_to_100
            upgrade_100_to_101
            upgrade_101_to_102
            upgrade_102_to_103
            upgrade_103_to_104
            ;;
        "1.0.0")
            upgrade_100_to_101
            upgrade_101_to_102
            upgrade_102_to_103
            upgrade_103_to_104
            ;;
        "1.0.1")
            upgrade_101_to_102
            upgrade_102_to_103
            upgrade_103_to_104
            ;;
        "1.0.2")
            upgrade_102_to_103
            upgrade_103_to_104
            ;;
        "1.0.3")
            upgrade_103_to_104
            ;;
        "1.0.4")
            print_ok "Your system is already up to date. No update available."
            exit 0
            ;;
        *)
            print_error "Unknown current version. Exiting."
            exit 1
            ;;
    esac

    # Apply updates to lsb-release, os-release, and issue files
    applyLsbRelease
    print_ok "System upgraded successfully to version ${LATEST_VERSION}"
}

main