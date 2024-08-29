set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing gnome-shell and other gnome applications"
waitNetwork
apt install -y \
    ca-certificates gpg apt-transport-https \
    ubuntu-session yaru-theme-sound yaru-theme-gnome-shell \
    plymouth plymouth-label plymouth-theme-spinner plymouth-theme-ubuntu-text plymouth-theme-ubuntu-logo \
    gnome-shell gir1.2-gmenu-3.0 gnome-menus gnome-shell-extensions \
    nautilus usb-creator-gtk cheese baobab file-roller gnome-sushi ffmpegthumbnailer \
    gnome-calculator gnome-disk-utility gnome-control-center gnome-logs \
    gnome-chess gnome-mines gnome-sudoku \
    gnome-shell-extension-prefs gnome-shell-extension-desktop-icons-ng gnome-shell-extension-appindicator \
    gnome-screenshot gnome-system-monitor gnome-sound-recorder gnome-characters gnome-font-viewer \
    fonts-noto-cjk fonts-noto-core fonts-noto-mono fonts-noto-color-emoji \
    cups system-config-printer cups-bsd \
    ubuntu-drivers-common alsa-utils \
    gnome-clocks \
    gnome-weather \
    gedit \
    gnome-nettool \
    seahorse gdebi evince \
    ibus \
    shotwell \
    remmina remmina-plugin-rdp \
    firefox \
    totem totem-plugins gstreamer1.0-libav \
    rhythmbox rhythmbox-plugins \
    transmission-gtk transmission-common \
    gnome-console nautilus-extension-gnome-console \
    python3-apt python3-pip python-is-python3 \
    git lsb-release coreutils \
    gnupg vim nano \
    wget curl \
    httping nethogs net-tools iftop traceroute dnsutils iperf3 \
    smartmontools \
    htop iotop iftop \
    tree ntp ntpdate ntpstat \
    w3m sysbench \
    zip unzip jq \
    cifs-utils \
    aisleriot \
    libsass1 sassc \
    dmz-cursor-theme
judge "Install gnome-shell and other gnome applications"

print_ok "Installing $LANGUAGE_PACKS language packs"
apt install -y $LANGUAGE_PACKS
judge "Install language packs"