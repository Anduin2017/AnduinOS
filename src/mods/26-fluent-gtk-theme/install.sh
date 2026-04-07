set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing Fluent theme"
mkdir -p ./themes/
wget https://git.aiursoft.com/PublicVault/Fluent-gtk-theme/archive/master.zip -O ./themes/fluent-gtk-theme.zip
unzip -q -O UTF-8 ./themes/fluent-gtk-theme.zip -d ./themes/
judge "Download Fluent theme"

(
    cd ./themes/fluent-gtk-theme/ && \
    ./install.sh --tweaks noborder round --theme all 
)
judge "Install Fluent theme"