set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# | Group               | Language Codes                                                            | Sans-serif             | Serif                  | Monospace                                      | Description                                                                            |
# |---------------------|---------------------------------------------------------------------------|------------------------|------------------------|-------------------------------------------------|----------------------------------------------------------------------------------------|
# | Simplified Chinese  | `zh_CN`                                                                   | Noto Sans CJK SC       | Noto Serif CJK SC      | Noto Sans Mono CJK SC                           | `lang=zh_CN`, prepend-strong: use SC CJK variants for Chinese                          |
# | Traditional Chinese | `zh_TW`, `zh_HK`                                                          | Noto Sans CJK TC/HK    | Noto Serif CJK TC      | Noto Sans Mono CJK TC                           | `lang=zh_TW/zh_HK`, prepend-strong: use TC/HK variants for Traditional Chinese         |
# | Japanese            | `ja`, `ja_JP`                                                             | Noto Sans CJK JP       | Noto Serif CJK JP      | Noto Sans Mono CJK JP                           | `lang=ja`, prepend-strong: use JP variants for Japanese                                |
# | Korean              | `ko`, `ko_KR`                                                             | Noto Sans CJK KR       | Noto Serif CJK KR      | Noto Sans Mono CJK KR                           | `lang=ko`, prepend-strong: use KR variants for Korean                                  |
# | Thai                | `th`, `th_TH`                                                             | Noto Sans Thai         | Noto Serif Thai        | Cascadia Code                                  | `lang=th`, prepend-strong: use Thai fonts; code blocks → Cascadia Code                 |
# | Arabic              | `ar`, `ar_SA`                                                             | Noto Naskh Arabic      | Noto Naskh Arabic      | Cascadia Code                                  | `lang=ar`, prepend-strong: use Naskh Arabic; code blocks → Cascadia Code               |
# | Latin & Cyrillic    | `en_US`, `en_GB`, `de_DE`, `fr_FR`, `es_ES`, `it_IT`, `pt_BR`, `pt_PT`, `nl_NL`, `sv_SE`, `pl_PL`, `tr_TR`, `vi_VN`, `ru_RU`, `ro_RO` | Noto Sans               | Noto Serif             | Cascadia Code                                  | `lang contains X`, prepend-strong: use pure Latin/Cyrillic fonts before CJK to fix punctuation |
# | Generic fallback    | *                                                                           | Noto Sans CJK SC       | Noto Serif CJK SC      | Noto Sans Mono CJK SC + Symbols Nerd Font + Twitter Color Emoji | default sans/serif/mono rules for all other or mixed content                           |

print_ok "Patching fonts..."
cp ./local.conf /etc/fonts/
unzip -q -O UTF-8 ./fonts.zip -d /usr/share/fonts/
judge "Patch fonts"

print_ok "Updating font cache"
fc-cache -f
judge "Update font cache"
