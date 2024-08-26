set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Installing Fluent theme"
git clone https://git.aiursoft.cn/PublicVault/Fluent-gtk-theme ./themes/Fluent-gtk-theme
(
    cd ./themes/Fluent-gtk-theme/ && \
    ./install.sh --tweaks noborder round
)
judge "Install Fluent theme"