#!/bin/bash

function create_tarball() {
    if [[ ! -d new_building_os ]]; then
        echo "Error: please build system first"
        exit 1
    fi

    print_ok "Building wsl /docker image..."
    DATE=`TZ="UTC" date +"%y%m%d%H%M"`
    sudo tar --numeric-owner --exclude=boot -C new_building_os -cf $TARGET_NAME.tar .

    print_ok "Moving wsl/docker  image to $SCRIPT_DIR/dist/$TARGET_BUSINESS_NAME-$TARGET_BUILD_VERSION-$LANG_MODE-$DATE.tar..."
    mkdir -p $SCRIPT_DIR/dist
    mv $SCRIPT_DIR/$TARGET_NAME.tar $SCRIPT_DIR/dist/$TARGET_BUSINESS_NAME-$TARGET_BUILD_VERSION-$LANG_MODE-$DATE.tar

    judge "Move wsl/docker image"

    print_ok "Generating sha256 checksum..."
    HASH=`sha256sum $SCRIPT_DIR/dist/$TARGET_BUSINESS_NAME-$TARGET_BUILD_VERSION-$LANG_MODE-$DATE.tar | cut -d ' ' -f 1`
    echo "SHA256: $HASH" > $SCRIPT_DIR/dist/$TARGET_BUSINESS_NAME-$TARGET_BUILD_VERSION-$LANG_MODE-$DATE.sha256
    judge "Generate sha256 checksum"

}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
    source $SCRIPT_DIR/shared.sh
    source $SCRIPT_DIR/args.sh
    create_tarball 
fi