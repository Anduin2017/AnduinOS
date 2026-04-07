set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

print_ok "Downloading Fluent icon theme"
mkdir -p ./themes/
wget https://git.aiursoft.com/PublicVault/Fluent-icon-theme/archive/master.zip -O ./themes/fluent-icon-theme.zip
unzip -q -O UTF-8 ./themes/fluent-icon-theme.zip -d ./themes/
judge "Download Fluent icon theme"

print_ok "Installing Fluent icon theme"
(
    print_ok "Installing Fluent icon theme" && \
    cd ./themes/fluent-icon-theme/ && \
    ./install.sh --all
)
judge "Install Fluent icon theme"

#==============================================

print_ok "Installing Fluent cursor theme"
(
    print_ok "Installing Fluent cursor theme" && \
    cd ./themes/fluent-icon-theme/cursors/ && \
    ./install.sh
)
judge "Install Fluent cursor theme"