set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Updating /etc/casper.conf"
cat << EOF > /etc/casper.conf
# This file should go in /etc/casper.conf
# Supported variables are:
# USERNAME, USERFULLNAME, HOST, BUILD_SYSTEM, FLAVOUR

export USERNAME="try-user"
export USERFULLNAME="AnduinOS Live session user"
export HOST="anduinos"
export BUILD_SYSTEM="Ubuntu"

# USERNAME and HOSTNAME as specified above won't be honoured and will be set to
# flavour string acquired at boot time, unless you set FLAVOUR to any
# non-empty string.

export FLAVOUR="AnduinOS"
EOF