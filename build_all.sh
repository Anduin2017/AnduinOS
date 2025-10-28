#!/bin/bash
#
# Usage examples:
#   ./build_all.sh -c ./config/all.json     # Builds for all languages
#   ./build_all.sh -c ./config/fast.json    # Builds only en_US and zh_CN
#
set -e                  # Exit immediately if any command returns a non-zero status
set -o pipefail         # If any command in a pipeline fails, the entire pipeline fails
set -u                  # Treat unset variables as an error

# -----------------------------------------------------------------------------
# 1. Parse input argument for configuration file
# -----------------------------------------------------------------------------
CONFIG_JSON="./config/all.json"  # Default config file

while [[ $# -gt 0 ]]; do
  case "$1" in
    -c|--config)
      CONFIG_JSON="$2"
      echo "[INFO] Using configuration file '$CONFIG_JSON'."
      shift 2
      ;;
    *)
      echo "[ERROR] Usage: $0 -c <config.json>"
      exit 1
      ;;
  esac
done

if [[ ! -f "$CONFIG_JSON" ]]; then
  echo "[ERROR] Configuration file $CONFIG_JSON does not exist."
  exit 1
fi

# -----------------------------------------------------------------------------
# 2. Check if jq is installed, install if not
# -----------------------------------------------------------------------------
if ! command -v jq &> /dev/null; then
  echo "[INFO] Installing jq for JSON parsing..."
  sudo apt-get update && sudo apt-get install -y jq
fi

# Load languages
selected_languages=$(jq -c '.' "$CONFIG_JSON")

# -----------------------------------------------------------------------------
# 3. Cleanup old files
# -----------------------------------------------------------------------------
echo "[INFO] Removing old distribution files..."
sudo rm -rf ./src/dist/*

# -----------------------------------------------------------------------------
# 4. Check for required files
# -----------------------------------------------------------------------------
if [[ ! -f "./src/args.sh" || ! -f "./src/build.sh" ]]; then
  echo "[ERROR] ./src/args.sh or ./src/build.sh does not exist."
  exit 1
fi

# -----------------------------------------------------------------------------
# 5. Build loop for selected languages with retry mechanism
# -----------------------------------------------------------------------------
# Get the count of languages from the selected_languages JSON array
lang_count=$(echo "$selected_languages" | jq '. | length')

for ((i=0; i<lang_count; i++)); do
  # Extract language information from JSON
  lang_info=$(echo "$selected_languages" | jq -c ".[$i]")
  
  # Display summary of the current language for logging
  LANG_MODE=$(echo "$lang_info" | jq -r '.lang_mode')
  echo "================================================="
  echo "[INFO] Starting build -> LANG_MODE: ${LANG_MODE}"
  echo "Current language configuration:"
  echo "$lang_info" | jq '.'
  echo "================================================="
  
  # Dynamically update all fields in ./src/args.sh
  # Get all keys from the current language configuration
  keys=$(echo "$lang_info" | jq -r 'keys[]')
  
  # For each key, update the corresponding environment variable in ./src/args.sh
  for key in $keys; do
    # Convert key to uppercase for environment variable naming
    env_var=$(echo "$key" | tr '[:lower:]' '[:upper:]')
    # Get the value and escape any special characters
    value=$(echo "$lang_info" | jq -r --arg k "$key" '.[$k]')
    escaped_value=$(echo "$value" | sed 's/[\/&]/\\&/g')
    sed -i "s|^export ${env_var}=\".*\"|export ${env_var}=\"${escaped_value}\"|" ./src/args.sh
  done

  # Initialize retry parameters
  MAX_RETRIES=3
  attempt=1

  while [ $attempt -le $MAX_RETRIES ]; do
    echo "[INFO] Build attempt $attempt for LANG_MODE: ${LANG_MODE}"
    
    # cd ./src and run the build script
    if ./src/build.sh; then
      echo "[INFO] Build succeeded for LANG_MODE: ${LANG_MODE} on attempt $attempt."
      break
    else
      echo "[WARNING] Build failed for LANG_MODE: ${LANG_MODE} on attempt $attempt."
      if [ $attempt -lt $MAX_RETRIES ]; then
        echo "[INFO] Retrying build for LANG_MODE: ${LANG_MODE}..."
        attempt=$((attempt + 1))
      else
        echo "[ERROR] Build failed after $MAX_RETRIES attempts for LANG_MODE: ${LANG_MODE}."
        echo "[ERROR] Stopping build process and waiting for manual intervention."
        sleep 99999999
      fi
    fi
  done
done

echo "[INFO] All build tasks have been completed."
echo "[INFO] Generating torrent files..."

shopt -s extglob

(
  cd ./src/dist || exit 1
  sudo apt install -y mktorrent

  for f in AnduinOS-*-+([0-9]).@(iso|sha256); do
    mv -- "$f" "${f%-+([0-9]).@(iso|sha256)}.${f##*.}"
  done

  shopt -u extglob

  tracker=$(mktemp)
  curl -fsSL -o "$tracker" \
    https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best.txt

  mapfile -t raw_trackers < "$tracker"
  rm "$tracker"

  trackers=()
  for t in "${raw_trackers[@]}"; do
    [[ -n "$t" ]] && trackers+=( -a "$t" )
  done

  for iso in AnduinOS-*.iso; do
    base="${iso%.iso}"
    echo "[INFO] Generating torrent for $iso"
    echo "[INFO] Using trackers: ${trackers[@]}"
    mktorrent "${trackers[@]}" -o "${base}.torrent" "$iso"
  done
)