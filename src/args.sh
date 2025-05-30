#!/bin/bash

#==========================
# Builder Environment Variables
#==========================
export DEBIAN_FRONTEND=noninteractive
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
export HOME=/root

# Set if build in an interactive way.
# Can be: "-y" or ""
export INTERACTIVE="-y"

#==========================
# Language Information
#==========================

# Set the language environment. Can be: en_US, en_GB, zh_CN, zh_TW, zh_HK, ja_JP, ko_KR, vi_VN, th_TH, de_DE, fr_FR, es_ES, ru_RU, it_IT, pt_BR, pt_PT, ar_SA, nl_NL, sv_SE, pl_PL, tr_TR
export LANG_MODE="en_US"
# Set the language pack code. Can be: zh, en, ja, ko, vi, th, de, fr, es, ru, it, pt, pt, ar, nl, sv, pl, tr
export LANG_PACK_CODE="en"

export LC_ALL=$LANG_MODE.UTF-8
export LC_CTYPE=$LANG_MODE.UTF-8
export LC_TIME=$LANG_MODE.UTF-8
export LC_NAME=$LANG_MODE.UTF-8
export LC_ADDRESS=$LANG_MODE.UTF-8
export LC_TELEPHONE=$LANG_MODE.UTF-8
export LC_MEASUREMENT=$LANG_MODE.UTF-8
export LC_IDENTIFICATION=$LANG_MODE.UTF-8
export LC_NUMERIC=$LANG_MODE.UTF-8
export LC_PAPER=$LANG_MODE.UTF-8
export LC_MONETARY=$LANG_MODE.UTF-8
export LANG=$LANG_MODE.UTF-8
export LANGUAGE=$LANG_MODE:$LANG_PACK_CODE

# language-pack-zh-hans   language-pack-zh-hans-base language-pack-gnome-zh-hans \
# language-pack-zh-hant   language-pack-zh-hant-base language-pack-gnome-zh-hant \
# language-pack-en        language-pack-en-base      language-pack-gnome-en \
export LANGUAGE_PACKS="language-pack-$LANG_PACK_CODE* language-pack-gnome-$LANG_PACK_CODE*"

# Continue with the rest of the script
echo "Language environment has been set to $LANG_MODE"

#==========================
# OS system information
#==========================
# Can be: jammy noble oracular plucky questing
export TARGET_UBUNTU_VERSION="questing"

# See https://docs.anduinos.com/Install/Select-Best-Apt-Source.html
export BUILD_UBUNTU_MIRROR="http://mirror.aiursoft.cn/ubuntu/"

# Must be lowercase without special characters and spaces
export TARGET_NAME="anduinos"

# Business name. No special characters or spaces
export TARGET_BUSINESS_NAME="AnduinOS"

# Version number. Must be in the format of x.y.z
export TARGET_BUILD_VERSION="1.4.0"

# Fork version. Must be in the format of x.y
export TARGET_BUILD_BRANCH=$(git rev-parse --abbrev-ref HEAD)

#===========================
# Installer customization
#===========================
# Packages will be uninstalled during the installation process
export TARGET_PACKAGE_REMOVE="
    ubiquity \
    casper \
    discover \
    laptop-detect \
    os-prober \
"

#============================
# Store experience customization
#============================
# How to install the store. Can be "none", "web", "flatpak", "snap"
# none:     no app store
# web:      use a web shortcut to browse the app store
# flatpak:  use gnome software to browse the app store, and install flatpak as plugin
# snap:     use gnome software to browse the app store, and install snap as plugin
export STORE_PROVIDER="flatpak"

# The mirror URL for flathub. Can be: "https://mirror.sjtu.edu.cn/flathub"
export FLATHUB_MIRROR=""
if [[ "$FLATHUB_MIRROR" != "" && "$STORE_PROVIDER" != "flatpak" ]]; then
    echo "Error: FLATHUB_MIRROR is set, but STORE_PROVIDER is not set to flatpak"
    exit 1
fi

# The gpg file for the flathub mirror. Can be: "https://mirror.sjtu.edu.cn/flathub/flathub.gpg"
export FLATHUB_GPG=""
if [[ "$FLATHUB_GPG" != "" && "$FLATHUB_MIRROR" == "" ]]; then
    echo "Error: FLATHUB_GPG is set, but FLATHUB_MIRROR is not set"
    exit 1
fi

#============================
# Browser configuration
#============================
# How to install Firefox. Can be: "none", "deb", "flatpak", "snap"
# none:     no firefox
# deb:      install firefox from PPA with apt
# flatpak:  install firefox from flathub (Only available if STORE_PROVIDER is set to "flatpak")
# snap:     install firefox from snap (Only available if STORE_PROVIDER is set to "snap")
# TODO: Snap firefox seems to be broken. Investigation required.
export FIREFOX_PROVIDER="deb"
if [[ "$FIREFOX_PROVIDER" == "flatpak" && "$STORE_PROVIDER" != "flatpak" ]]; then
    echo "Error: FIREFOX_PROVIDER is set to flatpak, but STORE_PROVIDER is not set to flatpak"
    exit 1
