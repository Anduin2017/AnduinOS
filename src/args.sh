#!/bin/bash

#=================================================
#           PLEASE READ THIS BEFORE EDITING
#=================================================
# This file is used to set the environment variables for the build process.
# Before building AnduinOS, you should edit this file to customize the build process.
# It is sourced by the build script and should not be executed directly.
# You can edit this file to customize the build process.
# However, you should not change the variable names or the structure of the file.
# After editing this file, you can run the build script `make` to start the build process.

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

# Set the language environment. Can be: en_US, en_UK, zh_CN, zh_TW, zh_HK, ja_JP, ko_KR, vi_VN, th_TH, de_DE, fr_FR, es_ES, ru_RU, it_IT, pt_BR, pt_PT, ar_SA, nl_NL, sv_SE, pl_PL, tr_TR
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

# These are the language packs to be installed.
# language-pack-zh-hans   language-pack-zh-hans-base language-pack-gnome-zh-hans \
# language-pack-zh-hant   language-pack-zh-hant-base language-pack-gnome-zh-hant \
# language-pack-en        language-pack-en-base      language-pack-gnome-en \
export LANGUAGE_PACKS="language-pack-$LANG_PACK_CODE* language-pack-gnome-$LANG_PACK_CODE*"

# Just logging. Continue with the rest of the script
echo "Language environment has been set to $LANG_MODE"

#==========================
# OS system information
#==========================

# This is the target Ubuntu version code name for the build.
# It should match the Ubuntu version you are building against.
# For example, if you are building against Ubuntu 22.04 LTS, this should be "jammy".
# If you are building against Ubuntu 24.04 LTS, this should be "noble".
# If you are building against Ubuntu 24.10, this should be "oracular".
# If you are building against Ubuntu 25.04, this should be "plucky".
# If you are building against Ubuntu 25.10, this should be "questing".
# Can be: jammy noble oracular plucky questing
export TARGET_UBUNTU_VERSION="plucky"

# This is the apt source for the build.
# It can be any Ubuntu mirror that you prefer.
# The default is the Aiursoft mirror.
# You can change it to any other mirror that you prefer.
# See https://docs.anduinos.com/Install/Select-Best-Apt-Source.html
export BUILD_UBUNTU_MIRROR="http://mirror.aiursoft.cn/ubuntu/"

# This is the name of the target OS.
# Must be lowercase without special characters and spaces
export TARGET_NAME="anduinos"

# This is the full display name of the target OS.
# Business name. No special characters or spaces
export TARGET_BUSINESS_NAME="AnduinOS"

# Version number. Must be in the format of x.y.z
export TARGET_BUILD_VERSION="1.3.5"

# Fork version. Must be in the format of x.y
# By default, it is the branch name of the git repository.
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
export BUILD_FIREFOX_MIRROR="mirror-ppa.aiursoft.cn"
if [[ "$BUILD_FIREFOX_MIRROR" != "" && "$FIREFOX_PROVIDER" != "deb" ]]; then
    echo "Error: BUILD_FIREFOX_MIRROR is set, but FIREFOX_PROVIDER is not set to deb"
    exit 1
fi

# The Firefox mirror for live system. If set, it will be used to replace the default PPA mirror.
# This must be set if FIREFOX_PROVIDER is set to "deb"
# Default: ppa.launchpadcontent.net
export LIVE_FIREFOX_MIRROR="ppa.launchpadcontent.net"
if [[ "$FIREFOX_PROVIDER" == "deb" && -z "$LIVE_FIREFOX_MIRROR" ]]; then
    echo "Error: FIREFOX_PROVIDER is deb, but didn't set LIVE_FIREFOX_MIRROR"
    exit 1
fi

export FIREFOX_LOCALE_PACKAGE="firefox-locale-$LANG_PACK_CODE*"
if [[ "$FIREFOX_LOCALE_PACKAGE" != "" && "$FIREFOX_PROVIDER" != "deb" ]]; then
    echo "Error: FIREFOX_LOCALE_PACKAGE is set, but FIREFOX_PROVIDER is not set to deb"
    exit 1
fi
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

# This will affect the default weather location in the weather plugin.
export CONFIG_WEATHER_LOCATION="[(uint32 0, 'San Francisco, California, United States', uint32 0, '37.7749295,-122.4194155')]"

#============================
# Live system configuration
#============================

# This is the default apt server in the live system.
# It can be any Ubuntu mirror that you prefer.
export LIVE_UBUNTU_MIRROR="http://archive.ubuntu.com/ubuntu/"

#============================
# System apps configuration
#============================
# The default apps to be installed.
# All those apps are optional. You can remove any of them if you don't need them.
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
    gnome-startup-applications \
    policykit-desktop-privileges
"

# The default CLI tools to be installed.
# All those tools are optional. You can remove any of them if you don't need them.
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

# The default Flatpak tools to be installed.
# All those tools are optional. You can remove any of them if you don't need them.
export DEFAULT_FLATPAK_TOOLS=""
# export DEFAULT_FLATPAK_TOOLS="
#     chat.revolt.RevoltDesktop \
#     com.discordapp.Discord \
#     com.google.EarthPro \
#     com.jetbrains.Rider \
#     com.obsproject.Studio \
#     com.spotify.Client \
#     com.tencent.WeChat \
#     com.valvesoftware.Steam \
#     io.github.shiftey.Desktop \
#     net.agalwood.Motrix \
#     org.musescore.MuseScore \
#     org.qbittorrent.qBittorrent \
#     org.signal.Signal \
#     org.gnome.Boxes \
#     org.kde.krita \
#     io.missioncenter.MissionCenter \
#     com.getpostman.Postman \
#     org.shotcut.Shotcut \
#     org.blender.Blender \
#     org.videolan.VLC \
#     com.wps.Office \
#     org.chromium.Chromium \
#     com.dosbox_x.DOSBox-X \
#     com.mojang.Minecraft \
#     org.codeblocks.codeblocks
#     "