set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing basic packages..."
apt install -y \
    ca-certificates gpg apt-transport-https gnupg software-properties-common
judge "Install basic packages"

print_ok "Setting up hostname..."
echo "$TARGET_NAME" > /etc/hostname
hostname "$TARGET_NAME"
judge "Set up hostname to $TARGET_NAME"

print_ok "Configuring locales and resolvconf..."
apt update
apt install -y locales resolvconf
judge "Install locales and resolvconf"

print_ok "Configuring locales..."
echo "$LANG UTF-8" > /etc/locale.gen
locale-gen
update-locale LANG=$LANG LC_ALL=$LANG
judge "Configure locales"
