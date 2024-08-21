print_ok "Patching Dash-to-panel"
msgunfmt /usr/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/locale/zh_CN/LC_MESSAGES/dash-to-panel.mo -o /tmp/dash-to-panel.po
sed -i "s/Dash to Panel 设置/任务栏设置/g" /tmp/dash-to-panel.po
msgfmt /tmp/dash-to-panel.po -o /usr/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/locale/zh_CN/LC_MESSAGES/dash-to-panel.mo
judge "Patch Dash-to-panel"

# Clean up
rm /tmp/dash-to-panel.po