#!/bin/bash
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
OK="${Green}[  OK  ]${Font}"
ERROR="${Red}[FAILED]${Font}"
function print_ok() {
  echo -e "${OK} ${Blue} $1 ${Font}"
}

function print_error() {
  echo -e "${ERROR} ${Red} $1 ${Font}"
}
judge() {
  if [[ 0 -eq $? ]]; then
    print_ok "$1 succeeded"
    sleep 1
  else
    print_error "$1 failed"
    exit 1
  fi
}

clear
cd ~
echo "The command you are running is deploying AnduinOS on Ubuntu $(lsb_release -sc)."
echo "This may introduce non-open-source software to your system."

export DEBIAN_FRONTEND=noninteractive

print_ok "Ensure you are Ubuntu 22.04..."
if ! lsb_release -a | grep "Ubuntu 22.04" > /dev/null; then
  print_error "You are not using Ubuntu 22.04. Please upgrade your system to 22.04 and try again."
  exit 1
fi
judge "Ensure you are Ubuntu 22.04"

# Allow run sudo without password.
if ! sudo grep -q "$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers.d/$USER; then
  print_ok "Adding $USER to sudoers..."
  sudo mkdir -p /etc/sudoers.d
  sudo touch /etc/sudoers.d/$USER
  echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/$USER
  judge "Add $USER to sudoers"
fi

