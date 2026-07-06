#!/bin/bash

#=================================================
#           AnduinOS Upgrade Script
#=================================================
# This script upgrades AnduinOS from 1.3.x (plucky)
# to 2.0.0 (resolute).
#
# Usage:
# ./do_anduinos_distupgrade.sh
# (Script will auto-elevate to root/sudo)
#=================================================

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

# Current Upgrade Stage (plucky vs resolute)
CURRENT_STAGE="plucky"

# The Point of No Return flag.
# Once we start modifying on-disk packages, reverting APT sources is FATAL
# because it would create a "Franken-System" — new binaries with old repos.
POINT_OF_NO_RETURN="false"

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

# --- 4.5 GUI/Persistence Safeguard ---

function check_gui_safeguard() {
  # Skip check in auto-upgrade mode
  if [[ "$AUTO_UPGRADE" == "Y" ]] || [[ "$AUTO_UPGRADE" == "y" ]]; then
    print_ok "Auto-upgrade mode enabled, skipping persistence safeguard check."
    return
  fi

  # During the upgrade GDM/GNOME will be restarted.  If the script is
  # running inside a GUI terminal (gnome-terminal, xterm, etc.) that
  # terminal dies along with the session — killing the upgrade mid-flight.
  # screen/tmux detach from the GUI and survive.
  if [ -z "${STY:-}" ] && [ -z "${TMUX:-}" ] && [[ "${TERM:-}" != *"screen"* ]] && [[ "${TERM:-}" != *"tmux"* ]]; then
    print_warn "You are NOT running inside a screen or tmux session!"
    print_warn "During the upgrade, the graphical desktop (GDM/GNOME) WILL BE RESTARTED."
    print_warn "If you run this directly in a GUI terminal, the terminal will CLOSE"
    print_warn "mid-upgrade and CORRUPT your system."
    print_warn ""
    print_warn "  Recommended:  tmux new -s upgrade  (or  screen -S upgrade)"
    print_warn ""

    if [ -t 0 ]; then
        read -p "Are you absolutely sure you want to risk this? (y/N): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            print_error "Aborted. Please run 'tmux' or 'screen' first, then re-run this script."
            exit 1
        fi
    fi
  else
    print_ok "Running inside persistence (screen/tmux). Terminal will survive GUI restarts."
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

  # ── Check if we've already started modifying on-disk packages ──
  if [ "$POINT_OF_NO_RETURN" == "true" ]; then
    print_error "═══════════════════════════════════════════════════════════"
    print_error "  CRITICAL: Core packages have already been modified!"
    print_error "  Rolling back APT sources NOW WOULD DESTROY YOUR SYSTEM."
    print_error "  (It would create a Franken-System — new binaries, old repos.)"
    print_error "═══════════════════════════════════════════════════════════"
    print_warn ""
    print_warn "  ── EMERGENCY RECOVERY ──"
    print_warn "  1. DO NOT REBOOT."
    print_warn "  2. Fix interrupted package installations:"
    print_warn "     sudo dpkg --configure -a"
    print_warn "  3. Fix broken dependencies:"
    print_warn "     sudo apt-get --fix-broken install"
    print_warn "  4. Resume the upgrade:"
    print_warn "     sudo apt-get dist-upgrade"
    print_warn "  ─────────────────────────"
    print_error ""
    print_error "  Backup files are preserved in: $BACKUP_DIR"
    exit 1
  fi

  # ── Safe zone: no packages modified yet, source rollback is safe ──
  print_warn "Starting rollback procedure (safe mode — no packages modified yet)..."

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

  # Use the global CURRENT_STAGE variable to decide which codename to use (plucky vs resolute)
  # This prevents downgrading sources if fallback occurs during the upgrade phase.
  local codename="${CURRENT_STAGE:-plucky}"

  print_warn "Targeting distribution codename: $codename"
  generate_new_format "http://archive.ubuntu.com/ubuntu/" "$codename"

  print_ok "Switched to official mirror: archive.ubuntu.com ($codename)"
}

