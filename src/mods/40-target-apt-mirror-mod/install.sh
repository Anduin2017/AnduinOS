set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Setting up apt sources..."

# Can be: en_US, zh_CN, zh_TW, zh_HK, ja_JP, ko_KR, de_DE, fr_FR, es_ES, ru_RU, it_IT, pt_PT, vi_VN, th_TH, ar_SA, nl_NL, sv_SE, pl_PL, tr_TR
if [ "$LANG_MODE" == "en_US" ]; then
    MIRROR="http://archive.ubuntu.com/ubuntu/"
elif [ "$LANG_MODE" == "zh_CN" ]; then
    MIRROR="https://mirrors.tuna.tsinghua.edu.cn/ubuntu/"
elif [ "$LANG_MODE" == "zh_TW" ]; then
    MIRROR="https://mirror.twds.com.tw/ubuntu/"
elif [ "$LANG_MODE" == "zh_HK" ]; then
    MIRROR="http://hk.mirrors.thegigabit.com/ubuntu/"
elif [ "$LANG_MODE" == "ja_JP" ]; then
    MIRROR="https://ftp.udx.icscoe.jp/Linux/ubuntu/"
elif [ "$LANG_MODE" == "ko_KR" ]; then
    MIRROR="https://ftp.kaist.ac.kr/ubuntu/"
elif [ "$LANG_MODE" == "de_DE" ]; then
    MIRROR="https://ftp.uni-stuttgart.de/ubuntu/"
elif [ "$LANG_MODE" == "fr_FR" ]; then
    MIRROR="https://mirror.ubuntu.ikoula.com/"
elif [ "$LANG_MODE" == "es_ES" ]; then
    MIRROR="https://labs.eif.urjc.es/mirror/ubuntu/"
elif [ "$LANG_MODE" == "ru_RU" ]; then
    MIRROR="https://mirror.team-host.ru/ubuntu/"
elif [ "$LANG_MODE" == "it_IT" ]; then
    MIRROR="https://ubuntu.mirror.garr.it/ubuntu/"
elif [ "$LANG_MODE" == "pt_PT" ]; then
    MIRROR="https://labs.eif.urjc.es/mirror/ubuntu/"
elif [ "$LANG_MODE" == "vi_VN" ]; then
    MIRROR="https://mirror.bizflycloud.vn/ubuntu/"
elif [ "$LANG_MODE" == "th_TH" ]; then
    MIRROR="https://mirror.kku.ac.th/ubuntu/"
elif [ "$LANG_MODE" == "ar_SA" ]; then
    MIRROR="https://mirrors.isu.net.sa/apt-mirror/"
elif [ "$LANG_MODE" == "nl_NL" ]; then
    MIRROR="https://mirror.i3d.net/pub/ubuntu/"
elif [ "$LANG_MODE" == "sv_SE" ]; then
    MIRROR="https://ftp.acc.umu.se/ubuntu/"
elif [ "$LANG_MODE" == "pl_PL" ]; then
    MIRROR="https://mirroronet.pl/pub/mirrors/ubuntu/"
elif [ "$LANG_MODE" == "tr_TR" ]; then
    MIRROR="https://mirror.alastyr.com/ubuntu/ubuntu-archive/"
else
    print_warn "Unsupported language mode, using default mirror."
    MIRROR="http://archive.ubuntu.com/ubuntu/"
fi

cat << EOF > /etc/apt/sources.list
deb $MIRROR $TARGET_UBUNTU_VERSION main restricted universe multiverse
deb $MIRROR $TARGET_UBUNTU_VERSION-updates main restricted universe multiverse
deb $MIRROR $TARGET_UBUNTU_VERSION-backports main restricted universe multiverse
deb $MIRROR $TARGET_UBUNTU_VERSION-security main restricted universe multiverse
EOF
judge "Set up apt sources to $MIRROR"

apt update