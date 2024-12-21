set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Removing some usr-is-merged folders..."
rm -rf /bin.usr-is-merged
rm -rf /lib.usr-is-merged
rm -rf /sbin.usr-is-merged
judge "Remove some usr-is-merged folders"