# Get DISTRIB_RELEASE
CURRENT_VERSION=$(cat /etc/os-release | grep DISTRIB_RELEASE | cut -d "=" -f 2)
LATEST_VERSION="0.1.1-beta"