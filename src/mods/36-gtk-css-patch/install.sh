set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Copying patched gnome-shell css to /etc/skel"
mkdir -p /etc/skel/.config/gtk-3.0
cp ./gtk.css /etc/skel/.config/gtk-3.0/
judge "Copy patched gnome-shell css to /etc/skel"

# TODO: The CSS is not working for new gnome settings.