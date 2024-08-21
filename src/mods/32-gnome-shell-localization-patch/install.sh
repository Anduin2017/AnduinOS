print_ok "Patching Gnome Shell..."
msgunfmt /usr/share/locale-langpack/zh_CN/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
sed -i "s/收藏夹/任务栏/g" /tmp/gnome-shell.po
msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/zh_CN/LC_MESSAGES/gnome-shell.mo
judge "Patch Gnome Shell"

# Clean up
rm /tmp/gnome-shell.po