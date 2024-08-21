print_ok "Removing Ubuntu motd and update-manager"
rm /etc/update-manager/ -rf
rm /etc/update-motd.d/ -rf
judge "Remove Ubuntu motd and update-manager"