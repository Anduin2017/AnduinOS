set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Patching Arc Menu..."

print_ok "Patch Arc Menu logo..."
mv ./logo.svg /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/icons/anduinos-logo.svg
judge "Patch Arc Menu logo"

print_ok "Patch Arc Menu text..."
sed -i 's/Unpin from ArcMenu/Unpin from Start menu/g' /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/appMenu.js
sed -i 's/Pin to ArcMenu/Pin to Start menu/g' /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/appMenu.js
sed -i "s/_('Log Out...')/_('Log Out')/" /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/constants.js
sed -i "s/_('Restart...')/_('Restart')/" /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/constants.js
sed -i "s/_('Power Off...')/_('Power Off')/" /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/constants.js
judge "Patch Arc Menu text"

print_ok "Patch Arc Menu localization..."
msgunfmt /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/locale/zh_CN/LC_MESSAGES/arcmenu.mo -o /tmp/arcmenu.po
cat ./arcmenu.po >> /tmp/arcmenu.po
sed -i "s/新建/新增/g" /tmp/arcmenu.po
msgfmt /tmp/arcmenu.po -o /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/locale/zh_CN/LC_MESSAGES/arcmenu.mo
judge "Patch Arc Menu localization"

# Clean up
rm /tmp/arcmenu.po