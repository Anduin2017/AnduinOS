set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# Can be: en_US, zh_CN, zh_TW, zh_HK, ja_JP, ko_KR, vi_VN, th_TH, de_DE, fr_FR, es_ES, ru_RU, it_IT, pt_BR, pt_PT, ar_SA, nl_NL, sv_SE, pl_PL, tr_TR
if [ "$LANG_MODE" == "en_US" ]; then
    print_ok "Creating and Patching Gnome Shell for en_US..."
    cat <<EOL > /tmp/gnome-shell.po
msgid ""
msgstr ""
"Content-Type: text/plain; charset=UTF-8\n"

msgid "Add to Favorites"
msgstr "Add to Taskbar"

msgid "Remove from Favorites"
msgstr "Remove from Taskbar"
EOL
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/en/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "zh_CN" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/zh_CN/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/收藏夹/任务栏/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/zh_CN/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "zh_TW" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/zh_TW/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/收藏夹/任務列/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/zh_TW/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "zh_HK" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/zh_HK/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/收藏夹/任務欄/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/zh_HK/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "ja" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/ja_JP/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/お気に入り/タスクバー/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/ja_JP/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "ko" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/ko_KR/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/즐겨찾기/작업 표시줄/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/ko_KR/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "vi" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/vi_VN/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/Yêu thích/Thanh tác vụ/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/vi_VN/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "th" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/th_TH/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/รายการโปรด/แถบงาน/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/th_TH/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/g
elif [ "$LANG_MODE" == "de" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/de_DE/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/Favoriten/Taskleiste/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/de_DE/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "fr" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/fr_FR/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/Favoris/Barre des tâches/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/fr_FR/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "es" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/es_ES/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/Favoritos/Barra de tareas/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/es_ES/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "ru" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/ru_RU/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/Избранное/Панель задач/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/ru_RU/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "it" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/it_IT/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/Preferiti/Barra delle applicazioni/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/it_IT/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "pt" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/pt_PT/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/Favoritos/Barra de tarefas/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/pt_PT/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "pt_BR" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/pt_BR/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/Favoritos/Barra de tarefas/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/pt_BR/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "ar" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/ar_SA/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/المفضلة/شريط المهام/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/ar_SA/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "nl" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/nl_NL/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/Favorieten/Taakbalk/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/nl_NL/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "sv" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/sv_SE/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/Favoriter/Activitetsfält/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/sv_SE/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "pl" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/pl_PL/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/Ulubione/Pasek zadań/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/pl_PL/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
elif [ "$LANG_MODE" == "tr" ]; then
    print_ok "Patching Gnome Shell..."
    msgunfmt /usr/share/locale-langpack/tr_TR/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i "s/Sık Kullanılanlar/Görev Çubuğu/g" /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/tr_TR/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po
else
    print_warn "Skipping Gnome Shell patching for $LANG_MODE"
fi
