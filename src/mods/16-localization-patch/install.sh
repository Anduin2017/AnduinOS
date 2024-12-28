set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Patching Shotwell localization..."
sed -i "/^Name=/a Name[zh_CN]=图库" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[zh_TW]=圖庫" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[zh_HK]=圖庫" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[ja_JP]=写真" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[ko_KR]=사진" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[vi_VN]=Ảnh" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[th_TH]=รูปภาพ" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[de_DE]=Fotos" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[fr_FR]=Photos" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[es_ES]=Fotos" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[ru_RU]=Фотографии" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[it_IT]=Foto" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[pt_PT]=Fotos" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[pt_BR]=Fotos" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[ar_SA]=الصور" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[nl_NL]=Fotos" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[sv_SE]=Foton" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[pl_PL]=Zdjęcia" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^Name=/a Name[tr_TR]=Fotoğraflar" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[zh_CN]=图库" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[zh_TW]=圖庫" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[zh_HK]=圖庫" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[ja_JP]=写真" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[ko_KR]=사진" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[vi_VN]=Ảnh" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[th_TH]=รูปภาพ" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[de_DE]=Fotos" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[fr_FR]=Photos" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[es_ES]=Fotos" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[ru_RU]=Фотографии" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[it_IT]=Foto" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[pt_PT]=Fotos" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[pt_BR]=Fotos" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[ar_SA]=الصور" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[nl_NL]=Fotos" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[sv_SE]=Foton" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[pl_PL]=Zdjęcia" /usr/share/applications/org.gnome.Shotwell.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[tr_TR]=Fotoğraflar" /usr/share/applications/org.gnome.Shotwell.desktop
judge "Patch Shotwell localization"

print_ok "Patching rhythmbox localization..."
sed -i "/^Name=Rhythmbox/a Name[zh_CN]=音乐" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[zh_TW]=音樂" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[zh_HK]=音樂" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[ja_JP]=音楽" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[ko_KR]=음악" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[vi_VN]=Âm nhạc" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[th_TH]=เพลง" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[de_DE]=Musik" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[fr_FR]=Musique" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[es_ES]=Música" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[ru_RU]=Музыка" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[it_IT]=Musica" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[pt_PT]=Música" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[pt_BR]=Música" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[ar_SA]=الموسيقى" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[nl_NL]=Muziek" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[sv_SE]=Musik" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[pl_PL]=Muzyka" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^Name=Rhythmbox/a Name[tr_TR]=Müzik" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[zh_CN]=音乐" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[zh_TW]=音樂" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[zh_HK]=音樂" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[ja_JP]=音楽" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[ko_KR]=음악" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[vi_VN]=Âm nhạc" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[th_TH]=เพลง" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[de_DE]=Musik" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[fr_FR]=Musique" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[es_ES]=Música" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[ru_RU]=Музыка" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[it_IT]=Musica" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[pt_PT]=Música" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[pt_BR]=Música" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[ar_SA]=الموسيقى" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[nl_NL]=Muziek" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[sv_SE]=Musik" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[pl_PL]=Muzyka" /usr/share/applications/org.gnome.Rhythmbox3.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[tr_TR]=Müzik" /usr/share/applications/org.gnome.Rhythmbox3.desktop
judge "Patch rhythmbox localization"

print_ok "Patching baobab localization..."
sed -i "/^Name=/a Name[zh_CN]=磁盘分析" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[zh_TW]=磁碟分析" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[zh_HK]=磁碟分析" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[ja_JP]=ディスク使用状況" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[ko_KR]=디스크 사용량 분석" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[vi_VN]=Phân tích đĩa" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[th_TH]=วิเคราะห์การใช้งานดิสก์" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[de_DE]=Festplattenbelegung" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[fr_FR]=Analyseur d'utilisation des disques" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[es_ES]=Analizador de uso de disco" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[ru_RU]=Анализ использования диска" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[it_IT]=Analizzatore utilizzo disco" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[pt_PT]=Analisador de uso de disco" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[pt_BR]=Analisador de uso de disco" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[ar_SA]=محلل استخدام القرص" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[nl_NL]=Schijfgebruik" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[sv_SE]=Diskanvändning" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[pl_PL]=Analiza użycia dysku" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^Name=/a Name[tr_TR]=Disk Kullanım Analizi" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[zh_CN]=磁盘分析" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[zh_TW]=磁碟分析" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[zh_HK]=磁碟分析" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[ja_JP]=ディスク使用状況" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[ko_KR]=디스크 사용량 분석" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[vi_VN]=Phân tích đĩa" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[th_TH]=วิเคราะห์การใช้งานดิสก์" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[de_DE]=Festplattenbelegung" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[fr_FR]=Analyseur d'utilisation des disques" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[es_ES]=Analizador de uso de disco" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[ru_RU]=Анализ использования диска" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[it_IT]=Analizzatore utilizzo disco" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[pt_PT]=Analisador de uso de disco" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[pt_BR]=Analisador de uso de disco" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[ar_SA]=محلل استخدام القرص" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[nl_NL]=Schijfgebruik" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[sv_SE]=Diskanvändning" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[pl_PL]=Analiza użycia dysku" /usr/share/applications/org.gnome.baobab.desktop
sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[tr_TR]=Disk Kullanım Analizi" /usr/share/applications/org.gnome.baobab.desktop

judge "Patch baobab localization"