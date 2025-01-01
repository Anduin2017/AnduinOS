#!/bin/bash

#==========================
# Basic Information
#==========================

# Set the language environment. Can be: en_US, zh_CN, zh_TW, zh_HK, ja_JP, ko_KR, vi_VN, th_TH, de_DE, fr_FR, es_ES, ru_RU, it_IT, pt_BR, pt_PT, ar_SA, nl_NL, sv_SE, pl_PL, tr_TR
export LANG_MODE="zh_CN"
# Set the language pack code. Can be: zh, en, ja, ko, vi, th, de, fr, es, ru, it, pt, pt, ar, nl, sv, pl, tr
export LANG_PACK_CODE="zh"

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

export DEBIAN_FRONTEND=noninteractive
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
export HOME=/root
# Can be: jammy noble oracular
export TARGET_UBUNTU_VERSION="oracular"

# See https://docs.anduinos.com/Install/Select-Best-Apt-Source.html
export BUILD_UBUNTU_MIRROR="http://mirror.aiursoft.cn/ubuntu/"

# Must be lowercase without special characters and spaces
export TARGET_NAME="anduinos"

# Business name. No special characters or spaces
export TARGET_BUSINESS_NAME="AnduinOS"

# Version number. Must be in the format of x.y.z
export TARGET_BUILD_VERSION="1.2.0"

# The kernel package to install. Can be:
# linux-generic-hwe-22.04 for jammy
# linux-generic-hwe-24.04 for noble
# linux-generic-hwe-24.04 for oracular
export TARGET_KERNEL_PACKAGE="linux-generic-hwe-24.04"

# Set to mirror-ppa.aiursoft.cn to use that as mirror. Set to empty to disable
export FIREFOX_MIRROR="mirror-ppa.aiursoft.cn"

# Packages will be uninstalled during the installation process
export TARGET_PACKAGE_REMOVE="
    ubiquity \
    casper \
    discover \
    laptop-detect \
    os-prober \
"
