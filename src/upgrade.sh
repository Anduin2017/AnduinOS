#!/bin/bash
#==========================
# Set up the environment
#==========================
set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error
export DEBIAN_FRONTEND=noninteractive
export LATEST_VERSION="1.3.3"
export CODE_NAME="plucky"
export OS_ID="AnduinOS"
export CURRENT_VERSION=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -d "=" -f 2)

#==========================
# Color
#==========================
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
OK="${Green}[  OK  ]${Font}"
ERROR="${Red}[FAILED]${Font}"
WARNING="${Yellow}[ WARN ]${Font}"

#==========================
# Print Colorful Text
#==========================
function print_ok() {
  echo -e "${OK} ${Blue} $1 ${Font}"
}

function print_error() {
  echo -e "${ERROR} ${Red} $1 ${Font}"
}

function print_warn() {
  echo -e "${WARNING} ${Yellow} $1 ${Font}"
}

#==========================
# Judge function
#==========================
function judge() {
  if [[ 0 -eq $? ]]; then
    print_ok "$1 succeeded"
    sleep 0.2
  else
    print_error "$1 failed"
    exit 1
  fi
}

function ensureCurrentOsAnduinOs() {
    # Ensure the current OS is AnduinOS
    if ! grep -q "DISTRIB_ID=AnduinOS" /etc/lsb-release; then
        print_error "This script can only be run on AnduinOS."
        exit 1
    fi
}

function upgrade_130_to_131() {
    print_ok "Upgrading from 1.3.0 to 1.3.1..."
    sudo apt update
    sudo apt install -y \
        gstreamer1.0-libav \
        gnome-browser-connector \
        gnome-control-center-faces \
        gnome-keyring-pkcs11 \
        gvfs-backends \
        orca \
        wsdd \
        libpam-gnome-keyring \
        libpam-sss \
        libpam-fprintd \
        --no-install-recommends

    fonts_config="https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/1.4/src/mods/15-fonts-mod/local.conf?ref_type=heads"
    sudo wget -O /etc/fonts/local.conf $fonts_config
    fc-cache -f
    judge "Upgrade from 1.3.0 to 1.3.1 completed"
}

function install_spg() {
    print_ok "Downloading software-properties-gtk..."
    sudo apt install -y \
        python3-dateutil \
        python3-distro-info \
        gir1.2-handy-1 \
        libgtk3-perl \
        --no-install-recommends
    judge "Install python3-dateutil"

    sudo apt-get download "software-properties-gtk"
    judge "Download software-properties-gtk"

    DEB_FILE=$(ls *.deb)
    print_ok "Found $DEB_FILE"
    sudo chown $USER:$USER "$DEB_FILE"

    print_ok "Extracting $DEB_FILE..."
    mkdir original
    dpkg-deb -R "$DEB_FILE" original
    judge "Extract $DEB_FILE"

    print_ok "Patching control file..."
    sed -i \
    '/^Depends:/s/, *ubuntu-pro-client//; /^Depends:/s/, *ubuntu-advantage-desktop-daemon//' \
    original/DEBIAN/control
    judge "Edit control file"

    MOD_DEB="modified.deb"

    print_ok "Repackaging $MOD_DEB..."
    dpkg-deb -b original "$MOD_DEB"
    judge "Repackage $MOD_DEB"

    print_ok "Cleaning up temp folder..."
    rm -rf original

    print_ok "Installing $MOD_DEB..."
    sudo dpkg -i "$MOD_DEB"
    judge "Install $MOD_DEB"

    print_ok "Cleaning up $MOD_DEB and $DEB_FILE..."
    rm -f "$MOD_DEB"
    rm -f "$DEB_FILE"
    judge "Clean up $MOD_DEB and $DEB_FILE"

    FILE=/usr/lib/python3/dist-packages/softwareproperties/gtk/SoftwarePropertiesGtk.py

    print_ok "Patching $FILE... to disable Ubuntu Pro"
    sudo cp "$FILE" "${FILE}.bak"
    sudo sed -i '/^from \.UbuntuProPage import UbuntuProPage$/d' "$FILE"
    sudo sed -i '/^[[:space:]]*def init_ubuntu_pro/,/^[[:space:]]*$/d' "$FILE"
    sudo sed -i '/^[[:space:]]*if is_current_distro_lts()/,/self.init_ubuntu_pro()/d' "$FILE"
    judge "Edit $FILE"

    print_ok "Marking software-properties-gtk as held..."
    sudo apt-mark hold software-properties-gtk
    judge "Mark software-properties-gtk as held"

}

