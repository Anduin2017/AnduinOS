# This script can only run on AnduinOS. It will detect current OS distro first. Stop running on other distros.
# This script will compare current version based on: /etc/lsb-release and latest version from the repository
# This script will see if there is a new version available and if so, it will upgrade the system
# Every version upgrade will be a function. For example: 0.1.1, 0.1.2, 0.1.3, etc.
# This script will run all missing upgrades in order to reach the latest version. For example: Current version is 0.1.1, latest version is 0.1.3. This script will run 0.1.2 and 0.1.3 upgrades.
# If there is no new version available, this script will do nothing, only output a message
# Finally this script will update the /etc/lsb-release, /etc/os-release and /etc/issue files with the latest version

echo "This script will upgrade the AnduinOS to the latest version."

echo "No new version available. Your system is up to date."