print_ok "Removing ubuntu-advantage advertisement..."
sudo rm /var/lib/ubuntu-advantage/messages/* > /dev/null 2>&1
print_ok "Remove ubuntu-advantage advertisement"

echo "Using Aiursoft APT mirror..."
echo "
deb http://mirror.aiursoft.cn/ubuntu/ jammy main restricted universe multiverse
deb http://mirror.aiursoft.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb http://mirror.aiursoft.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb http://mirror.aiursoft.cn/ubuntu/ jammy-security main restricted universe multiverse
" | sudo tee /etc/apt/sources.list
judge "Using Aiursoft APT mirror"

# print_ok "Removing i386 architecture..."
# sudo dpkg --remove-architecture i386 || true
# judge "Remove i386 architecture"

print_ok "Installing basic packages..."
sudo systemctl daemon-reload
sudo apt update
sudo apt install -y ca-certificates wget gpg curl apt-transport-https software-properties-common gnupg
judge "Install wget,gpg,curl,apt-transport-https,software-properties-common,gnupg"

print_ok "Setting apt sources..."
sudo add-apt-repository -y multiverse -n
sudo add-apt-repository -y universe -n
sudo add-apt-repository -y restricted -n
judge "Add multiverse, universe, restricted"

print_ok "Disabling Ubuntu Pro advertisement..."
sudo apt autoremove -y ubuntu-advantage-tools || true
sudo apt-mark hold ubuntu-advantage-tools || true
sudo mv /etc/apt/apt.conf.d/20apt-esm-hook.conf /etc/apt/apt.conf.d/20apt-esm-hook.conf.bak
sudo touch /etc/apt/apt.conf.d/20apt-esm-hook.conf
sudo pro config set apt_news=false || true
sudo pro config set motd=false || true
judge "Disable Ubuntu Pro advertisement"

# Test if the user can access Google.
print_ok "Testing network..."
if ! curl -s --head  --request GET http://www.google.com/generate_204 | grep "204" > /dev/null; then
  print_error "You are not able to access Internet. Please check your network and try again!"
  exit 1
fi
judge "Test network"

# Snap
print_ok "Removing snap..."
sudo killall -9 firefox > /dev/null 2>&1
sudo snap remove firefox > /dev/null 2>&1
sudo snap remove snap-store > /dev/null 2>&1
sudo snap remove gtk-common-themes > /dev/null 2>&1
sudo snap remove snapd-desktop-integration > /dev/null 2>&1
sudo snap remove bare > /dev/null 2>&1
sudo systemctl disable --now snapd
sudo apt purge -y snapd
sudo rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd ~/snap
cat << EOF | sudo tee -a /etc/apt/preferences.d/no-snap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
sudo chown root:root /etc/apt/preferences.d/no-snap.pref
judge "Remove snap"

# Docker source
print_ok "Setting docker..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
judge "Trust docker gpg"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
judge "Setting docker"

# Google Chrome Source
print_ok "Setting google chrome..."
wget https://dl-ssl.google.com/linux/linux_signing_key.pub -O /tmp/google.pub
sudo gpg --no-default-keyring --keyring /etc/apt/keyrings/google-chrome.gpg --import /tmp/google.pub
echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
judge "Setting google chrome"

# Google Earth Pro
print_ok "Setting google earth pro..."
wget -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/earth.gpg > /dev/null 2>&1
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/earth/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
judge "Setting google earth pro"

# Code
print_ok "Setting VSCode..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
judge "Setting VSCode"

# Spotify
print_ok "Setting spotify..."
curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list > /dev/null
judge "Setting spotify"

# Nextcloud
print_ok "Setting nextcloud..."
sudo add-apt-repository -y ppa:nextcloud-devs/client -n > /dev/null 2>&1
sudo sh -c 'echo "deb https://mirror-ppa.aiursoft.cn/nextcloud-devs/client/ubuntu/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/nextcloud-devs-client-$(lsb_release -sc).list'
judge "Setting nextcloud"

# Firefox
print_ok "Setting firefox..."
sudo add-apt-repository -y ppa:mozillateam/ppa -n > /dev/null 2>&1
sudo sh -c 'echo "deb https://mirror-ppa.aiursoft.cn/mozillateam/ppa/ubuntu/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/mozillateam-ubuntu-ppa-$(lsb_release -sc).list'
echo -e '\nPackage: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1002' | sudo tee /etc/apt/preferences.d/mozilla-firefox
judge "Setting firefox"

# Node
print_ok "Setting node 20..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg --yes
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
judge "Setting node 20"

print_ok "Installing apt softwares..."
sudo apt update
judge "Update apt sources"

sudo apt install -y \
  linux-generic-hwe-22.04 \
  nautilus usb-creator-gtk cheese baobab file-roller\
  gnome-calculator gnome-system-monitor gnome-disk-utility\
  gnome-tweaks gnome-shell-extension-prefs\
  gnome-clocks\
  gnome-weather\
  gnome-text-editor\
  gnome-nettool\
  seahorse\
  firefox\
  google-chrome-stable\
  ibus-rime\
  nextcloud-desktop nautilus-nextcloud\
  code\
  shotwell\
  remmina remmina-plugin-rdp\
  pinta\
  vlc\
  obs-studio\
  docker-ce docker-ce-cli containerd.io docker-compose\
  gnome-boxes\
  gnome-console nautilus-extension-gnome-terminal\
  blender\
  google-earth-pro-stable\
  shotcut\
  sqlitebrowser\
  nodejs\
  golang-go\
  dotnet8\
  openjdk-17-jdk default-jre\
  ruby\
  python3-apt python3-pip python-is-python3\
  hugo\
  spotify-client\
  adb\
  git neofetch lsb-release clinfo\
  gnupg vim nano\
  wget curl aria2\
  httping nethogs net-tools iftop traceroute dnsutils iperf3\
  smartmontools\
  htop iotop iftop\
  ffmpeg\
  tree ntp ntpdate ntpstat\
  w3m sysbench\
  zip unzip jq\
  cifs-utils\
  aisleriot\
  qtwayland5
judge "Install apt softwares"

# WeChat
print_ok "Setting wechat..."
wget -O- https://deepin-wine.i-m.dev/setup.sh | sh
judge "Setting wechat source"

sudo apt install -y com.qq.weixin.deepin
judge "Install wechat"

# print_ok "Removing i386 architecture..."
# sudo dpkg --remove-architecture i386 > /dev/null 2>&1
# judge "Remove i386 architecture"

print_ok "Removing obsolete gnome apps..."
sudo apt autoremove -y gnome-initial-setup > /dev/null 2>&1 || true
sudo apt autoremove -y gnome-maps > /dev/null 2>&1 || true
sudo apt autoremove -y gnome-photos > /dev/null 2>&1 || true
sudo apt autoremove -y eog > /dev/null 2>&1 || true
sudo apt autoremove -y totem totem-plugins > /dev/null 2>&1 || true
sudo apt autoremove -y rhythmbox > /dev/null 2>&1 || true
sudo apt autoremove -y gnome-contacts > /dev/null 2>&1 || true
sudo apt autoremove -y gnome-terminal > /dev/null 2>&1 || true
sudo apt autoremove -y gedit > /dev/null 2>&1 || true # gedit is replaced by gnome-text-editor
judge "Remove obsolete gnome apps"

# Add current user as docker.
print_ok "Adding $USER to docker group..."
sudo gpasswd -a $USER docker
judge "Add $USER to docker group"

# NPM
print_ok "Installing npm global packages..."
sudo npm i -g yarn npm npx typescript ts-node marked
judge "Install yarn, npm, npx, typescript, ts-node, marked"

# Insomnia
print_ok "Installing Insomnia..."
wget https://updates.insomnia.rest/downloads/ubuntu/latest -O insomnia.deb
sudo dpkg -i insomnia.deb
judge "Install Insomnia"
rm ./insomnia.deb

# Installing wps-office
if ! dpkg -s wps-office > /dev/null 2>&1; then
    print_ok "wps-office is not installed, downloading and installing..."
    # Download the deb package
    wget https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11698/wps-office_11.1.0.11698.XA_amd64.deb
    # Install the package
    sudo dpkg -i wps-office_11.1.0.11698.XA_amd64.deb
    judge "Install wps-office"
    # Remove the package file
    rm wps-office_11.1.0.11698.XA_amd64.deb
else
    print_ok "wps-office is already installed"
fi

# Install Motrix from: https://dl.motrix.app/release/Motrix_1.8.19_amd64.deb
if ! dpkg -s motrix > /dev/null 2>&1; then
    print_ok "Motrix is not installed, downloading and installing..."
    # Download the deb package
    wget https://dl.motrix.app/release/Motrix_1.8.19_amd64.deb
    # Install the package
    sudo dpkg -i Motrix_1.8.19_amd64.deb
    judge "Install Motrix"
    # Remove the package file
    rm Motrix_1.8.19_amd64.deb
else
    print_ok "Motrix is already installed"
fi

# Installing docker-desktop
if ! dpkg -s docker-desktop > /dev/null 2>&1; then
    print_ok "docker-desktop is not installed, downloading and installing..."
    # Download the deb package
    wget https://desktop.docker.com/linux/main/amd64/docker-desktop-4.30.0-amd64.deb
    # Install the package
    sudo dpkg -i docker-desktop-4.30.0-amd64.deb
    sudo apt install --fix-broken -y
    judge "Install docker-desktop"
    # Remove the package file
    rm docker-desktop-4.30.0-amd64.deb
else
    print_ok "docker-desktop is already installed"
fi

# Chinese input
print_ok "Setting up Chinese input..."
wget https://github.com/iDvel/rime-ice/archive/refs/heads/main.zip
unzip main.zip -d rime-ice-main
mkdir -p ~/.config/ibus/rime
mv rime-ice-main/*/* ~/.config/ibus/rime/ -f > /dev/null 2>&1
rm -rf rime-ice-main
rm main.zip
judge "Set up Chinese input (rime)"

