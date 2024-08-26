set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Patch Ubiquity installer"
rsync -Aavx --update --delete ./slides/ /usr/share/ubiquity-slideshow/slides/
judge "Patch Ubiquity installer"