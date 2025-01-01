#!/usr/bin/env bash

POT_HEADER=$(cat <<'EOF'
msgid ""
msgstr ""
"Project-Id-Version: loc@anduinos.com\n"
"Report-Msgid-Bugs-To: \n"
"POT-Creation-Date: 2025-01-01 00:00+0000\n"
"Last-Translator: \n"
"Language-Team: \n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"
"Plural-Forms: nplurals=2; plural=(n != 1);\n"
EOF
)

function po_content_en_US() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "Location Services"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "Privacy Settings"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "Failed to open Privacy Settings: %s"
EOF
}

function po_content_zh_CN() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "位置服务"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "隐私设置"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "无法打开隐私设置：%s"
EOF
}

function po_content_zh_TW() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "位置服務"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "隱私設定"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "無法打開隱私設定：%s"
EOF
}

function po_content_zh_HK() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "位置服務"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "私隱設定"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "無法開啟私隱設定：%s"
EOF
}

function po_content_ja_JP() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "位置情報サービス"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "プライバシー設定"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "プライバシー設定を開けませんでした: %s"
EOF
}

function po_content_ko_KR() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "위치 서비스"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "개인 정보 보호 설정"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "개인 정보 보호 설정을 열 수 없습니다: %s"
EOF
}

function po_content_vi_VN() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "Dịch vụ vị trí"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "Cài đặt quyền riêng tư"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "Không thể mở Cài đặt quyền riêng tư: %s"
EOF
}

function po_content_th_TH() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "บริการระบุตำแหน่ง"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "การตั้งค่าความเป็นส่วนตัว"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "ไม่สามารถเปิดการตั้งค่าความเป็นส่วนตัวได้: %s"
EOF
}

function po_content_de_DE() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "Standortdienste"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "Datenschutzeinstellungen"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "Datenschutzeinstellungen konnten nicht geöffnet werden: %s"
EOF
}

function po_content_fr_FR() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "Services de localisation"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "Paramètres de confidentialité"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "Impossible d’ouvrir les paramètres de confidentialité : %s"
EOF
}

function po_content_es_ES() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "Servicios de ubicación"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "Configuración de privacidad"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "No se pudo abrir la Configuración de privacidad: %s"
EOF
}

function po_content_ru_RU() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "Службы определения местоположения"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "Настройки конфиденциальности"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "Не удалось открыть настройки конфиденциальности: %s"
EOF
}

function po_content_it_IT() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "Servizi di localizzazione"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "Impostazioni sulla privacy"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "Impossibile aprire le impostazioni sulla privacy: %s"
EOF
}

function po_content_pt_BR() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "Serviços de localização"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "Configurações de privacidade"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "Não foi possível abrir as configurações de privacidade: %s"
EOF
}

function po_content_pt_PT() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "Serviços de localização"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "Definições de privacidade"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "Não foi possível abrir as definições de privacidade: %s"
EOF
}

function po_content_ar_SA() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "خدمات الموقع"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "إعدادات الخصوصية"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "تعذّر فتح إعدادات الخصوصية: %s"
EOF
}

function po_content_nl_NL() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "Locatiediensten"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "Privacy-instellingen"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "Kon privacy-instellingen niet openen: %s"
EOF
}

function po_content_sv_SE() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "Platstjänster"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "Sekretessinställningar"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "Det gick inte att öppna sekretessinställningar: %s"
EOF
}

function po_content_pl_PL() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "Usługi lokalizacji"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "Ustawienia prywatności"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "Nie można otworzyć ustawień prywatności: %s"
EOF
}

function po_content_tr_TR() {
cat <<EOF

#: extension.js:21 extension.js:24
msgid "Location Services"
msgstr "Konum Servisleri"

#: extension.js:35 extension.js:46
msgid "Privacy Settings"
msgstr "Gizlilik Ayarları"

#: extension.js:48
msgid "Failed to open Privacy Settings: %s"
msgstr "Gizlilik Ayarları açılamadı: %s"
EOF
}

function generate_mo_for_lang() {
    local LOCALE="$1"
    local FUNC_NAME="po_content_${LOCALE//-/_}"

    mkdir -p "./locale/$LOCALE/LC_MESSAGES"
    local TMP_PO="/tmp/loc@anduinos.com.${LOCALE}.po"

    {
        echo "$POT_HEADER"
        $FUNC_NAME
    } > "$TMP_PO"

    msgfmt "$TMP_PO" -o "./locale/$LOCALE/LC_MESSAGES/loc@anduinos.com.mo"
    rm -f "$TMP_PO"
}

function generate_all_mo() {
    for LOCALE in en_US zh_CN zh_TW zh_HK ja_JP ko_KR vi_VN th_TH de_DE fr_FR es_ES ru_RU it_IT pt_BR pt_PT ar_SA nl_NL sv_SE pl_PL tr_TR
    do
        echo "Generating .mo for $LOCALE ..."
        generate_mo_for_lang "$LOCALE"
    done
}

# Uncomment to generate all .mo files at once:
generate_all_mo
