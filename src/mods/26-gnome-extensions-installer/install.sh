set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing gnome extensions"
#/usr/bin/pip3 install --upgrade gnome-extensions-cli
pipx install gnome-extensions-cli

install_extension() {
    local extension_id=$1
    local retries=8

    for ((i=1; i<=retries; i++)); do
        print_info "Attempting to install $extension_id (attempt $i/$retries)..."

        set +e
        output=$(/root/.local/bin/gext -F install "$extension_id" 2>&1)
        set -e

        echo "$output"

        if echo "$output" | grep -q -e 'Error' -e 'Cannot'; then
            print_warn "$extension_id Failed to install, retrying in 10 seconds..."
            # Every time fail, sleep more time
            sleep $((i * 20))
        else
            print_ok "$extension_id Installed successfully"
            return 0
        fi
    done

    print_error "After $retries attempts, $extension_id failed to install"
    exit 1
}

extensions=(
    "arcmenu@arcmenu.com"
    "sound-output-device-chooser@kgshank.net"
    "ProxySwitcher@flannaghan.com"
    "customize-ibus@hollowman.ml"
    "dash-to-panel@jderose9.github.com"
    "network-stats@gnome.noroadsleft.xyz"
    "openweather-extension@penguin-teal.github.io"
    "rounded-window-corners@fxgn"
    "lockkeys@vaina.lt"
    "tiling-assistant@leleat-on-github"
)

# 遍历安装所有扩展
for extension in "${extensions[@]}"; do
    install_extension "$extension"
done

judge "Install gnome extensions"