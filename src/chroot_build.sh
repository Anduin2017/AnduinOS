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
export LANG=C.UTF-8
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

function install_pkg() {
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

    # Call into config function
    print_ok "Customizing image..."
    customize_image
    judge "Customize image"

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
install_pkg
finish_up
echo "$0 - Initial build is done!"

