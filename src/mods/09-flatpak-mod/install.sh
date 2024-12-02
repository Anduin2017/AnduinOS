set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing flatpak"
waitNetwork
apt install -y flatpak gnome-software-plugin-flatpak
judge "Install flatpak"

print_ok "Adding flathub repository"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
judge "Add flathub repository"