fi
if [[ "$FIREFOX_PROVIDER" == "snap" && "$STORE_PROVIDER" != "snap" ]]; then
    echo "Error: FIREFOX_PROVIDER is set to snap, but STORE_PROVIDER is not set to snap"
    exit 1
fi

# Whether to install firefox with apt. If set, it will be installed from the PPA. If empty, it will be installed from the default source
# Must set FIREFOX_PROVIDER to "deb" before using this option
# Sample: mirror-ppa.aiursoft.cn
export FIREFOX_MIRROR="mirror-ppa.aiursoft.cn"
if [[ "$FIREFOX_MIRROR" != "" && "$FIREFOX_PROVIDER" != "deb" ]]; then
    echo "Error: FIREFOX_MIRROR is set, but FIREFOX_PROVIDER is not set to deb"
    exit 1
fi

export FIREFOX_LOCALE_PACKAGE="firefox-locale-$LANG_PACK_CODE*"
if [[ "$FIREFOX_LOCALE_PACKAGE" != "" && "$FIREFOX_PROVIDER" != "deb" ]]; then
    echo "Error: FIREFOX_LOCALE_PACKAGE is set, but FIREFOX_PROVIDER is not set to deb"
    exit 1
fi

# Whether to install the Firefox mod
INSTALL_FIREFOX_MOD=${INSTALL_FIREFOX_MOD:-true}


#============================
# Input method configuration
#============================
# Packages will be installed during the installation process
# Can be:
# * ibus-rime
# * ibus-libpinyin
# * ibus-chewing
# * ibus-table-cangjie
# * ibus-mozc
# * ibus-hangul
# * ibus-unikey
# * ibus-libthai
export INPUT_METHOD_INSTALL=""

# Boolean indicator for whether to install anduinos-ibus-rime
export CONFIG_IBUS_RIME="false"
if [[ "$CONFIG_IBUS_RIME" == "true" && "$INPUT_METHOD_INSTALL" != *"ibus-rime"* ]]; then
    echo "Error: CONFIG_IBUS_RIME is set to true, but INPUT_METHOD_INSTALL is not set to ibus-rime"
    exit 1
fi

# The default keyboard layout. Can be:
# * [('xkb', 'us')]
# * [('xkb', 'us'), ('ibus', 'rime')]
# * [('xkb', 'us'), ('ibus', 'chewing')]
# * [('xkb', 'us'), ('xkb', 'fr')]
export CONFIG_INPUT_METHOD="[('xkb', 'us')]"


#============================
# Software properties configuration
#============================

# To install software-properties-gtk, set to "true" or "false"
export INSTALL_MODIFIED_SOFTWARE_PROPERTIES_GTK="true"

#============================
# Time zone configuration
#============================

# The timezone for the new OS being built (In chroot environment)
# To view available options, run: `ls /usr/share/zoneinfo/`
export TIMEZONE="America/Los_Angeles"

#============================
# Weather plugin configuration
#============================
export CONFIG_WEATHER_LOCATION="[(uint32 0, 'San Francisco, California, United States', uint32 0, '37.7749295,-122.4194155')]"

#============================
# Live system configuration
#============================
export LIVE_UBUNTU_MIRROR="http://archive.ubuntu.com/ubuntu/"

#============================
# System apps configuration
#============================
# The default apps to be installed.
export DEFAULT_APPS="
    gnome-chess \
    gnome-clocks \
    gnome-weather \
    gnome-nettool \
    gnome-text-editor \
    seahorse \
    evince \
    shotwell \
    remmina remmina-plugin-rdp \
    rhythmbox rhythmbox-plugins \
    totem totem-plugins \
    transmission-gtk transmission-common \
    ffmpegthumbnailer \
    libgdk-pixbuf2.0-bin \
    usb-creator-gtk \
    baobab \
    file-roller \
    gnome-sushi \
    qalculate-gtk \
    yelp \
    gnome-shell-extension-prefs \
    gnome-user-docs \
    gnome-disk-utility \
    gnome-logs \
    gnome-screenshot \
    gnome-system-monitor \
    gnome-sound-recorder \
    gnome-characters \
    gnome-bluetooth \
    gnome-power-manager \
    gnome-snapshot \
    gnome-maps \
    gnome-font-viewer \
    gnome-browser-connector \
    gnome-control-center-faces \
    gnome-startup-applications
"

export DEFAULT_CLI_TOOLS="
    curl \
    vim \
    nano \
    git \
    build-essential \
    make \
    gcc \
    g++ \
    dpkg-dev \
    net-tools \
    htop \
    httping \
    iputils-ping \
    iputils-tracepath \
    dnsutils \
    smartmontools \
    traceroute \
    whois \
    nmap
    "