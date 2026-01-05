#!/bin/bash

#=================================================
#           AnduinOS Upgrade Script
#=================================================
# This script upgrades AnduinOS from 1.3.9 (plucky)
# to 1.4.2 (questing).
#
# Usage:
# ./do_anduinos_distupgrade.sh
# (Script will auto-elevate to root/sudo)
#=================================================

set -e
set -o pipefail
set -u

# --- 1. Visual Definitions ---
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
OK="${Green}[  OK  ]${Font}"
ERROR="${Red}[FAILED]${Font}"
WARNING="${Yellow}[ WARN ]${Font}"

# --- 2. Configuration ---
# Use /var/backups for persistence and space safety
BACKUP_ROOT="/var/backups/anduinos-upgrade"
BACKUP_DIR="$BACKUP_ROOT/backup_$(date +%Y%m%d_%H%M%S)"
PPA_BACKUP_DIR="$BACKUP_DIR/ppa"
UBUNTU_SOURCE_BACKUP="$BACKUP_DIR/ubuntu_sources"

# Auto-upgrade mode: Set ANDUINOS_AUTO_UPGRADE=Y to skip all interactive prompts
AUTO_UPGRADE="${ANDUINOS_AUTO_UPGRADE:-N}"

# --- 3. Helper Functions (Logging) ---

function print_ok() {
  echo -e "${OK} ${Blue} $1 ${Font}"
}

function print_error() {
  echo -e "${ERROR} ${Red} $1 ${Font}"
}

function print_warn() {
  echo -e "${WARNING} ${Yellow} $1 ${Font}"
}

# --- 4. Privilege Check (Auto-Elevation) ---

function ensure_root() {
  if [ "$EUID" -ne 0 ]; then
    print_warn "This script requires root privileges."
    print_ok "Attempting to escalate privileges via sudo..."
    
    if ! command -v sudo &> /dev/null; then
      print_error "sudo is not installed. Please run this script as root."
      exit 1
    fi

    # Re-execute the script with sudo, preserving ANDUINOS_AUTO_UPGRADE and arguments
    exec sudo ANDUINOS_AUTO_UPGRADE="${ANDUINOS_AUTO_UPGRADE:-N}" "$0" "$@"
    exit 0
  fi
  # If we are here, we are root.
}

# --- 4.5 SSH & Persistence Check ---

function check_ssh_safeguard() {
  # Skip check in auto-upgrade mode
  if [[ "$AUTO_UPGRADE" == "Y" ]] || [[ "$AUTO_UPGRADE" == "y" ]]; then
    print_ok "Auto-upgrade mode enabled, skipping SSH safeguard check."
    return
  fi
  
  if [ -n "${SSH_CLIENT:-}" ] || [ -n "${SSH_TTY:-}" ]; then
    # Check for screen/tmux
    if [ -n "${STY:-}" ] || [ -n "${TMUX:-}" ] || [[ "${TERM:-}" == *"screen"* ]] || [[ "${TERM:-}" == *"tmux"* ]]; then
        print_ok "SSH detected, but running inside persistence (screen/tmux). Safe."
        return
    fi
    
    print_warn "SSH session detected WITHOUT screen/tmux!"
    print_warn "Network disconnection could kill the critical upgrade process."
    
    if [ -t 0 ]; then
        read -p "Continue anyway? (y/N): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            print_error "Aborted. Please use screen/tmux."
            exit 1
        fi
    fi

  fi
}

# --- 5. Unattended Configuration (Anti-Prompt) ---

function configure_unattended() {
  print_ok "Configuring system for unattended upgrades..."

  # Install debconf-utils to pre-seed answers
  if ! command -v debconf-set-selections &> /dev/null; then
    print_ok "Installing debconf-utils..."
    apt-get update && apt-get install -y debconf-utils
  fi

  # Pre-answer "Yes" to "Restart services during package upgrades without asking?"
  # This kills the libc6/libpam dialog.
  echo '* libraries/restart-without-asking boolean true' | debconf-set-selections

  # Configure environment variables for the session
  # NEEDRESTART_MODE=a : Automatically restart services (fixes purple screen prompt)
  export NEEDRESTART_MODE=a
  export DEBIAN_FRONTEND=noninteractive
  
  judge "Configure unattended mode"
}

# --- 6. Core Logic with Detailed Rollback ---

