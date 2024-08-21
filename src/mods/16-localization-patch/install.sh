print_ok "Patching Shotwell localization..."
sed -i '/^Name=/a Name[zh_CN]=图库' /usr/share/applications/shotwell.desktop
sed -i '/^Name=/a Name[zh_TW]=圖庫' /usr/share/applications/shotwell.desktop
sed -i '/^X-GNOME-FullName=/a X-GNOME-FullName[zh_CN]=图库' /usr/share/applications/shotwell.desktop
sed -i '/^X-GNOME-FullName=/a X-GNOME-FullName[zh_TW]=圖庫' /usr/share/applications/shotwell.desktop
judge "Patch Shotwell localization"

print_ok "Patching rhythmbox localization..."
sed -i '/^Name=/a Name[zh_CN]=音乐' /usr/share/applications/rhythmbox.desktop
sed -i '/^Name=/a Name[zh_TW]=音樂' /usr/share/applications/rhythmbox.desktop
sed -i '/^X-GNOME-FullName=/a X-GNOME-FullName[zh_CN]=音乐' /usr/share/applications/rhythmbox.desktop
sed -i '/^X-GNOME-FullName=/a X-GNOME-FullName[zh_TW]=音樂' /usr/share/applications/rhythmbox.desktop
judge "Patch rhythmbox localization"

print_ok "Patching baobab localization..."
sed -i '/^Name=/a Name[zh_CN]=磁盘分析' /usr/share/applications/org.gnome.baobab.desktop
sed -i '/^Name=/a Name[zh_TW]=磁碟分析' /usr/share/applications/org.gnome.baobab.desktop
sed -i '/^X-GNOME-FullName=/a X-GNOME-FullName[zh_CN]=磁盘分析' /usr/share/applications/org.gnome.baobab.desktop
sed -i '/^X-GNOME-FullName=/a X-GNOME-FullName[zh_TW]=磁碟分析' /usr/share/applications/org.gnome.baobab.desktop
judge "Patch baobab localization"