function install_desktop_mon() {
    print_ok "Clean up deskmon..."
    sudo rm -f /usr/local/bin/deskmon || true
    sudo rm -f /usr/local/bin/deskmon.service || true
    sudo rm -f /etc/systemd/user/deskmon.service || true
    sudo rm -f /etc/systemd/user/default.target.wants/deskmon.service || true

    link="https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/1.4/src/mods/20-deskmon-mod/deskmon?ref_type=heads"
    print_ok "Downloading deskmon..."
    sudo rm -f /usr/local/bin/deskmon || true
    sudo wget -O /usr/local/bin/deskmon "$link"
    sudo chmod +x /usr/local/bin/deskmon
    judge "Download deskmon"

    print_ok "Installing deskmon.service"
    service_link="https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/1.4/src/mods/20-deskmon-mod/deskmon.service?ref_type=heads"
    wget -O deskmon.service "$service_link"
    sudo install -D deskmon.service /etc/systemd/user/deskmon.service
    sudo mkdir -p /etc/systemd/user/default.target.wants
    sudo ln -s /etc/systemd/user/deskmon.service \
            /etc/systemd/user/default.target.wants/deskmon.service
    systemctl --user daemon-reload
    sudo rm deskmon.service
    print_ok "Deskmon service installed. Starting deskmon..."
    systemctl --user start deskmon.service
    systemctl --user enable deskmon.service
    judge "Install deskmon.service"
}

function upgrade_131_to_132() {
    # If the flatpak remote is https://mirror.sjtu.edu.cn/flathub
    # Change it to sudo flatpak remote-modify flathub --url=https://mirrors.ustc.edu.cn/flathub

    # If flatpak installed
    if command -v flatpak &> /dev/null; then
      current_url=$(flatpak remotes --columns=name,url | awk '$1=="flathub"{print $2}')
      if [[ "$current_url" == *"https://mirror.sjtu.edu.cn/flathub"* ]]; then
          print_ok "Detected SJTU mirror for flathub. Switching to USTC mirror..."
          sudo flatpak remote-modify flathub --url=https://mirrors.ustc.edu.cn/flathub
          print_ok "Switch completed."
      fi
    fi

    sudo apt update
    sudo apt install -y \
        vim \
        cracklib-runtime \
        power-profiles-daemon \
        xserver-xorg-input-all \
        xorg \
        xserver-xorg-legacy \
        xserver-xorg-video-intel \
        xserver-xorg-video-qxl \
        --no-install-recommends
    judge "Install vim completed"

    ext_source="https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/1.4/src/mods/29-gnome-extension-anduinos-switcher/switcher@anduinos/extension.js?ref_type=heads"
    sudo wget -O /usr/share/gnome-shell/extensions/switcher@anduinos/extension.js $ext_source

    apt list --installed | grep software-properties-gtk || install_spg

    if [ ! -f /usr/local/bin/deskmon ]; then
        install_desktop_mon
    fi
}

function upgrade_132_to_133() {
    print_ok "Upgrading from 1.3.2 to 1.3.3..."
    sudo apt update
    sudo apt install -y \
      orca \
      speech-dispatcher-espeak-ng \
      speech-dispatcher-audio-plugins \
      speech-dispatcher \
      espeak-ng-data \
      policykit-desktop-privileges \
      --no-install-recommends

    # If ibus rime is installed, then install librime-plugin-lua
    if dpkg -s ibus-rime &>/dev/null; then
        print_ok "Installing librime-plugin-lua..."
        sudo apt install -y librime-plugin-lua --no-install-recommends
    else
        print_warn "ibus-rime is not installed, skipping librime-plugin-lua installation."
    fi

    # If /etc/apt/sources.list.d/mozillateam-ubuntu-ppa-plucky.sources exists, then replace mirror-ppa.aiursoft.cn to ppa.launchpadcontent.net
    if [ -f /etc/apt/sources.list.d/mozillateam-ubuntu-ppa-plucky.sources ]; then
        print_ok "Replacing mirror-ppa.aiursoft.cn with ppa.launchpadcontent.net in mozillateam-ubuntu-ppa-plucky.sources"
        sudo sed -i 's/mirror-ppa.aiursoft.cn/ppa.launchpadcontent.net/g' /etc/apt/sources.list.d/mozillateam-ubuntu-ppa-plucky.sources
        judge "Replace mirror-ppa.aiursoft.cn with ppa.launchpadcontent.net"
    fi
    judge "Upgrade from 1.3.2 to 1.3.3 completed"
}

