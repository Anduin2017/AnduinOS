set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

if [ "$LANG_MODE" == "zh_CN" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/zh_CN/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/收藏夹/任务栏/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/zh_CN/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    # Clean up
    rm /tmp/gnome-shell.po
else
    print_warn "Skipping Gnome Shell patching for $LANG_MODE"
fi
