print_ok "Patch Ubiquity installer"
rsync -Aavx --update --delete ./slides/ /usr/share/ubiquity-slideshow/slides/
judge "Patch Ubiquity installer"