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
Comment[zh_HK]=瀏覽 AnduinOS 的軟體商店並安裝我們驗證過的應用
Comment[ja_JP]=AnduinOS のソフトウェアコレクションを閲覧し、検証済みのアプリケーションをインストールします
Comment[ko_KR]=AnduinOS의 소프트웨어 컬렉션을 탐색하고 검증된 애플리케이션을 설치합니다
Comment[de_DE]=Durchsuchen Sie die Softwarekollektion von AnduinOS und installieren Sie unsere verifizierten Anwendungen
Comment[fr_FR]=Parcourez la collection de logiciels d'AnduinOS et installez nos applications vérifiées
Comment[es_ES]=Explore la colección de software de AnduinOS e instale nuestras aplicaciones verificadas
Comment[ru_RU]=Просматривайте коллекцию программного обеспечения AnduinOS и устанавливайте наши проверенные приложения
Comment[it_IT]=Esplora la collezione di software di AnduinOS e installa le nostre applicazioni verificate
Comment[pt_PT]=Explore a coleção de software da AnduinOS e instale nossos aplicativos verificados
Comment[vi_VN]=Duyệt bộ sưu tập phần mềm của AnduinOS và cài đặt các ứng dụng đã được xác minh của chúng tôi
Comment[th_TH]=เรียกดูคอลเลกชันซอฟต์แวร์ของ AnduinOS และติดตั้งแอปพลิเคชันที่ได้รับการตรวจสอบของเรา
Comment[ar_SA]=تصفح مجموعة البرامج الخاصة بـ AnduinOS وقم بتثبيت تطبيقاتنا الموثقة
Comment[nl_NL]=Blader door de softwarecollectie van AnduinOS en installeer onze geverifieerde applicaties
Comment[sv_SE]=Bläddra i AnduinOS programvarusamling och installera våra verifierade applikationer
Comment[pl_PL]=Przeglądaj kolekcję oprogramowania AnduinOS i instaluj nasze zweryfikowane aplikacje
Comment[tr_TR]=AnduinOS'un yazılım koleksiyonunu göz atın ve doğrulanmış uygulamalarımızı yükleyin
Categories=System;
Exec=xdg-open https://docs.anduinos.com/Applications/Introduction.html
Terminal=false
Type=Application
Icon=system-software-install
StartupNotify=true
EOF