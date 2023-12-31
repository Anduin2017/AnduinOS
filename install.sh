#!/bin/bash
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

echo "The command you are running is deploying AnduinOS..."
echo "This may introduce non-open-source software to your system."
echo "Please press [ENTER] to continue, or press CTRL+C to cancel."
read

export DEBIAN_FRONTEND=noninteractive

# Allow run sudo without password.
if ! sudo grep -q "$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers.d/$USER; then
  echo "Adding $USER to sudoers..."
  sudo mkdir -p /etc/sudoers.d
  sudo touch /etc/sudoers.d/$USER
  echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/$USER
fi

sudo rm /var/lib/ubuntu-advantage/messages/* > /dev/null 2>&1

echo "Preinstall..."
sudo add-apt-repository -y multiverse
sudo apt update
sudo apt install -y wget gpg curl apt-transport-https software-properties-common gnupg

# Snap
echo "Removing snap..."
sudo killall -9 firefox > /dev/null 2>&1
sudo snap remove firefox > /dev/null 2>&1
sudo snap remove snap-store > /dev/null 2>&1
sudo snap remove gtk-common-themes > /dev/null 2>&1
sudo snap remove snapd-desktop-integration > /dev/null 2>&1
sudo snap remove bare > /dev/null 2>&1
bash -c "$(curl -fsSL https://raw.githubusercontent.com/BryanDollery/remove-snap/main/remove-snap.sh)" > /dev/null 2>&1

# Docker source
echo "Setting docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Google Chrome Source
echo "Setting google..."
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list' 
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

# Google Earth Pro
echo "Setting google earth pro..."
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/earth/deb/ stable main" > /etc/apt/sources.list.d/google.list'

# Code
echo "Setting ms..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

# Spotify
echo "Setting spotify..."
curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

# Nextcloud
echo "Setting nextcloud..."
sudo add-apt-repository ppa:nextcloud-devs/client --yes

# Firefox
echo "Setting firefox..."
sudo add-apt-repository ppa:mozillateam/ppa --yes
echo -e '\nPackage: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1002' | sudo tee /etc/apt/preferences.d/mozilla-firefox

# Node
echo "Setting node..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg --yes
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

# WeChat
echo "Setting wechat..."
wget -O- https://deepin-wine.i-m.dev/setup.sh | sh

echo "Installing softwares..."
sudo apt update
sudo apt install -y \
  nautilus usb-creator-gtk cheese baobab file-roller\
  gnome-calculator gnome-system-monitor gnome-disk-utility\
  gnome-tweaks gnome-shell-extension-prefs\
  gnome-clocks\
  gnome-weather\
  gnome-text-editor\
  gnome-nettool\
  firefox\
  google-chrome-stable\
  ibus-rime\
  nextcloud-desktop nautilus-nextcloud\
  code\
  shotwell\
  remmina remmina-plugin-rdp\
  spotify-client\
  pinta\
  vlc\
  obs-studio\
  gnome-boxes\
  com.qq.weixin.deepin\
  blender\
  google-earth-pro-stable\
  shotcut\
  sqlitebrowser\
  nodejs\
  golang-go\
  dotnet6 dotnet7\
  openjdk-17-jdk default-jre\
  ruby\
  python3-apt python3-pip python-is-python3\
  docker-ce docker-ce-cli containerd.io docker-compose\
  hugo\
  adb\
  git\
  neofetch lsb-release\
  gnupg\
  vim nano\
  wget curl aria2 httping\
  ffmpeg\
  tree htop iotop iftop smartmontools net-tools clinfo\
  zip unzip jq\
  ntp ntpdate ntpstat\
  w3m\
  sysbench\
  apt-transport-https ca-certificates \
  cifs-utils\
  aisleriot

sudo apt autoremove -y gnome-maps > /dev/null 2>&1
sudo apt autoremove -y gnome-photos > /dev/null 2>&1
sudo apt autoremove -y eog > /dev/null 2>&1
sudo apt autoremove -y totem totem-plugins > /dev/null 2>&1
sudo apt autoremove -y rhythmbox > /dev/null 2>&1
sudo apt autoremove -y gnome-contacts > /dev/null 2>&1

# Add current user as docker.
sudo gpasswd -a $USER docker

# NPM
sudo npm i -g yarn npm npx typescript ts-node marked

# Insomnia
echo "Installing insomnia..."
wget https://updates.insomnia.rest/downloads/ubuntu/latest -O insomnia.deb
sudo dpkg -i insomnia.deb
rm ./insomnia.deb
echo "Insomnia has been installed successfully!"

# Installing wps-office
if ! dpkg -s wps-office > /dev/null 2>&1; then
    echo "wps-office is not installed, downloading and installing..."
    # Download the deb package
    wget https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11698/wps-office_11.1.0.11698.XA_amd64.deb
    # Install the package
    sudo dpkg -i wps-office_11.1.0.11698.XA_amd64.deb
    # Remove the package file
    rm wps-office_11.1.0.11698.XA_amd64.deb
else
    echo "wps-office is already installed"
fi

# Install Motrix from: https://dl.motrix.app/release/Motrix_1.8.19_amd64.deb
if ! dpkg -s motrix > /dev/null 2>&1; then
    echo "Motrix is not installed, downloading and installing..."
    # Download the deb package
    wget https://dl.motrix.app/release/Motrix_1.8.19_amd64.deb
    # Install the package
    sudo dpkg -i Motrix_1.8.19_amd64.deb
    # Remove the package file
    rm Motrix_1.8.19_amd64.deb
else
    echo "Motrix is already installed"
fi

# Installing docker-desktop
if ! dpkg -s docker-desktop > /dev/null 2>&1; then
    echo "docker-desktop is not installed, downloading and installing..."
    # Download the deb package
    wget https://desktop.docker.com/linux/main/amd64/docker-desktop-4.22.0-amd64.deb
    # Install the package
    sudo dpkg -i docker-desktop-4.22.0-amd64.deb
    sudo apt install --fix-broken -y
    # Remove the package file
    rm docker-desktop-4.22.0-amd64.deb
else
    echo "docker-desktop is already installed"
fi

# Chinese input
echo "Setting Chinese input..."
wget https://github.com/iDvel/rime-ice/archive/refs/heads/main.zip
unzip main.zip -d rime-ice-main
mkdir -p ~/.config/ibus/rime
mv rime-ice-main/*/* ~/.config/ibus/rime/
rm -rf rime-ice-main
rm main.zip
echo "Rime configured!"

