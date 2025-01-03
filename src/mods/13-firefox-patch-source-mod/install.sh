set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Adding Mozilla Firefox PPA"
waitNetwork
apt install -y software-properties-common
add-apt-repository -y ppa:mozillateam/ppa
if [ -n "$FIREFOX_MIRROR" ]; then
  print_ok "Replace ppa.launchpadcontent.net with $FIREFOX_MIRROR to get faster download speed"
  sed -i "s/ppa.launchpadcontent.net/$FIREFOX_MIRROR/g" \
    /etc/apt/sources.list.d/mozillateam-ubuntu-ppa-$(lsb_release -sc).sources
fi
cat << EOF > /etc/apt/preferences.d/mozilla-firefox
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox
Pin: version 1:1snap*
Pin-Priority: -1
EOF
chown root:root /etc/apt/preferences.d/mozilla-firefox
judge "Add Mozilla Firefox PPA"

print_ok "Updating package list to refresh firefox package cache"
apt update
judge "Update package list"

print_ok "Setting firefox homepage to https://www.anduinos.com/"
sudo mkdir -p /usr/lib/firefox/defaults/pref
cat << EOF > /usr/lib/firefox/defaults/pref/autoconfig.js
pref("general.config.filename", "mozilla.cfg");
pref("general.config.obscure_value", 0);
EOF
cat << EOF > /usr/lib/firefox/mozilla.cfg
// Mozilla Firefox Configuration
// Homepage
lockPref("browser.startup.homepage", "https://www.anduinos.com/");
EOF
chown -R root:root /usr/lib/firefox
judge "Set firefox homepage"