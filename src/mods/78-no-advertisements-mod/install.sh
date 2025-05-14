set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Removing Ubuntu Pro advertisements"
aptConf=/etc/apt/apt.conf.d/20apt-esm-hook.conf
[[ -f $aptConf ]] && dd if=/dev/null of=$aptConf >/dev/null 2>&1 || touch $aptConf
pro config set apt_news=false || true
# This key doesn't work.
# pro config set motd=false || true
apt remove -y --purge -qq -o=Dpkg::Use-Pty=0 ubuntu-pro-client >/dev/null 2>&1
judge "Remove Ubuntu Pro advertisements"