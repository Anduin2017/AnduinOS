print_ok "Setting up hostname..."
echo "$TARGET_NAME" > /etc/hostname
hostname "$TARGET_NAME"
judge "Set up hostname to $TARGET_NAME"
