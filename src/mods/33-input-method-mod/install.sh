if [ "$LANG_MODE" == "zh_CN" ]; then
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
    #rsync -Aavx --update --delete ./anduinos-rime-master/assets/ /etc/skel/.config/ibus/rime/
    rsync -Aavx --update --delete ./anduinos-rime-master/assets/ /etc/skel/.config/ibus/rime/
    rm -rf ./anduinos-rime-master/
    judge "Install Rime schema"

    print_ok "Hold ibus-libpinyin to avoid installation of it..."
    apt-mark hold ibus-libpinyin
    judge "Hold ibus-libpinyin"
else
    print_warn "Skipping input method installation for $LANG_MODE"
fi
