#!/bin/bash

#==========================
# Basic Information
#==========================

# Set the language environment. Can be: en_US, zh_CN, zh_TW, zh_HK, ja_JP, ko_KR, de_DE, fr_FR, es_ES, ru_RU, it_IT, pt_PT, vi_VN, th_TH, ar_SA, nl_NL, sv_SE, pl_PL, tr_TR
export LANG_MODE="zh_CN"
# Set the language pack code. Can be: zh, en, ja, ko, de, fr, es, ru, it, pt, vi, th, ar, nl, sv, pl, tr
export LANG_PACK_CODE="zh"

export LC_ALL=$LANG_MODE.UTF-8
export LC_TIME=$LANG_MODE.UTF-8
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

#==========================
# Color
#==========================
export Green="\033[32m"
export Red="\033[31m"
export Yellow="\033[33m"
export Blue="\033[36m"
export Font="\033[0m"
export GreenBG="\033[42;37m"
export RedBG="\033[41;37m"
export INFO="${Blue}[ INFO ]${Font}"
export OK="${Green}[  OK  ]${Font}"
export ERROR="${Red}[FAILED]${Font}"
export WARNING="${Yellow}[ WARN ]${Font}"

#==========================
# Print Colorful Text
#==========================
function print_ok() {
  echo -e "${OK} ${Blue} $1 ${Font}"
}

function print_info() {
  echo -e "${INFO} ${Font} $1"
}

function print_error() {
  echo -e "${ERROR} ${Red} $1 ${Font}"
}

function print_warn() {
  echo -e "${WARNING} ${Yellow} $1 ${Font}"
}

function judge() {
  if [[ 0 -eq $? ]]; then
    print_ok "$1 succeeded"
    sleep 0.2
  else
    print_error "$1 failed"
    exit 1
  fi
}

function waitNetwork() {
    while curl -s mirror.aiursoft.cn > /dev/null; [ $? -ne 0 ]; do
        echo "Waiting for registry (https://mirror.aiursoft.cn) to start... ETA: 25s"
        sleep 1
    done
    print_ok "Network is online. Continue..."
}

export -f print_ok print_error print_warn judge waitNetwork

export TARGET_UBUNTU_VERSION="jammy"
export BUILD_UBUNTU_MIRROR="http://mirror.aiursoft.cn/ubuntu/"
export TARGET_UBUNTU_MIRROR="http://archive.ubuntu.com/ubuntu/"
export TARGET_NAME="anduinos"
export TARGET_BUSINESS_NAME="AnduinOS"
export TARGET_BUILD_VERSION="0.3.0-rc"
export TARGET_PACKAGE_REMOVE="
    ubiquity \
    casper \
    discover \
    laptop-detect \
    os-prober \
"