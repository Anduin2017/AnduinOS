print_ok "Setting up initctl..."
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl
judge "Set up initctl"