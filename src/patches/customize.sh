#!/bin/bash

export TARGET_UBUNTU_VERSION="jammy"
export BUILD_UBUNTU_MIRROR="http://mirror.aiursoft.cn/ubuntu/"
export TARGET_UBUNTU_MIRROR="http://mirrors.anduinos.com/ubuntu/"
export TARGET_NAME="anduinos"
export TARGET_BUSINESS_NAME="AnduinOS"
export TARGET_BUILD_VERSION="0.1.5-beta"
export TARGET_PACKAGE_REMOVE="
    ubiquity \
    casper \
    discover \
    laptop-detect \
    os-prober \
"
export DEBIAN_FRONTEND=noninteractive
