print_ok "Installing Fluent theme"
git clone https://git.aiursoft.cn/PublicVault/Fluent-gtk-theme ./themes/Fluent-gtk-theme
(
    cd ./themes/Fluent-gtk-theme/ && \
    ./install.sh --tweaks noborder round
)
judge "Install Fluent theme"