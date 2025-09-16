set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Enabling gnome extensions for root..."
/root/.local/bin/gext -F enable arcmenu@arcmenu.com
/root/.local/bin/gext -F enable blur-my-shell@aunetx
/root/.local/bin/gext -F enable ProxySwitcher@flannaghan.com
/root/.local/bin/gext -F enable customize-ibus@hollowman.ml
/root/.local/bin/gext -F enable dash-to-panel@jderose9.github.com
/root/.local/bin/gext -F enable network-stats@gnome.noroadsleft.xyz
/root/.local/bin/gext -F enable openweather-extension@penguin-teal.github.io
/root/.local/bin/gext -F enable switcher@anduinos
/root/.local/bin/gext -F enable noti-bottom-right@anduinos
/root/.local/bin/gext -F enable loc@anduinos.com
/root/.local/bin/gext -F enable lockkeys@vaina.lt
/root/.local/bin/gext -F enable tiling-assistant@leleat-on-github
/root/.local/bin/gext -F enable mediacontrols@cliffniff.github.com
/root/.local/bin/gext -F enable clipboard-indicator@tudmotu.com
judge "Enable gnome extensions"

# Install jq:
print_ok "Updating gnome extensions to force enable for gnome 49..."
apt install $INTERACTIVE jq --no-install-recommends
find /usr/share/gnome-shell/extensions -type f -name metadata.json | while IFS= read -r file; do
    if jq -e 'has("shell-version")' "$file" > /dev/null; then
        if jq -e '.["shell-version"] | index("49")' "$file" > /dev/null; then
            print_info "$file already supports gnome \"49\"."
        else
            print_warn "$file does not contain \"49\", updating file..."
            tmpfile=$(mktemp)
            jq '.["shell-version"] += ["49"]' "$file" > "$tmpfile" && mv "$tmpfile" "$file"
            chmod 644 "$file"
        fi
    else
        print_error "$file does not contain \"shell-version\"!"
        exit 1
    fi
done