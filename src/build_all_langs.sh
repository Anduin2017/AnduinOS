#!/bin/bash
set -e                  # Exit immediately if any command returns a non-zero status
set -o pipefail         # If any command in a pipeline fails, the entire pipeline fails
set -u                  # Treat unset variables as an error

# Clean up old files
sudo rm -rf ./dist/*

# Define language modes and corresponding language pack codes
LANG_MODES=(     "en_US" "zh_CN" "zh_TW" "zh_HK" "ja_JP" "ko_KR" "vi_VN" "th_TH" "de_DE" "fr_FR" "es_ES" "ru_RU" "it_IT" "pt_PT" "pt_BR" "ar_SA" "nl_NL" "sv_SE" "pl_PL" "tr_TR")
LANG_PACK_CODES=("en"    "zh"     "zh"   "zh"    "ja"    "ko"    "vi"    "th"    "de"    "fr"    "es"    "ru"    "it"    "pt"    "pt"    "ar"    "nl"    "sv"    "pl"    "tr")

# Check if the required files exist
if [[ ! -f "args.sh" || ! -f "build.sh" ]]; then
  echo "Error: args.sh or build.sh does not exist."
  exit 1
fi

# Build for different languages
for i in "${!LANG_MODES[@]}"; do
  LANG_MODE="${LANG_MODES[$i]}"
  LANG_CODE="${LANG_PACK_CODES[$i]}"

  # Update language environment
  sed -i "s/^export LANG_MODE=\".*\"/export LANG_MODE=\"${LANG_MODE}\"/" args.sh
  sed -i "s/^export LANG_PACK_CODE=\".*\"/export LANG_PACK_CODE=\"${LANG_CODE}\"/" args.sh

  echo "=============================================="
  echo "Starting build, Language mode: ${LANG_MODE}, Language code: ${LANG_CODE}"
  echo "=============================================="

  # Execute build
  ./build.sh
done

echo "All build tasks have been completed."
