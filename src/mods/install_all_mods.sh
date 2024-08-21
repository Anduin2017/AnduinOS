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

#==========================
# Variables for mods
#==========================
export TARGET_UBUNTU_VERSION="jammy"
export BUILD_UBUNTU_MIRROR="http://mirror.aiursoft.cn/ubuntu/"
export TARGET_UBUNTU_MIRROR="http://mirrors.anduinos.com/ubuntu/"
export TARGET_NAME="anduinos"
export TARGET_BUSINESS_NAME="AnduinOS"
export TARGET_BUILD_VERSION="0.2.1-beta"
export TARGET_PACKAGE_REMOVE="
    ubiquity \
    casper \
    discover \
    laptop-detect \
    os-prober \
"
#==========================
# Execute mods
#==========================
for mod in "$SCRIPT_DIR"/*; do
    if [[ -d "$mod" && -f "$mod/install.sh" ]]; then
        print_info "Processing mod: $mod"
        (
            cd "$mod" && \
            chmod +x install.sh && \
            bash "$mod/install.sh"
        )
        judge "$mod/install.sh"
    fi
done
