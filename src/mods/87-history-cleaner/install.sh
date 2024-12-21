set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Removing bash history and temporary files..."
rm -rf /tmp/* ~/.bash_history
judge "Remove bash history and temporary files"

# Disable history in bash to avoid saving commands
export HISTSIZE=0

# TODO: after build, if run apt update, will get error that duplicate sources