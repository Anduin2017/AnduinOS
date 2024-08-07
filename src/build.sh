#!/bin/bash

#==========================
# Set up the environment
#==========================
set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

#==========================
# Basic Information
#==========================
export LC_ALL=C
export LANG=en_US.UTF-8
export DEBIAN_FRONTEND=noninteractive
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

#==========================
# Color
#==========================
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
OK="${Green}[  OK  ]${Font}"
ERROR="${Red}[FAILED]${Font}"
WARNING="${Yellow}[ WARN ]${Font}"

#==========================
# Print Colorful Text
#==========================
function print_ok() {
  echo -e "${OK} ${Blue} $1 ${Font}"
}

function print_error() {
  echo -e "${ERROR} ${Red} $1 ${Font}"
}

function print_warn() {
  echo -e "${WARNING} ${Yellow} $1 ${Font}"
}

#==========================
# Judge function
#==========================
function judge() {
  if [[ 0 -eq $? ]]; then
    print_ok "$1 succeeded"
    sleep 1
  else
    print_error "$1 failed"
    exit 1
  fi
}

#==========================
# Are you sure function
#==========================
function areYouSure() {
  print_error "This script found some issue and failed to run. Continue may cause system unstable."
  print_error "Are you sure to continue the installation? Enter [y/N] to continue"
  read -r install
  case $install in
  [yY][eE][sS] | [yY])
    print_ok "Continue the installation"
    ;;
  *)
    print_error "Installation terminated"
    exit 1
    ;;
  esac
}

# Load configuration values from file
function load_config() {
    print_ok "Loading configuration from $SCRIPT_DIR/customize.sh..."
    . "$SCRIPT_DIR/patches/customize.sh"
    judge "Load configuration"
}

function check_host() {
    local os_ver
    os_ver=`lsb_release -i | grep -E "(Ubuntu|Debian)"`
    if [[ -z "$os_ver" ]]; then
        print_warn "This script is only supported on Ubuntu/Debian"
        areYouSure
    fi

    if [ $(id -u) -eq 0 ]; then
        print_error "This script should not be run as 'root'"
        exit 1
    fi
}

function clean() {
    print_ok "Cleaning up..."
    sudo umount chroot/dev || sudo umount -lf chroot/dev || true
    sudo umount chroot/run || sudo umount -lf chroot/run || true
    sudo umount chroot/proc || sudo umount -lf chroot/proc || true
    sudo umount chroot/sys || sudo umount -lf chroot/sys || true
    sudo rm -rf chroot || true
    judge "Clean up rootfs"
    sudo rm -rf image || true
    judge "Clean up image"
    sudo rm -f $TARGET_NAME.iso || true
    judge "Clean up iso"
}

function setup_host() {
    print_ok "Setting up host environment..."
    sudo apt update
    sudo apt install -y binutils debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools dosfstools unzip
    judge "Install required tools"

    print_ok "Creating chroot directory..."
    sudo mkdir -p chroot
    judge "Create chroot directory"
}

function download_base_system() {
    print_ok "Calling debootstrap to download base debian system..."
    sudo debootstrap  --arch=amd64 --variant=minbase $TARGET_UBUNTU_VERSION chroot $TARGET_UBUNTU_MIRROR
    judge "Download base system"
}

function run_chroot() {
    print_ok "Mounting /dev /run /proc /sys from host to chroot..."
    sudo mount --bind /dev chroot/dev
    sudo mount --bind /run chroot/run
    sudo chroot chroot mount none -t proc /proc
    sudo chroot chroot mount none -t sysfs /sys
    sudo chroot chroot mount none -t devpts /dev/pts
    judge "Mount /dev /run /proc /sys"

    print_ok "Copying patches to chroot /root..."
    sudo cp -r $SCRIPT_DIR/patches chroot/root/patches

    print_ok "Running chroot_build.sh in chroot..."
    print_warn "============================================"
    print_warn "   The following will run in chroot ENV!"
    print_warn "============================================"
    sudo chroot chroot /usr/bin/env DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-readline} /root/patches/chroot_build.sh -
    print_warn "============================================"
    print_warn "   chroot ENV execution completed!"
    print_warn "============================================"
    judge "Run chroot_build.sh in chroot"

    print_ok "Cleaning patches from chroot /root..."
    sudo rm -rf chroot/root/patches
    judge "Clean up chroot /root/patches"

    print_ok "Sleeping for 5 seconds to allow chroot to exit cleanly..."
    sleep 5

    print_ok "Unmounting /dev /run /proc /sys from chroot..."
    sudo chroot chroot umount /proc || sudo chroot chroot umount -lf /proc
    sudo chroot chroot umount /sys || sudo chroot chroot umount -lf /sys
    sudo chroot chroot umount /dev/pts || sudo chroot chroot umount -lf /dev/pts
    sudo umount chroot/dev || sudo umount -lf chroot/dev
    sudo umount chroot/run || sudo umount -lf chroot/run
    judge "Unmount /dev /run /proc /sys"
}

