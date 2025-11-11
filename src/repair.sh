#!/bin/bash

#=================================================
#           PLEASE READ THIS BEFORE CONTINUING
#=================================================
# This file is used to repair AnduinOS by mounting
# the ISO and replacing system files. It is intended
# for use when the system is broken or corrupted.
#
# This file is ONLY compatible with AnduinOS installed
# on a system, not live session.
#
# Do NOT run this script as root. Run it as a normal
# user with sudo privileges.
#
# Example:
#    bash ./REPAIR.sh
#=================================================

set -e
set -o pipefail
set -u

PKG_TEMP_FILE=$(mktemp)
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
export SQUASH_FILE="$SCRIPT_DIR/casper/filesystem.squashfs"
export DCONF_FILE="$SCRIPT_DIR/casper/default-dconf.ini"
trap 'rm -f "$PKG_TEMP_FILE"' EXIT

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

function print_ok() {
  echo -e "${OK} ${Blue} $1 ${Font}"
}

function print_error() {
  echo -e "${ERROR} ${Red} $1 ${Font}"
}

function print_warn() {
  echo -e "${WARNING} ${Yellow} $1 ${Font}"
}

function judge() {
  if [[ 0 -eq $? ]]; then
    print_ok "$1 succeeded"
    sleep 0.2
  else
    print_error "$1 failed"
    exit 1
  fi
}

function clean_up() {
  print_ok "Cleaning up old files..."
  sudo umount /mnt/anduinos_squashfs >/dev/null 2>&1 || true
  sudo rm -rf /mnt/anduinos_squashfs >/dev/null 2>&1 || true
  #sudo umount /mnt/anduinos_iso >/dev/null 2>&1 || true
  #sudo rm -rf /mnt/anduinos_iso >/dev/null 2>&1 || true
  judge "Cleanup"
}

clean_up

print_ok "Checking ISO and system compatibility..."

# 1. Get ISO info from .disk/info
DISK_INFO_FILE="$SCRIPT_DIR/.disk/info"
if [ ! -f "$DISK_INFO_FILE" ]; then
    print_error ".disk/info file not found in ISO root! Cannot verify target."
    exit 1
fi

# Parse "AnduinOS 1.4.1 questing - Release amd64 (20251111)"
ISO_PRODUCT=$(awk '{print $1}' "$DISK_INFO_FILE")
ISO_VERSION=$(awk '{print $2}' "$DISK_INFO_FILE")
ISO_CODENAME=$(awk '{print $3}' "$DISK_INFO_FILE")
ISO_ARCH=$(awk '{print $6}' "$DISK_INFO_FILE")

# 2. Get System info from /etc/lsb-release
if [ ! -f "/etc/lsb-release" ]; then
    print_error "System /etc/lsb-release file not found. Is this an installed AnduinOS?"
    exit 1
fi

source /etc/lsb-release # Loads $DISTRIB_ID, $DISTRIB_RELEASE, $DISTRIB_CODENAME
SYS_PRODUCT=$DISTRIB_ID
SYS_VERSION=$DISTRIB_RELEASE
SYS_CODENAME=$DISTRIB_CODENAME
SYS_ARCH=$(dpkg --print-architecture)

# 4. Compare system vs ISO versions with new rules
  ISO_MAJOR_MINOR=$(echo "$ISO_VERSION" | cut -d'.' -f1-2)
  SYS_MAJOR_MINOR=$(echo "$SYS_VERSION" | cut -d'.' -f1-2)

  if [[ "$ISO_MAJOR_MINOR" != "$SYS_MAJOR_MINOR" ]]; then
      # Critical unmatch (e.g., ISO 1.4.x vs System 1.3.x)
      print_error "Version Mismatch (Major.Minor)."
      print_error "System is $SYS_VERSION (base $SYS_MAJOR_MINOR), but ISO is $ISO_VERSION (base $ISO_MAJOR_MINOR)."
      print_error "This ISO cannot repair this system. Aborting."
      exit 1
  
  elif [[ "$ISO_VERSION" != "$SYS_VERSION" ]]; then
      # Minor unmatch (e.g., ISO 1.4.0 vs System 1.4.1)
      print_warn "Version Mismatch (Patch)."
      print_warn "System version ($SYS_VERSION) does not exactly match ISO version ($ISO_VERSION)."
      print_warn "Since the base version ($ISO_MAJOR_MINOR) matches, you may proceed, but this is not guaranteed."
      
      read -p "Do you want to force continue the repair? (y/N): " force_confirm
      if [[ "$force_confirm" != "y" && "$force_confirm" != "Y" ]]; then
          print_error "Repair process aborted by user due to version mismatch."
          exit 1
      fi
      
      print_ok "User confirmed. Forcing repair with different patch version."
  fi

