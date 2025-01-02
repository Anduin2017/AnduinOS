sudo bash -c 'cat << EOF > /usr/local/bin/do_anduinos_upgrade
#!/bin/bash
echo "Upgrading AnduinOS..."
curl -sSL https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/1.0/src/upgrade.sh | bash
EOF
'
sudo chmod +x /usr/local/bin/do_anduinos_upgrade
/usr/local/bin/do_anduinos_upgrade