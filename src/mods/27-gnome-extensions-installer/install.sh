set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing gnome extensions"
#/usr/bin/pip3 install --upgrade gnome-extensions-cli
pipx install gnome-extensions-cli

install_extension() {
    local extension_id=$1
    local retries=8
    local extension_path="/root/.local/share/gnome-shell/extensions/$extension_id"

    for ((i=1; i<=retries; i++)); do
        print_info "Attempting to install $extension_id (attempt $i/$retries)..."

        set +e
        output=$(/root/.local/bin/gext -F install "$extension_id" 2>&1)
        set -e

        echo "$output"

        if echo "$output" | grep -q -e 'Error' -e 'Cannot'; then
            print_warn "$extension_id Failed to install, retrying..."
            sleep $((i * 10))
        else
            print_ok "$extension_id Installed successfully"

            if ls "$extension_path/schemas/"*.gschema.xml 1> /dev/null 2>&1; then
                print_info "Found schemas, compiling for $extension_id..."
                mkdir -p "$extension_path/schemas"
                glib-compile-schemas "$extension_path/schemas"
                judge "Compile schemas for $extension_id"

                print_info "Ensure the compiled gschemas.compiled file exists..."
                if [ -f "$extension_path/schemas/gschemas.compiled" ]; then
                    print_ok "gschemas.compiled file exists."
                else
                    print_error "gschemas.compiled file does not exist after compilation!"
                    exit 1
                fi
            else
                print_info "No schemas found for $extension_id, skipping compilation."
            fi

            return 0
        fi
    done

    print_error "After $retries attempts, $extension_id failed to install"
    exit 1
}

extensions=(
    "accent-gtk-theme@brgvos"
    "accent-user-theme@brgvos"
    "accent-icons-theme@brgvos"
    "arcmenu@arcmenu.com"
    "blur-my-shell@aunetx"
    "ProxySwitcher@flannaghan.com"
    "customize-ibus@hollowman.ml"
    "dash-to-panel@jderose9.github.com"
    "network-stats@gnome.noroadsleft.xyz"
    "simple-weather@romanlefler.com"
    "lockkeys@vaina.lt"
    "tiling-assistant@leleat-on-github"
    "mediacontrols@cliffniff.github.com"
    "clipboard-indicator@tudmotu.com"
)

for extension in "${extensions[@]}"; do
    install_extension "$extension"
done

judge "Install gnome extensions"