function build_iso() {
    print_ok "Building ISO image..."

    print_ok "Creating image directory..."
    rm -rf image
    mkdir -p image/{casper,isolinux,.disk}
    judge "Create image directory"

    # copy kernel files
    print_ok "Copying kernel files as /casper/vmlinuz and /casper/initrd..."
    sudo cp chroot/boot/vmlinuz-**-**-generic image/casper/vmlinuz
    sudo cp chroot/boot/initrd.img-**-**-generic image/casper/initrd
    judge "Copy kernel files"

    # grub
    print_ok "Generating grub.cfg..."
    touch image/ubuntu
    # TRY mode
    # * Enfoce user name `ubuntu` and hostname `ubuntu`
    # * Enforce X11
    # * Couldn't logout
    # * Couldn't lock screen
    # * On the desktop there will be a "Install" icon for Ubiquity installer

    # Install mode
    # * Enfoce user name `ubuntu` and hostname `ubuntu`
    # * Enforce X11
    # * Couldn't logout
    # * Couldn't lock screen
    # * Desktop is enabled. All gnome extensions are disabled.
    # * Will show Ubiquity installer by default
    # * Ubiquity installer won't ask if you want to keep trying this OS

    # After installation
    # * Requires login. User name is set during installation
    # * Nvidia users will enforce X11. Others will use Wayland
    # * Can logout
    # * Can lock screen
    # * Desktop is enabled. All gnome extensions are enabled
    # * No Ubiquity installer
    # * No "Install" icon on the desktop

    # Those configurations are setup in chroot/usr/share/initramfs-tools/scripts/casper-bottom/25configure_init
    cat << EOF > image/isolinux/grub.cfg

search --set=root --file /ubuntu

insmod all_video

set default="0"
set timeout=30

menuentry "Try AnduinOS" {
   linux /casper/vmlinuz boot=casper nopersistent toram quiet splash ---
   initrd /casper/initrd
}

menuentry "Install AnduinOS" {
   linux /casper/vmlinuz boot=casper only-ubiquity quiet splash ---
   initrd /casper/initrd
}
EOF
    judge "Generate grub.cfg"

    # generate manifest
    print_ok "Generating manifes for filesystem..."
    sudo chroot chroot dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee image/casper/filesystem.manifest >/dev/null 2>&1
    judge "Generate manifest for filesystem"

    print_ok "Generating manifest for filesystem-desktop..."
    sudo cp -v image/casper/filesystem.manifest image/casper/filesystem.manifest-desktop
    for pkg in $TARGET_PACKAGE_REMOVE; do
        sudo sed -i "/$pkg/d" image/casper/filesystem.manifest-desktop
    done
    judge "Generate manifest for filesystem-desktop"

    print_ok "Compressing rootfs as squashfs on /casper/filesystem.squashfs..."
    sudo mksquashfs chroot image/casper/filesystem.squashfs \
        -noappend -no-duplicates -no-recovery \
        -wildcards \
        -comp xz -b 1M -Xdict-size 100% \
        -e "var/cache/apt/archives/*" \
        -e "root/*" \
        -e "root/.*" \
        -e "tmp/*" \
        -e "tmp/.*" \
        -e "swapfile"
    judge "Compress rootfs"
    
    print_ok "Generating filesystem.size on /casper/filesystem.size..."
    printf $(sudo du -sx --block-size=1 chroot | cut -f1) > image/casper/filesystem.size
    judge "Generate filesystem.size"

    print_ok "Generating README.diskdefines..."
    cat << EOF > image/README.diskdefines
#define DISKNAME  Try AnduinOS
#define TYPE  binary
#define TYPEbinary  1
#define ARCH  amd64
#define ARCHamd64  1
#define DISKNUM  1
#define DISKNUM1  1
#define TOTALNUM  0
#define TOTALNUM0  1
EOF
    judge "Generate README.diskdefines"

    print_ok "Copying boot files..."
    pushd $SCRIPT_DIR/image
    grub-mkstandalone \
        --format=x86_64-efi \
        --output=isolinux/bootx64.efi \
        --locales="" \
        --fonts="" \
        "boot/grub/grub.cfg=isolinux/grub.cfg"
    judge "Copy boot files"

    print_ok "Creating EFI boot image on /isolinux/efiboot.img..."
    (
        cd isolinux && \
        dd if=/dev/zero of=efiboot.img bs=1M count=10 && \
        sudo mkfs.vfat efiboot.img && \
        LC_CTYPE=C mmd -i efiboot.img efi efi/boot && \
        LC_CTYPE=C mcopy -i efiboot.img ./bootx64.efi ::efi/boot/
    )
    judge "Create EFI boot image"

    print_ok "Creating BIOS boot image on /isolinux/bios.img..."
    grub-mkstandalone \
        --format=i386-pc \
        --output=isolinux/core.img \
        --install-modules="linux16 linux normal iso9660 biosdisk memdisk search tar ls" \
        --modules="linux16 linux normal iso9660 biosdisk search" \
        --locales="" \
        --fonts="" \
        "boot/grub/grub.cfg=isolinux/grub.cfg"
    judge "Create BIOS boot image"

    print_ok "Creating hybrid boot image on /isolinux/bios.img..."
    cat /usr/lib/grub/i386-pc/cdboot.img isolinux/core.img > isolinux/bios.img
    judge "Create hybrid boot image"

    print_ok "Creating .disk/info..."
    echo "$TARGET_BUSINESS_NAME $TARGET_BUILD_VERSION "Jammy Jellyfish" - Release amd64 ($(date +%Y%m%d))" | sudo tee .disk/info
    judge "Create .disk/info"

    print_ok "Creating md5sum.txt..."
    sudo /bin/bash -c "(find . -type f -print0 | xargs -0 md5sum | grep -v -e 'md5sum.txt' -e 'bios.img' -e 'efiboot.img' > md5sum.txt)"
    judge "Create md5sum.txt"

    print_ok "Creating iso image on $SCRIPT_DIR/$TARGET_NAME.iso..."
    sudo xorriso \
        -as mkisofs \
        -iso-level 3 \
        -full-iso9660-filenames \
        -volid "$TARGET_NAME" \
        -eltorito-boot boot/grub/bios.img \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        --eltorito-catalog boot/grub/boot.cat \
        --grub2-boot-info \
        --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
        -eltorito-alt-boot \
        -e EFI/efiboot.img \
        -no-emul-boot \
        -append_partition 2 0xef isolinux/efiboot.img \
        -output "$SCRIPT_DIR/$TARGET_NAME.iso" \
        -m "isolinux/efiboot.img" \
        -m "isolinux/bios.img" \
        -graft-points \
           "/EFI/efiboot.img=isolinux/efiboot.img" \
           "/boot/grub/bios.img=isolinux/bios.img" \
           "."
    judge "Create iso image"

    DATE=`TZ="UTC" date +"%y%m%d%H%M"`
    print_ok "Moving iso image to $SCRIPT_DIR/dist/$TARGET_BUSINESS_NAME-$TARGET_BUILD_VERSION-$DATE.iso..."
    mkdir -p $SCRIPT_DIR/dist
    mv $SCRIPT_DIR/$TARGET_NAME.iso $SCRIPT_DIR/dist/$TARGET_BUSINESS_NAME-$TARGET_BUILD_VERSION-$DATE.iso
    judge "Move iso image"

    print_ok "Generating sha256 checksum..."
    HASH=`sha256sum $SCRIPT_DIR/dist/$TARGET_BUSINESS_NAME-$TARGET_BUILD_VERSION-$DATE.iso | cut -d ' ' -f 1`
    echo "SHA256: $HASH" > $SCRIPT_DIR/dist/$TARGET_BUSINESS_NAME-$TARGET_BUILD_VERSION-$DATE.sha256
    judge "Generate sha256 checksum"

    popd

    # Play a sound to indicate the build is done
    if [ -x "$(command -v paplay)" ]; then
        print_ok "Playing sound to indicate build is done..."
        paplay /usr/share/sounds/freedesktop/stereo/complete.oga
        judge "Play sound"
    fi
}

# =============   main  ================
cd $SCRIPT_DIR
load_config
check_host
clean
setup_host
download_base_system
run_chroot
build_iso
echo "$0 - Initial build is done!"