function shift_screenshot_key() {
    #!/usr/bin/env bash
    #
    # Remove the screenshot keybinding (custom3), shift custom4→custom3, custom5→custom4,
    # and update the custom-keybindings list.

    # dconf paths
    BASE_SCHEMA="/org/gnome/settings-daemon/plugins/media-keys"
    CUSTOM_BASE="${BASE_SCHEMA}/custom-keybindings"
    OLD_COUNT=6
    NEW_COUNT=5

    # 1. Update the custom-keybindings list to only custom0–custom4
    print_ok "Updating custom-keybindings list to custom0–custom4..."
    dconf write "${BASE_SCHEMA}/custom-keybindings" "[
    '${CUSTOM_BASE}/custom0/',
    '${CUSTOM_BASE}/custom1/',
    '${CUSTOM_BASE}/custom2/',
    '${CUSTOM_BASE}/custom3/',
    '${CUSTOM_BASE}/custom4/'
    ]"
    judge "Update custom-keybindings list to custom0–custom4"

    # 2. Wipe out any old values under custom3–custom5
    print_ok "Resetting custom3–custom5..."
    dconf reset -f "${CUSTOM_BASE}/custom3/"
    dconf reset -f "${CUSTOM_BASE}/custom4/"
    dconf reset -f "${CUSTOM_BASE}/custom5/"
    judge "Reset custom3–custom5"

    # 3. Recreate custom3 with the former custom4 (“Toggle Network”)
    print_ok "Recreating custom3 with former custom4 (Toggle Network)..."
    dconf write "${CUSTOM_BASE}/custom3/binding"   "'<Super>u'"
    dconf write "${CUSTOM_BASE}/custom3/command"   "'toggle_network_stats'"
    dconf write "${CUSTOM_BASE}/custom3/name"      "'Toggle Network'"
    judge "Recreate custom3 with former custom4 (Toggle Network)"

    # 4. Recreate custom4 with the former custom5 (“Characters”)
    print_ok "Recreating custom4 with former custom5 (Characters)..."
    dconf write "${CUSTOM_BASE}/custom4/binding"   "'<Super>semicolon'"
    dconf write "${CUSTOM_BASE}/custom4/command"   "'gnome-characters'"
    dconf write "${CUSTOM_BASE}/custom4/name"      "'Characters'"
    judge "Recreate custom4 with former custom5 (Characters)"

    # 5. Add Super+Shift+s for screenshot
    print_ok "Adding Super+Shift+s for screenshot..."
    dconf write /org/gnome/shell/keybindings/show-screenshot-ui "['<Super><Shift>s', 'Print']"
    judge "Add Super+Shift+s for screenshot"

    print_ok "✔ Custom media-key bindings migrated: screenshot removed, keys shifted."
}

function patch_dash_to_panel() {
    TARGET_FILE="/usr/share/gnome-shell/extensions/dash-to-panel@jderose9.github.com/panelPositions.js"

    # --- Ensure target exists ---
    if [[ ! -f "$TARGET_FILE" ]]; then
        echo "[ERROR] Target file not found: $TARGET_FILE" >&2
        exit 1
    fi
    # --- If target file already contains the patch, skip ---
    if grep -q "AnduinOS custom default panel layout" "$TARGET_FILE"; then
        print_ok "Dash-to-panel patch already applied. Skipping..."
        return
    fi

    print_ok "Applying new panel layout patch"
    sudo sed -i '/export const defaults = \[/,/^\]$/c\
    \/\/ AnduinOS custom default panel layout\
    export const defaults = [\
    { element: LEFT_BOX, visible: true, position: STACKED_TL },\
    { element: CENTER_BOX, visible: true, position: CENTERED_MONITOR },\
    { element: TASKBAR, visible: true, position: CENTERED_MONITOR },\
    { element: RIGHT_BOX, visible: true, position: STACKED_BR },\
    { element: SYSTEM_MENU, visible: true, position: STACKED_BR },\
    { element: DATE_MENU, visible: true, position: STACKED_BR },\
    { element: DESKTOP_BTN, visible: true, position: STACKED_BR },\
    ];' \
    "$TARGET_FILE"
    judge "Apply new panel layout patch"

    # --- Verify success ---
    if ! grep -q "AnduinOS custom default panel layout" "$TARGET_FILE"; then
        echo "[ERROR] Replacement verification failed" >&2
        exit 1
    fi
    print_ok "Dash-to-panel patch applied successfully"
}

