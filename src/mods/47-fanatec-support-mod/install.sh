#!/bin/bash
# Install SimRacing Wheels support (Fanatec udev rules)

set -e
source /root/mods/shared.sh
source /root/mods/args.sh

print_ok "Starting SimRacing Wheels Integration (Fanatec udev rules)..."

DEBIAN_FRONTEND=noninteractive apt-get install -y joystick

# FANATEC: udev rules
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

# FANATEC: evdev-joystick deadzone fix (Left-turn bug)
print_ok "Adding deadzone fix for Fanatec wheels..."
cat << 'EOF' > /etc/udev/rules.d/99-fanatec-evdev.rules
# Fix left-turn bug by zeroing deadzone and fuzz for Fanatec wheels
ACTION=="add", KERNEL=="event*", SUBSYSTEM=="input", ATTRS{idVendor}=="0eb7", RUN+="/usr/bin/evdev-joystick --evdev /dev/%k --deadzone 0 --fuzz 0"
EOF
judge "Install Fanatec evdev deadzone fix rules"

print_ok "SimRacing Wheels Integration completed!"
