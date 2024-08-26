set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Setting up apt sources..."
cat << EOF > /etc/apt/sources.list
deb $BUILD_UBUNTU_MIRROR $TARGET_UBUNTU_VERSION main restricted universe multiverse
deb $BUILD_UBUNTU_MIRROR $TARGET_UBUNTU_VERSION-updates main restricted universe multiverse
deb $BUILD_UBUNTU_MIRROR $TARGET_UBUNTU_VERSION-backports main restricted universe multiverse
deb $BUILD_UBUNTU_MIRROR $TARGET_UBUNTU_VERSION-security main restricted universe multiverse
EOF
judge "Set up apt sources to $BUILD_UBUNTU_MIRROR"