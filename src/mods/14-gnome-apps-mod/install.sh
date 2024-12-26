set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing gnome-shell and other gnome applications"
waitNetwork

print_ok "Installing basic packages..."
apt install -y \
    apt-transport-https \
    ca-certificates \
    cifs-utils \
    cloud-init \
    coreutils \
    curl \
    dnsutils \
    git \
    gnupg \
    gpg \
    gvfs-fuse \
    htop \
    httping \
    libsass1 \
    lsb-release \
    nano \
    net-tools \
    ntp \
    ntpdate \
    ntpstat \
    sassc \
    smartmontools \
    software-properties-common \
    squashfs-tools \
    sysstat \
    thermald \
    traceroute \
    unzip \
    vim \
    wget \
    whiptail \
    zip
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
    plymouth-theme-ubuntu-text
judge "Install plymouth"

print_ok "Installing network manager vpn packages..."
case $TARGET_UBUNTU_VERSION in
    "jammy" | "noble")
        apt-get install -y wireless-tools
        ;;
    *)
        print_warn "Package wireless-tools is not available for $TARGET_UBUNTU_VERSION"
        ;;
esac
apt install -y \
    openvpn \
    network-manager-openvpn \
    network-manager-openvpn-gnome \
    network-manager-pptp-gnome
judge "Install network manager vpn packages"

print_ok "Installing gnome basic applications..."
apt install -y \
    nautilus \
    usb-creator-gtk \
    cheese \
    baobab \
    file-roller \
    ibus \
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
    gnome-text-editor \
    seahorse \
    gdebi \
    evince \
    shotwell \
    remmina remmina-plugin-rdp \
    rhythmbox rhythmbox-plugins \
    totem totem-plugins \
    transmission-gtk transmission-common \
    ffmpegthumbnailer
judge "Install gnome additional applications"

print_ok "Installing gnome multimedia support..."
apt install -y \
    gstreamer1.0-libav \
    gstreamer1.0-alsa \
    gstreamer1.0-vaapi \
    gstreamer1.0-tools \
    gstreamer1.0-packagekit \
    gstreamer1.0-plugins-base-apps
judge "Install gstreamer"

print_ok "Installing gnome console..."
apt install -y \
    gnome-console #nautilus-extension-gnome-console
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
    ubuntu-drivers-common alsa-utils alsa-base fprintd
judge "Install ubuntu drivers support"

print_ok "Installing web browser..."
apt install -y \
    firefox
judge "Install web browser"

print_ok "Installing python3..."
apt install -y \
    python3 python3-pip python-is-python3 pipx
judge "Install python3"

print_ok "Remove the default htop.desktop file"
rm /usr/share/applications/htop.desktop
judge "Remove the default htop.desktop file"

print_ok "Remove the default vim.desktop file"
rm /usr/share/applications/vim.desktop
judge "Remove the default vim.desktop file"

print_ok "Installing $LANGUAGE_PACKS language packs"
apt install -y $LANGUAGE_PACKS
judge "Install language packs"