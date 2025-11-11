set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Adding new command to this OS: do_anduinos_upgrade..."
cp ./do-anduinos-autorepair.sh /usr/local/bin/do-anduinos-autorepair
chmod +x /usr/local/bin/do-anduinos-autorepair
judge "Add new command do-anduinos-autorepair"
