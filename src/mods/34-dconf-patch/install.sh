set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# dconf is a binary file. To apply default dconf to all users, we must:
# - First apply the dconf settings to root user
# - Then copy the dconf settings to /etc/skel
# - Then remove the dconf settings from root user

print_ok "Loading dconf settings"
export $(dbus-launch)

# TODO FIXED PENDING CONFIRM: Overview was shown. Not working properly.
# TODO: Power button was shown, but not working properly

dconf load /org/gnome/ < ./dconf.ini
dconf write /org/gtk/settings/file-chooser/sort-directories-first true
dconf write /org/gnome/desktop/input-sources/xkb-options "@as []"
dconf write /org/gnome/desktop/input-sources/mru-sources "[('xkb', 'us')]"
judge "Load dconf settings"

print_ok "Patching global gdm3 dconf settings"
cp ./anduinos_text_smaller.png /usr/share/pixmaps/anduinos_text_smaller.png
cp ./greeter.dconf-defaults.ini /etc/gdm3/greeter.dconf-defaults
dconf update
judge "Patch global gdm3 dconf settings"

# TODO: Migrate to newer version of openweather-extension
if [ "$LANG_MODE" == "en_US" ]; then
    print_ok "Patching openweather city for San Francisco, California, United States"
    dconf write /org/gnome/shell/extensions/openweather/city "'37.7749295,-122.4194155>San Francisco, California, United States>0'"
    judge "Patch openweather city for San Francisco, California, United States"
elif [ "$LANG_MODE" == "zh_CN" ]; then
    print_ok "Installing on zh_CN mode, patching dconf for ibus-rime..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'rime')]"
    judge "Patch dconf for ibus-rime"

    print_ok "Patching openweather city for Suzhou, Jiangsu, China"
    dconf write /org/gnome/shell/extensions/openweather/city "'31.311123,120.6212881>苏州, 江苏>0'"
    judge "Patch openweather city for Suzhou, Jiangsu, China"
elif [ "$LANG_MODE" == "zh_TW" ]; then
    print_ok "Installing on zh_TW mode, patching dconf for ibus-chewing..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'chewing')]"
    judge "Patch dconf for ibus-chewing"

    print_ok "Patching openweather city for Taipei, Taiwan"
    dconf write /org/gnome/shell/extensions/openweather/city "'25.0329694,121.5654177>臺北市, 臺灣>0'"
    judge "Patch openweather city for Taipei, Taiwan"
elif [ "$LANG_MODE" == "zh_HK" ]; then
    print_ok "Installing on zh_HK mode, patching dconf for ibus-cangjie..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'table:cangjie-big')]"
    judge "Patch dconf for ibus-cangjie"

    print_ok "Patching openweather city for Hong Kong"
    dconf write /org/gnome/shell/extensions/openweather/city "'22.3193039,114.1693611>香港>0'"
    judge "Patch openweather city for Hong Kong"
elif [ "$LANG_MODE" == "ja_JP" ]; then
    print_ok "Installing on ja_JP mode, patching dconf for ibus-mozc-jp..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'mozc-jp')]"
    judge "Patch dconf for ibus-mozc-jp"

    print_ok "Patching openweather city for Tokyo, Japan"
    dconf write /org/gnome/shell/extensions/openweather/city "'35.6894875,139.6917064>東京都, 日本>0'"
    judge "Patch openweather city for Tokyo, Japan"
elif [ "$LANG_MODE" == "ko_KR" ]; then
    print_ok "Installing on ko_KR mode, patching dconf for ibus-hangul..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'hangul')]"
    judge "Patch dconf for ibus-hangul"

    print_ok "Patching openweather city for Seoul, South Korea"
    dconf write /org/gnome/shell/extensions/openweather/city "'37.566535,126.9779692>서울특별시, 대한민국>0'"
    judge "Patch openweather city for Seoul, South Korea"
elif [ "$LANG_MODE" == "vi_VN" ]; then
    print_ok "Installing on vi_VN mode, patching dconf for ibus-unikey..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'Unikey')]"
    judge "Patch dconf for ibus-unikey"

    print_ok "Patching openweather city for Thành phố Hà Nội, Việt Nam"
    dconf write /org/gnome/shell/extensions/openweather/city "'21.028511,105.804817>Thành phố Hà Nội, Việt Nam>0'"
    judge "Patch openweather city for Thành phố Hà Nội, Việt Nam"
elif [ "$LANG_MODE" == "th_TH" ]; then
    print_ok "Installing on th_TH mode, patching dconf for ibus-libthai..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('ibus', 'libthai')]"
    judge "Patch dconf for ibus-libthai"

    print_ok "Patching openweather city for กรุงเทพมหานคร, ประเทศไทย"
    dconf write /org/gnome/shell/extensions/openweather/city "'13.7563309,100.5017651>กรุงเทพมหานคร, ประเทศไทย>0'"
    judge "Patch openweather city for กรุงเทพมหานคร, ประเทศไทย"
elif [ "$LANG_MODE" == "de_DE" ]; then
    print_ok "Installing on de_DE mode, patching dconf for xkb-de..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('xkb', 'de')]"
    judge "Patch dconf for xkb-de"

    print_ok "Patching openweather city for Berlin, Deutschland"
    dconf write /org/gnome/shell/extensions/openweather/city "'52.5200066,13.404954>Berlin, Deutschland>0'"
    judge "Patch openweather city for Berlin, Deutschland"
