set -e
set -o pipefail
set -u

print_ok "Patch Ubiquity installer"
rsync -Aax --update --delete ./slides/ /usr/share/ubiquity-slideshow/slides/
judge "Patch Ubiquity installer"

# 1. Create a robust, readable wrapper script. 
# This script handles the bwrap hack safely at RUNTIME.
print_ok "Creating AnduinOS installer wrapper"
cat << 'EOF' > /usr/bin/anduinos-installer
#!/bin/bash
# Enable critical permissions
xhost +SI:localuser:root > /dev/null 2>&1 || true

# Apply bwrap stabilizer temporarily in RAM
if [ -f /usr/bin/bwrap ] && [ ! -f /usr/bin/bwrap.real ]; then
    mv /usr/bin/bwrap /usr/bin/bwrap.real
    echo -e '#!/bin/bash\nexec /usr/bin/bwrap.real "$@" 2> /dev/null' > /usr/bin/bwrap
    chmod +x /usr/bin/bwrap
fi

# Run ubiquity with all proven environment variables
# Note: We EXPLICITLY do NOT preserve HOME here.
export PYTHONPATH=/usr/lib/ubiquity
export LIBGL_ALWAYS_SOFTWARE=1
ubiquity gtk_ui

# Cleanup: Restore bwrap so the Live environment remains stable
if [ -f /usr/bin/bwrap.real ]; then
    mv -f /usr/bin/bwrap.real /usr/bin/bwrap
fi
EOF
chmod +x /usr/bin/anduinos-installer
judge "Create installer wrapper"

# 2. Create an Ubiquity Hook to ensure this wrapper is DELETED from the target disk.
# Ubiquity runs scripts in target-config.d inside the new system's chroot.
print_ok "Creating cleanup hook for target system"
mkdir -p /usr/lib/ubiquity/target-config.d
cat << 'EOF' > /usr/lib/ubiquity/target-config.d/anduinos-clean-wrapper
#!/bin/bash
# Remove the installer wrapper from the target system so it's 100% clean
rm -f /usr/bin/anduinos-installer
EOF
chmod +x /usr/lib/ubiquity/target-config.d/anduinos-clean-wrapper
judge "Create cleanup hook"

# 3. Edit .desktop to point to our clean wrapper
print_ok "Edit /usr/share/applications/ubiquity.desktop"
old_exec="sudo --preserve-env=DBUS_SESSION_BUS_ADDRESS,XDG_DATA_DIRS,XDG_RUNTIME_DIR,GTK_THEME sh -c 'ubiquity gtk_ui'"
new_exec="sudo --preserve-env=DBUS_SESSION_BUS_ADDRESS,XDG_DATA_DIRS,XDG_RUNTIME_DIR,GTK_THEME,XAUTHORITY,DISPLAY /usr/bin/anduinos-installer"

sed -i "s%Exec=${old_exec}%Exec=${new_exec}%" /usr/share/applications/ubiquity.desktop
judge "Edit /usr/share/applications/ubiquity.desktop"
