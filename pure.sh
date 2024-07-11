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
WARNING="${Yellow}[ WARN ]${Font}"
function print_ok() {
  echo -e "${OK} ${Blue} $1 ${Font}"
}

function print_error() {
  echo -e "${ERROR} ${Red} $1 ${Font}"
}

function print_warn() {
  echo -e "${WARNING} ${Yellow} $1 ${Font}"
}

function judge() {
  if [[ 0 -eq $? ]]; then
    print_ok "$1 succeeded"
    sleep 1
  else
    print_error "$1 failed"
    exit 1
  fi
}

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

function switchSource() {
  # 镜像源列表
  mirrors=(
      "http://archive.ubuntu.com/ubuntu/" # 默认源
      "http://sg.archive.ubuntu.com/ubuntu/" # 新加坡
      "http://jp.archive.ubuntu.com/ubuntu/" # 日本
      "http://kr.archive.ubuntu.com/ubuntu/" # 韩国
      "http://us.archive.ubuntu.com/ubuntu/" # 美国
      "http://ca.archive.ubuntu.com/ubuntu/" # 加拿大
      "http://tw.archive.ubuntu.com/ubuntu/" # 台湾地区
      "http://th.archive.ubuntu.com/ubuntu/" # 泰国
      "http://de.archive.ubuntu.com/ubuntu/" # 德国
      "https://ubuntu.mirrors.uk2.net/ubuntu/" # 英国
      "http://ubuntu.mirror.cambrium.nl/ubuntu/" # 荷兰
      "http://mirrors.ustc.edu.cn/ubuntu/" # 中国科技大学
      "http://ftp.sjtu.edu.cn/ubuntu/" # 上海交通大学
      "http://mirrors.tuna.tsinghua.edu.cn/ubuntu/" # 清华大学
      "http://mirrors.aliyun.com/ubuntu/" # 阿里云
      "http://mirrors.163.com/ubuntu/" # 网易
      "http://mirrors.cloud.tencent.com/ubuntu/" # 腾讯云
      "http://mirror.aiursoft.cn/ubuntu/" # Aiursoft
      "http://mirrors.huaweicloud.com/ubuntu/" # 华为云
      "http://mirrors.zju.edu.cn/ubuntu/" # 浙江大学
      "http://azure.archive.ubuntu.com/ubuntu/" # 微软 Azure
  )

  # 存储测速结果
  declare -A results

  # 测速函数
  test_speed() {
      url=$1
      response=$(curl -o /dev/null -s -w "%{http_code} %{time_total}\n" --connect-timeout 1 --max-time 5 "$url")
      http_code=$(echo $response | awk '{print $1}')
      time_total=$(echo $response | awk '{print $2}')

      if [ "$http_code" -eq 200 ]; then
          results["$url"]=$time_total
      else
          print_warn "Failed to access $url"
          results["$url"]="9999" # 大的数值表示不可用
      fi
  }

  # 测试所有镜像源
  print_ok "Testing all mirrors..."
  for mirror in "${mirrors[@]}"; do
      test_speed "$mirror"
  done

  # 按速度排序
  sorted_mirrors=$(for url in "${!results[@]}"; do echo "$url ${results[$url]}"; done | sort -k2 -n)

  # 输出排序后的镜像源列表
  print_ok "Sorted mirrors:"
  echo "$sorted_mirrors"

  # 获取最快的镜像源
  fastest_mirror=$(echo "$sorted_mirrors" | head -n 1 | awk '{print $1}')

  # 输出并切换到最快的镜像源
  print_ok "Fastest mirror: $fastest_mirror"
  echo "
  deb $fastest_mirror jammy main restricted universe multiverse
  deb $fastest_mirror jammy-updates main restricted universe multiverse
  deb $fastest_mirror jammy-backports main restricted universe multiverse
  deb $fastest_mirror jammy-security main restricted universe multiverse
  " | sudo tee /etc/apt/sources.list
}

clear
cd ~
echo "The command you are running is deploying AnduinOS on Ubuntu $(lsb_release -sc)."
echo "This may introduce non-open-source software to your system."

export DEBIAN_FRONTEND=noninteractive

print_ok "Ensure current architecture is amd64..."
if [[ $(dpkg --print-architecture) != "amd64" ]]; then
  print_error "You are not using amd64 architecture. This script is only for amd64 architecture."
  areYouSure
fi

