set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Patch Ubiquity installer"
rsync -Aax --update --delete ./slides/ /usr/share/ubiquity-slideshow/slides/
judge "Patch Ubiquity installer"

# Edit /usr/share/applications/ubiquity.desktop
# Comment this line:
# Exec=sudo --preserve-env=DBUS_SESSION_BUS_ADDRESS,XDG_DATA_DIRS,XDG_RUNTIME_DIR,GTK_THEME sh -c 'ubiquity gtk_ui'
# Replace it with:
# Exec=sudo --preserve-env=DBUS_SESSION_BUS_ADDRESS,XDG_DATA_DIRS,XDG_RUNTIME_DIR,GTK_THEME,HOME sh -c 'ubiquity gtk_ui'
print_ok "Edit /usr/share/applications/ubiquity.desktop"
old_exec="sudo --preserve-env=DBUS_SESSION_BUS_ADDRESS,\
XDG_DATA_DIRS,\
XDG_RUNTIME_DIR,\
GTK_THEME sh -c 'ubiquity gtk_ui'"

new_exec="sudo --preserve-env=DBUS_SESSION_BUS_ADDRESS,\
XDG_DATA_DIRS,\
XDG_RUNTIME_DIR,\
GTK_THEME,\
HOME sh -c 'LIBGL_ALWAYS_SOFTWARE=1 ubiquity gtk_ui'"

sed -i \
  "s|Exec=${old_exec}|Exec=${new_exec}|" \
  /usr/share/applications/ubiquity.desktop
judge "Edit /usr/share/applications/ubiquity.desktop"
