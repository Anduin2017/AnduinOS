set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

if [ "$LANG_MODE" == "en_US" ]; then
    print_ok "United State users do not need to install input method."
elif [ "$LANG_MODE" == "zh_CN" ]; then
    print_ok "Installing ibus-rime..."
    apt install ibus-rime -y
    judge "Install ibus-rime"

    print_ok "Setting up ibus..."
    im-config -n ibus
    judge "Set up ibus"

    print_ok "Installing Rime schema..."
    zip=https://gitlab.aiursoft.cn/anduin/anduinos-rime/-/archive/master/anduinos-rime-master.zip
    wget $zip -O anduinos-rime.zip && unzip anduinos-rime.zip && rm anduinos-rime.zip
    mkdir -p /etc/skel/.config/ibus/rime
    rsync -Aavx --update --delete ./anduinos-rime-master/assets/ /etc/skel/.config/ibus/rime/
    rm -rf ./anduinos-rime-master/
    judge "Install Rime schema"
elif [ "$LANG_MODE" == "zh_TW" ]; then
    print_ok "Installing ibus-chewing..."
    apt install ibus-chewing -y
    judge "Install ibus-chewing"
elif [ "$LANG_MODE" == "zh_HK" ]; then
    print_ok "Installing ibus-cangjie..."
    apt install ibus-table-cangjie -y
    judge "Install ibus-cangjie"
elif [ "$LANG_MODE" == "ja_JP" ]; then
    print_ok "Installing ibus-mozc..."
    apt install ibus-mozc -y
    judge "Install ibus-mozc"
elif [ "$LANG_MODE" == "ko_KR" ]; then
    print_ok "Installing ibus-hangul..."
    apt install ibus-hangul -y
    judge "Install ibus-hangul"
elif [ "$LANG_MODE" == "vi_VN" ]; then
    print_ok "Installing ibus-unikey..."
    apt install ibus-unikey -y
    judge "Install ibus-unikey"
elif [ "$LANG_MODE" == "th_TH" ]; then
    print_ok "Installing ibus-libthai..."
    apt install ibus-libthai -y
    judge "Install ibus-libthai"
elif [ "$LANG_MODE" == "de_DE" ]; then
    print_ok "German users do not need to install input method."
elif [ "$LANG_MODE" == "fr_FR" ]; then
    print_ok "French users do not need to install input method."
elif [ "$LANG_MODE" == "es_ES" ]; then
    print_ok "Spanish users do not need to install input method."
elif [ "$LANG_MODE" == "ru_RU" ]; then
    print_ok "Russian users do not need to install input method."
elif [ "$LANG_MODE" == "it_IT" ]; then
    print_ok "Italian users do not need to install input method."
elif [ "$LANG_MODE" == "pt_PT" ]; then
    print_ok "Portuguese users do not need to install input method."
elif [ "$LANG_MODE" == "ar_SA" ]; then
    print_ok "Arabic users do not need to install input method."
elif [ "$LANG_MODE" == "nl_NL" ]; then
    print_ok "Dutch users do not need to install input method."
elif [ "$LANG_MODE" == "sv_SE" ]; then
    print_ok "Swedish users do not need to install input method."
elif [ "$LANG_MODE" == "pl_PL" ]; then
    print_ok "Polish users do not need to install input method."
elif [ "$LANG_MODE" == "tr_TR" ]; then
    print_ok "Turkish users do not need to install input method."
else
    print_warn "Skipping input method installation for $LANG_MODE"
fi

print_ok "Patching language-selector to install input method packages"
# Remove all lines in /usr/share/language-selector/data/pkg_depends that starts with 'im:'
sed -i '/^im:/d' /usr/share/language-selector/data/pkg_depends
# Add the the lines to /usr/share/language-selector/data/pkg_depends based on ./pkg_depends_patch
cat ./pkg_depends_patch >> /usr/share/language-selector/data/pkg_depends
judge "Patch language-selector to install input method packages"