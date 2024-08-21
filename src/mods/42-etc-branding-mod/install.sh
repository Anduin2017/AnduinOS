print_ok "Customization complete. Updating lsb/os-release files"
cat << EOF > /etc/lsb-release
DISTRIB_ID=$TARGET_BUSINESS_NAME
DISTRIB_RELEASE=$TARGET_BUILD_VERSION
DISTRIB_CODENAME=$TARGET_UBUNTU_VERSION
DISTRIB_DESCRIPTION="$TARGET_BUSINESS_NAME $TARGET_BUILD_VERSION"
EOF
judge "Update lsb-release"

cat << EOF > /etc/os-release
PRETTY_NAME="$TARGET_BUSINESS_NAME $TARGET_BUILD_VERSION"
NAME="$TARGET_BUSINESS_NAME"
VERSION_ID="$TARGET_BUILD_VERSION"
VERSION="$TARGET_BUILD_VERSION ($TARGET_UBUNTU_VERSION)"
VERSION_CODENAME=$TARGET_UBUNTU_VERSION
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.anduinos.com/"
SUPPORT_URL="https://github.com/Anduin2017/AnduinOS/discussions"
BUG_REPORT_URL="https://github.com/Anduin2017/AnduinOS/issues"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=$TARGET_UBUNTU_VERSION
EOF
judge "Update os-release"