print_ok "Ensure you are Ubuntu 22.04..."
if ! lsb_release -a | grep "Ubuntu 22.04" > /dev/null; then
  print_error "You are not using Ubuntu 22.04. Please upgrade your system to 22.04 and try again."
  areYouSure
fi
judge "Ensure you are Ubuntu 22.04"

print_ok "Ensure current user is a normal user instead of root..."
if [[ $EUID -eq 0 ]]; then
  print_error "You are running this script as root. Please run this script as a normal user. Using root user is extreamly dangerous."
  areYouSure
fi
judge "Ensure current user is a normal user"

print_ok "Ensure current user is in sudo group..."
if ! groups $USER | grep -q "sudo"; then
  print_error "You are not in sudo group. Please add your user to sudo group and try again."
  areYouSure
fi
judge "Ensure current user is in sudo group"

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

print_ok "Switching to best apt source..."
switchSource
judge "Using best apt source"

print_ok "Disabling Ubuntu Pro advertisement..."
# Comment this line, because software-properties-gtk requires ubuntu-advantage-tools.
#sudo apt autoremove -y ubuntu-advantage-tools || true
#sudo apt-mark hold ubuntu-advantage-tools || true
sudo mv /etc/apt/apt.conf.d/20apt-esm-hook.conf /etc/apt/apt.conf.d/20apt-esm-hook.conf.bak
sudo touch /etc/apt/apt.conf.d/20apt-esm-hook.conf
sudo pro config set apt_news=false || true
sudo pro config set motd=false || true
judge "Disable Ubuntu Pro advertisement"
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


# Firefox is based on MPL-2.0 license.
print_ok "Setting firefox..."
sudo add-apt-repository -y ppa:mozillateam/ppa -n > /dev/null 2>&1
sudo sh -c 'echo "deb https://mirror-ppa.aiursoft.cn/mozillateam/ppa/ubuntu/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/mozillateam-ubuntu-ppa-$(lsb_release -sc).list'
echo -e '\nPackage: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1002' | sudo tee /etc/apt/preferences.d/mozilla-firefox
judge "Setting firefox"

print_ok "Installing apt softwares..."
sudo apt update
judge "Update apt sources"

sudo apt install -y \
  linux-generic-hwe-22.04 \
  gnome-shell gir1.2-gmenu-3.0 gnome-menus gnome-shell-extensions\
  nautilus usb-creator-gtk cheese baobab file-roller gnome-sushi ffmpegthumbnailer\
  gnome-calculator gnome-system-monitor gnome-disk-utility gnome-control-center software-properties-gtk\
  gnome-tweaks gnome-shell-extension-prefs gnome-shell-extension-desktop-icons-ng gnome-shell-extension-appindicator\
  gnome-clocks\
  gnome-weather\
  gnome-text-editor\
  gnome-nettool\
  seahorse gdebi evince\
  firefox\
  ibus-rime\
  shotwell\
  remmina remmina-plugin-rdp\
  vlc\
  gnome-console nautilus-extension-gnome-console\
  python3-apt python3-pip python-is-python3\
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
sudo apt autoremove -y gnome-shell-extension-ubuntu-dock > /dev/null 2>&1 || true # Ubuntu dock is replaced by dash-to-dock
sudo apt autoremove -y libreoffice-* > /dev/null 2>&1 || true # LibreOffice is replaced by wps-office
judge "Remove obsolete gnome apps"

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

# Clean up obsolete apt sources.
print_ok "Cleaning up obsolete apt sources...."
# This link requires to be updated manually regularly.
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
sudo rm /opt/themes -rvf > /dev/null 2>&1
sudo mkdir /opt/themes > /dev/null 2>&1
sudo chown $USER:$USER -R /opt/themes
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
dconf write /org/gtk/settings/file-chooser/sort-directories-first true
gsettings set org.gnome.desktop.interface gtk-theme 'Fluent-round-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Fluent'
gsettings set org.gnome.desktop.interface cursor-theme 'DMZ-White'
judge "Configure gnome settings"

print_ok "Configuring default templates..."
mkdir -p ~/Templates
touch ~/Templates/Markdown.md
touch ~/Templates/Text.txt
judge "Configure default templates"