# Bash RC
print_ok "Setting up bashrc..."
cp /etc/skel/.bashrc ~/
echo '# generated by anduinos
alias qget="aria2c -c -s 16 -x 16 -k 1M -j 16"
' >> ~/.bashrc
source ~/.bashrc
judge "Set up bashrc (qget)"

# Dotnet tools
function TryInstallDotnetTool {
  toolName=$1
  globalTools=$(dotnet tool list --global)

  if [[ $globalTools =~ $toolName ]]; then
    echo "$toolName is already installed. Updating it.." 
    dotnet tool update --global $toolName --interactive 2>/dev/null
  else
    echo "$toolName is not installed. Installing it.."
    if ! dotnet tool install --global $toolName --interactive 2>/dev/null; then
      echo "$toolName failed to be installed. Trying updating it.."
      dotnet tool update --global $toolName --interactive 2>/dev/null
    fi
  fi
}

print_ok "Installing dotnet tools..."
TryInstallDotnetTool "dotnet-ef"
TryInstallDotnetTool "Aiursoft.Static"
TryInstallDotnetTool "Aiursoft.Httping"
judge "Install dotnet tools (dotnet-ef, static, httping)"

# Python Tools
print_ok "Installing youtube-dl..."
pip install 'git+https://git.aiursoft.cn/PublicVault/youtube-dl.git@master#egg=youtube_dl'
sudo cp ~/.local/bin/youtube-dl /usr/local/bin/youtube-dl
sudo chmod a+rx /usr/local/bin/youtube-dl
judge "Install youtube-dl"

