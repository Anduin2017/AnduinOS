set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Patching Arc Menu..."

print_ok "Patch Arc Menu logo..."
mv ./logo.svg /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/icons/anduinos-logo.svg
judge "Patch Arc Menu logo"

print_ok "Patch Arc Menu text..."
# TODO: The text was not localized
sed -i 's/Unpin from ArcMenu/Unpin from Start menu/g' /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/appMenu.js
sed -i 's/Pin to ArcMenu/Pin to Start menu/g' /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/appMenu.js
judge "Patch Arc Menu text"

print_ok "Patch Arc Menu localization..."
# TODO: Localization for other languages
msgunfmt /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/locale/zh_CN/LC_MESSAGES/arcmenu.mo -o /tmp/arcmenu.po
cat << EOF >> /tmp/arcmenu.po
msgid "Pin to Start menu"
msgstr "固定到开始菜单"

msgid "Unpin from Start menu"
msgstr "从开始菜单取消固定"

EOF
sed -i "s/新建/新增/g" /tmp/arcmenu.po # Only zh_CN need this fix.
msgfmt /tmp/arcmenu.po -o /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/locale/zh_CN/LC_MESSAGES/arcmenu.mo
judge "Patch Arc Menu localization"

# Clean up
rm /tmp/arcmenu.po