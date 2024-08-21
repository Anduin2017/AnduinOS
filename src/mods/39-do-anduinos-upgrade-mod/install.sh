print_ok "Adding new command to this OS: do_anduinos_upgrade..."
cat << EOF > /usr/local/bin/do_anduinos_upgrade
#!/bin/bash
echo "Upgrading AnduinOS..."
curl -sSL https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/master/src/upgrade.sh | bash
EOF
chmod +x /usr/local/bin/do_anduinos_upgrade
judge "Add new command do_anduinos_upgrade"