# Clean up obsolete apt sources.
print_ok "Cleaning up obsolete apt sources...."
wget https://github.com/davidfoerster/aptsources-cleanup/releases/download/v0.1.7.5.2/aptsources-cleanup.pyz
chmod +x aptsources-cleanup.pyz
sudo bash -c "echo all | ./aptsources-cleanup.pyz  --yes"
judge "Clean up obsolete apt sources"
rm ./aptsources-cleanup.pyz

print_ok "Upgrading packages..."
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt --purge autoremove -y
sleep 2
sudo DEBIAN_FRONTEND=noninteractive apt install --fix-broken  -y
sleep 2
sudo DEBIAN_FRONTEND=noninteractive apt install --fix-missing  -y
sleep 2
sudo DEBIAN_FRONTEND=noninteractive dpkg --configure -a
sleep 2
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y --allow-downgrades
judge "Upgrade packages"

# Fix CJK fonts
print_ok "Fixing CJK fonts..."
sudo wget https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/master/Config/fonts.conf -O /etc/fonts/local.conf
wget -P /tmp https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/master/Assets/fonts.zip
sudo unzip -o /tmp/fonts.zip -d /usr/share/fonts/
rm -f /tmp/fonts.zip
sudo fc-cache -fv
judge "Fix CJK fonts"

# Theme
print_ok "Configuring theme..."
rm /opt/themes -rvf > /dev/null 2>&1
sudo mkdir /opt/themes > /dev/null 2>&1
sudo chown $USER:$USER /opt/themes
git clone https://git.aiursoft.cn/PublicVault/Fluent-icon-theme /opt/themes/Fluent-icon-theme
/opt/themes/Fluent-icon-theme/install.sh 
git clone https://git.aiursoft.cn/PublicVault/Fluent-gtk-theme /opt/themes/Fluent-gtk-theme
sudo apt install libsass1 sassc -y
/opt/themes/Fluent-gtk-theme/install.sh -i ubuntu --tweaks noborder round
gsettings set org.gnome.desktop.interface gtk-theme 'Fluent-round-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Fluent'
git clone -b Wallpaper https://git.aiursoft.cn/PublicVault/Fluent-gtk-theme /opt/themes/Fluent-gtk-theme-wallpaper
/opt/themes/Fluent-gtk-theme-wallpaper/install-wallpapers.sh
gsettings set org.gnome.desktop.background picture-uri "file:///home/$USER/.local/share/backgrounds/Fluent-building-night.png"
gsettings set org.gnome.desktop.background picture-uri-dark "file:///home/$USER/.local/share/backgrounds/Fluent-building-night.png"
gsettings set org.gnome.desktop.background picture-options "zoom"
judge "Configure theme"

# Gnome extensions
print_ok "Configuring gnome extensions..."
/usr/bin/pip3 install --upgrade gnome-extensions-cli
~/.local/bin/gext -F install arcmenu@arcmenu.com
~/.local/bin/gext -F install blur-my-shell@aunetx
~/.local/bin/gext -F install customize-ibus@hollowman.ml
~/.local/bin/gext -F install dash-to-panel@jderose9.github.com
~/.local/bin/gext -F install drive-menu@gnome-shell-extensions.gcampax.github.com
~/.local/bin/gext -F install network-stats@gnome.noroadsleft.xyz
#~/.local/bin/gext -F install no-overview@fthx
~/.local/bin/gext -F install openweather-extension@jenslody.de
~/.local/bin/gext -F install user-theme@gnome-shell-extensions.gcampax.github.com
/usr/bin/pip3 uninstall gnome-extensions-cli -y
judge "Configure gnome extensions"

print_ok "Setting distributor logo..."
wget -O /opt/themes/distributor-logo-ubuntu.svg https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/master/Assets/distributor-logo-ubuntu.svg
judge "Set distributor logo"

print_ok "Configuring gnome settings..."
dconf load /org/gnome/ < <(curl https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/master/Config/gnome-settings.txt)
gsettings set org.gnome.desktop.interface gtk-theme 'Fluent-round-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Fluent'
gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-White'
judge "Configure gnome settings"

# Clean up desktop icons
print_ok "Cleaning up desktop icons..."
rm ~/Desktop/*.desktop
print_ok "Clean up desktop icons"

print_ok "Deploy Finished! Please log out and log in again to take effect."
