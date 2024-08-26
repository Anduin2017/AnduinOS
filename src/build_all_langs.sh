#!/bin/bash

LANG_MODES=(     "en_US" "zh_CN" "zh_TW" "zh_HK" "ja_JP" "ko_KR" "de_DE" "fr_FR" "es_ES" "ru_RU" "it_IT" "pt_PT" "vi_VN" "th_TH" "ar_SA" "nl_NL" "sv_SE" "pl_PL" "tr_TR")
LANG_PACK_CODES=("en"    "zh"     "zh"   "zh"    "ja"    "ko"    "de"    "fr"    "es"    "ru"    "it"    "pt"    "vi"    "th"    "ar"    "nl"    "sv"    "pl"    "tr")

if [[ ! -f "args.sh" || ! -f "build.sh" ]]; then
  echo "Error: args.sh or build.sh not found."
  exit 1
fi

for i in "${!LANG_MODES[@]}"; do
  sed -i "s/^export LANG_MODE=\".*\"/export LANG_MODE=\"${LANG_MODES[$i]}\"/" args.sh
  sed -i "s/^export LANG_PACK_CODE=\".*\"/export LANG_PACK_CODE=\"${LANG_PACK_CODES[$i]}\"/" args.sh
  echo "Running build.sh for LANG_MODE=${LANG_MODES[$i]} and LANG_PACK_CODE=${LANG_PACK_CODES[$i]}"
  ./build.sh
done
