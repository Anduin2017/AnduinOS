#!/bin/bash
#==========================
# Set up the environment
#==========================
set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error
export DEBIAN_FRONTEND=noninteractive
export LATEST_VERSION="0.1.3-beta"
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

}

function upgrade_011_to_012() {
    # Add your upgrade steps from 0.1.1 to 0.1.2 here
    print_ok "Upgrading from 0.1.1 to 0.1.2"

    print_ok "Installing ubuntu-drivers-common"
    sudo apt install ubuntu-drivers-common -y
    judge "Install ubuntu-drivers-common"

    # Upgrade script shouldn't uninstall packages, even in this version it's removed by default
    # This is because the user might have installed it manually
    #print_ok "Uninstalling apport, neofetch"
    #sudo apt autoremove apport neofetch -y
    #judge "Uninstalling apport, neofetch"

    print_ok "Removing /etc/update-manager/, /etc/update-motd.d/"
    sudo rm /etc/update-manager/ -rf
    sudo rm /etc/update-motd.d/ -rf
    judge "Removing /etc/update-manager/, /etc/update-motd.d/"

    print_ok "Upgrade to 0.1.2-beta succeeded"
}

function upgrade_012_to_013() {
    # Add your upgrade steps from 0.1.2 to 0.1.3 here
    print_ok "Upgrading from 0.1.2 to 0.1.3"

    print_ok "Installing fluent-cursor-theme"
    (
        cd /tmp
        git clone https://git.aiursoft.cn/PublicVault/Fluent-icon-theme.git
        cd /tmp/Fluent-icon-theme/cursors
        bash -c /tmp/Fluent-icon-theme/cursors/install.sh
        gsettings set org.gnome.desktop.interface cursor-theme 'Fluent-dark-cursors'
        cd ~
    )
    judge "Install fluent-cursor-theme"

    print_ok "Installing new plugin..."
    (
        cd /tmp
        mkdir -p /tmp/repo
        git clone -b 1.1.3 https://gitlab.aiursoft.cn/anduin/anduinos.git /tmp/repo
        sudo rsync -Aavx --update --delete /tmp/repo/src/patches/switcher@anduinos/* /usr/share/gnome-shell/extensions/switcher@anduinos

        sudo cp /tmp/repo/src/patches/wallpaper/Fluent-building-light.png /usr/share/backgrounds/
        sudo cp /tmp/repo/src/patches/wallpaper/Fluent-building-night.png /usr/share/backgrounds/

        dconf load /org/gnome/ < /tmp/repo/src/patches/dconf/dconf.ini
        rm -rf /tmp/repo
    )
    judge "Install new plugin"

    print_ok "Patching /etc/os-release"
    # Replace HOME_URL="https://www.ubuntu.com/" to HOME_URL="https://www.anduinos.com/"
    sudo sed -i "s/HOME_URL=.*/HOME_URL=\"https:\/\/www.anduinos.com\/\"/" /etc/os-release
    judge "Patch /etc/os-release"

    print_ok "Upgrade to 0.1.3-beta succeeded"
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
    print_ok "Please press [ENTER] to continue, or press CTRL+C to cancel."
    read


    # Run necessary upgrades based on current version
    case "$CURRENT_VERSION" in
        "0.1.0-beta")
            upgrade_010_to_011
            upgrade_011_to_012
            upgrade_012_to_013
            ;;
        "0.1.1-beta")
            upgrade_011_to_012
            upgrade_012_to_013
            ;;
        "0.1.2-beta")
            upgrade_012_to_013
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