#!/bin/bash

export TARGET_UBUNTU_VERSION="jammy"
export TARGET_UBUNTU_MIRROR="http://mirror.aiursoft.cn/ubuntu/"
export TARGET_KERNEL_PACKAGE="linux-generic-hwe-22.04"
export TARGET_NAME="anduinos"
export TARGET_BUSINESS_NAME="AnduinOS"
export TARGET_BUILD_VERSION="0.0.7-alpha"
export GRUB_LIVEBOOT_LABEL="Try AnduinOS"
export GRUB_INSTALL_LABEL="Install AnduinOS"
export TARGET_PACKAGE_REMOVE="
    ubiquity \
    casper \
    discover \
    laptop-detect \
    os-prober \
"
export DEBIAN_FRONTEND=noninteractive
