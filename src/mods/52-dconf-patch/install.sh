#!/bin/bash
set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# ==============================================================================
# AnduinOS dconf System-Level Configuration
# ==============================================================================
# This script configures system-wide defaults using:
# 1. gsettings schema overrides for standard schemas
# 2. dconf system database for relocatable schemas
# 
# Benefits over the old /etc/skel approach:
# - Single shared configuration instead of per-user copies
# - Text-based configuration for easy auditing
# - True default value semantics (users can reset to defaults)
# - System updates can push new defaults without overwriting user changes
# ==============================================================================

print_ok "Configuring AnduinOS system-wide dconf defaults"

# ==============================================================================
# 1. Install gsettings schema overrides
# ==============================================================================
print_ok "Installing gsettings schema overrides"

cp ./schemas/99-anduinos-defaults.gschema.override \
   /usr/share/glib-2.0/schemas/99-anduinos-defaults.gschema.override
judge "Copy gsettings schema override"

glib-compile-schemas /usr/share/glib-2.0/schemas/
judge "Compile gsettings schemas"

# ==============================================================================
# 2. Configure dconf profile
# ==============================================================================
print_ok "Configuring dconf profile"

mkdir -p /etc/dconf/profile
cp ./dconf-profile/user /etc/dconf/profile/user
judge "Install dconf profile"

# ==============================================================================
# 3. Install dconf system database configurations
# ==============================================================================
print_ok "Installing dconf system database configurations"

mkdir -p /etc/dconf/db/anduinos.d
cp ./dconf-db/01-custom-keybindings.conf /etc/dconf/db/anduinos.d/
cp ./dconf-db/02-ptyxis-terminal.conf /etc/dconf/db/anduinos.d/
cp ./dconf-db/03-gnome-extensions.conf /etc/dconf/db/anduinos.d/
judge "Copy dconf system configurations"

# ==============================================================================
# 4. Process dynamic configurations (input method & weather location)
# ==============================================================================
print_ok "Processing dynamic build-time configurations"

# Validate required environment variables
if [ -z "$CONFIG_INPUT_METHOD" ]; then
    print_error "Error: CONFIG_INPUT_METHOD is not set."
    exit 1
fi

if [ -z "$CONFIG_WEATHER_LOCATION" ]; then
    print_error "Error: CONFIG_WEATHER_LOCATION is not set."
    exit 1
fi

# Generate dynamic configuration file
print_ok "Generating dynamic configuration with build-time variables"
cat > /etc/dconf/db/anduinos.d/04-dynamic-configs.conf << EOF
# AnduinOS Dynamic Configuration
# Auto-generated during build

# ============================================================================
# Input Method Configuration
# ============================================================================
[org/gnome/desktop/input-sources]
sources=$CONFIG_INPUT_METHOD

# ============================================================================
# Weather Extension Location
# ============================================================================
[org/gnome/shell/extensions/simple-weather]
locations=$CONFIG_WEATHER_LOCATION
EOF
judge "Generate dynamic configuration"

# ==============================================================================
# 5. Compile dconf system database
# ==============================================================================
print_ok "Compiling dconf system database"

dconf update
judge "Compile dconf system database"

# ==============================================================================
# 6. Configure GDM greeter
# ==============================================================================
print_ok "Configuring GDM greeter"

cp ./anduinos_text_smaller.png /usr/share/pixmaps/anduinos_text_smaller.png
judge "Copy GDM logo"

cp ./greeter.dconf-defaults.ini /etc/gdm3/greeter.dconf-defaults
judge "Install GDM greeter configuration"

# Trigger GDM configuration update
dconf update
judge "Update GDM configuration"

# ==============================================================================
# Summary
# ==============================================================================
print_ok "✓ gsettings schema overrides installed"
print_ok "✓ dconf profile configured"
print_ok "✓ dconf system database compiled"
print_ok "✓ GDM greeter configured"
print_ok ""
print_ok "System-wide dconf defaults configured successfully!"
print_ok "Users will inherit these defaults on first login."
print_ok "User modifications will be saved to ~/.config/dconf/user"
print_ok "No configuration files copied to /etc/skel - space saved!"
