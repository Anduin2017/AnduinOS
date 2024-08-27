set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# dconf is a binary file. To apply default dconf to all users, we must:
# - First apply the dconf settings to root user
# - Then copy the dconf settings to /etc/skel
# - Then remove the dconf settings from root user

print_ok "Loading dconf settings"
export $(dbus-launch)

dconf load /org/gnome/ < ./dconf.ini
dconf write /org/gtk/settings/file-chooser/sort-directories-first true
dconf write /org/gnome/desktop/input-sources/xkb-options "@as []"
judge "Load dconf settings"

# Can be: en_US, zh_CN, zh_TW, zh_HK, ja_JP, ko_KR, de_DE, fr_FR, es_ES, ru_RU, it_IT, pt_PT, vi_VN, th_TH, ar_SA, nl_NL, sv_SE, pl_PL, tr_TR
if [ "$LANG_MODE" == "en_US" ]; then
    print_ok "Skipping input method dconf patch for en_US"
elif [ "$LANG_MODE" == "zh_CN" ]; then
    print_ok "Installing on zh_CN mode, patching dconf for ibus-rime..."
    dconf write /org/gnome/desktop/input-sources/mru-sources "[('xkb', 'us'), ('ibus', 'rime')]"
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'rime')]"
    judge "Patch dconf for ibus-rime"
elif [ "$LANG_MODE" == "zh_TW" ]; then
    print_ok "Installing on zh_TW mode, patching dconf for ibus-cangjie and ibus-libzhuyin..."
    dconf write /org/gnome/desktop/input-sources/mru-sources "[('xkb', 'us'), ('ibus', 'table:cangjie-big'), ('ibus', 'libzhuyin')]"
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'table:cangjie-big'), ('ibus', 'libzhuyin')]"
    judge "Patch dconf for ibus-cangjie and ibus-libzhuyin"
elif [ "$LANG_MODE" == "zh_HK" ]; then
    print_ok "Installing on zh_HK mode, patching dconf for ibus-cangjie..."
    dconf write /org/gnome/desktop/input-sources/mru-sources "[('xkb', 'us'), ('ibus', 'table:cangjie-big')]"
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'table:cangjie-big')]"
    judge "Patch dconf for ibus-cangjie"
elif [ "$LANG_MODE" == "ja_JP" ]; then
    print_ok "Installing on ja_JP mode, patching dconf for ibus-anthy..."
    dconf write /org/gnome/desktop/input-sources/mru-sources "[('xkb', 'us'), ('ibus', 'anthy')]"
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'anthy')]"
    judge "Patch dconf for ibus-anthy"
elif [ "$LANG_MODE" == "ko_KR" ]; then
    print_ok "Installing on ko_KR mode, patching dconf for ibus-hangul..."
    dconf write /org/gnome/desktop/input-sources/mru-sources "[('xkb', 'us'), ('ibus', 'hangul')]"
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'hangul')]"
    judge "Patch dconf for ibus-hangul"
elif [ "$LANG_MODE" == "de_DE" ]; then
    print_ok "Skipping input method dconf patch for de_DE"
elif [ "$LANG_MODE" == "fr_FR" ]; then
    print_ok "Skipping input method dconf patch for fr_FR"
elif [ "$LANG_MODE" == "es_ES" ]; then
    print_ok "Skipping input method dconf patch for es_ES"
elif [ "$LANG_MODE" == "ru_RU" ]; then
    print_ok "Installing on ru_RU mode, patching dconf for ibus-m17n..."
    dconf write /org/gnome/desktop/input-sources/mru-sources "[('xkb', 'us'), ('ibus', 'm17n:ru:kbd')]"
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'm17n:ru:kbd')]"
elif [ "$LANG_MODE" == "it_IT" ]; then
    print_ok "Skipping input method dconf patch for it_IT"
elif [ "$LANG_MODE" == "pt_PT" ]; then
    print_ok "Skipping input method dconf patch for pt_PT"
elif [ "$LANG_MODE" == "vi_VN" ]; then
    print_ok "Installing on vi_VN mode, patching dconf for ibus-unikey..."
    dconf write /org/gnome/desktop/input-sources/mru-sources "[('xkb', 'us'), ('ibus', 'Unikey')]"
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'Unikey')]"
    judge "Patch dconf for ibus-unikey"
elif [ "$LANG_MODE" == "th_TH" ]; then
    print_ok "Installing on th_TH mode, patching dconf for ibus-libthai..."
    dconf write /org/gnome/desktop/input-sources/mru-sources "[('xkb', 'us'), ('ibus', 'libthai')]"
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'libthai')]"
    judge "Patch dconf for ibus-libthai"
elif [ "$LANG_MODE" == "ar_SA" ]; then
    print_ok "Installing on ar_SA mode, patching dconf for ibus-m17n..."
    dconf write /org/gnome/desktop/input-sources/mru-sources "[('xkb', 'us'), ('ibus', 'm17n:ar:kbd')]"
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'm17n:ar:kbd')]"
elif [ "$LANG_MODE" == "nl_NL" ]; then
    print_ok "Skipping input method dconf patch for nl_NL"
elif [ "$LANG_MODE" == "sv_SE" ]; then
    print_ok "Skipping input method dconf patch for sv_SE"
elif [ "$LANG_MODE" == "pl_PL" ]; then
    print_ok "Skipping input method dconf patch for pl_PL"
elif [ "$LANG_MODE" == "tr_TR" ]; then
    print_ok "Skipping input method dconf patch for tr_TR"
else
    print_warn "Skipping input method dconf patch for $LANG_MODE"
fi

print_ok "Copying root's dconf settings to /etc/skel"
mkdir -p /etc/skel/.config/dconf
cp /root/.config/dconf/user /etc/skel/.config/dconf/user
judge "Copy root's dconf settings to /etc/skel"
