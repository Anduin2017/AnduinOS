set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing gnome-shell and other gnome applications"
waitNetwork

print_ok "Installing basic packages..."
apt install -y \
    ca-certificates gpg apt-transport-https gnupg software-properties-common
judge "Install basic packages"

print_ok "Installing gnome basic sessions..."
apt install -y \
    gnome-shell ubuntu-session yaru-theme-sound yaru-theme-gnome-shell gir1.2-gmenu-3.0 gnome-menus gnome-shell-extensions
judge "Install gnome basic sessions"

print_ok "Installing plymouth..."
apt install -y \
    plymouth \
    plymouth-label \
    plymouth-theme-spinner \
    plymouth-theme-ubuntu-text \
    plymouth-theme-ubuntu-gnome-logo
judge "Install plymouth"

print_ok "Installing gnome basic applications..."
apt install -y \
    nautilus \
    usb-creator-gtk \
    cheese \
    baobab \
    file-roller \
    gnome-sushi \
    qalculate-gtk \
    yelp \
    gnome-user-docs \
    gnome-disk-utility \
    gnome-control-center \
    gnome-logs \
    gnome-screenshot \
    gnome-system-monitor \
    gnome-sound-recorder \
    gnome-characters \
    gnome-bluetooth \
    gnome-power-manager \
    gnome-maps \
    gnome-font-viewer 
judge "Install gnome basic applications"

print_ok "Installing gnome games..."
apt install -y \
    gnome-chess
judge "Install gnome games"

print_ok "Installing gnome extension utilities..."
apt install -y \
    gnome-shell-extension-prefs \
    gnome-shell-extension-desktop-icons-ng \
    gnome-shell-extension-appindicator 
judge "Install gnome extension utilities"

print_ok "Installing gnome additional applications..."
apt install -y \
    gnome-clocks \
    gnome-weather \
    gnome-nettool \
    gedit \
    seahorse \
    gdebi \
    evince \
    shotwell \
    remmina remmina-plugin-rdp \
    rhythmbox rhythmbox-plugins \
    totem totem-plugins gstreamer1.0-libav \
    transmission-gtk transmission-common \
    ffmpegthumbnailer
judge "Install gnome additional applications"

print_ok "Installing gnome console..."
apt install -y \
    gnome-console nautilus-extension-gnome-console
judge "Install gnome console"

print_ok "Installing gnome fonts..."
apt install -y \
    fonts-noto-cjk fonts-noto-core fonts-noto-mono fonts-noto-color-emoji
judge "Install gnome fonts"

print_ok "Installing gnome printer support..."
apt install -y \
    cups system-config-printer cups-bsd
judge "Install gnome printer support"

print_ok "Installing ubuntu drivers support..."
apt install -y \
    ubuntu-drivers-common alsa-utils
judge "Install ubuntu drivers support"

print_ok "Installing input method..."
apt install -y \
    ibus
judge "Install input method"

print_ok "Installing web browser..."
apt install -y \
    firefox
judge "Install web browser"

print_ok "Installing python3..."
apt install -y \
    python3 python3-pip python-is-python3
judge "Install python3"

print_ok "Installing other libraries..."
apt install -y \
    git lsb-release coreutils \
    vim nano \
    wget curl \
    httping net-tools traceroute dnsutils \
    smartmontools htop \
    ntp ntpdate ntpstat \
    zip unzip \
    cifs-utils \
    libsass1 sassc
judge "Install other libraries"

print_ok "Remove the default htop.desktop file"
rm /usr/share/applications/htop.desktop
judge "Remove the default htop.desktop file"

print_ok "Remove the default vim.desktop file"
rm /usr/share/applications/vim.desktop
judge "Remove the default vim.desktop file"

print_ok "Installing $LANGUAGE_PACKS language packs"
apt install -y $LANGUAGE_PACKS
judge "Install language packs"