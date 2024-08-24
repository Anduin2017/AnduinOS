print_ok "Setting up hostname..."
echo "$TARGET_NAME" > /etc/hostname
hostname "$TARGET_NAME"
judge "Set up hostname to $TARGET_NAME"

print_ok "Configuring locales and resolvconf..."
apt update
apt install -y locales resolvconf
judge "Install locales and resolvconf"

print_ok "Configuring locales and resolvconf to $LANG..."
locale-gen $LANG
update-locale LANG=$LANG
judge "Configure locales and resolvconf"
