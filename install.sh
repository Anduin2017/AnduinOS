export DEBIAN_FRONTEND=noninteractive

# Allow run sudo without password.
if ! sudo grep -q "$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers.d/$USER; then
  echo "Adding $USER to sudoers..."
  sudo mkdir -p /etc/sudoers.d
  sudo touch /etc/sudoers.d/$USER
  echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/$USER
fi

sudo rm /var/lib/ubuntu-advantage/messages/*

echo "Preinstall..."
sudo add-apt-repository -y multiverse
sudo apt-get install wget gpg curl apt-transport-https software-properties-common

# Snap
echo "Removing snap..."
sudo snap remove firefox
sudo snap remove snap-store
sudo snap remove gtk-common-themes
sudo snap remove snapd-desktop-integration
sudo snap remove bare
bash -c "$(curl -fsSL https://raw.githubusercontent.com/BryanDollery/remove-snap/main/remove-snap.sh)"

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
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# WeChat
echo "Setting wechat..."
wget -O- https://deepin-wine.i-m.dev/setup.sh | sh

echo "Installing node, google, firefox, ibus-rime, apt-transport-https, code, vim, remmina, remmina-plugin-rdp, w3m, git, vim, sl, zip, unzip, wget, curl, neofetch, jq, net-tools, libglib2.0-dev-bin, httping, ffmpeg, nano, gnome-tweaks, gnome-shell-extension-prefs, spotify-client, vlc, golang-go, aria2, adb, ffmpeg, nextcloud-desktop, ruby, openjdk-17-jdk, default-jre, dotnet6, ca-certificates, gnupg, lsb-release, docker-ce, docker-ce-cli, pinta, aisleriot, containerd.io, jq, htop, iotop, iftop, ntp, ntpdate, ntpstat, docker-compose, tree, smartmontools..."
sudo apt install nodejs google-chrome-stable firefox ibus-rime nautilus-nextcloud\
  apt-transport-https code vim remmina remmina-plugin-rdp cifs-utils\
  w3m git sl zip unzip wget curl neofetch jq com.qq.weixin.deepin\
  net-tools libglib2.0-dev-bin httping ffmpeg nano iperf3 usb-creator-gtk\
  gnome-tweaks gnome-shell-extension-prefs spotify-client shotwell\
  vlc golang-go aria2 adb ffmpeg nextcloud-desktop python3-pip google-earth-pro-stable\
  ruby openjdk-17-jdk default-jre dotnet6 ca-certificates python-is-python3\
  gnupg lsb-release  docker-ce docker-ce-cli pinta aisleriot stellarium\
  containerd.io jq htop iotop iftop ntp ntpdate ntpstat clinfo shotcut\
  docker-compose tree smartmontools blender hugo baobab gedit steam\
  libfuse2 libapr1 libaprutil1 libxcb-cursor0 sqlitebrowser obs-studio

# Add current user as docker.
sudo gpasswd -a $USER docker

# NPM
sudo npm i -g yarn npm

# Postman
wget https://dl.pstmn.io/download/latest/linux_64 -O postman-linux-x64.tar.gz
sudo rm -rf /opt/Postman/
sudo tar xzf postman-linux-x64.tar.gz -C /opt/
sudo ln -s /opt/Postman/Postman /usr/bin/postman
cat > ~/.local/share/applications/postman.desktop <<EOL
[Desktop Entry]
Encoding=UTF-8
Name=Postman
X-GNOME-FullName=Postman API Client
Exec=/usr/bin/postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
EOL
chmod +x ~/.local/share/applications/postman.desktop
rm ./postman-linux-x64.tar.gz
echo "Postman has been installed successfully!"

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
    dotnet tool update --global $toolName --interactive --add-source "https://nuget.aiursoft.cn/v3/index.json" 2>/dev/null
  else
    echo "$toolName is not installed. Installing it.."
    if ! dotnet tool install --global $toolName --interactive --add-source "https://nuget.aiursoft.cn/v3/index.json" 2>/dev/null; then
      echo "$toolName failed to be installed. Trying updating it.."
      dotnet tool update --global $toolName --interactive --add-source "https://nuget.aiursoft.cn/v3/index.json" 2>/dev/null
      echo "Failed to install or update .NET $toolName"
    fi
  fi
}

TryInstallDotnetTool "dotnet-ef"

# Theme
echo "Configuring theme..."
rm /opt/themes -rvf > /dev/null 2>&1
sudo mkdir /opt/themes > /dev/null 2>&1
sudo chown $USER:$USER /opt/themes
git clone https://git.aiursoft.cn/PublicVault/Fluent-icon-theme /opt/themes/Fluent-icon-theme
/opt/themes/Fluent-icon-theme/install.sh 
git clone https://git.aiursoft.cn/PublicVault/Fluent-gtk-theme /opt/themes/Fluent-gtk-theme
/opt/themes/Fluent-gtk-theme/install.sh -i ubuntu --tweaks noborder round
git clone -b Wallpaper https://github.com/vinceliuice/Fluent-gtk-theme.git /opt/themes/Fluent-gtk-theme-wallpaper
/opt/themes/Fluent-gtk-theme-wallpaper/install-wallpapers.sh
gsettings set org.gnome.desktop.background picture-uri "file:///home/$USER/.local/share/backgrounds/Fluent-building-night.png"
gsettings set org.gnome.desktop.background picture-uri-dark "file:///home/$USER/.local/share/backgrounds/Fluent-building-night.png"
gsettings set org.gnome.desktop.background picture-options "zoom"

echo "Configuring gnome extensions..."
pip3 install --upgrade gnome-extensions-cli --break-system-packages
~/.local/bin/gext -F arcmenu@arcmenu.com
~/.local/bin/gext -F backslide@codeisland.org
~/.local/bin/gext -F blur-my-shell@aunetx
~/.local/bin/gext -F customize-ibus@hollowman.ml
~/.local/bin/gext -F dash-to-panel@jderose9.github.com
~/.local/bin/gext -F drive-menu@gnome-shell-extensions.gcampax.github.com
~/.local/bin/gext -F network-stats@gnome.noroadsleft.xyz
~/.local/bin/gext -F no-overview@fthx
~/.local/bin/gext -F openweather-extension@jenslody.de
~/.local/bin/gext -F stocks@infinicode.de
~/.local/bin/gext -F user-theme@gnome-shell-extensions.gcampax.github.com
dconf load /org/gnome/ < <(curl https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/master/Config/gnome-settings.txt)

# Fix
echo "Updating old packages..."
sudo DEBIAN_FRONTEND=noninteractive apt --purge autoremove -y
sleep 1
sudo DEBIAN_FRONTEND=noninteractive apt install --fix-broken  -y
sleep 1
sudo DEBIAN_FRONTEND=noninteractive apt install --fix-missing  -y
sleep 1
sudo DEBIAN_FRONTEND=noninteractive dpkg --configure -a
sleep 1
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y

echo "Deploy Finished! Please log out and log in again to take effect."