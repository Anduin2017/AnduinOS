print_ok "Configuring machine id..."
dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id
judge "Configure machine id"