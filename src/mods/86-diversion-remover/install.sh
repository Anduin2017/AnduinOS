print_ok "Removing diversion..."
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl
judge "Remove diversion"