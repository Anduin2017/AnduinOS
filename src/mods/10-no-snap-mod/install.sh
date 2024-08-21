print_ok "Removing snap packages"
snap remove firefox || true
snap remove snap-store || true
snap remove gtk-common-themes || true
snap remove snapd-desktop-integration || true
snap remove bare || true
apt purge -y snapd
rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd ~/snap
cat << EOF > /etc/apt/preferences.d/no-snap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
chown root:root /etc/apt/preferences.d/no-snap.pref
judge "Remove snap packages"