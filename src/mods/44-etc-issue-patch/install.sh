print_ok "Updating /etc/issue"
cat << EOF > /etc/issue
$TARGET_BUSINESS_NAME $TARGET_BUILD_VERSION \n \l

EOF
judge "Update /etc/issue"

print_ok "Updating /etc/issue.net"
cat << EOF > /etc/issue.net
$TARGET_BUSINESS_NAME $TARGET_BUILD_VERSION
EOF
judge "Update /etc/issue.net"