# Bash RC
cp /etc/skel/.bashrc ~/
echo '# generated by anduinos
alias qget="aria2c -c -s 16 -x 16 -k 1M -j 16"
' >> ~/.bashrc
source ~/.bashrc

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

TryInstallDotnetTool "dotnet-ef"
TryInstallDotnetTool "Aiursoft.Static"

# Python Tools
echo "Installing youtube-dl..."
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
sudo chmod a+rx /usr/local/bin/youtube-dl

# Clean up obsolete apt sources.
echo "Cleaning up obsolete apt sources...."
wget https://github.com/davidfoerster/aptsources-cleanup/releases/download/v0.1.7.5.2/aptsources-cleanup.pyz
chmod +x aptsources-cleanup.pyz
sudo bash -c "echo all | ./aptsources-cleanup.pyz  --yes"
rm ./aptsources-cleanup.pyz

echo "Upgrading packages..."
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt --purge autoremove -y
sleep 2
sudo DEBIAN_FRONTEND=noninteractive apt install --fix-broken  -y
sleep 2
sudo DEBIAN_FRONTEND=noninteractive apt install --fix-missing  -y
sleep 2
sudo DEBIAN_FRONTEND=noninteractive dpkg --configure -a
sleep 2
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

# Fix CJK fonts
sudo wget https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/master/Config/fonts.conf -O /etc/fonts/local.conf
wget -P /tmp https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/master/Assets/fonts.zip
sudo unzip -o /tmp/fonts.zip -d /usr/share/fonts/
rm -f /tmp/fonts.zip
sudo fc-cache -fv

# Theme
echo "Configuring theme..."
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

# Gnome extensions
echo "Configuring gnome extensions..."
/usr/bin/pip3 install --upgrade gnome-extensions-cli --break-system-packages
~/.local/bin/gext -F install arcmenu@arcmenu.com
~/.local/bin/gext -F install blur-my-shell@aunetx
~/.local/bin/gext -F install customize-ibus@hollowman.ml
~/.local/bin/gext -F install dash-to-panel@jderose9.github.com
~/.local/bin/gext -F install drive-menu@gnome-shell-extensions.gcampax.github.com
~/.local/bin/gext -F install network-stats@gnome.noroadsleft.xyz
~/.local/bin/gext -F install no-overview@fthx
~/.local/bin/gext -F install openweather-extension@jenslody.de
~/.local/bin/gext -F install stocks@infinicode.de
~/.local/bin/gext -F install user-theme@gnome-shell-extensions.gcampax.github.com
/usr/bin/pip3 uninstall gnome-extensions-cli -y --break-system-packages

dconf load /org/gnome/ < <(curl https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/master/Config/gnome-settings.txt)
gsettings set org.gnome.desktop.interface gtk-theme 'Fluent-round-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Fluent'
gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-White'

# Clean up desktop icons
rm ~/Desktop/*.desktop

echo "Deploy Finished! Please log out and log in again to take effect."

echo "Please press [y] to log out, or press [c] to continue."
# When user press 'y', run: gnome-session-quit --logout --no-prompt
# When user press 'c', run: echo "You pressed 'c'"
read -n 1 -s -r -p "" key
if [ "$key" = "y" ]; then
    gnome-session-quit --logout --no-prompt
fi
