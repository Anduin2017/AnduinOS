set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Configuring locales and resolvconf..."
dpkg-reconfigure locales
dpkg-reconfigure resolvconf
judge "Configure locales and resolvconf"

print_ok "Configuring locales to $LANG..."

cat << EOF > /etc/default/locale
#  File generated by update-locale
LANG="$LANG"
EOF
judge "Configure /etc/default/locale"

# Comment the lines below.
# This is because if you uncomment them, the ubiquity installer will throw an error indicating that `grub-install: error "cannot find EFI directory"`.
# I have wasted several hours trying to figure out why the ubiquity installer is throwing this error. But I have not found a solution yet.
# So please just comment the lines below.

# cat << EOF > /etc/skel/.pam_environment
# LANGUAGE	DEFAULT=$LANG_MODE:$LANG_PACK_CODE
# LANG	DEFAULT=$LANG
# LC_NUMERIC	DEFAULT=$LANG
# LC_TIME	DEFAULT=$LANG
# LC_MONETARY	DEFAULT=$LANG
# LC_PAPER	DEFAULT=$LANG
# LC_NAME	DEFAULT=$LANG
# LC_ADDRESS	DEFAULT=$LANG
# LC_TELEPHONE	DEFAULT=$LANG
# LC_MEASUREMENT	DEFAULT=$LANG
# LC_IDENTIFICATION	DEFAULT=$LANG
# PAPERSIZE	DEFAULT=a4
# EOF
# judge "Configure /etc/skel/.pam_environment"

if [ "$LANG_MODE" == "en_US" ]; then
    TIMEZONE="America/Los_Angeles"
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
elif [ "$LANG_MODE" == "vi_VN" ]; then
    TIMEZONE="Asia/Ho_Chi_Minh"
elif [ "$LANG_MODE" == "th_TH" ]; then
    TIMEZONE="Asia/Bangkok"
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

# This is actually setting on the system clock, not the timezone. Do not use this command:
# > timedatectl set-timezone $TIMEZONE
# To set the timezone for the new OS being built (In chroot environment), use the following command:

print_ok "Configuring timezone to $TIMEZONE..."
if [ ! -f /usr/share/zoneinfo/$TIMEZONE ]; then
    print_error "Error: /usr/share/zoneinfo/$TIMEZONE not found."
    exit 1
fi

print_ok "Configuring /etc/timezone to $TIMEZONE..."
echo $TIMEZONE > /etc/timezone
judge "Configure /etc/timezone"

print_ok "Configuring /etc/localtime to $TIMEZONE..."
rm /etc/localtime
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
judge "Configure /etc/timezone and /etc/localtime"


