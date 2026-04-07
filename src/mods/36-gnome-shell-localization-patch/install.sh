set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error
# ...existing code...

# Dictionary of localized strings for "Add to Taskbar" and "Unpin from Taskbar"
declare -A taskbar_add_strings=(
    ["en"]="Add to Taskbar"
    ["zh_CN"]="添加到任务栏"
    ["zh_TW"]="加入工作列"
    ["zh_HK"]="加入工作欄"
    ["ja"]="タスクバーに追加"
    ["ko"]="작업표시줄에 추가"
    ["vi"]="Thêm vào thanh tác vụ"
    ["th"]="เพิ่มไปยังแถบงาน"
    ["de"]="Zur Taskleiste hinzufügen"
    ["fr"]="Ajouter à la barre des tâches"
    ["es"]="Agregar a la barra de tareas"
    ["ru"]="Добавить на панель задач"
    ["it"]="Aggiungi alla barra delle applicazioni"
    ["pt"]="Adicionar à barra de tarefas"
    ["pt_BR"]="Adicionar à barra de tarefas"
    ["ar"]="إضافة إلى شريط المهام"
    ["nl"]="Toevoegen aan taakbalk"
    ["sv"]="Lägg till i aktivitetsfältet"
    ["pl"]="Dodaj do paska zadań"
    ["tr"]="Görev çubuğuna ekle"
    ["ro"]="Adăugați în bara de activități"
)

declare -A taskbar_remove_strings=(
    ["en"]="Unpin from Taskbar"
    ["zh_CN"]="从任务栏中移除"
    ["zh_TW"]="從工作列移除"
    ["zh_HK"]="從工作欄移除"
    ["ja"]="タスクバーから削除"
    ["ko"]="작업표시줄에서 제거"
    ["vi"]="Xóa khỏi thanh tác vụ"
    ["th"]="ลบออกจากแถบงาน"
    ["de"]="Aus der Taskleiste entfernen"
    ["fr"]="Retirer de la barre des tâches"
    ["es"]="Eliminar de la barra de tareas"
    ["ru"]="Удалить с панели задач"
    ["it"]="Rimuovi dalla barra delle applicazioni"
    ["pt"]="Remover da barra de tarefas"
    ["pt_BR"]="Remover da barra de tarefas"
    ["ar"]="إزالة من شريط المهام"
    ["nl"]="Verwijderen van taakbalk"
    ["sv"]="Ta bort från aktivitetsfältet"
    ["pl"]="Usuń z paska zadań"
    ["tr"]="Görev çubuğundan kaldır"
    ["ro"]="Anulați fixarea din bara de activități"
)

# Special case for English - create new .mo file
print_ok "Creating and Patching Gnome Shell for en..."
if [ -d "/usr/share/locale-langpack/en/LC_MESSAGES" ]; then
    cat <<EOL > /tmp/gnome-shell.po
msgid ""
msgstr ""
"Content-Type: text/plain; charset=UTF-8\n"

msgid "Pin to Dash"
msgstr "Add to Taskbar"

msgid "Unpin"
msgstr "Remove from Taskbar"
EOL
    msgfmt /tmp/gnome-shell.po -o /usr/share/locale-langpack/en/LC_MESSAGES/gnome-shell.mo
    judge "Patch Gnome Shell (en)"
    rm /tmp/gnome-shell.po
fi

# For all other languages, patch existing files
print_ok "Scanning and patching all available language packs..."
found_languages=0

# Loop through all directories in locale-langpack
for lang_dir in /usr/share/locale-langpack/*/; do
    lang=$(basename "$lang_dir")
    # Skip English as it's handled separately
    if [ "$lang" == "en" ]; then
        continue
    fi
    
    mo_file="$lang_dir/LC_MESSAGES/gnome-shell.mo"
    
    # Check if language has gnome-shell.mo file and if we have translations for it
    if [ -f "$mo_file" ] && [ -n "${taskbar_add_strings[$lang]+isset}" ] || [ -n "${taskbar_add_strings[$lang]+isset}" ]; then
        print_ok "Patching Gnome Shell for $lang..."
        msgunfmt "$mo_file" -o /tmp/gnome-shell.po
        
        # Get the translations (use language code without country if specific one not available)
        lang_code="${lang%%_*}"
        add_string="${taskbar_add_strings[$lang]:-${taskbar_add_strings[$lang_code]:-Add to Taskbar}}"
        remove_string="${taskbar_remove_strings[$lang]:-${taskbar_remove_strings[$lang_code]:-Remove from Taskbar}}"
        
        sed -i '/msgid "Pin to Dash"/{n;s/.*/msgstr "'"$add_string"'"/}' /tmp/gnome-shell.po
        sed -i '/msgid "Unpin"/{n;s/.*/msgstr "'"$remove_string"'"/}' /tmp/gnome-shell.po
        
        msgfmt /tmp/gnome-shell.po -o "$mo_file"
        judge "Patch Gnome Shell ($lang)"
        found_languages=$((found_languages + 1))
    fi
done

rm -f /tmp/gnome-shell.po
print_ok "Patched gnome-shell.mo for $found_languages languages"