print_ok "ISO target:   ${Blue}$ISO_PRODUCT $ISO_VERSION ($ISO_CODENAME) $ISO_ARCH${Font}"
print_ok "System found: ${Blue}$SYS_PRODUCT $SYS_VERSION ($SYS_CODENAME) $SYS_ARCH${Font}"

# 3. Compare compatibility
if [[ "$SYS_PRODUCT" != "$ISO_PRODUCT" ]]; then
    print_error "Product mismatch. System is '$SYS_PRODUCT', ISO is for '$ISO_PRODUCT'."
    exit 1
fi

if [[ "$SYS_CODENAME" != "$ISO_CODENAME" ]]; then
    print_error "Codename mismatch. System is '$SYS_CODENAME', ISO is for '$ISO_CODENAME'."
    print_error "This ISO can only repair '$ISO_CODENAME' systems."
    exit 1
fi

if [[ "$SYS_ARCH" != "$ISO_ARCH" ]]; then
    print_error "Architecture mismatch. System is '$SYS_ARCH', ISO is for '$ISO_ARCH'."
    exit 1
fi

print_ok "System is compatible with this repair ISO."
judge "System compatibility check"

echo -e "${Yellow}WARNING: This script is for repairing ${ISO_PRODUCT} ($ISO_CODENAME) systems.${Font}"
echo -e "${Yellow}This ISO (${ISO_VERSION}) will be used to repair your installed system (${SYS_VERSION}).${Font}"
echo -e "${Yellow}Some configuration files may be overwritten during this process. Including:${Font}"
echo -e "${Yellow}- APT sources and preferences files${Font}"
echo -e "${Yellow}- GNOME session and Wayland session files${Font}"
echo -e "${Yellow}- GNOME extensions, icons, themes, and backgrounds${Font}"
echo -e "${Yellow}- System version information files${Font}"
echo -e "${Yellow}Please ensure you have backups of any important data before proceeding.${Font}"
read -p "Do you want to continue? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    print_error "Repair process aborted by user."
    exit 1
fi

print_ok "Ensure current user is not root..."
if [[ "$(id -u)" -eq 0 ]]; then
    print_error "This script must not be run as root. Please run as a normal user with sudo privileges."
    exit 1
fi

print_ok "Installing required packages (curl)..."
sudo apt install -y curl || sudo apt update && sudo apt install -y curl
judge "Install required packages (curl)"

print_ok "Verifying content in the ISO..."
(cd ${SCRIPT_DIR} && sudo md5sum -c md5sum.txt)
judge "ISO content integrity verification"

print_ok "Mounting the filesystem.squashfs..."
sudo mkdir -p /mnt/anduinos_squashfs
sudo mount -o loop,ro "$SQUASH_FILE" /mnt/anduinos_squashfs
judge "Mount filesystem.squashfs"

# backup
print_ok "Backing up APT configuration files..."
sudo mkdir /etc/apt/preferences.d.bak >/dev/null 2>&1 || true
sudo rsync -Aax /etc/apt/preferences.d/ /etc/apt/preferences.d.bak/ >/dev/null 2>&1 || true
judge "Backup APT configuration files"
# reset

