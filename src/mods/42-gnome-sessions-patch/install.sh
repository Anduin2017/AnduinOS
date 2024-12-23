set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Setting up /usr/share/gnome-sessions/sessions..."
sed -i 's/Ubuntu/AnduinOS/g' /usr/share/gnome-session/sessions/ubuntu.session
judge "Set up /usr/share/gnome-sessions/sessions"

print_ok "Setting up /usr/share/xsessions..."
rm /usr/share/xsessions/gnome*

mv /usr/share/xsessions/ubuntu.desktop /usr/share/xsessions/anduinos.desktop
mv /usr/share/xsessions/ubuntu-xorg.desktop /usr/share/xsessions/anduinos-xorg.desktop
sed -i 's/Name=Ubuntu/Name=AnduinOS/g' /usr/share/xsessions/anduinos.desktop
sed -i 's/Name=Ubuntu/Name=AnduinOS/g' /usr/share/xsessions/anduinos-xorg.desktop
judge "Set up /usr/share/xsessions"

print_ok "Setting up /usr/share/wayland-sessions..."
rm /usr/share/wayland-sessions/gnome*

mv /usr/share/wayland-sessions/ubuntu.desktop /usr/share/wayland-sessions/anduinos.desktop
mv /usr/share/wayland-sessions/ubuntu-wayland.desktop /usr/share/wayland-sessions/anduinos-wayland.desktop
sed -i 's/Name=Ubuntu/Name=AnduinOS/g' /usr/share/wayland-sessions/anduinos.desktop
sed -i 's/Name=Ubuntu/Name=AnduinOS/g' /usr/share/wayland-sessions/anduinos-wayland.desktop
judge "Set up /usr/share/wayland-sessions"

print_ok "Setting up apparmor to allow user namespaces..."
# See: https://askubuntu.com/questions/1511854/how-to-permanently-disable-ubuntus-new-apparmor-user-namespace-creation-restric
# It may seem that this may opens up a lot of security issues, but that is really not the case because a malware which gains
# administrative privileges can revert such restriction and do anything. And a malware with administrative privileges can
# basically do anything. The only way you can increase security is to stick to the official repositories and not install
# untrusted apps at all, and not give your password to them. Other distributions like Mint and Solus are reverting this change
# in apparmor. Other distributions like Debian, Fedora, or Arch don't have this restriction at all. Also, Ubuntu 22.04 and prior
# versions did not have this apparmor policy, and your system would be no more insecure than Ubuntu 22.04.
echo 'kernel.apparmor_restrict_unprivileged_userns = 0' | 
  sudo tee /etc/sysctl.d/20-apparmor-donotrestrict.conf
judge "Set up apparmor"