function apt_update_with_retry() {
  local max_attempts=10
  local attempt=1
  local wait_time=3

  while [ $attempt -le $max_attempts ]; do
    print_ok "Attempting apt update (attempt $attempt/$max_attempts)..."

    if apt update; then
      print_ok "apt update succeeded"
      return 0
    fi

    print_warn "apt update failed on attempt $attempt"

    # Run repair immediately on failure
    run_dpkg_repair

    # If this is the 2nd failure (or later), switch to official mirror to rule out bad mirrors early
    if [ $attempt -eq 2 ]; then
      print_warn "Repeat failure detected. Switching to official Ubuntu mirror as fallback..."
      switch_to_official_mirror
    fi

    if [ $attempt -lt $max_attempts ]; then
      print_ok "Waiting ${wait_time}s before retry..."
      sleep $wait_time
      # Cap wait time at 30s
      if [ $wait_time -lt 30 ]; then
        wait_time=$((wait_time * 2))
      fi
    fi

    attempt=$((attempt + 1))
  done

  print_error "apt update failed after $max_attempts attempts"
  return 1
}

function apt_upgrade_with_retry() {
  local max_attempts=10
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

    run_dpkg_repair

    if [ $attempt -eq 2 ]; then
        print_warn "Switching to official Ubuntu mirror as fallback..."
        switch_to_official_mirror
        apt_update_with_retry || return 1
    fi

    if [ $attempt -lt $max_attempts ]; then
      print_ok "Waiting ${wait_time}s before retry..."
      sleep $wait_time
      if [ $wait_time -lt 60 ]; then
          wait_time=$((wait_time * 2))
      fi
    fi

    attempt=$((attempt + 1))
  done

  print_error "apt upgrade failed after $max_attempts attempts"
  return 1
}

