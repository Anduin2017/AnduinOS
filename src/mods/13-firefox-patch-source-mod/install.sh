print_ok "Adding Mozilla Firefox PPA"
waitNetwork
apt install -y software-properties-common
add-apt-repository -y ppa:mozillateam/ppa -n
echo "deb https://mirror-ppa.aiursoft.cn/mozillateam/ppa/ubuntu/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/mozillateam-ubuntu-ppa-$(lsb_release -sc).list
cat << EOF > /etc/apt/preferences.d/mozilla-firefox
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1002
EOF
chown root:root /etc/apt/preferences.d/mozilla-firefox
judge "Add Mozilla Firefox PPA"

print_ok "Updating package list to refresh firefox package cache"
apt update
judge "Update package list"