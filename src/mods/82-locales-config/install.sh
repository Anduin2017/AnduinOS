set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Configuring locales and resolvconf..."
dpkg-reconfigure locales
dpkg-reconfigure resolvconf
judge "Configure locales and resolvconf"

print_ok "Configuring locales to $LANG..."

cat << EOF > /etc/default/locale
# Generated by AnduinOS.
LANG="$LANG"
LC_ALL="$LANG"
LC_NUMERIC="$LANG"
LC_TIME="$LANG"
LC_MONETARY="$LANG"
LC_PAPER="$LANG"
LC_NAME="$LANG"
LC_ADDRESS="$LANG"
LC_TELEPHONE="$LANG"
LC_MEASUREMENT="$LANG"
LC_IDENTIFICATION="$LANG"
EOF
judge "Configure /etc/default/locale"

cat << EOF > /etc/skel/.pam_environment
# Generated by AnduinOS.
LANG="$LANG"
LC_ALL="$LANG"
LC_NUMERIC="$LANG"
LC_TIME="$LANG"
LC_MONETARY="$LANG"
LC_PAPER="$LANG"
LC_NAME="$LANG"
LC_ADDRESS="$LANG"
LC_TELEPHONE="$LANG"
LC_MEASUREMENT="$LANG"
LC_IDENTIFICATION="$LANG"
EOF
judge "Configure /etc/skel/.pam_environment"

# Set the language environment. Can be: en_US, zh_CN, zh_TW, zh_HK, ja_JP, ko_KR, de_DE, fr_FR, es_ES, ru_RU, it_IT, pt_PT, vi_VN, th_TH, ar_SA, nl_NL, sv_SE, pl_PL, tr_TR
if [ "$LANG_MODE" == "en_US" ]; then
    TIMEZONE="America/New_York"
elif [ "$LANG_MODE" == "zh_CN" ]; then
    TIMEZONE="Asia/Shanghai"
elif [ "$LANG_MODE" == "zh_TW" ]; then
    TIMEZONE="Asia/Taipei"
elif [ "$LANG_MODE" == "zh_HK" ]; then
    TIMEZONE="Asia/Hong_Kong"
elif [ "$LANG_MODE" == "ja_JP" ]; then
    TIMEZONE="Asia/Tokyo"
elif [ "$LANG_MODE" == "ko_KR" ]; then
    TIMEZONE="Asia/Seoul"
elif [ "$LANG_MODE" == "de_DE" ]; then
    TIMEZONE="Europe/Berlin"
elif [ "$LANG_MODE" == "fr_FR" ]; then
    TIMEZONE="Europe/Paris"
elif [ "$LANG_MODE" == "es_ES" ]; then
    TIMEZONE="Europe/Madrid"
elif [ "$LANG_MODE" == "ru_RU" ]; then
    TIMEZONE="Europe/Moscow"
elif [ "$LANG_MODE" == "it_IT" ]; then
    TIMEZONE="Europe/Rome"
elif [ "$LANG_MODE" == "pt_PT" ]; then
    TIMEZONE="Europe/Lisbon"
elif [ "$LANG_MODE" == "vi_VN" ]; then
    TIMEZONE="Asia/Ho_Chi_Minh"
elif [ "$LANG_MODE" == "th_TH" ]; then
    TIMEZONE="Asia/Bangkok"
elif [ "$LANG_MODE" == "ar_SA" ]; then
    TIMEZONE="Asia/Riyadh"
elif [ "$LANG_MODE" == "nl_NL" ]; then
    TIMEZONE="Europe/Amsterdam"
elif [ "$LANG_MODE" == "sv_SE" ]; then
    TIMEZONE="Europe/Stockholm"
elif [ "$LANG_MODE" == "pl_PL" ]; then
    TIMEZONE="Europe/Warsaw"
elif [ "$LANG_MODE" == "tr_TR" ]; then
    TIMEZONE="Europe/Istanbul"
else
    TIMEZONE="GMT"
fi

print_ok "Configuring timezone to $TIMEZONE..."
timedatectl set-timezone $TIMEZONE
judge "Configure timezone to $TIMEZONE"