function patch_fix_toggle_network() {
    print_ok "Patching toggle_network_stats script to ensure compatibility with gnome-extensions command"
    sudo sed -i \
        's|gnome-extensions show|LC_ALL=C &|' \
        /usr/local/bin/toggle_network_stats
    judge "Patch toggle_network_stats script"
}

function upgrade_133_to_134() {
    print_ok "Upgrading from 1.3.3 to 1.3.4..."

    shift_screenshot_key
    
    patch_dash_to_panel

    patch_fix_toggle_network

    print_ok "Disabling cache-images in clipboard-indicator extension for performance"
    dconf write  /org/gnome/shell/extensions/clipboard-indicator/cache-images false
    judge "Disable cache-images in clipboard-indicator extension"

    print_ok "Enabling show-favorites-all-monitors in dash-to-panel extension"
    dconf write /org/gnome/shell/extensions/dash-to-panel/show-favorites-all-monitors true
    judge "Enable show-favorites-all-monitors in dash-to-panel extension"
}


function applyLsbRelease() {

    # Update /etc/os-release
    sudo bash -c "cat > /etc/os-release <<EOF
PRETTY_NAME=\"AnduinOS $LATEST_VERSION\"
NAME=\"AnduinOS\"
VERSION_ID=\"$LATEST_VERSION\"
VERSION=\"$LATEST_VERSION ($CODE_NAME)\"
VERSION_CODENAME=$CODE_NAME
ID=ubuntu
ID_LIKE=debian
HOME_URL=\"https://www.anduinos.com/\"
SUPPORT_URL=\"https://github.com/Anduin2017/AnduinOS/discussions\"
BUG_REPORT_URL=\"https://github.com/Anduin2017/AnduinOS/issues\"
PRIVACY_POLICY_URL=\"https://www.ubuntu.com/legal/terms-and-policies/privacy-policy\"
UBUNTU_CODENAME=$CODE_NAME
EOF"

    # Update /etc/lsb-release
    sudo bash -c "cat > /etc/lsb-release <<EOF
DISTRIB_ID=AnduinOS
DISTRIB_RELEASE=$LATEST_VERSION
DISTRIB_CODENAME=$CODE_NAME
DISTRIB_DESCRIPTION=\"AnduinOS $LATEST_VERSION\"
EOF"

    # Update /etc/issue
    echo "AnduinOS ${LATEST_VERSION} \n \l
" | sudo tee /etc/issue

    # Update /usr/lib/os-release
    sudo cp /etc/os-release /usr/lib/os-release || true
}

function main() {
    print_ok "Current version is: ${CURRENT_VERSION}. Checking for updates..."

    # Ensure the current OS is AnduinOS
    ensureCurrentOsAnduinOs

    # Compare current version with latest version
    if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
        print_ok "Your system is already up to date. No update available."
        exit 0
    fi

    print_ok "This script will upgrade your system to version ${LATEST_VERSION}..."
    print_ok "Please press CTRL+C to cancel... Countdown will start in 5 seconds..."
    sleep 5

    # Run necessary upgrades based on current version
    case "$CURRENT_VERSION" in
          "1.3.0")
              upgrade_130_to_131
              upgrade_131_to_132
              upgrade_132_to_133
              ;;
          "1.3.1")
              upgrade_131_to_132
              upgrade_132_to_133
              ;;
          "1.3.2")
              upgrade_132_to_133
              ;;
          "1.3.3")
              print_ok "Your system is already up to date. No update available."
              exit 0
              ;;
           *)
              print_error "Unknown current version. Exiting."
              exit 1
              ;;
    esac

    # Grammar sample:
    # case "$CURRENT_VERSION" in
    #     "1.0.2")
    #         upgrade_102_to_103
    #         upgrade_103_to_104
    #         ;;
    #     "1.0.3")
    #         upgrade_103_to_104
    #         ;;
    #     "1.0.4")
    #         print_ok "Your system is already up to date. No update available."
    #         exit 0
    #         ;;
    #     *)
    #         print_error "Unknown current version. Exiting."
    #         exit 1
    #         ;;
    # esac

    # Apply updates to lsb-release, os-release, and issue files
    applyLsbRelease
    print_ok "System upgraded successfully to version ${LATEST_VERSION}"
}

main