function rollback_on_error() {
  print_error "An error occurred during the upgrade process"
  print_warn "Starting rollback procedure..."
  
  # Restore ubuntu.sources if backup exists
  if [ -f "$UBUNTU_SOURCE_BACKUP/ubuntu.sources" ]; then
    print_ok "Restoring ubuntu.sources..."
    cp "$UBUNTU_SOURCE_BACKUP/ubuntu.sources" /etc/apt/sources.list.d/
    print_ok "Restored ubuntu.sources"
  fi
  
  # Restore sources.list if backup exists
  if [ -f "$UBUNTU_SOURCE_BACKUP/sources.list" ]; then
    print_ok "Restoring sources.list..."
    cp "$UBUNTU_SOURCE_BACKUP/sources.list" /etc/apt/
    print_ok "Restored sources.list"
  fi
  
  # Restore PPA sources (Detailed Loop from Old Script)
  if [ -d "$PPA_BACKUP_DIR" ]; then
    ppa_count=$(ls -1 "$PPA_BACKUP_DIR" 2>/dev/null | wc -l)
    
    if [ "$ppa_count" -gt 0 ]; then
      print_ok "Restoring PPA sources..."
      for file in "$PPA_BACKUP_DIR"/*; do
        if [ -f "$file" ]; then
          cp "$file" /etc/apt/sources.list.d/
          print_ok "Restored $(basename "$file")"
        fi
      done
    fi
  fi
  
  # Remove temporary apt configuration if exists
  if [ -f "/etc/apt/apt.conf.d/99-local-versions" ]; then
    rm -f /etc/apt/apt.conf.d/99-local-versions
    print_ok "Removed temporary apt configuration"
  fi
  
  # Run apt update to restore repository state
  print_ok "Running apt update to restore repository state..."
  apt update || true
  
  print_warn "Rollback completed"
  print_warn "Your system has been restored to the previous state"
  print_warn "Backup files are preserved in: $BACKUP_DIR"
  print_error "Please check the error messages above and try again"
  
  exit 1
}

function judge() {
  if [[ 0 -eq $? ]]; then
    print_ok "$1 succeeded"
    sleep 0.2
  else
    print_error "$1 failed"
    rollback_on_error
  fi
}

function run_dpkg_repair() {
  print_ok "Running dpkg repair operations..."
  
  # Fix interrupted package installations
  dpkg --configure -a || true
  
  # Fix broken dependencies
  apt-get install -f -y || true
  
  print_ok "Repair operations completed"
}

function switch_to_official_mirror() {
  print_warn "Switching to official Ubuntu archive mirror..."
  
  local codename=$(lsb_release -cs)
  generate_new_format "http://archive.ubuntu.com/ubuntu/" "$codename"
  
  print_ok "Switched to official mirror: archive.ubuntu.com"
}

function apt_update_with_retry() {
  local max_attempts=3
  local attempt=1
  local wait_time=5
  
  while [ $attempt -le $max_attempts ]; do
    print_ok "Attempting apt update (attempt $attempt/$max_attempts)..."
    
    if apt update; then
      print_ok "apt update succeeded"
      return 0
    fi
    
    print_warn "apt update failed on attempt $attempt"
    
    if [ $attempt -lt $max_attempts ]; then
      # Run repair before retry
      run_dpkg_repair
      
      # If this is the second attempt failure, switch to official mirror
      if [ $attempt -eq 2 ]; then
        print_warn "Multiple failures detected. Switching to official Ubuntu mirror as fallback..."
        switch_to_official_mirror
      fi
      
      print_ok "Waiting ${wait_time}s before retry..."
      sleep $wait_time
      wait_time=$((wait_time * 2))
    fi
    
    attempt=$((attempt + 1))
  done
  
  print_error "apt update failed after $max_attempts attempts"
  return 1
}

function apt_upgrade_with_retry() {
  local max_attempts=3
  local attempt=1
  local wait_time=5
  
  while [ $attempt -le $max_attempts ]; do
    print_ok "Attempting apt upgrade (attempt $attempt/$max_attempts)..."
    
    # Use --fix-missing to skip unavailable packages
    if DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt upgrade -y --fix-missing; then
      print_ok "apt upgrade succeeded"
      return 0
    fi
    
    print_warn "apt upgrade failed on attempt $attempt"
    
    if [ $attempt -lt $max_attempts ]; then
      # Run repair before retry
      run_dpkg_repair
      
      # If this is the second attempt failure, switch to official mirror
      if [ $attempt -eq 2 ]; then
        print_warn "Multiple failures detected. Switching to official Ubuntu mirror as fallback..."
        switch_to_official_mirror
        # Update package lists with new mirror
        apt_update_with_retry || return 1
      fi
      
      print_ok "Waiting ${wait_time}s before retry..."
      sleep $wait_time
      wait_time=$((wait_time * 2))
    fi
    
    attempt=$((attempt + 1))
  done
  
  print_error "apt upgrade failed after $max_attempts attempts"
  return 1
}

function apt_dist_upgrade_with_retry() {
  local max_attempts=3
  local attempt=1
  local wait_time=5
  
  while [ $attempt -le $max_attempts ]; do
    print_ok "Attempting apt dist-upgrade (attempt $attempt/$max_attempts)..."
    
    # Run dist-upgrade with --fix-missing
    if bash -c 'DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a APT_LISTCHANGES_FRONTEND=none \
    apt-get -y dist-upgrade --fix-missing \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold"'; then
      print_ok "apt dist-upgrade succeeded"
      return 0
    fi
    
    print_warn "apt dist-upgrade failed on attempt $attempt"
    
    if [ $attempt -lt $max_attempts ]; then
      # Run repair before retry
      run_dpkg_repair
      
      # If this is the second attempt failure, switch to official mirror
      if [ $attempt -eq 2 ]; then
        print_warn "Multiple failures detected. Switching to official Ubuntu mirror as fallback..."
        switch_to_official_mirror
        # Update package lists with new mirror
        apt_update_with_retry || return 1
      fi
      
      print_ok "Waiting ${wait_time}s before retry..."
      sleep $wait_time
      wait_time=$((wait_time * 2))
    fi
    
    attempt=$((attempt + 1))
  done
  
  print_error "apt dist-upgrade failed after $max_attempts attempts"
  return 1
}

function check_disk_space() {
  print_ok "Checking available disk space..."
  
  # Ensure backup directory exists
  mkdir -p "$BACKUP_DIR"
  
  # Get available space in / (in KB)
  local root_space=$(df / | awk 'NR==2 {print $4}')
  # Convert to MB
  local root_space_mb=$((root_space / 1024))
  # Required space: 2GB
  local required_space=2048
  
  print_ok "Available space in /: ${root_space_mb}MB"
  print_ok "Backup location: $BACKUP_DIR"
  
  if [ "$root_space_mb" -lt "$required_space" ]; then
    print_error "Insufficient disk space in /. Required: ${required_space}MB, Available: ${root_space_mb}MB"
    exit 1
  fi
  
  print_ok "Disk space check passed"
}

function update_system() {
  print_ok "Ensuring current system (1.3 / Ubuntu 25.04) is fully updated..."

  print_ok "Running apt update with retry..."
  apt_update_with_retry
  judge "apt update with retry"

  print_ok "Installing any missing updates for the current version..."
  # Use retry logic with --fix-missing
  apt_upgrade_with_retry
  judge "apt upgrade with retry"
}

function backup_ubuntu_sources() {
  print_ok "Backing up Ubuntu official sources..."
  
  mkdir -p "$UBUNTU_SOURCE_BACKUP"
  
  # Backup ubuntu.sources if exists
  if [ -f "/etc/apt/sources.list.d/ubuntu.sources" ]; then
    cp /etc/apt/sources.list.d/ubuntu.sources "$UBUNTU_SOURCE_BACKUP/"
    print_ok "Backed up ubuntu.sources"
  fi
  
  # Backup sources.list if it exists and is not empty
  if [ -f "/etc/apt/sources.list" ] && [ -s "/etc/apt/sources.list" ]; then
    cp /etc/apt/sources.list "$UBUNTU_SOURCE_BACKUP/"
    print_ok "Backed up sources.list"
  fi
  
  judge "Backup Ubuntu sources"
}

function backup_and_remove_ppa() {
  print_ok "Backing up and temporarily removing PPA sources..."
  
  mkdir -p "$PPA_BACKUP_DIR"
  
  # Move all files in /etc/apt/sources.list.d/ except ubuntu.sources
  if [ -d "/etc/apt/sources.list.d" ]; then
    for file in /etc/apt/sources.list.d/*; do
      if [ -f "$file" ] && [ "$(basename "$file")" != "ubuntu.sources" ]; then
        mv "$file" "$PPA_BACKUP_DIR/"
        print_ok "Moved $(basename "$file") to backup"
      fi
    done
  fi
  
  print_ok "PPA sources moved to: $PPA_BACKUP_DIR"
  judge "Backup and remove PPA sources"
}

function check_apt_source_format() {
  local old_format=false
  local new_format=false

  # Check old format (.list)
  if [ -f "/etc/apt/sources.list" ]; then
    if grep -v '^#' /etc/apt/sources.list | grep -q '[^[:space:]]'; then
      old_format=true
    fi
  fi

  # Check for ubuntu.sources file in new format
  if [ -f "/etc/apt/sources.list.d/ubuntu.sources" ]; then
    if grep -v '^#' /etc/apt/sources.list.d/ubuntu.sources | grep -q '[^[:space:]]'; then
      new_format=true
    fi
  fi

  # Return status
  if $old_format && $new_format; then
    echo "both"
  elif $old_format; then
    echo "old"
  elif $new_format; then
    echo "new"
  else
    echo "none"
  fi
}

function find_fastest_mirror() {
  # Redirect all output to stderr
  echo "Testing mirror speeds..." >&2

  # Enable required packages
  apt install -y curl lsb-release >&2

  # Get current Ubuntu codename
  codename=$(lsb_release -cs)

  # Define list of potential mirrors
  mirrors=(
      "https://archive.ubuntu.com/ubuntu/"
      "https://mirror.aarnet.edu.au/pub/ubuntu/archive/" # Australia
      "https://mirror.fsmg.org.nz/ubuntu/"               # New Zealand
      "https://mirrors.neterra.net/ubuntu/archive/"       # Bulgaria
      "https://mirror.csclub.uwaterloo.ca/ubuntu/"        # Canada
      "https://mirrors.dotsrc.org/ubuntu/"                # Denmark
      "https://mirrors.nic.funet.fi/ubuntu/"              # Finland
      "https://mirror.ubuntu.ikoula.com/"                 # France
      "https://mirror.xtom.com.hk/ubuntu/"                # Hong Kong
      "https://mirrors.piconets.webwerks.in/ubuntu-mirror/ubuntu/" # India
      "https://ftp.udx.icscoe.jp/Linux/ubuntu/"           # Japan
      "https://ftp.kaist.ac.kr/ubuntu/"                   # Korea
      "https://ubuntu.mirror.garr.it/ubuntu/"             # Italy
      "https://ftp.uni-stuttgart.de/ubuntu/"              # Germany
      "https://mirror.i3d.net/pub/ubuntu/"                # Netherlands
      "https://mirroronet.pl/pub/mirrors/ubuntu/"         # Poland
      "https://ubuntu.mobinhost.com/ubuntu/"              # Iran
      "http://sg.archive.ubuntu.com/ubuntu/"              # Singapore
      "http://ossmirror.mycloud.services/os/linux/ubuntu/" # Singapore
      "https://mirror.enzu.com/ubuntu/"                   # United States
      "http://jp.archive.ubuntu.com/ubuntu/"              # Japan
      "http://kr.archive.ubuntu.com/ubuntu/"              # Korea
      "http://us.archive.ubuntu.com/ubuntu/"              # United States
      "http://tw.archive.ubuntu.com/ubuntu/"              # Taiwan
      "https://mirror.twds.com.tw/ubuntu/"                # Taiwan
      "https://ubuntu.mirrors.uk2.net/ubuntu/"            # United Kingdom
      "http://mirrors.ustc.edu.cn/ubuntu/"                # USTC
      "http://ftp.sjtu.edu.cn/ubuntu/"                    # SJTU
      "http://mirrors.tuna.tsinghua.edu.cn/ubuntu/"       # Tsinghua
      "http://mirrors.aliyun.com/ubuntu/"                 # Aliyun
      "http://mirrors.163.com/ubuntu/"                    # NetEase
      "http://mirrors.cloud.tencent.com/ubuntu/"          # Tencent Cloud
      "http://mirrors.huaweicloud.com/ubuntu/"            # Huawei Cloud
      "http://mirrors.zju.edu.cn/ubuntu/"                 # Zhejiang University
      "http://azure.archive.ubuntu.com/ubuntu/"           # Azure
      "https://mirrors.isu.net.sa/apt-mirror/"            # Saudi Arabia
      "https://mirror.team-host.ru/ubuntu/"               # Russia
      "https://labs.eif.urjc.es/mirror/ubuntu/"           # Spain
      "https://mirror.alastyr.com/ubuntu/ubuntu-archive/" # Turkey
      "https://ftp.acc.umu.se/ubuntu/"                    # Sweden
      "https://mirror.kku.ac.th/ubuntu/"                  # Thailand
      "https://mirror.bizflycloud.vn/ubuntu/"             # Vietnam
  )

  declare -A results

  # Test speed of each mirror
  for mirror in "${mirrors[@]}"; do
      echo "Testing $mirror ..." >&2
      response="$(curl -o /dev/null -s -w "%{http_code} %{time_total}\n" \
                --connect-timeout 1 --max-time 3 "${mirror}dists/${codename}/Release")"

      http_code=$(echo "$response" | awk '{print $1}')
      time_total=$(echo "$response" | awk '{print $2}')

      if [ "$http_code" -eq 200 ]; then
          results["$mirror"]="$time_total"
          echo "  Success: $time_total seconds" >&2
      else
          echo "  Failed: HTTP code $http_code" >&2
          results["$mirror"]="9999"
      fi
  done

  # Sort mirrors by response time
  sorted_mirrors="$(
      for url in "${!results[@]}"; do
          echo "$url ${results[$url]}"
      done | sort -k2 -n
  )"

  echo >&2
  echo "=== Mirrors sorted by response time (ascending) ===" >&2
  echo "$sorted_mirrors" >&2
  echo >&2

  # Choose the fastest mirror
  fastest_mirror="$(echo "$sorted_mirrors" | head -n 1 | awk '{print $1}')"

  if [[ "$fastest_mirror" == "" || "${results[$fastest_mirror]}" == "9999" ]]; then
      echo "No usable mirror found, using default mirror" >&2
      fastest_mirror="http://archive.ubuntu.com/ubuntu/"
  fi

  echo "Fastest mirror found: $fastest_mirror" >&2
  
  # Only this line will be returned to caller
  echo "$fastest_mirror"
}

function generate_new_format() {
  local mirror="$1"
  local codename="$2"

  print_ok "Generating new format source list /etc/apt/sources.list.d/ubuntu.sources"

  cat > /etc/apt/sources.list.d/ubuntu.sources <<EOF
Types: deb
URIs: $mirror
Suites: $codename
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: $mirror
Suites: $codename-updates
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: $mirror
Suites: $codename-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: $mirror
Suites: $codename-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF

  print_ok "New format source list updated"
}

function optimize_apt_sources() {
  print_ok "Optimizing APT sources..."

  # Install required packages if missing
  if ! command -v curl &> /dev/null || ! command -v lsb_release &> /dev/null; then
    print_ok "Installing curl and lsb-release..."
    apt update && apt install -y curl lsb-release
  fi

  local format=$(check_apt_source_format)
  print_ok "Current APT source format status: $format"

  local codename=$(lsb_release -cs)
  print_ok "Ubuntu codename: $codename"

  if [ "$format" == "new" ]; then
    print_ok "Already in new format. Skipping mirror re-check to preserve user settings."
    return
  fi

  print_ok "Searching for the fastest mirror..."
  # Capture output, separating stdout (result) from stderr (logs)
  # But find_fastest_mirror already handles >&2 for logs
  local fastest_mirror
  fastest_mirror=$(find_fastest_mirror)
  print_ok "Fastest mirror selected: $fastest_mirror"

  case "$format" in
    "none" | "old")
      print_ok "Converting to modern format..."
      generate_new_format "$fastest_mirror" "$codename"
      
      if [ -f "/etc/apt/sources.list" ]; then
        mv /etc/apt/sources.list /etc/apt/sources.list.bak
        print_ok "Old sources.list backed up"
      fi
      ;;
    "both")
      print_ok "Consolidating formats..."
      mv /etc/apt/sources.list /etc/apt/sources.list.bak
      print_ok "Old format source list backed up to /etc/apt/sources.list.bak"
      generate_new_format "$fastest_mirror" "$codename"
      ;;
  esac
  
  judge "Optimize APT sources"
}

function replace_plucky_with_questing() {
  print_ok "Replacing plucky with questing in ubuntu.sources..."
  
  if [ ! -f "/etc/apt/sources.list.d/ubuntu.sources" ]; then
    print_error "/etc/apt/sources.list.d/ubuntu.sources not found"
    rollback_on_error
  fi
  
  sed -i 's/plucky/questing/g' /etc/apt/sources.list.d/ubuntu.sources
  judge "Replace plucky with questing"
  
  print_ok "Running apt update with questing repositories (with retry)..."
  apt_update_with_retry
  judge "apt update with questing"
}

function install_coreutils_uutils() {
  print_ok "Installing coreutils-from-uutils..."
  
  DEBIAN_FRONTEND=noninteractive apt install -y coreutils-from-uutils
  judge "Install coreutils-from-uutils"
}

function run_dist_upgrade() {
  print_ok "Simulating apt dist-upgrade first..."
  apt -s dist-upgrade > /dev/null
  judge "apt -s dist-upgrade"

  print_ok "Running apt dist-upgrade with retry logic..."
  
  # Configure dpkg to keep local versions by default
  bash -c 'cat > /etc/apt/apt.conf.d/99-local-versions <<EOF
Dpkg::Options {
   "--force-confdef";
   "--force-confold";
}
EOF'
  
  # Run dist-upgrade with retry and --fix-missing
  apt_dist_upgrade_with_retry
  judge "apt dist-upgrade with retry"
  
  # Remove temporary configuration
  rm -f /etc/apt/apt.conf.d/99-local-versions
}

function update_release_files() {
  print_ok "Updating release information files to 1.4.2..."
  
  # Update /etc/os-release
  if [ -f "/etc/os-release" ]; then
    print_ok "Updating /etc/os-release..."
    bash -c "cat > /etc/os-release" <<EOF
PRETTY_NAME="AnduinOS 1.4.2"
NAME="AnduinOS"
VERSION_ID="1.4.2"
VERSION="1.4.2 (questing)"
VERSION_CODENAME=questing
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.anduinos.com/"
SUPPORT_URL="https://github.com/Anduin2017/AnduinOS/discussions"
BUG_REPORT_URL="https://github.com/Anduin2017/AnduinOS/issues"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=questing
EOF

    judge "Update /etc/os-release"
  fi
  
  # Update /etc/lsb-release
  if [ -f "/etc/lsb-release" ]; then
    print_ok "Updating /etc/lsb-release..."
    
    bash -c "cat > /etc/lsb-release" <<EOF
DISTRIB_ID=AnduinOS
DISTRIB_RELEASE=1.4.2
DISTRIB_CODENAME=questing
DISTRIB_DESCRIPTION="AnduinOS 1.4.2"
EOF

    judge "Update /etc/lsb-release"
  fi
  
  print_ok "Release files updated successfully"
}

function restore_and_upgrade_ppa_sources() {
  print_ok "Restoring and upgrading PPA sources..."
  
  if [ -d "$PPA_BACKUP_DIR" ]; then
    ppa_count=$(ls -1 "$PPA_BACKUP_DIR" 2>/dev/null | wc -l)
    
    if [ "$ppa_count" -gt 0 ]; then
      # Restore files first
      for file in "$PPA_BACKUP_DIR"/*; do
        if [ -f "$file" ]; then
          mv "$file" /etc/apt/sources.list.d/
          print_ok "Restored $(basename "$file")"
        fi
      done
      
      # Check and upgrade PPA configurations
      print_ok "Checking restored PPAs for version 'plucky'..."
      local upgraded_count=0
      
      # Iterate over all files in sources.list.d to be safe
      for file in /etc/apt/sources.list.d/*; do
        if [ -f "$file" ]; then
          # Skip ubuntu.sources to avoid messing with core repos
          if [ "$(basename "$file")" == "ubuntu.sources" ]; then
            continue
          fi

          # Check if file contains "plucky"
          if grep -q "plucky" "$file"; then
            local ppa_name=$(basename "$file")
            
            # Extract URL (First valid HTTP/HTTPS URL)
            
            local url=$(grep -E '^\s*deb' "$file" | grep -oE 'https?://[^ ]+' | head -n1)
            local can_upgrade=false

            if [ -n "$url" ]; then
              # Remove trailing slash
              url="${url%/}"
              
              # Check availability (Release or InRelease)
              # We use a silent check with timeout to verify if the new questing dist exists
              if curl -s -I -f -L --max-time 3 "$url/dists/questing/Release" &>/dev/null || \
                 curl -s -I -f -L --max-time 3 "$url/dists/questing/InRelease" &>/dev/null; then
                 can_upgrade=true
              fi
            fi
            
            if $can_upgrade; then
              sed -i 's/plucky/questing/g' "$file"
              print_ok "Upgraded PPA $ppa_name to questing"
              ((upgraded_count++))
            else
              print_warn "PPA $ppa_name does not support 'questing' yet (Connection failed or 404)."
              print_warn "Disabling $ppa_name to ensure clean upgrade."
              mv "$file" "${file}.save"
            fi
          fi
        fi
      done
      
      if [ "$upgraded_count" -eq 0 ]; then
        print_ok "No PPA files needed version upgrading."
      fi
      print_ok "Running apt update with restored PPAs (with retry)..."
      apt_update_with_retry
      judge "Restore and upgrade PPA sources"
    else
      print_ok "No PPA sources to restore"
    fi
  else
    print_warn "PPA backup directory not found, skipping restore"
  fi
}

function cleanup_system() {
  print_ok "Cleaning up system..."
  print_ok "Removing unused packages (orphans)..."
  if apt autoremove -y; then
    print_ok "apt autoremove succeeded"
  else
    print_warn "apt autoremove failed, but upgrade was successful."
  fi

  print_ok "Cleaning apt cache..."
  if apt clean; then
    print_ok "apt clean succeeded"
  else
    print_warn "apt clean failed, but upgrade was successful."
  fi
}

function main() {
  # 1. Ensure we are root first
  ensure_root

  # --- Enable Logging ---
  LOG_FILE="/var/log/anduinos-upgrade.log"
  # Create a fresh log section
  echo "--- Upgrade Session Started at $(date) ---" >> "$LOG_FILE"
  
  # Redirect stdout and stderr to tee, appending to the log file
  exec > >(tee -a "$LOG_FILE") 2>&1
  
  print_ok "Output is being logged to: $LOG_FILE"

  print_ok "Starting AnduinOS upgrade process..."
  
  echo -e "${Yellow}WARNING: This script will upgrade your system from 1.3.9 (plucky) to 1.4.2 (questing).${Font}"
  echo -e "${Yellow}Please ensure you have backed up important data before proceeding.${Font}"
  
  # Interactive check only if we have a terminal (TTY) and not in auto mode
  if [ -t 0 ] && [[ "$AUTO_UPGRADE" != "Y" ]] && [[ "$AUTO_UPGRADE" != "y" ]]; then
      read -p "Do you want to continue? (y/N): " confirm
      if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        print_error "Upgrade process aborted by user."
        exit 1
      fi
  elif [[ "$AUTO_UPGRADE" == "Y" ]] || [[ "$AUTO_UPGRADE" == "y" ]]; then
      print_ok "Auto-upgrade mode enabled, proceeding without confirmation."
  fi
  
  # Step 0: Check Safeguards
  check_ssh_safeguard

  # Step 1: Configure Unattended (Anti-Prompt)
  configure_unattended

  # Step 1: Check disk space
  check_disk_space
  
  # Step 2: Update current system
  update_system
  
  # Step 3: Backup Ubuntu official sources
  backup_ubuntu_sources
  
  # Step 4: Backup and remove PPA sources
  backup_and_remove_ppa
  
  # Step 5: Detect and convert APT format
  optimize_apt_sources
  
  # Step 6: Replace plucky with questing
  replace_plucky_with_questing
  
  # Step 7: Install coreutils-from-uutils
  install_coreutils_uutils
  
  # Step 8: Run dist-upgrade
  run_dist_upgrade
  
  # Step 9: Update release files (to 1.4.2)
  update_release_files
  
  # Step 10: Restore and upgrade PPA sources
  restore_and_upgrade_ppa_sources
  
  # Step 11: Cleanup system
  cleanup_system
  
  print_ok "Upgrade completed successfully!"
  print_ok "Your system has been upgraded to AnduinOS 1.4.2 (questing)"
  print_ok "Backup files are stored in: $BACKUP_DIR"
  print_warn "Please reboot your system to complete the upgrade."
}

main