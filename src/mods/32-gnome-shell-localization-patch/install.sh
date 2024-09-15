set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# Supported LANG_MODE can be: en_US, zh_CN, zh_TW, zh_HK, ja_JP, ko_KR, vi_VN, th_TH, de_DE, fr_FR, es_ES, ru_RU, it_IT, pt_BR, pt_PT, ar_SA, nl_NL, sv_SE, pl_PL, tr_TR
# Patching Gnome Shell based on LANG_MODE
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
    print_ok "Patching Gnome Shell for zh_CN..."
    msgunfmt /usr/share/locale-langpack/zh_CN/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "添加到任务栏"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "从任务栏中移除"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/zh_CN/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "zh_TW" ]; then
    print_ok "Patching Gnome Shell for zh_TW..."
    msgunfmt /usr/share/locale-langpack/zh_TW/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "加入工作列"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "從工作列移除"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/zh_TW/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "zh_HK" ]; then
    print_ok "Patching Gnome Shell for zh_HK..."
    msgunfmt /usr/share/locale-langpack/zh_HK/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "加入工作欄"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "從工作欄移除"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/zh_HK/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "ja_JP" ]; then
    print_ok "Patching Gnome Shell for ja_JP..."
    msgunfmt /usr/share/locale-langpack/ja/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "タスクバーに追加"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "タスクバーから削除"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/ja/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "ko_KR" ]; then
    print_ok "Patching Gnome Shell for ko_KR..."
    msgunfmt /usr/share/locale-langpack/ko/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "작업표시줄에 추가"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "작업표시줄에서 제거"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/ko/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "vi_VN" ]; then
    print_ok "Patching Gnome Shell for vi_VN..."
    msgunfmt /usr/share/locale-langpack/vi/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "Thêm vào thanh tác vụ"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "Xóa khỏi thanh tác vụ"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/vi/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "th_TH" ]; then
    print_ok "Patching Gnome Shell for th_TH..."
    msgunfmt /usr/share/locale-langpack/th/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "เพิ่มไปยังแถบงาน"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "ลบออกจากแถบงาน"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/th/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "de_DE" ]; then
    print_ok "Patching Gnome Shell for de_DE..."
    msgunfmt /usr/share/locale-langpack/de/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "Zur Taskleiste hinzufügen"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "Aus der Taskleiste entfernen"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/de/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "fr_FR" ]; then
    print_ok "Patching Gnome Shell for fr_FR..."
    msgunfmt /usr/share/locale-langpack/fr/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "Ajouter à la barre des tâches"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "Retirer de la barre des tâches"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/fr/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "es_ES" ]; then
    print_ok "Patching Gnome Shell for es_ES..."
    msgunfmt /usr/share/locale-langpack/es/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "Agregar a la barra de tareas"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "Eliminar de la barra de tareas"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/es/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "ru_RU" ]; then
    print_ok "Patching Gnome Shell for ru_RU..."
    msgunfmt /usr/share/locale-langpack/ru/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "Добавить на панель задач"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "Удалить с панели задач"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/ru/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "it_IT" ]; then
    print_ok "Patching Gnome Shell for it_IT..."
    msgunfmt /usr/share/locale-langpack/it/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "Aggiungi alla barra delle applicazioni"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "Rimuovi dalla barra delle applicazioni"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/it/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "pt_PT" ]; then
    print_ok "Patching Gnome Shell for pt_PT..."
    msgunfmt /usr/share/locale-langpack/pt/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "Adicionar à barra de tarefas"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "Remover da barra de tarefas"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/pt/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "pt_BR" ]; then
    print_ok "Patching Gnome Shell for pt_BR..."
    msgunfmt /usr/share/locale-langpack/pt_BR/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "Adicionar à barra de tarefas"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "Remover da barra de tarefas"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/pt_BR/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "ar_SA" ]; then
    print_ok "Patching Gnome Shell for ar_SA..."
    msgunfmt /usr/share/locale-langpack/ar/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "إضافة إلى شريط المهام"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "إزالة من شريط المهام"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/ar/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "nl_NL" ]; then
    print_ok "Patching Gnome Shell for nl_NL..."
    msgunfmt /usr/share/locale-langpack/nl/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "Toevoegen aan taakbalk"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "Verwijderen van taakbalk"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/nl/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "sv_SE" ]; then
    print_ok "Patching Gnome Shell for sv_SE..."
    msgunfmt /usr/share/locale-langpack/sv/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "Lägg till i aktivitetsfältet"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "Ta bort från aktivitetsfältet"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/sv/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "pl_PL" ]; then
    print_ok "Patching Gnome Shell for pl_PL..."
    msgunfmt /usr/share/locale-langpack/pl/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "Dodaj do paska zadań"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "Usuń z paska zadań"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/pl/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

elif [ "$LANG_MODE" == "tr_TR" ]; then
    print_ok "Patching Gnome Shell for tr_TR..."
    msgunfmt /usr/share/locale-langpack/tr/LC_MESSAGES/gnome-shell.mo -o /tmp/gnome-shell.po
    sed -i '/msgid "Add to Favorites"/{n;s/.*/msgstr "Görev çubuğuna ekle"/}' /tmp/gnome-shell.po
    sed -i '/msgid "Remove from Favorites"/{n;s/.*/msgstr "Görev çubuğundan kaldır"/}' /tmp/gnome-shell.po
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/tr/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell"
    rm /tmp/gnome-shell.po

else
    print_warn "Skipping Gnome Shell patching for $LANG_MODE"
fi
