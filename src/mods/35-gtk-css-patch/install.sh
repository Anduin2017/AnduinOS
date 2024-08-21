print_ok "Copying patched gnome-shell css to /etc/skel"
mkdir -p /etc/skel/.config/gtk-3.0
cp ./gtk.css /etc/skel/.config/gtk-3.0/
judge "Copy patched gnome-shell css to /etc/skel"
