#!/bin/bash

#=================================================
#    AnduinOS Auto-Repair Tool (do-anduinos-autorepair.sh)
#=================================================
# This script automatically detects the current
# system version, downloads the corresponding
# repair ISO, mounts it, and executes the
# REPAIR.sh script found inside.
#
# Do NOT run this script as root. Run it as a normal
# user with sudo privileges.
#=================================================

set -e
set -o pipefail
set -u

# --- Global Variables ---
ISO_MNT_POINT="/mnt/anduinos_iso_repair"
DOWNLOAD_DIR="$HOME/Downloads/anduinos_repair_temp"
# FILE_PREFIX will be set after system detection (e.g., "AnduinOS-1.4.1")
FILE_PREFIX=""

# --- Color and Print Functions ---
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
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
    # Cleanup will be triggered by the trap
    exit 1
  fi
}

# --- Cleanup Function ---
# This function is responsible for unmounting the ISO
# and deleting all temporary download files.
function clean_up() {
  print_ok "Cleaning up repair files..."
  sudo umount "$ISO_MNT_POINT" >/dev/null 2>&1 || true
  sudo rm -rf "$ISO_MNT_POINT" >/dev/null 2>&1 || true
  
  # Only remove files if FILE_PREFIX was set
  if [ -n "$FILE_PREFIX" ]; then
    print_ok "Removing ${DOWNLOAD_DIR}/${FILE_PREFIX}* ..."
    sudo rm -rf "$DOWNLOAD_DIR" >/dev/null 2>&1 || true
  fi
  judge "Cleanup"
}

# --- Trap ---
# Ensures clean_up is called on script exit (success or failure)
trap 'clean_up' EXIT

# --- Initial Run ---
# Clean up any leftover files from a previous failed run
clean_up

# --- Pre-flight Checks ---
print_ok "Ensure current user is not root..."
if [[ "$(id -u)" -eq 0 ]]; then
    print_error "This script must not be run as root. Please run as a normal user with sudo privileges."
    exit 1
fi
judge "User check"

print_ok "Installing required packages (aria2, curl)..."
sudo apt install -y aria2 curl || (sudo apt update && sudo apt install -y aria2 curl)
judge "Install required packages"

# --- 1. System Detection ---
print_ok "Detecting current system version..."
if [ ! -f "/etc/lsb-release" ]; then
    print_error "System /etc/lsb-release file not found. Is this an installed AnduinOS?"
    exit 1
fi

source /etc/lsb-release # Loads $DISTRIB_ID, $DISTRIB_RELEASE, $DISTRIB_CODENAME
SYS_PRODUCT=$DISTRIB_ID
SYS_VERSION=$DISTRIB_RELEASE   # e.g., 1.4.1
SYS_CODENAME=$DISTRIB_CODENAME # e.g., questing
SYS_ARCH=$(dpkg --print-architecture)

# Get base version (e.g., "1.4.1" -> "1.4")
SYS_BASE_VERSION=$(echo "$SYS_VERSION" | cut -d'.' -f1-2)
# Set global prefix for filenames and cleanup
FILE_PREFIX="AnduinOS-$SYS_VERSION"

print_ok "System detected:  ${Blue}$SYS_PRODUCT $SYS_VERSION ($SYS_CODENAME) $SYS_ARCH${Font}"
print_ok "Download target:  ${Blue}Base $SYS_BASE_VERSION, Full $SYS_VERSION${Font}"
judge "System detection"

# --- 2. Download Logic ---
CURRENT_LANG=${LANG%%.*}
BASE_URL="https://download.anduinos.com/$SYS_BASE_VERSION/$SYS_VERSION"
FILE_NAME_BASE="${FILE_PREFIX}-${CURRENT_LANG}" # e.g., AnduinOS-1.4.1-zh_CN
mkdir -p "$DOWNLOAD_DIR"
TORRENT_FILE="${DOWNLOAD_DIR}/${FILE_PREFIX}.torrent"
SHA256_FILE="${DOWNLOAD_DIR}/${FILE_PREFIX}.sha256"

DOWNLOAD_URL="${BASE_URL}/${FILE_NAME_BASE}.torrent"
HASH_URL="${BASE_URL}/${FILE_NAME_BASE}.sha256"

print_ok "Current system language detected: ${CURRENT_LANG}"
print_ok "Attempting to download with URL: ${DOWNLOAD_URL}"

# Fallback to en_US if language-specific ISO is not found
if ! curl --head --silent --fail "$DOWNLOAD_URL" >/dev/null; then
    print_warn "Language pack for ${CURRENT_LANG} not found, falling back to en_US"
    FILE_NAME_BASE="${FILE_PREFIX}-en_US"
    DOWNLOAD_URL="${BASE_URL}/${FILE_NAME_BASE}.torrent"
    HASH_URL="${BASE_URL}/${FILE_NAME_BASE}.sha256"
