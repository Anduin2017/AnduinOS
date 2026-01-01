set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing gnome-shell and other gnome applications"
wait_network

print_ok "Installing basic CLI tools..."
apt install $INTERACTIVE \
    apt-transport-https \
    cifs-utils \
    cloud-init \
    coreutils \
    gnupg \
    gpg \
    gvfs-fuse \
    gvfs-backends \
    wsdd \
    libsass1 \
    lsb-release \
    systemd-timesyncd \
    fwupd \
    fwupd-signed \
    gdb \
    sassc \
    software-properties-common \
    gnome-remote-desktop \
    mesa-vulkan-drivers \
    squashfs-tools \
    sysstat \
    wget \
    whiptail \
    gdisk \
    eatmydata \
    patch \
    less \
    gnupg-l10n \
    gpg-wks-client \
    upower \
    mdadm \
    appstream \
    packagekit-tools \
    python3-babel \
    unattended-upgrades \
    exfatprogs \
    iw \
    xxd \
    xdg-utils \
    zenity \
    power-profiles-daemon \
    --no-install-recommends
judge "Install basic CLI tools"

print_ok "Installing gnome basic sessions..."
apt install $INTERACTIVE \
    gnome-shell \
    ubuntu-session \
    yaru-theme-sound \
    yaru-theme-gnome-shell \
    gir1.2-gmenu-3.0 \
    gnome-menus \
    gnome-shell-extensions \
    spice-vdagent \
    gdm3 \
    libpam-gnome-keyring \
    gnome-keyring \
    gnome-keyring-pkcs11 \
    libcanberra-gtk3-0 \
    libcanberra-gtk3-module \
    libcanberra-pulse \
    libcanberra0 \
    --no-install-recommends
judge "Install gnome basic sessions"

apt install $INTERACTIVE \
    orca \
    speech-dispatcher-espeak-ng \
    speech-dispatcher-audio-plugins \
    speech-dispatcher \
    espeak-ng-data \
    --no-install-recommends

print_ok "Installing plymouth..."
apt install $INTERACTIVE \
    plymouth \
    plymouth-label \
    plymouth-theme-spinner \
    plymouth-theme-ubuntu-text --no-install-recommends
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
apt install $INTERACTIVE \
    openvpn \
    network-manager-openvpn \
    network-manager-openvpn-gnome \
    network-manager-pptp \
    network-manager-pptp-gnome \
    --no-install-recommends
judge "Install network manager vpn packages"

print_ok "Installing nautilus..."
apt install $INTERACTIVE nautilus --no-install-recommends
judge "Install nautilus"

print_ok "Installing gnome extension utilities..."
apt install $INTERACTIVE \
    gnome-shell-extension-desktop-icons-ng \
    gnome-shell-extension-appindicator --no-install-recommends
judge "Install gnome extension utilities"

print_ok "Installing gnome additional applications $DEFAULT_APPS..."
apt install $INTERACTIVE \
    gnome-control-center \
    $DEFAULT_APPS \
    --no-install-recommends
judge "Install gnome additional applications"

print_ok "Installing default cli applications..."
apt install $INTERACTIVE \
    wget \
    $DEFAULT_CLI_TOOLS \
    --no-install-recommends
judge "Install default cli applications"

print_ok "Installing gnome multimedia support..."
apt install $INTERACTIVE \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    libavcodec-extra \
    gstreamer1.0-pipewire \
    gstreamer1.0-alsa \
    gstreamer1.0-gl \
    gstreamer1.0-gtk3 \
    gstreamer1.0-x \
    gstreamer1.0-tools \
    gstreamer1.0-packagekit \
    gstreamer1.0-plugins-base-apps --no-install-recommends
judge "Install gstreamer"

print_ok "Installing ptyxis..."
apt install $INTERACTIVE \
    ptyxis  --no-install-recommends
judge "Install ptyxis"

print_ok "Installing ibus..."
apt install $INTERACTIVE \
    ibus \
    ibus-gtk ibus-gtk3 ibus-gtk4 im-config --no-install-recommends
judge "Install ibus"

print_ok "Installing gnome fonts..."
apt install $INTERACTIVE \
    fonts-noto-cjk fonts-noto-core fonts-noto-mono fonts-noto-color-emoji --no-install-recommends
judge "Install gnome fonts"

print_ok "Installing gnome printer support..."
apt install $INTERACTIVE \
    system-config-printer \
    printer-driver-all # With recommends this time. Because only this way it installs the actual drivers
judge "Install printer-driver-all"

print_ok "Installing scanner support..."
apt install $INTERACTIVE \
    sane-airscan sane-utils simple-scan \
    --no-install-recommends
judge "Install scanner support"

print_ok "Installing gnome printer support..."
apt install $INTERACTIVE \
    cups \
    cups-bsd \
    cups-browsed \
    cups-pk-helper \
    ipp-usb \
    --no-install-recommends
judge "Install gnome printer support"

print_ok "Installing ubuntu drivers support..."
apt install $INTERACTIVE \
    ubuntu-drivers-common \
    alsa-utils \
    alsa-base \
    alsa-topology-conf \
    alsa-ucm-conf \
    fprintd --no-install-recommends
judge "Install ubuntu drivers support"

print_ok "Installing python3..."
apt install $INTERACTIVE \
    python3 \
    python3-pip \
    python-is-python3 \
    pipx \
    --no-install-recommends
judge "Install python3"

print_ok "Remove the default htop.desktop file"
rm /usr/share/applications/htop.desktop || true
judge "Remove the default htop.desktop file"

print_ok "Remove the default vim.desktop file"
rm /usr/share/applications/vim.desktop || true
judge "Remove the default vim.desktop file"

print_ok "Installing $LANGUAGE_PACKS language packs"
apt install $INTERACTIVE $LANGUAGE_PACKS --no-install-recommends
judge "Install language packs"