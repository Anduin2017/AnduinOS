# dconf is a binary file. To apply default dconf to all users, we must:
# - First apply the dconf settings to root user
# - Then copy the dconf settings to /etc/skel
# - Then remove the dconf settings from root user

print_ok "Loading dconf settings"
export $(dbus-launch)

dconf load /org/gnome/ < ./dconf.ini
dconf write /org/gtk/settings/file-chooser/sort-directories-first true
judge "Load dconf settings"

if [ "$LANG_MODE" == "zh_CN" ]; then
    print_ok "Installing on zh_CN mode, use ibus-rime as input method"
    dconf write /org/gnome/desktop/input-sources/mru-sources "[('xkb', 'us'), ('ibus', 'rime')]"
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'rime')]"
    dconf write /org/gnome/desktop/input-sources/xkb-options "@as []"
    judge "Patch dconf for ibus-rime"
else
    print_warn "Skipping input method dconf patch for $LANG_MODE"
fi

print_ok "Copying root's dconf settings to /etc/skel"
mkdir -p /etc/skel/.config/dconf
cp /root/.config/dconf/user /etc/skel/.config/dconf/user
judge "Copy root's dconf settings to /etc/skel"
