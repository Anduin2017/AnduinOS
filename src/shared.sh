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

function waitNetwork() {
    while curl -s mirror.aiursoft.cn > /dev/null; [ $? -ne 0 ]; do
        echo "Waiting for registry (https://mirror.aiursoft.cn) to start... ETA: 25s"
        sleep 1
    done
    print_ok "Network is online. Continue..."
}

export -f print_ok print_error print_warn judge waitNetwork print_info