function apt_dist_upgrade_with_retry() {
  local max_attempts=20
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

    run_dpkg_repair

    # Fallback to official mirror early (attempt 2)
    if [ $attempt -eq 2 ]; then
      print_warn "Switching to official Ubuntu mirror as fallback..."
      switch_to_official_mirror
      apt_update_with_retry || return 1
    fi

    # Sometimes 404s are due to mirror sync delay, just waiting helps.
    # But aggressive retrying helps resume downloads.

    if [ $attempt -lt $max_attempts ]; then
      print_ok "Waiting ${wait_time}s before retry..."
      sleep $wait_time
      if [ $wait_time -lt 60 ]; then
         wait_time=$((wait_time * 2))
      fi
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

  print_ok "Removing any APT pinning that may block upgrades..."
  sudo rm /etc/apt/preferences.d/no-* 2>/dev/null || true
  judge "Remove APT pinning"

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

  # Enable required packages (refresh cache first in case the system is stale)
  apt update >&2 || true
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

function replace_plucky_with_resolute() {
  print_ok "Replacing plucky with resolute in ubuntu.sources..."

  if [ ! -f "/etc/apt/sources.list.d/ubuntu.sources" ]; then
    print_error "/etc/apt/sources.list.d/ubuntu.sources not found"
    rollback_on_error
  fi

  # Replace plucky (Ubuntu 25.04 base for 1.3.x) with resolute (Ubuntu 26.04 / AnduinOS 2.0).
  sed -i 's/plucky/resolute/g' /etc/apt/sources.list.d/ubuntu.sources

  # Update global stage so fallback works correctly from now on
  CURRENT_STAGE="resolute"
  print_ok "System is now targeting: $CURRENT_STAGE"

  judge "Replace plucky with resolute in sources"

  print_ok "Running apt update with resolute repositories (with retry)..."
  apt_update_with_retry
  judge "apt update with resolute repositories"
}

function install_coreutils_uutils() {
  print_ok "Installing coreutils-from-uutils..."

  DEBIAN_FRONTEND=noninteractive apt install -y coreutils-from-uutils
  judge "Install coreutils-from-uutils"
}

function cleanup_legacy_dkms() {
  # ── DKMS mine-sweeper ──
  # Kernel 6.x → 7.0 changes the C headers/API.  Any hand-installed
  # third-party DKMS module (xpadneo, anbox, rtl88x2bu, v4l2loopback,
  # etc.) will FAIL to compile against the new kernel headers.
  #
  # DKMS failures cascade: the kernel postinst hook runs `dkms autoinstall`,
  # the build dies, dpkg marks linux-image-* as half-configured, and APT
  # enters a deadlock where NO package can be installed/removed until the
  # kernel is "fixed" — which can never happen because the old C code will
  # never magically become compatible.
  #
  # Strategy: rip out every non-NVIDIA DKMS module BEFORE the kernel
  # upgrade.  Users can reinstall compatible versions later.
  # ───────────────────────────────────────────────────────────────
  print_ok "Scanning for legacy third-party DKMS modules..."

  if command -v dkms &> /dev/null; then
    while read -r line; do
      # Skip NVIDIA (official driver has Kernel-7-compatible versions)
      if [[ "$line" == *"nvidia"* ]]; then
        continue
      fi

      local module_name=$(echo "$line" | awk -F', ' '{print $1}')
      local module_version=$(echo "$line" | awk -F', ' '{print $2}' | awk '{print $1}')

      if [ -n "$module_name" ] && [ -n "$module_version" ]; then
        print_warn "Removing risky DKMS module: $module_name/$module_version"
        dkms remove "$module_name/$module_version" --all 2>/dev/null || true
        rm -rf "/var/lib/dkms/$module_name" 2>/dev/null || true
      fi
    done < <(dkms status)

    print_ok "Legacy DKMS cleanup complete."
  else
    print_ok "DKMS not installed. Skipping DKMS cleanup."
  fi
}

function run_dist_upgrade() {
  # ═══════════════════════════════════════════════════════════════
  # CROSSING THE RUBICON
  # Once we pass this point, core packages are being modified on disk.
  # Restoring old APT sources after this would create a Franken-System
  # (new binaries + old repos = unfixable dependency hell).
  # ═══════════════════════════════════════════════════════════════
  POINT_OF_NO_RETURN="true"
  print_warn "Crossing the point of no return — package modifications beginning..."
  print_warn "From here on, failures will NOT roll back APT sources (that would be fatal)."

  # Sweep legacy DKMS modules before the kernel upgrade
  cleanup_legacy_dkms

  # ── Phase 1: Minimal upgrade (upgrade existing pkgs, NO new pkgs) ──
  # This solves the "apt resolver gap".  The old (24.10) apt cannot
  # resolve 26.04 transitions like sudo→sudo-rs.  By upgrading apt,
  # dpkg and libc6 first WITHOUT introducing new packages we give the
  # system a 26.04-grade dependency solver.
  print_ok "Phase 1: Running minimal upgrade to stabilize APT and core libraries..."
  if bash -c 'DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a APT_LISTCHANGES_FRONTEND=none \
    apt-get -y upgrade --without-new-pkgs \
    -o Dpkg::Options::="--force-confdef" \
    -o Dpkg::Options::="--force-confold"'; then
    print_ok "Minimal upgrade succeeded"
  else
    print_warn "Minimal upgrade encountered issues, running dpkg repair..."
    run_dpkg_repair
  fi

  # ── Phase 2: Pre-resolve the sudo → sudo-rs transition ──
  # Ubuntu 26.04 replaces the 40-year-old C-language `sudo` with
  # Rust-based `sudo-rs`.  The old resolver chokes on this with:
  #   "Conf Broken sudo-common:amd64"
  # By installing the new trio manually we unblock dist-upgrade.
  print_ok "Phase 2: Pre-resolving Ubuntu 26.04 critical transition (sudo -> sudo-rs)..."
  DEBIAN_FRONTEND=noninteractive apt-get install -y sudo-common sudo-rs sudo || true

  # ── Phase 3: Full dist-upgrade with retry ──
  print_ok "Phase 3: Running full apt-get dist-upgrade with retry logic..."

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
  print_ok "Updating release information files to 2.0.0..."

  # Update /etc/os-release
  if [ -f "/etc/os-release" ]; then
    print_ok "Updating /etc/os-release..."
    bash -c "cat > /etc/os-release" <<EOF
PRETTY_NAME="AnduinOS 2.0.0"
NAME="AnduinOS"
VERSION_ID="2.0.0"
VERSION="2.0.0 (resolute)"
VERSION_CODENAME=resolute
ID=anduinos
ID_LIKE=debian
HOME_URL="https://www.anduinos.com/"
SUPPORT_URL="https://github.com/Anduin2017/AnduinOS/discussions"
BUG_REPORT_URL="https://github.com/Anduin2017/AnduinOS/issues"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=resolute
EOF

    judge "Update /etc/os-release"
  fi

  # Update /etc/lsb-release
  if [ -f "/etc/lsb-release" ]; then
    print_ok "Updating /etc/lsb-release..."

    bash -c "cat > /etc/lsb-release" <<EOF
DISTRIB_ID=AnduinOS
DISTRIB_RELEASE=2.0.0
DISTRIB_CODENAME=resolute
DISTRIB_DESCRIPTION="AnduinOS 2.0.0"
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
              # We use a silent check with timeout to verify if the new resolute dist exists
              if curl -s -I -f -L --max-time 3 "$url/dists/resolute/Release" &>/dev/null || \
                 curl -s -I -f -L --max-time 3 "$url/dists/resolute/InRelease" &>/dev/null; then
                 can_upgrade=true
              fi
            fi

            if $can_upgrade; then
              sed -i 's/plucky/resolute/g' "$file"
              print_ok "Upgraded PPA $ppa_name to resolute"
              ((upgraded_count++))
            else
              print_warn "PPA $ppa_name does not support 'resolute' yet (Connection failed or 404)."
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


function install_anduinos2_packages() {
  # Variables for APT repository and GPG key
  APKG_SERVER="https://packages.anduinos.com"
  CERT_NAME="anduinos"
  KEYRING_PATH="/usr/share/keyrings/anduinos-archive-keyring.gpg"
  SUITE="$(lsb_release -sc)-addon"

  # Update package lists and install prerequisites
  sudo apt update
  sudo apt install -y curl gnupg2 ca-certificates

  # Create the keyring directory and download the AnduinOS GPG key
  print_ok "Adding AnduinOS APT repository and GPG key..."
  sudo mkdir -p /usr/share/keyrings
  curl -sL "${APKG_SERVER}/artifacts/certs/${CERT_NAME}" \
      | sed '1s/^\xEF\xBB\xBF//' \
      | gpg --dearmor \
      | sudo tee "${KEYRING_PATH}" > /dev/null
  judge "Add AnduinOS GPG key"

  print_ok "Adding AnduinOS repository to APT sources..."
  sudo tee /etc/apt/sources.list.d/anduinos.sources > /dev/null <<EOF
Types: deb
URIs: ${APKG_SERVER}/artifacts/anduinos/
Suites: ${SUITE}
Components: main
Architectures: amd64
Signed-By: ${KEYRING_PATH}
EOF
  judge "Add AnduinOS repository"

  sudo apt update

  # ═══════════════════════════════════════════════════════════════════
  # Grand Unification — one apt-get invocation to rule them all.
  #
  # Why a single command?  APT's dependency resolver sees the ENTIRE
  # picture at once.  Splitting across multiple apt-get calls forces
  # it to re-solve an incomplete state each time, which creates
  # "hostage situations" (plymouth won't upgrade because it would
  # remove anduinos-desktop, etc.).
  #
  # This single invocation:
  #   -o Dpkg::Options::="--force-overwrite"   → clobber Ubuntu-owned files
  #   -o Dpkg::Options::="--force-confnew"      → nuke 1.4 imperative hacks
  #   -o APT::Get::Always-Include-Phased-Updates → ignore Canonical phasing
  #   --allow-downgrades / --allow-change-held-packages → full freedom
  #
  # The remove-list (trailing -) includes the three "hostage-takers"
  # that caused the 3 AM shovel session:
  #   plymouth-theme-ubuntu-text-  packagekit-tools-  libavcodec-extra-
  # ═══════════════════════════════════════════════════════════════════
  print_ok "Executing Grand Unification: installing AnduinOS, GNOME 50, and wiping Ubuntu conflicts..."
  DEBIAN_FRONTEND=noninteractive sudo apt-get install -y \
      --allow-downgrades \
      --allow-change-held-packages \
      -o Dpkg::Options::="--force-overwrite" \
      -o Dpkg::Options::="--force-confnew" \
      -o APT::Get::Always-Include-Phased-Updates=true \
      coreutils-from-uutils \
      gnome-shell gdm3 mutter-common python3 libadwaita-1-0 gnome-control-center gnome-session \
      anduinos-desktop anduinos-desktop-apps anduinos-gnome-extensions \
      anduinos-appstore anduinos-theme anduinos-wallpapers anduinos-fonts \
      anduinos-no-snapd anduinos-session \
      anduinos-software-properties-common/resolute-addon \
      anduinos-software-properties-gtk/resolute-addon \
      anduinos-system-tweaks firefox-anduinos \
      gnome-shell-extension-appindicator-anduinos \
      gnome-shell-extension-dash-to-panel-anduinos \
      gnome-shell-extension-desktop-icons-ng-anduinos \
      plymouth-anduinos alsa-ucm-conf-anduinos firmware-sof-anduinos initramfs-tools \
      snapd- firefox- ubuntu-session- ubuntu-desktop- ubiquity-slideshow-ubuntu- \
      yaru-theme-gnome-shell- gnome-shell-ubuntu-extensions- update-notifier- \
      update-notifier-common- update-manager- update-manager-core- \
      ubuntu-release-upgrader-core- ubuntu-release-upgrader-gtk- whoopsie- \
      software-properties-gtk- software-properties-common- firmware-sof-signed- \
      alsa-ucm-conf- plymouth-theme-spinner- gnome-shell-extension-appindicator- \
      gnome-shell-extension-dash-to-panel- gnome-shell-extension-desktop-icons-ng- \
      ubuntu-wallpapers- ubuntu-advantage-desktop-daemon- ubuntu-pro-client- \
      ubuntu-wallpapers-resolute- \
      plymouth-theme-ubuntu-text- packagekit-tools- libavcodec-extra- \
      mesa-va-drivers- \
      --install-recommends
  judge "Grand Unification installation"

  print_ok "Reinstalling base-files to ensure correct release information..."
  DEBIAN_FRONTEND=noninteractive sudo apt-get install -y --reinstall \
      --allow-downgrades \
      --allow-change-held-packages \
      -o Dpkg::Options::="--force-overwrite" \
      -o Dpkg::Options::="--force-confnew" \
      -o APT::Get::Always-Include-Phased-Updates=true \
      base-files/resolute-addon anduinos-apt-config/resolute-addon
  judge "Reinstall base-files"

  print_ok "Purging orphaned dependencies and old ABI libraries..."
  sudo apt-get autoremove --purge -y
  judge "Cleanup unused packages and cache"

  print_ok "Updating dconf settings to apply AnduinOS defaults..."
  sudo dconf update
  judge "Update dconf settings"

  print_ok "AnduinOS 2.0 packages installed and sealed successfully!"
}

function cleanup_system() {
  # Final aggressive sweep — `apt full-upgrade` uses a more aggressive
  # resolver than `apt-get dist-upgrade`.  It will forcefully remove
  # old blocking packages (like mesa-va-drivers) that would otherwise
  # hold the entire Mesa display stack hostage.
  print_ok "Performing final aggressive full-upgrade sweep..."
  DEBIAN_FRONTEND=noninteractive sudo apt \
      -o APT::Get::Always-Include-Phased-Updates=true \
      -o Dpkg::Options::="--force-overwrite" \
      -o Dpkg::Options::="--force-confnew" \
      full-upgrade -y || true

  print_ok "Removing unused packages (orphans)..."
  if apt autoremove --purge -y; then
    print_ok "apt autoremove succeeded"
  else
    print_warn "apt autoremove failed, but upgrade was successful."
  fi

  # ── Purge orphaned Ubuntu transitional packages ──
  # These are packages that became orphans during the upgrade because their
  # real dependencies (e.g., snap-based firefox) were replaced by AnduinOS
  # equivalents (e.g., firefox-anduinos).  apt autoremove may not catch them
  # if they were installed as part of language-packs or tasks.
  print_ok "Purging orphaned Ubuntu transitional packages..."
  # firefox-locale-* are transitional dummy packages for snap-based firefox
  if dpkg -l 2>/dev/null | grep -q '^ii.*firefox-locale-'; then
      dpkg -l | grep '^ii.*firefox-locale-' | awk '{print $2}' | xargs -r sudo apt-get purge -y
      print_ok "Purged orphaned firefox-locale-* transitional packages"
  fi
  # tracker-extract is a transitional package replaced by localsearch (Ubuntu 26.04)
  if dpkg -l 2>/dev/null | grep -q '^ii.*tracker-extract'; then
      sudo apt-get purge -y tracker-extract
      print_ok "Purged orphaned tracker-extract transitional package"
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

  echo -e "${Yellow}WARNING: This script will upgrade your system from 1.3.x (plucky) to 2.0.0 (resolute).${Font}"
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
  check_gui_safeguard

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

  # Step 6: Replace plucky with resolute
  replace_plucky_with_resolute

  # Step 7: Run dist-upgrade (stabilize the base system first)
  run_dist_upgrade

  # Step 8: Update release files (to 2.0.0)
  update_release_files

  # Step 9: Install AnduinOS 2.0 packages (coreutils, desktop, branding, app ecosystem)
  install_anduinos2_packages

  # Step 10: Restore and upgrade PPA sources
  restore_and_upgrade_ppa_sources

  # Step 11: Cleanup system
  cleanup_system

  print_ok "Upgrade completed successfully!"
  print_ok "Your system has been upgraded to AnduinOS 2.0.0 (resolute)"
  print_ok "Backup files are stored in: $BACKUP_DIR"
  print_warn "Please reboot your system to complete the upgrade."
}

main
