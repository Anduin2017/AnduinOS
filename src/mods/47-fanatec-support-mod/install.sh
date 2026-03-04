#!/bin/bash
# Install SimRacing Wheels support (Fanatec udev rules & Thrustmaster hid-tmff2 DKMS)
# Requires: git, dkms, linux-headers-generic, make, gcc

set -e
source /root/mods/shared.sh
source /root/mods/args.sh

print_ok "Starting SimRacing Wheels Integration..."

# 1. FANATEC: udev rules
print_ok "Adding udev rules for Fanatec steering wheels..."
cat << 'EOF' > /etc/udev/rules.d/99-fanatec.rules
# Fanatec udev rules
# PID 0001: ClubSport V1
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0eb7", ATTRS{idProduct}=="0001", MODE="0666"
# PID 0002: Porsche 911 Turbo S
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0eb7", ATTRS{idProduct}=="0002", MODE="0666"
# PID 0003: Porsche 911 Carrera
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0eb7", ATTRS{idProduct}=="0003", MODE="0666"
# PID 0004: Porsche 911 GT3 RS
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0eb7", ATTRS{idProduct}=="0004", MODE="0666"
# PID 0005: ClubSport V2
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0eb7", ATTRS{idProduct}=="0005", MODE="0666"
# PID 0006: CSL Elite Wheel Base
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0eb7", ATTRS{idProduct}=="0006", MODE="0666"
# PID 0007: CSL Elite Wheel Base PS4
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0eb7", ATTRS{idProduct}=="0007", MODE="0666"
# PID 0011: Podium Wheel Base DD1
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0eb7", ATTRS{idProduct}=="0011", MODE="0666"
# PID 0013: Podium Wheel Base DD2
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0eb7", ATTRS{idProduct}=="0013", MODE="0666"
# PID 0016: ClubSport Wheel Base V2.5
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0eb7", ATTRS{idProduct}=="0016", MODE="0666"
# PID 0020: CSL DD / GT DD Pro Base
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0eb7", ATTRS{idProduct}=="0020", MODE="0666"
# PID 0197: CSL Elite Pedals
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0eb7", ATTRS{idProduct}=="0197", MODE="0666"
# PID 0E03: CSL Elite Pedals LC
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0eb7", ATTRS{idProduct}=="0e03", MODE="0666"
# PID 1839: ClubSport Pedals V3
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0eb7", ATTRS{idProduct}=="1839", MODE="0666"
# PID 183B: ClubSport Handbrake V1.5
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0eb7", ATTRS{idProduct}=="183b", MODE="0666"
# PID 1A93: ClubSport Shifter SQ V1.5
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0eb7", ATTRS{idProduct}=="1a93", MODE="0666"
EOF
judge "Install Fanatec udev rules"

# 2. THRUSTMASTER: hid-tmff2 via DKMS
print_ok "Installing hid-tmff2 module via DKMS for Thrustmaster advanced Force Feedback..."

export DEBIAN_FRONTEND=noninteractive
apt-get update
# Install prerequisites for building kernel modules just in case (build-essential already in defaults)
apt-get install -y git dkms linux-headers-generic make gcc

# Clone repository into /usr/src for DKMS
cd /usr/src
if [ -d "hid-tmff2" ]; then
    rm -rf hid-tmff2
fi
git clone https://github.com/Kimplul/hid-tmff2.git
cd hid-tmff2

# Read version prefix from dkms.conf automatically or set default
TMFF2_VERSION=$(grep -E '^PACKAGE_VERSION=' dkms.conf | cut -d '"' -f 2)
if [ -z "$TMFF2_VERSION" ]; then
    TMFF2_VERSION="0.1"
fi
print_ok "Registering hid-tmff2 version ${TMFF2_VERSION} to DKMS..."

# Add and Install via DKMS
# Note: DKMS during chroot might fail if kernels mismatch, but since we are installing linux-headers-generic matching the chroot's kernel, it usually succeeds.
dkms add ./
dkms build hid-tmff2/${TMFF2_VERSION} || print_warn "DKMS Build encountered an issue. Please verify kernel headers."
dkms install hid-tmff2/${TMFF2_VERSION} || print_warn "DKMS Install encountered an issue."

# Blacklist old drivers
print_ok "Blacklisting legacy hid-thrustmaster driver..."
cat << 'EOF' > /etc/modprobe.d/hid-tmff2.conf
blacklist hid_thrustmaster
EOF

judge "Install Thrustmaster hid-tmff2 driver"

# 3. OVERSTEER: The UI config tool
print_ok "Installing Oversteer from PyPI (recommended for TM and Fanatec configuration)..."
apt-get install -y python3-pip python3-gi python3-xdg gir1.2-gtk-3.0 appstream gettext
pip3 install --break-system-packages oversteer
judge "Install Oversteer"

print_ok "SimRacing Wheels Integration completed!"