print_ok "Configuring default applications..."
# video
xdg-mime default vlc.desktop video/x-matroska # mkv
xdg-mime default vlc.desktop video/mp4 # mp4
xdg-mime default vlc.desktop video/quicktime # mov
xdg-mime default vlc.desktop video/x-msvideo # avi
xdg-mime default vlc.desktop video/x-ms-wmv # wmv
xdg-mime default vlc.desktop video/x-flv # flv
xdg-mime default vlc.desktop video/x-m4v # m4v
xdg-mime default vlc.desktop video/webm # webm
# images
xdg-mime default shotwell-viewer.desktop image/png # png
xdg-mime default shotwell-viewer.desktop image/jpeg # jpg
xdg-mime default shotwell-viewer.desktop image/gif # gif
xdg-mime default shotwell-viewer.desktop image/bmp # bmp
xdg-mime default shotwell-viewer.desktop image/tiff # tiff
xdg-mime default shotwell-viewer.desktop image/webp # webp
xdg-mime default shotwell-viewer.desktop image/x-xcf # xcf
# audio
xdg-mime default vlc.desktop audio/mpeg # mp3
xdg-mime default vlc.desktop audio/x-wav # wav
xdg-mime default vlc.desktop audio/x-ms-wma # wma
xdg-mime default vlc.desktop audio/x-flac # flac
xdg-mime default vlc.desktop audio/x-m4a # m4a
xdg-mime default vlc.desktop audio/x-aac # aac
xdg-mime default vlc.desktop audio/x-vorbis+ogg # ogg
xdg-mime default vlc.desktop audio/x-ms-asf # asf
xdg-mime default vlc.desktop audio/ogg # ogg
# code
xdg-mime default code.desktop text/html
xdg-mime default code.desktop text/css
xdg-mime default code.desktop text/tsx
xdg-mime default code.desktop text/markdown
xdg-mime default code.desktop text/xml
xdg-mime default code.desktop text/x-csrc
xdg-mime default code.desktop text/x-csharp
xdg-mime default code.desktop text/x-c++src
xdg-mime default code.desktop text/x-c++hdr
xdg-mime default code.desktop text/x-python
xdg-mime default code.desktop text/x-java
xdg-mime default code.desktop text/x-ruby
xdg-mime default code.desktop text/x-php
xdg-mime default code.desktop text/x-shellscript
xdg-mime default code.desktop text/x-yaml
xdg-mime default code.desktop text/x-sql
xdg-mime default code.desktop text/x-dockerfile
xdg-mime default code.desktop text/x-nginx-conf
xdg-mime default code.desktop text/x-apacheconf
xdg-mime default code.desktop text/x-ini
xdg-mime default code.desktop text/x-toml
xdg-mime default code.desktop application/json
xdg-mime default code.desktop application/xml
xdg-mime default code.desktop application/javascript
xdg-mime default code.desktop application/typescript
xdg-mime default code.desktop application/x-shellscript
xdg-mime default code.desktop application/x-yaml
# books
xdg-mime default org.gnome.Evince.desktop application/pdf
xdg-mime default org.gnome.Evince.desktop application/epub+zip
# docx, xlsx, pptx
#xdg-mime default wps-office-et.desktop application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
#xdg-mime default wps-office-wpp.desktop application/vnd.openxmlformats-officedocument.presentationml.presentation
#xdg-mime default wps-office-wps.desktop application/vnd.openxmlformats-officedocument.wordprocessingml.document
# zip
xdg-mime default org.gnome.FileRoller.desktop application/zip
xdg-mime default org.gnome.FileRoller.desktop application/x-7z-compressed
xdg-mime default org.gnome.FileRoller.desktop application/x-rar
xdg-mime default org.gnome.FileRoller.desktop application/x-tar
xdg-mime default org.gnome.FileRoller.desktop application/gzip
# txt
xdg-mime default org.gnome.TextEditor.desktop text/plain
# deb
xdg-mime default gdebi.desktop application/vnd.debian.binary-package
judge "Configure default applications"

print_ok "Configuring default terminal to gnome-console..."
gsettings set org.gnome.desktop.default-applications.terminal exec kgx
judge "Configure default terminal"

# Clean up desktop icons
print_ok "Cleaning up desktop icons..."
rm ~/Desktop/*.desktop
print_ok "Clean up desktop icons"

print_ok "Deploy Finished! Please log out and log in again to take effect."
nautilus -q

## After installation, we can have the following tests:

## Ensure there is start button on the task bar.
## Ensure double click a video file is opened by VLC.
## Ensure the video file has a preview on nautilus.
## Ensure user can configure desktop icons when right click the desktop.

## Non-open-source softwares used:

## * Rime (GPL-3.0 License)
## * WeChat (Owned by Tencent)
