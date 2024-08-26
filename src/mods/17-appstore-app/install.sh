set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Adding new app called AnduinOS Software..."
cat << EOF > /usr/share/applications/anduinos-software.desktop
[Desktop Entry]
Name=Apps Store
GenericName=Apps Store
Name[zh_CN]=应用商店
Name[zh_TW]=應用商店
Comment=Browse AnduinOS's software collection and install our verified applications
Comment[zh_CN]=浏览 AnduinOS 的软件商店并安装我们验证过的应用
Comment[zh_TW]=瀏覽 AnduinOS 的軟體商店並安裝我們驗證過的應用
Categories=System;
Exec=xdg-open https://docs.anduinos.com/Applications/Introduction.html
Terminal=false
Type=Application
Icon=system-software-install
StartupNotify=true
EOF