print_ok "Resetting APT configuration files..."
sudo rm /etc/apt/preferences.d/* >/dev/null 2>&1 || true
judge "Reset APT configuration files"

print_ok "Updating package mirrors..."
curl -s https://gitlab.aiursoft.com/anduin/init-server/-/raw/master/mirror.sh?ref_type=heads | bash
sudo apt update
judge "Update package mirrors"

print_ok "Updating Mozilla Team PPA..."
sudo rm -f /etc/apt/sources.list.d/mozillateam*
sudo rsync -Aax /mnt/anduinos_squashfs/etc/apt/sources.list.d/mozillateam* /etc/apt/sources.list.d/
sudo apt update
judge "Update Mozilla Team PPA"

print_ok "Generating package list for upgrade..."
MANIFEST_FILE="$SCRIPT_DIR/casper/filesystem.manifest-desktop"

cut -d' ' -f1 "$MANIFEST_FILE" \
  | grep -v '^linux-' \
  | grep -v '^lib' \
  | grep -v '^plymouth-' \
  | grep -v '^software-properties-' > "$PKG_TEMP_FILE"

if [ ! -s "$PKG_TEMP_FILE" ]; then
    print_ok "No missing packages to install."
else
    if xargs sudo apt install --no-install-recommends -y < "$PKG_TEMP_FILE" > /tmp/anduinos-fast-install.log 2>&1; then
        print_ok "Fast mode installation successful."
        rm -f /tmp/anduinos-fast-install.log
    
    else
        print_warn "Fast mode failed. Retrying one by one (robust mode)..."
        print_ok "This may take 5-30 minutes. Only errors will be displayed."
        
        PKG_INSTALL_LOG="/tmp/anduinos-pkg-install.log"

        while read -r pkg; do
            if [ -n "$pkg" ]; then
                if sudo apt install --no-install-recommends -y "$pkg" > "$PKG_INSTALL_LOG" 2>&1; then
                    : # Bash的 "no-op" (空操作)
                else
                    print_warn "Failed to install package: '$pkg'. Details:"
                    cat "$PKG_INSTALL_LOG"
                    echo -e "${Red}-----------------------------------------------------${Font}"
                fi
            fi
        done < "$PKG_TEMP_FILE"
        
        rm -f "$PKG_INSTALL_LOG"
        print_ok "Robust missing package install mode finished."
    fi
fi
judge "Install missing packages"

print_ok "Removing obsolete packages..."
sudo apt autoremove -y \
  distro-info \
  software-properties-gtk \
  ubuntu-advantage-tools \
  ubuntu-pro-client \
  ubuntu-pro-client-l10n \
  ubuntu-release-upgrader-gtk \
  ubuntu-report \
  ubuntu-settings \
  update-notifier-common \
  update-manager \
  update-manager-core \
  update-notifier \
  ubuntu-release-upgrader-core \
  ubuntu-advantage-desktop-daemon \
  kgx
judge "Remove obsolete packages"

print_ok "Upgrading installed packages..."
sudo apt upgrade -y
sudo apt autoremove --purge -y
judge "System package cleanup"

print_ok "Upgrading GNOME Shell extensions..."
sudo rsync -Aax --update --delete /mnt/anduinos_squashfs/usr/share/gnome-shell/extensions/ /usr/share/gnome-shell/extensions/
judge "Upgrade GNOME Shell extensions"

print_ok "Upgrading icon and theme files..."
sudo rsync -Aax --update --delete /mnt/anduinos_squashfs/usr/share/icons/ /usr/share/icons/
sudo rsync -Aax --update --delete /mnt/anduinos_squashfs/usr/share/themes/ /usr/share/themes/
judge "Upgrade icon and theme files"

# Intel SOF Mod installation
print_ok "Installing Intel SOF Mod..."
#/usr/local/bin/sof-*
#/lib/firmware/intel/sof*
#/usr/share/alsa/ucm2/
sudo rsync -Aax --update /mnt/anduinos_squashfs/lib/firmware/intel/sof* /lib/firmware/intel/
sudo rsync -Aax --update /mnt/anduinos_squashfs/usr/local/bin/sof-* /usr/local/bin/
sudo rsync -Aax --update /mnt/anduinos_squashfs/usr/share/alsa/ucm2/ /usr/share/alsa/ucm2/
judge "Install Intel SOF Mod"

print_ok "Upgrading desktop backgrounds..."
sudo rsync -Aax --update /mnt/anduinos_squashfs/usr/share/backgrounds/ /usr/share/backgrounds/
sudo rsync -Aax --update /mnt/anduinos_squashfs/usr/share/gnome-background-properties/ /usr/share/gnome-background-properties/
judge "Upgrade desktop backgrounds"

print_ok "Upgrading APT configuration files..."
sudo rsync -Aax --update --delete /mnt/anduinos_squashfs/etc/apt/apt.conf.d/ /etc/apt/apt.conf.d/
judge "Upgrade APT configuration files"

print_ok "Upgrading APT preferences files..."
sudo rsync -Aax --update --delete /mnt/anduinos_squashfs/etc/apt/preferences.d/ /etc/apt/preferences.d/
judge "Upgrade APT preferences files"

print_ok "Upgrading session files..."
sudo rsync -Aax --update --delete /mnt/anduinos_squashfs/usr/share/gnome-session/sessions/ /usr/share/gnome-session/sessions/
sudo rsync -Aax --update --delete /mnt/anduinos_squashfs/usr/share/wayland-sessions/ /usr/share/wayland-sessions/
judge "Upgrade session files"

print_ok "Upgrading pixmaps..."
sudo rsync -Aax --update --delete /mnt/anduinos_squashfs/usr/share/pixmaps/ /usr/share/pixmaps/
judge "Upgrade pixmaps"

print_ok "Upgrading /etc/skel/ files..."
sudo rsync -Aax --update --delete /mnt/anduinos_squashfs/etc/skel/ /etc/skel/
judge "Upgrade /etc/skel/ files"

print_ok "Upgrading python-apt templates and distro info..."
sudo rsync -Aax --update --delete /mnt/anduinos_squashfs/usr/share/python-apt/templates/ /usr/share/python-apt/templates/
sudo rsync -Aax --update --delete /mnt/anduinos_squashfs/usr/share/distro-info/ /usr/share/distro-info/
judge "Upgrade python-apt templates and distro info"

print_ok "Upgrading deskmon service..."
sudo rsync -Aax /mnt/anduinos_squashfs/usr/local/bin/deskmon /usr/local/bin/deskmon
sudo rsync -Aax /mnt/anduinos_squashfs/etc/systemd/user/deskmon.service /etc/systemd/user/deskmon.service
sudo rsync -Aax /mnt/anduinos_squashfs/etc/systemd/user/default.target.wants/deskmon.service /etc/systemd/user/default.target.wants/deskmon.service
judge "Upgrade deskmon service"

print_ok "Upgrading gnome-session and wayland session files..."
sudo rsync -Aax --update --delete /mnt/anduinos_squashfs/usr/share/gnome-session/sessions/ /usr/share/gnome-session/sessions/
sudo rsync -Aax --update --delete /mnt/anduinos_squashfs/usr/share/wayland-sessions/ /usr/share/wayland-sessions/
judge "Upgrade gnome-session and wayland session files"

print_ok "Updating system version information..."
sudo rsync -Aax /mnt/anduinos_squashfs/usr/local/bin/do_anduinos_upgrade /usr/local/bin/do_anduinos_upgrade
sudo rsync -Aax /mnt/anduinos_squashfs/usr/bin/add-apt-repository /usr/bin/add-apt-repository
sudo rsync -Aax /mnt/anduinos_squashfs/etc/lsb-release /etc/lsb-release
sudo rsync -Aax /mnt/anduinos_squashfs/etc/issue /etc/issue
sudo rsync -Aax /mnt/anduinos_squashfs/etc/issue.net /etc/issue.net
sudo rsync -Aax /mnt/anduinos_squashfs/etc/os-release /etc/os-release
sudo rsync -Aax /mnt/anduinos_squashfs/usr/lib/os-release /usr/lib/os-release
sudo rsync -Aax /mnt/anduinos_squashfs/etc/legal /etc/legal
sudo rsync -Aax /mnt/anduinos_squashfs/etc/sysctl.d/20-apparmor-donotrestrict.conf /etc/sysctl.d/20-apparmor-donotrestrict.conf
sudo rsync -Aax /mnt/anduinos_squashfs/var/lib/flatpak/repo/config /var/lib/flatpak/repo/config
sudo rsync -Aax /mnt/anduinos_squashfs/usr/share/plymouth/themes/spinner/bgrt-fallback.png /usr/share/plymouth/themes/spinner/bgrt-fallback.png
sudo rsync -Aax /mnt/anduinos_squashfs/usr/share/plymouth/themes/spinner/watermark.png /usr/share/plymouth/themes/spinner/watermark.png
sudo rsync -Aax /mnt/anduinos_squashfs/usr/share/plymouth/ubuntu-logo.png /usr/share/plymouth/ubuntu-logo.png
judge "Update system version information"

print_ok "Applying dconf settings patch..."
cat "$DCONF_FILE" | dconf load /org/gnome/
judge "Apply dconf settings patch"

print_ok "Updating initramfs..."
sudo update-initramfs -u -k all
judge "Update initramfs"

print_ok "Updating GRUB configuration..."
sudo update-grub
judge "Update GRUB configuration"

print_ok "Upgrade completed! Please reboot your system to apply all changes."

print_ok "Starting cleanup..."
clean_up