fi

if ! curl --head --silent --fail "$DOWNLOAD_URL" >/dev/null; then
    print_error "Download URL is not reachable: $DOWNLOAD_URL"
    print_error "Please check your network connection or the download server."
    exit 1
fi

print_ok "Downloading AnduinOS $SYS_VERSION torrent and checksum..."
curl -L -o "$TORRENT_FILE" "$DOWNLOAD_URL"
curl -L -o "$SHA256_FILE" "$HASH_URL"
judge "Download torrents"

REQUIRED_SPACE_KB=6291456 # 6GB in KiB (6 * 1024 * 1024)
print_ok "Checking for at least 6GB of free space in $DOWNLOAD_DIR..."
# Get available space in download dir in KiB
AVAILABLE_SPACE_KB=$(df -P -k "$DOWNLOAD_DIR" | awk 'NR==2 {print $4}')

if (( AVAILABLE_SPACE_KB < REQUIRED_SPACE_KB )); then
    print_error "Not enough free disk space in $DOWNLOAD_DIR."
    print_error "Required: ~6GB, Available: $(numfmt --to=iec-i --suffix=B ${AVAILABLE_SPACE_KB}K)"
    print_error "Please free up disk space and try again."
    exit 1
fi
judge "Disk space check"

print_ok "Starting download via aria2 (ISO file)..."
# Download to download dir, allow overwrite, don't seed, use 16 connections
aria2c --allow-overwrite=true --seed-ratio=0.0 --seed-time=0 -x 16 -s 16 -k 1M -d "$DOWNLOAD_DIR" "$TORRENT_FILE"
judge "Download AnduinOS ISO"

# --- 3. Integrity Check ---
ISO_FILE_PATH=$(ls "${DOWNLOAD_DIR}/${FILE_PREFIX}"*.iso | head -n 1)
print_ok "Ensure downloaded ISO file exists..."
if [[ -f "$ISO_FILE_PATH" ]]; then
    print_ok "Downloaded ISO file found: $ISO_FILE_PATH"
else
    print_error "Downloaded ISO file not found in $DOWNLOAD_DIR matching '${FILE_PREFIX}*.iso'"
    exit 1
fi

print_ok "Verifying download integrity..."
ACTUAL_SHA256=$(sha256sum "$ISO_FILE_PATH" | awk '{print $1}')
# The sha256 file might have different formats, let's find the hash value robustly
EXPECTED_SHA256=$(grep -o '[a-fA-F0-9]\{64\}' "$SHA256_FILE" | head -n 1)

if [[ "$ACTUAL_SHA256" == "$EXPECTED_SHA256" ]]; then
    print_ok "SHA256 checksum verification passed."
else
    print_ok "Expected SHA256: $EXPECTED_SHA256"
    print_ok "Actual SHA256:   $ACTUAL_SHA256"
    print_error "SHA256 checksum verification failed. The downloaded file may be corrupted."
    exit 1
fi
judge "ISO integrity check"

# --- 4. Mount ISO ---
print_ok "Mounting the ISO to $ISO_MNT_POINT..."
sudo mkdir -p "$ISO_MNT_POINT"
sudo mount -o loop,ro "$ISO_FILE_PATH" "$ISO_MNT_POINT"
judge "Mount ISO"

# --- 5. Execute REPAIR.sh ---
REPAIR_SCRIPT_PATH="$ISO_MNT_POINT/REPAIR.sh"
print_ok "Checking for REPAIR.sh in ISO..."
if [ ! -f "$REPAIR_SCRIPT_PATH" ]; then
    print_error "REPAIR.sh not found at $REPAIR_SCRIPT_PATH!"
    print_error "The downloaded ISO may be invalid or incomplete."
    exit 1
fi
judge "Found REPAIR.sh"

print_ok "Executing repair script from ISO. This may take a while..."
print_ok "Follow the prompts from the repair script."
echo -e "${Yellow}======================================================${Font}"

# Execute the script from the ISO
if "$REPAIR_SCRIPT_PATH"; then
    print_ok "REPAIR.sh script completed successfully."
else
    print_error "REPAIR.sh script failed."
    # The trap will handle cleanup
    exit 1
fi

echo -e "${Yellow}======================================================${Font}"
judge "System repair script execution"

# --- 6. Cleanup ---
# The 'trap' at the top will automatically call clean_up() here.
print_ok "Auto-repair process finished."
print_ok "Please reboot your system as recommended by the repair script."