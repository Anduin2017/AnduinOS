set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# This link needs to be updated regularly.
# This binary need to mirror from: 
# https://github.com/thesofproject/sof-bin/releases/download/v2025.12/sof-bin-2025.12.tar.gz
SOF_BIN_LINK="https://pub.aiursoft.com/sof-bin-2025.12.tar.gz"
ALSA_UCM_CONF_LINK="https://git.aiursoft.com/PublicVault/alsa-ucm-conf/archive/master.zip"

(
    print_ok "Installing Intel SOF Mod"
    tempdir=$(mktemp -d)

    print_ok "Preparing installation directory $tempdir"
    cd "$tempdir" || exit 1

    print_ok "Downloading SOF binaries"
    wget "$SOF_BIN_LINK" -O sof-bin.tar.gz
    judge "Downloaded SOF binaries"

    print_ok "Extracting SOF binaries"
    tar -xzf sof-bin.tar.gz
    judge "Extracted SOF binaries"

    print_ok "Removing old SOF binaries"
    rm -rf /lib/firmware/intel/sof*
    rm -rf /usr/local/bin/sof-*
    judge "Removed old SOF binaries"

    print_ok "Installing SOF binaries"
    cd ./sof-bin-2025.12
    ./install.sh
    judge "Installed SOF binaries"
    cd ..

    print_ok "Downloading alsa-ucm-conf"
    wget $ALSA_UCM_CONF_LINK -O ./alsa-ucm-conf.zip
    judge "Download alsa-ucm-conf"

    print_ok "Unzipping alsa-ucm-conf"
    mkdir -p ./alsa-ucm/
    unzip -q -O UTF-8 ./alsa-ucm-conf.zip -d ./alsa-ucm/
    judge "Unzip alsa-ucm-conf"

    print_ok "Copying alsa-ucm-conf to /usr/share/alsa/ucm2/"
    rsync -Aax --update --delete ./alsa-ucm/alsa-ucm-conf/ucm2/ /usr/share/alsa/ucm2/
    judge "Copy alsa-ucm-conf to /usr/share/alsa/ucm2/"

    print_ok "Cleaning up alsa-ucm-conf"
    cd ..
    rm -rf ./alsa-ucm/
    rm -rf ./alsa-ucm-conf.zip
    rm -rf "$tempdir"
    judge "Clean up alsa-ucm-conf"
)