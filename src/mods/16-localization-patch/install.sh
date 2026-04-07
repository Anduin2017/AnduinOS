set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# if DEFAULT_APPS contains shotwell:
if [[ $DEFAULT_APPS =~ "shotwell" ]]; then
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
    sed -i "/^Name=/a Name[ro_RO]=Fotografii" /usr/share/applications/org.gnome.Shotwell.desktop
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
    sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[ro_RO]=Fotografii" /usr/share/applications/org.gnome.Shotwell.desktop
    judge "Patch Shotwell localization"
fi

if [[ $DEFAULT_APPS =~ "rhythmbox" ]]; then
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
    sed -i "/^Name=Rhythmbox/a Name[ro_RO]=Muzică" /usr/share/applications/org.gnome.Rhythmbox3.desktop
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
    sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[ro_RO]=Muzică" /usr/share/applications/org.gnome.Rhythmbox3.desktop
    judge "Patch rhythmbox localization"
fi

if [[ $DEFAULT_APPS =~ "baobab" ]]; then
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
    sed -i "/^Name=/a Name[ro_RO]=Analizator de utilizare a hard discului" /usr/share/applications/org.gnome.baobab.desktop
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
    sed -i "/^X-GNOME-FullName=/a X-GNOME-FullName[ro_RO]=Analizator de utilizare a hard discului" /usr/share/applications/org.gnome.baobab.desktop
    judge "Patch baobab localization"
fi

if [[ $DEFAULT_APPS =~ "qalculate" ]]; then
    DESKTOP_FILE="/usr/share/applications/qalculate-gtk.desktop"
    print_ok "Patching qalculate localization..."

    # Map of locale codes → translated application name
    declare -A LOCALIZED_NAMES=(
        [zh_CN]="计算器"
        [zh_TW]="計算器"
        [zh_HK]="計算器"
        [ja_JP]="計算機"
        [ko_KR]="계산기"
        [vi_VN]="Máy tính"
        [th_TH]="เครื่องคิดเลข"
        [de_DE]="Taschenrechner"
        [fr_FR]="Calculatrice"
        [es_ES]="Calculadora"
        [ru_RU]="Калькулятор"
        [it_IT]="Calcolatrice"
        [pt_PT]="Calculadora"
        [pt_BR]="Calculadora"
        [ar_SA]="آلة حاسبة"
        [nl_NL]="Rekenmachine"
        [sv_SE]="Kalkylator"
        [pl_PL]="Kalkulator"
        [tr_TR]="Hesap Makinesi"
        [ro_RO]="Calculator"
    )

    # For each locale: remove any existing Name[<locale>] line, then insert our translation
    for locale in "${!LOCALIZED_NAMES[@]}"; do
        name="${LOCALIZED_NAMES[$locale]}"
        # delete any old entries
        sed -i "/^Name\[$locale\]=/d" "$DESKTOP_FILE"
        # insert immediately after the default Name= line
        sed -i "/^Name=/a Name[$locale]=${name}" "$DESKTOP_FILE"
        judge "Patch qalculate localization for $locale"
    done

    print_ok "Done. All locales patched in $DESKTOP_FILE."

fi

if [[ $DEFAULT_APPS =~ "papers" ]]; then
    print_ok "Patching Document Viewer (papers) localization..."
    DESKTOP_FILE="/usr/share/applications/org.gnome.Papers.desktop"

    # 定义一个包含所有翻译的关联数组
    declare -A LOCALIZED_NAMES=(
        [zh_CN]="文档查看器"
        [zh_TW]="文件檢視器"
        [zh_HK]="文件檢視器"
        [ja_JP]="ドキュメントビューアー"
        [ko_KR]="문서 뷰어"
        [vi_VN]="Trình xem tài liệu"
        [th_TH]="โปรแกรมดูเอกสาร"
        [de_DE]="Dokumentenbetrachter"
        [fr_FR]="Visionneur de documents"
        [es_ES]="Visor de documentos"
        [ru_RU]="Просмотрщик документов"
        [it_IT]="Visualizzatore di documenti"
        [pt_PT]="Visualizador de documentos"
        [pt_BR]="Visualizador de documentos"
        [ar_SA]="عارض المستندات"
        [nl_NL]="Documentviewer"
        [sv_SE]="Dokumentvisare"
        [pl_PL]="Przeglądarka dokumentów"
        [tr_TR]="Belge Görüntüleyici"
        [ro_RO]="Vizualizator de documente"
    )

    # 循环遍历数组，为每种语言添加翻译
    for locale in "${!LOCALIZED_NAMES[@]}"; do
        name="${LOCALIZED_NAMES[$locale]}"
        # 先删除可能存在的旧条目，防止重复
        sed -i "/^Name\[$locale\]=/d" "$DESKTOP_FILE"
        # 在 `Name=` 这一行之后插入新的翻译
        sed -i "/^Name=/a Name[$locale]=${name}" "$DESKTOP_FILE"
    done

    judge "Patch Document Viewer (papers) localization"
fi