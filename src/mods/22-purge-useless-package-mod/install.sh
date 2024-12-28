set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Purging unnecessary packages"
apt purge -y \
    gnome-mahjongg \
    gnome-mines \
    gnome-sudoku \
    aisleriot \
    hitori \
    gnome-initial-setup \
    gnome-photos \
    eog \
    tilix \
    gnome-contacts \
    gnome-terminal \
    zutty \
    update-manager-core \
    gnome-shell-extension-ubuntu-dock \
    libreoffice-* \
    yaru-theme-unity yaru-theme-icon yaru-theme-gtk \
    apport python3-systemd \
    imagemagick* \
    ubuntu-pro-client ubuntu-advantage-desktop-daemon ubuntu-advantage-tools ubuntu-pro-client ubuntu-pro-client-l10n \
    gnome-software gnome-software-common gnome-software-plugin-snap \
    software-properties-gtk > /dev/null
# Above remove everything about yaru-theme but keeps yaru-theme-sound and yaru-theme-gnome-shell (Required by Ubuntu session)
judge "Purge unnecessary packages"