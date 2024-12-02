set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Setting up /usr/share/gnome-sessions/sessions..."
sed -i 's/Ubuntu/AnduinOS/g' /usr/share/gnome-session/sessions/ubuntu.session
judge "Set up /usr/share/gnome-sessions/sessions"

print_ok "Setting up /usr/share/xsessions..."
rm /usr/share/xsessions/gnome*
# TODO: Verify what's the behavior of the gnome session
# mv /usr/share/xsessions/ubuntu.desktop /usr/share/xsessions/anduinos.desktop
# mv /usr/share/xsessions/ubuntu-xorg.desktop /usr/share/xsessions/anduinos-xorg.desktop
# sed -i 's/Name=Ubuntu/Name=AnduinOS/g' /usr/share/xsessions/anduinos.desktop
# sed -i 's/Name=Ubuntu/Name=AnduinOS/g' /usr/share/xsessions/anduinos-xorg.desktop
judge "Set up /usr/share/xsessions"

print_ok "Setting up /usr/share/wayland-sessions..."
# rm /usr/share/wayland-sessions/gnome*

# mv /usr/share/wayland-sessions/ubuntu.desktop /usr/share/wayland-sessions/anduinos.desktop
# mv /usr/share/wayland-sessions/ubuntu-wayland.desktop /usr/share/wayland-sessions/anduinos-wayland.desktop
# sed -i 's/Name=Ubuntu/Name=AnduinOS/g' /usr/share/wayland-sessions/anduinos.desktop
# sed -i 's/Name=Ubuntu/Name=AnduinOS/g' /usr/share/wayland-sessions/anduinos-wayland.desktop
judge "Set up /usr/share/wayland-sessions"
