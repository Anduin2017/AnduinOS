set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Setting up initctl..."
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl
judge "Set up initctl"