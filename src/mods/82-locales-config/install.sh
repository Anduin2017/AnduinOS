set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Configuring locales and resolvconf..."
dpkg-reconfigure locales
dpkg-reconfigure resolvconf
judge "Configure locales and resolvconf"

print_ok "Configuring locales to $LANG..."
cat <<EOF > /etc/default/locale
# Generated by AnduinOS.
LANG="$LANG"
LC_ALL="$LANG"
LC_NUMERIC="$LANG"
LC_TIME="$LANG"
LC_MONETARY="$LANG"
LC_PAPER="$LANG"
LC_NAME="$LANG"
LC_ADDRESS="$LANG"
LC_TELEPHONE="$LANG"
LC_MEASUREMENT="$LANG"
LC_IDENTIFICATION="$LANG"
EOF
judge "Configure locales to $LANG"