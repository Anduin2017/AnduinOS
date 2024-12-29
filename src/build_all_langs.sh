#!/bin/bash
set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# Clean up.
sudo rm ./dist/*

# Define language modes and language pack codes
LANG_MODES=(     "en_US" "zh_CN" "zh_TW" "zh_HK" "ja_JP" "ko_KR" "vi_VN" "th_TH" "de_DE" "fr_FR" "es_ES" "ru_RU" "it_IT" "pt_PT" "pt_BR" "ar_SA" "nl_NL" "sv_SE" "pl_PL" "tr_TR")
LANG_PACK_CODES=("en"    "zh"     "zh"   "zh"    "ja"    "ko"    "vi"    "th"    "de"    "fr"    "es"    "ru"    "it"    "pt"    "pt"    "ar"    "nl"    "sv"    "pl"    "tr")

# Define versions, code names, and kernels
VERSIONS=(  "1.1.0"                    "1.2.0")
CODE_NAME=( "noble"                    "oracular")
KERNELS=(   "linux-generic-hwe-24.04"  "linux-generic-hwe-24.04")

# Check if required files exist
if [[ ! -f "args.sh" || ! -f "build.sh" ]]; then
  echo "Error: args.sh or build.sh not found."
  exit 1
fi

# Check if the lengths of VERSIONS, CODE_NAME, and KERNELS arrays are consistent
if [[ ${#VERSIONS[@]} -ne ${#CODE_NAME[@]} || ${#VERSIONS[@]} -ne ${#KERNELS[@]} ]]; then
  echo "Error: The lengths of VERSIONS, CODE_NAME, and KERNELS arrays are inconsistent."
  exit 1
fi

# Record the total number of builds
TOTAL_BUILDS=$(( ${#VERSIONS[@]} * ${#LANG_MODES[@]} ))
CURRENT_BUILD=1

# Outer loop iterates over each version
for i in "${!VERSIONS[@]}"; do
  VERSION="${VERSIONS[$i]}"
  CODE="${CODE_NAME[$i]}"
  KERNEL="${KERNELS[$i]}"

  # Update the version, code name, and kernel in args.sh
  sed -i "s/^export TARGET_BUILD_VERSION=\".*\"/export TARGET_BUILD_VERSION=\"${VERSION}\"/" args.sh
  sed -i "s/^export TARGET_UBUNTU_VERSION=\".*\"/export TARGET_UBUNTU_VERSION=\"${CODE}\"/" args.sh
  sed -i "s/^export TARGET_KERNEL_PACKAGE=\".*\"/export TARGET_KERNEL_PACKAGE=\"${KERNEL}\"/" args.sh

  echo "=============================================="
  echo "Starting build for Version: ${VERSION}, Code Name: ${CODE}, Kernel: ${KERNEL}"
  echo "=============================================="

  # Inner loop iterates over each language mode
  for j in "${!LANG_MODES[@]}"; do
    LANG_MODE="${LANG_MODES[$j]}"
    LANG_CODE="${LANG_PACK_CODES[$j]}"

    # Update the language mode and language code in args.sh
    sed -i "s/^export LANG_MODE=\".*\"/export LANG_MODE=\"${LANG_MODE}\"/" args.sh
    sed -i "s/^export LANG_PACK_CODE=\".*\"/export LANG_PACK_CODE=\"${LANG_CODE}\"/" args.sh

    # Build identifier
    BUILD_IDENTIFIER="${VERSION}-${CODE}-${KERNEL}-${LANG_MODE}"
    echo "Build progress ${CURRENT_BUILD}/${TOTAL_BUILDS}: ${BUILD_IDENTIFIER}"
    
    # Execute build
    ./build.sh

    ((CURRENT_BUILD++))
  done
done

echo "All build tasks have been completed."
