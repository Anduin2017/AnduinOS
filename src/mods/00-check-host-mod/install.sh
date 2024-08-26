set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Checking host environment..."
if [ $(id -u) -ne 0 ]; then
    print_error "This script should be run as 'root'"
    exit 1
fi
judge "Check host environment"
