print_ok "Removing Ubuntu Pro advertisements"
rm /etc/apt/apt.conf.d/20apt-esm-hook.conf || true
touch /etc/apt/apt.conf.d/20apt-esm-hook.conf
pro config set apt_news=false || true
pro config set motd=false || true
judge "Remove Ubuntu Pro advertisements"