elif [ "$LANG_MODE" == "fr_FR" ]; then
    print_ok "Installing on fr_FR mode, patching dconf for xkb-fr..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('xkb', 'fr')]"
    judge "Patch dconf for xkb-fr"

    print_ok "Patching openweather city for Paris, France"
    dconf write /org/gnome/shell/extensions/openweather/city "'48.8566969,2.3514616>Paris, France>0'"
    judge "Patch openweather city for Paris, France"
elif [ "$LANG_MODE" == "es_ES" ]; then
    print_ok "Installing on es_ES mode, patching dconf for xkb-es..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('xkb', 'es')]"
    judge "Patch dconf for xkb-es"

    print_ok "Patching openweather city for Madrid, España"
    dconf write /org/gnome/shell/extensions/openweather/city "'40.4167754,-3.7037902>Madrid, España>0'"
    judge "Patch openweather city for Madrid, España"
elif [ "$LANG_MODE" == "ru_RU" ]; then
    print_ok "Installing on ru_RU mode, patching dconf for xkb-ru..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('xkb', 'ru')]"
    judge "Patch dconf for xkb-ru"

    print_ok "Patching openweather city for Moscow, Russia"
    dconf write /org/gnome/shell/extensions/openweather/city "'55.755826,37.6173>Москва, Россия>0'"
    judge "Patch openweather city for Moscow, Russia"
elif [ "$LANG_MODE" == "it_IT" ]; then
    print_ok "Installing on it_IT mode, patching dconf for xkb-it..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('xkb', 'it')]"
    judge "Patch dconf for xkb-it"

    print_ok "Patching openweather city for Roma, Italia"
    dconf write /org/gnome/shell/extensions/openweather/city "'41.9027835,12.4963655>Roma, Italia>0'"
    judge "Patch openweather city for Roma, Italia"
elif [ "$LANG_MODE" == "pt_PT" ]; then
    print_ok "Installing on pt_PT mode, patching dconf for xkb-pt..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('xkb', 'pt')]"
    judge "Patch dconf for xkb-pt"

    print_ok "Patching openweather city for Lisboa, Portugal"
    dconf write /org/gnome/shell/extensions/openweather/city "'38.7222524,-9.1393366>Lisboa, Portugal>0'"
    judge "Patch openweather city for Lisboa, Portugal"
elif [ "$LANG_MODE" == "pt_BR" ]; then
    print_ok "Installing on pt_BR mode, patching dconf for xkb-br..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('xkb', 'br')]"
    judge "Patch dconf for xkb-br"

    print_ok "Patching openweather city for São Paulo, Brasil"
    dconf write /org/gnome/shell/extensions/openweather/city "'-23.5505199,-46.6333094>São Paulo, Brasil>0'"
    judge "Patch openweather city for São Paulo, Brasil"

elif [ "$LANG_MODE" == "ar_SA" ]; then
    print_ok "Installing on ar_SA mode, patching dconf for xkb-ara..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('xkb', 'ara')]"
    judge "Patch dconf for xkb-ara"

    print_ok "Patching openweather city for الرياض, المملكة العربية السعودية"
    dconf write /org/gnome/shell/extensions/openweather/city "'24.7135517,46.6752957>الرياض, المملكة العربية السعودية>0'"
    judge "Patch openweather city for الرياض, المملكة العربية السعودية"
elif [ "$LANG_MODE" == "nl_NL" ]; then
    print_ok "Installing on nl_NL mode, patching dconf for xkb-nl..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('xkb', 'nl')]"
    judge "Patch dconf for xkb-nl"

    print_ok "Patching openweather city for Amsterdam, Nederland"
    dconf write /org/gnome/shell/extensions/openweather/city "'52.3675734,4.9041383>Amsterdam, Nederland>0'"
    judge "Patch openweather city for Amsterdam, Nederland"
elif [ "$LANG_MODE" == "sv_SE" ]; then
    print_ok "Installing on sv_SE mode, patching dconf for xkb-se..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('xkb', 'se')]"
    judge "Patch dconf for xkb-se"

    print_ok "Patching openweather city for Stockholm, Sverige"
    dconf write /org/gnome/shell/extensions/openweather/city "'59.3293235,18.0685808>Stockholm, Sverige>0'"
    judge "Patch openweather city for Stockholm, Sverige"
elif [ "$LANG_MODE" == "pl_PL" ]; then
    print_ok "Installing on pl_PL mode, patching dconf for xkb-pl..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('xkb', 'pl')]"
    judge "Patch dconf for xkb-pl"

    print_ok "Patching openweather city for Warszawa, Polska"
    dconf write /org/gnome/shell/extensions/openweather/city "'52.2296756,21.0122287>Warszawa, Polska>0'"
    judge "Patch openweather city for Warszawa, Polska"
elif [ "$LANG_MODE" == "tr_TR" ]; then
    print_ok "Installing on tr_TR mode, patching dconf for xkb-tr..."
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'us'), ('xkb', 'tr')]"
    judge "Patch dconf for xkb-tr"

    print_ok "Patching openweather city for İstanbul, Türkiye"
    dconf write /org/gnome/shell/extensions/openweather/city "'41.0082376,28.9783589>İstanbul, Türkiye>0'"
    judge "Patch openweather city for İstanbul, Türkiye"
else
    print_warn "Unsupported language mode, using default settings."

    print_ok "Patching openweather city for San Francisco, California, United States"
    dconf write /org/gnome/shell/extensions/openweather/city "'37.7749295,-122.4194155>San Francisco, California, United States>0'"
    judge "Patch openweather city for San Francisco, California, United States"
fi

print_ok "Copying root's dconf settings to /etc/skel"
mkdir -p /etc/skel/.config/dconf
cp /root/.config/dconf/user /etc/skel/.config/dconf/user
judge "Copy root's dconf settings to /etc/skel"
