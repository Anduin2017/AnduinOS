print_ok "Patching fonts..."
cp ./local.conf /etc/fonts/
unzip ./fonts.zip -d /usr/share/fonts/
judge "Patch fonts"

print_ok "Updating font cache"
fc-cache -f -v
judge "Update font cache"