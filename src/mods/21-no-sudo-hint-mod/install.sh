set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Removing the hint for sudo"
if grep -q "sudo hint" /etc/bash.bashrc; then
    sed -i '43,54d' /etc/bash.bashrc
    judge "Remove the hint for sudo"
else
    print_error "Error: 'sudo hint' not found in /etc/bash.bashrc."
    exit 1
fi