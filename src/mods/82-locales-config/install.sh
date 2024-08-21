print_ok "Configuring locales and resolvconf..."
dpkg-reconfigure locales
dpkg-reconfigure resolvconf
judge "Configure locales and resolvconf"