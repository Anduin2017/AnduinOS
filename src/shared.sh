#!/bin/bash

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

function wait_network() {
    local WGET_OPTS="--spider -q --timeout=5 --tries=1"

    until wget $WGET_OPTS https://github.com; do
        echo "Waiting for network (https://github.com) ... ETA: 25s"
        sleep 1
    done

    print_ok "Network is online. Continue..."
}

function install_opt() {
    print_ok "Installing $1... if available…"
    if apt-cache show $1 >/dev/null 2>&1; then
        apt install $INTERACTIVE -y $1 --no-install-recommends
        judge "Install $1"
    else
        print_warn "Package $1 is not available for $TARGET_UBUNTU_VERSION"
    fi
}

export -f print_ok print_error print_warn judge wait_network print_info install_opt
