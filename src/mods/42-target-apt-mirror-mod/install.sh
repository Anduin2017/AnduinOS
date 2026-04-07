set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Setting up apt sources..."

MIRROR=$LIVE_UBUNTU_MIRROR
print_info "Using apt mirror for live system: $MIRROR"

cat << EOF > /etc/apt/sources.list
deb $MIRROR $TARGET_UBUNTU_VERSION main restricted universe multiverse
deb $MIRROR $TARGET_UBUNTU_VERSION-updates main restricted universe multiverse
deb $MIRROR $TARGET_UBUNTU_VERSION-backports main restricted universe multiverse
deb $MIRROR $TARGET_UBUNTU_VERSION-security main restricted universe multiverse
EOF
judge "Set up apt sources to $MIRROR"

# print_info "Setting up apt sources for installed system..."
# apt modernize-sources -y
# sudo rm /etc/apt/sources.list.bak
# judge "Set up apt sources for installed system"
