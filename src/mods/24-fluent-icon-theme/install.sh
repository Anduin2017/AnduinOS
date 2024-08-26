set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Downloading Fluent icon theme"
git clone https://git.aiursoft.cn/PublicVault/Fluent-icon-theme ./themes/Fluent-icon-theme
judge "Download Fluent icon theme"

print_ok "Installing Fluent icon theme"
(
    print_ok "Installing Fluent icon theme" && \
    cd ./themes/Fluent-icon-theme/ && \
    ./install.sh standard
)
judge "Install Fluent icon theme"

#==============================================

print_ok "Installing Fluent cursor theme"
(
    print_ok "Installing Fluent cursor theme" && \
    cd ./themes/Fluent-icon-theme/cursors/ && \
    ./install.sh
)
judge "Install Fluent cursor theme"