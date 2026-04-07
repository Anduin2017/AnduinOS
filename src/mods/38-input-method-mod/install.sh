set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# Based on variable: INPUT_METHOD_INSTALL and CONFIG_IBUS_RIME
# If $INPUT_METHOD_INSTALL is not empty, install the packages
if [ -n "$INPUT_METHOD_INSTALL" ]; then
    print_ok "Installing input method packages: $INPUT_METHOD_INSTALL"
    apt install $INTERACTIVE --no-install-recommends \
        $INPUT_METHOD_INSTALL
    judge "Install input method packages"
else
    print_ok "No input method packages to install"
fi

# If config ibus rime:
if [ "$CONFIG_IBUS_RIME" == "true" ]; then
    print_ok "Installing im-config..."
    apt install $INTERACTIVE \
        im-config \
        librime-plugin-lua \
        --no-install-recommends
    judge "Install im-config"

    print_ok "Setting up ibus..."
    im-config -n ibus
    judge "Set up ibus"

    print_ok "Installing Rime schema..."
    zip=https://gitlab.aiursoft.com/anduin/anduinos-rime/-/archive/master/anduinos-rime-master.zip
    wget $zip -O anduinos-rime.zip && unzip -q -O UTF-8 anduinos-rime.zip && rm anduinos-rime.zip
    mkdir -p /etc/skel/.config/ibus/rime
    rsync -Aavx --update --delete ./anduinos-rime-master/assets/ /etc/skel/.config/ibus/rime/
    rm -rf ./anduinos-rime-master/
    judge "Install Rime schema"
else
    print_ok "No ibus-rime to install"
fi

print_ok "Patching language-selector to install input method packages"
# Remove all lines in /usr/share/language-selector/data/pkg_depends that starts with 'im:'
sed -i '/^im:/d' /usr/share/language-selector/data/pkg_depends
# Add the the lines to /usr/share/language-selector/data/pkg_depends based on ./pkg_depends_patch
cat ./pkg_depends_patch >> /usr/share/language-selector/data/pkg_depends
judge "Patch language-selector to install input method packages"