set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Patching Arc Menu..."

print_ok "Patch Arc Menu logo..."
sudo mkdir -p /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/icons/
mv ./logo.svg /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/icons/anduinos-logo.svg
judge "Patch Arc Menu logo"

print_ok "Patch Arc Menu text..."
sed -i 's/Unpin from ArcMenu/Unpin from Start menu/g' /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/appMenu.js
sed -i 's/Pin to ArcMenu/Pin to Start menu/g' /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/appMenu.js
judge "Patch Arc Menu text"

print_ok "Patch Arc Menu localization..."

declare -A arcmenu_pin_strings=(
    ["ar"]="تثبيت في قائمة ابدأ"
    ["be"]="Замацаваць у меню Пуск"
    ["bg"]="Закачи в менюто Старт"
    ["ca"]="Fixa al menú Inici"
    ["cs"]="Připnout do nabídky Start"
    ["da"]="Fastgør til startmenuen"
    ["de"]="An Startmenü anheften"
    ["el"]="Καρφίτσωμα στο μενού Έναρξη"
    ["es"]="Fijar en el menú Inicio"
    ["et"]="Kinnita algusmenüüsse"
    ["fi"]="Kiinnitä Käynnistä-valikkoon"
    ["fr"]="Épingler au menu Démarrer"
    ["he"]="הצמד לתפריט התחל"
    ["hi_IN"]="स्टार्ट मेनू में पिन करें"
    ["hu"]="Rögzítés a Start menübe"
    ["id"]="Sematkan ke menu Start"
    ["it"]="Aggiungi al menu Start"
    ["ja"]="スタートメニューに追加"
    ["ko"]="시작 메뉴에 고정"
    ["nb_NO"]="Fest til startmenyen"
    ["nl"]="Vastzetten aan Startmenu"
    ["oc"]="Afichar al menú Inici"
    ["pl"]="Przypnij do menu Start"
    ["pt_BR"]="Fixar no menu Iniciar"
    ["ru"]="Закрепить в меню Пуск"
    ["si"]="ආරම්භ මෙනුවට අමුණන්න"
    ["sk"]="Pripnúť do ponuky Štart"
    ["sr"]="Закачи у мени Старт"
    ["sr@latin"]="Zakači u meni Start"
    ["sv"]="Fäst i startmenyn"
    ["szl"]="Przipnij do menu Start"
    ["tr"]="Başlat menüsüne sabitle"
    ["uk"]="Закріпити в меню Пуск"
    ["zh_CN"]="固定到开始菜单"
    ["zh_TW"]="固定到開始功能表"
)

declare -A arcmenu_unpin_strings=(
    ["ar"]="إلغاء التثبيت من قائمة ابدأ"
    ["be"]="Адмацаваць з меню Пуск"
    ["bg"]="Откачи от менюто Старт"
    ["ca"]="Desfixa del menú Inici"
    ["cs"]="Odepnout z nabídky Start"
    ["da"]="Frigør fra startmenuen"
    ["de"]="Vom Startmenü lösen"
    ["el"]="Ξεκαρφίτσωμα από το μενού Έναρξη"
    ["es"]="Desfijar del menú Inicio"
    ["et"]="Eemalda algusmenüüst"
    ["fi"]="Irrota Käynnistä-valikosta"
    ["fr"]="Désépingler du menu Démarrer"
    ["he"]="הסר הצמדה מתפריט התחל"
    ["hi_IN"]="स्टार्ट मेनू से अनपिन करें"
    ["hu"]="Eltávolítás a Start menüből"
    ["id"]="Lepas dari menu Start"
    ["it"]="Rimuovi dal menu Start"
    ["ja"]="スタートメニューから削除"
    ["ko"]="시작 메뉴에서 고정 해제"
    ["nb_NO"]="Løsne fra startmenyen"
    ["nl"]="Losmaken van Startmenu"
    ["oc"]="Retirar del menú Inici"
    ["pl"]="Odepnij od menu Start"
    ["pt_BR"]="Desafixar do menu Iniciar"
    ["ru"]="Открепить от меню Пуск"
    ["si"]="ආරම්භ මෙනුවෙන් ගලවන්න"
    ["sk"]="Odopnúť z ponuky Štart"
    ["sr"]="Откачи из менија Старт"
    ["sr@latin"]="Otkači iz menija Start"
    ["sv"]="Lossa från startmenyn"
    ["szl"]="Odpnij od menu Start"
    ["tr"]="Başlat menüsünden çıkar"
    ["uk"]="Відкріпити з меню Пуск"
    ["zh_CN"]="从开始菜单取消固定"
    ["zh_TW"]="從開始功能表取消固定"
)

LOCALE_DIR="/usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/locale"
found_languages=0

for lang_dir in "$LOCALE_DIR"/*/; do
    lang=$(basename "$lang_dir")
    mo_file="$lang_dir/LC_MESSAGES/arcmenu.mo"

    if [ -f "$mo_file" ] && [ -n "${arcmenu_pin_strings[$lang]+isset}" ]; then
        print_ok "Patching Arc Menu localization for $lang..."
        msgunfmt "$mo_file" -o /tmp/arcmenu.po

        pin_string="${arcmenu_pin_strings[$lang]}"
        unpin_string="${arcmenu_unpin_strings[$lang]}"

        cat << EOF >> /tmp/arcmenu.po
msgid "Pin to Start menu"
msgstr "$pin_string"

msgid "Unpin from Start menu"
msgstr "$unpin_string"

EOF
        msgfmt /tmp/arcmenu.po -o "$mo_file"
        judge "Patch Arc Menu localization ($lang)"
        rm -f /tmp/arcmenu.po
        found_languages=$((found_languages + 1))
    fi
done

print_ok "Patched arcmenu.mo for $found_languages languages"