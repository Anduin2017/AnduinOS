if [ "$LANG_MODE" == "zh_CN" ]; then
    print_ok "Installing ibus-rime..."
    apt install ibus-rime
    judge "Install ibus-rime"

    print_ok "Setting up ibus..."
    im-config -n ibus
    judge "Set up ibus"

    print_ok "Installing Rime schema..."
    zip=https://gitlab.aiursoft.cn/anduin/anduinos-rime/-/archive/master/anduinos-rime-master.zip
    wget $zip -O anduinos-rime.zip && unzip anduinos-rime.zip && rm anduinos-rime.zip
    rsync -Aavx --update --delete ./anduinos-rime-master/assets/ ~/.config/ibus/rime/
    rm -rf anduinos-rime-master
    ibus restart
    ibus engine rime
    judge "Install Rime schema"
else
    print_warn "Skipping input method installation for $LANG_MODE"
fi
