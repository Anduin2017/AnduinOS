## Brief steps

This article helps you change the following items if your cloud provider didn't do that for you.

* Check disk information
* Delete other accounts.
* Create your own account instead of root.
* Disable password login and force to use SSH key to log in.
* Disable root account.
* Enable `sudo` without password.
* Enable firewall.
* Ajust timezone.
* Enable BBR
* Install a newer kernel.
* Setup mirror.

Before starting the process, make sure you have a valid SSH key-pair locally.

You can run the following command on your dev box to generate a new SSH key-pair:

```bash
ssh-keygen
```

## Check connection and OS

Fist, connect to the server. (With root password).

    you@local 
    $ ssh root@server

Check the disk configuration:

```
sudo fdisk -l # Check connected disks.
sudo lsblk # Check disk mountings.
sudo df -Th # Check partition usage.
```

Check installed RAM:

```
sudo free -h
```

You can view other accounts via:

```bash
$ ls /home
$ cat /etc/passwd | grep -v nologin
```

## Change hostname

Change computer name first:

```bash
sudo hostnamectl set-hostname aiursoftcn
```

## Create a new user for you

Add a new user for you. (With password)

    root@server
    $ sudo adduser anduin
    Adding user `anduin' ...
    Adding new group `anduin' (1000) ...
    Adding new user `anduin' (1000) with group `anduin' ...
    Creating home directory `/home/anduin' ...
    Copying files from `/etc/skel' ...
    New password:
    Retype new password:
    passwd: password updated successfully
    Changing the user information for anduin
    Enter the new value, or press ENTER for the default
            Full Name []:
            Room Number []:
            Work Phone []:
            Home Phone []:
            Other []:
    Is the information correct? [Y/n] Y

Give the user root privilege.

    root@server
    $ usermod -aG sudo anduin

Test the new user's privilege.

    root@server
    $ su - anduin
    
    anduin@server
    $ sudo ls
    [password]
		
## Copy SSH public key

Back to your local machine. Copy the SSH public key to your server.

    you@local 
    $ ssh-copy-id anduin@server
    anduin@server's password:
    
    Number of key(s) added: 1
    
    Now try logging into the machine, with:   "ssh 'anduin@server'"
    and check to make sure that only the key(s) you wanted were added.

And test if you can connect to it.

    you@local 
    $ ssh anduin@server

## Ensure SSH best practice

Now disable root sign in and password authentication.

    anduin@server
    $ sudo vim /etc/ssh/sshd_config

Change: `PermitRootLogin` to `no` to disable the root user login. And change `PasswordAuthentication`  to `no` to prevent the password login.


### (Dangerous, optional) Skip password for your acction

To skip password for your account, consider execute:

    anduin@server
    $ sudo visudo

And add the following line at the end of the file:

    anduin ALL=(ALL) NOPASSWD:ALL
		
This might be dangerous that some other program running as you may also execute `sudo` to get root permission.

## Renew Machine ID

If your server is copied from another image, you MUST renew the machine ID to avoid DHCP conflict.

```bash
echo "Machine ID is default. Resetting..."
  sudo rm /etc/machine-id
  sudo rm /var/lib/dbus/machine-id
  sudo systemd-machine-id-setup
  sudo cp /etc/machine-id /var/lib/dbus/machine-id
```

## Delete other users and reboot

Don't forget to delete the obsolete user if the provider created it. (Don't delete the root user)

    anduin@server
    $ sudo deluser default

Reboot the server.

    anduin@server
    $ sudo reboot

And now the server can only access from you and can not log it in through password or the root account.

## Enable Firewall (Optional)

If you are using the cloud server provider's firewall, do open the following ports:

```
22 (For SSH management)
Your other business ports. Like 80, 443, 
```

The configuration might looks like this:

![file](/image/img-f2c7e210-5746-46ac-bec3-431f6f7dd2d6.png)

If you are using firewall software like ufw, do the following practice:

```bash
$ sudo ufw allow 22
$ sudo ufw allow 80 # Your other business ports.
$ sudo ufw enable
```

![file](/image/img-7a83d35e-c0a2-40af-aaaa-50e55cf057a3.png)

![file](/image/img-88b730e6-9c7f-4be9-ab10-8c4ddfd4c464.png)

## Enable BBR (Optional)

Don't forget to enable BBR to speed up your server!

(Run the following command as root (You can run `sudo bash` first))

```bash
# 
enable_bbr_force()
{
    echo "BBR not enabled. Enabling BBR..."
    echo 'net.core.default_qdisc=fq' | tee -a /etc/sysctl.conf
    echo 'net.ipv4.tcp_congestion_control=bbr' | tee -a /etc/sysctl.conf
    sysctl -p
}
sysctl net.ipv4.tcp_available_congestion_control | grep -q bbr ||  enable_bbr_force
```

## Install newer kernel

For example, Ubuntu by default may install an older kernel. You can install a newer kernel to get better performance.

```bash
sudo apt install -y linux-generic-22.04-hwe
```

## Setup Mirror

You can use a mirror to speed up apt.

Run these for example:

```bash
function switchSource() {
  mirrors=(
      "http://archive.ubuntu.com/ubuntu/"
      "http://sg.archive.ubuntu.com/ubuntu/" # Singapore
      "http://jp.archive.ubuntu.com/ubuntu/" # Japan
      "http://kr.archive.ubuntu.com/ubuntu/" # Korea
      "http://us.archive.ubuntu.com/ubuntu/" # United States
      "http://ca.archive.ubuntu.com/ubuntu/" # Canada
      "http://tw.archive.ubuntu.com/ubuntu/" # Taiwan (Province of China)
      "http://th.archive.ubuntu.com/ubuntu/" # Thailand
      "http://de.archive.ubuntu.com/ubuntu/" # Germany
      "https://ubuntu.mirrors.uk2.net/ubuntu/" # United Kingdom
      "http://ubuntu.mirror.cambrium.nl/ubuntu/" # Netherlands
      "http://mirrors.ustc.edu.cn/ubuntu/" # 中国科学技术大学
      "http://ftp.sjtu.edu.cn/ubuntu/" # 上海交通大学
      "http://mirrors.tuna.tsinghua.edu.cn/ubuntu/" # 清华大学
      "http://mirrors.aliyun.com/ubuntu/" # Aliyun
      "http://mirrors.163.com/ubuntu/" # NetEase
      "http://mirrors.cloud.tencent.com/ubuntu/" # Tencent Cloud
      "http://mirror.aiursoft.cn/ubuntu/" # Aiursoft
      "http://mirrors.huaweicloud.com/ubuntu/" # Huawei Cloud
      "http://mirrors.zju.edu.cn/ubuntu/" # 浙江大学
      "http://azure.archive.ubuntu.com/ubuntu/" # Azure
  )

  declare -A results

  test_speed() {
      url=$1
      response=$(curl -o /dev/null -s -w "%{http_code} %{time_total}\n" --connect-timeout 1 --max-time 5 "$url")
      http_code=$(echo $response | awk '{print $1}')
      time_total=$(echo $response | awk '{print $2}')

      if [ "$http_code" -eq 200 ]; then
          results["$url"]=$time_total
      else
          echo "Failed to access $url"
          results["$url"]="9999"
      fi
  }

  echo "Testing all mirrors..."
  for mirror in "${mirrors[@]}"; do
      test_speed "$mirror"
  done

  sorted_mirrors=$(for url in "${!results[@]}"; do echo "$url ${results[$url]}"; done | sort -k2 -n)

  echo "Sorted mirrors:"
  echo "$sorted_mirrors"

  fastest_mirror=$(echo "$sorted_mirrors" | head -n 1 | awk '{print $1}')

  echo "Fastest mirror: $fastest_mirror"
  echo "
  deb $fastest_mirror jammy main restricted universe multiverse
  deb $fastest_mirror jammy-updates main restricted universe multiverse
  deb $fastest_mirror jammy-backports main restricted universe multiverse
  deb $fastest_mirror jammy-security main restricted universe multiverse
  " | sudo tee /etc/apt/sources.list
}

sudo apt update
sudo apt install curl -y
switchSource
```

## Change to performance mode

If you are running on a bare-mental Intel server, you can switch from power-saver to performance.

```bash
sudo apt install -y linux-tools-common linux-tools-generic
sudo cpupower frequency-info
sudo cpupower frequency-set -g performance
```

## Change timezone

To switch to UTC, simply execute

```bash
$ sudo dpkg-reconfigure tzdata
```

Scroll to the bottom of the Continents list and select `Etc` or `None of the above`; in the second list, select `UTC`. If you prefer GMT instead of UTC, it's just above UTC in that list.

## Remove Snap (Optional)

I understand that a lot of Ubuntu users don't like snap.

If you want to remove snap, simply call:

```bash
echo "Removing snap..."
sudo systemctl disable --now snapd
sudo apt purge -y snapd
sudo rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd ~/snap
cat << EOF | sudo tee -a /etc/apt/preferences.d/no-snap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
sudo chown root:root /etc/apt/preferences.d/no-snap.pref
echo "Snap removed"
```

## Mount /tmp as RAM (Optional)

You can use `sudo df -Th` to verify if `/tmp` folder is `tmpfs` file system.

To mount `/tmp` folder as `tmpfs` file system, run the following command, then reboot.

```bash
(sudo cat /etc/fstab | grep -q /tmp) || (echo "Mouting tmp..." && echo "tmpfs /tmp tmpfs rw,nosuid,nodev" | sudo tee -a /etc/fstab)
```

## Enable Auto update (Optional, dangerous)

If your server is a stateless server, or have proper backup, or you don't care about availbility, you can enable auto backup.

To enable that, first run the following command:

```bash
cd ~
touch update.sh
echo "sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y && sudo apt autoremove -y && sudo reboot" > ./update.sh
chmod +x ./update.sh
```

After that, you may see an `update.sh` file under your home folder.

You can configure that to run automatically.

Run:

```bash
crontab -e
```

Add this line (Update every day, UTC 0, China 8:00 am):

```bash
0 0 * * * /home/anduin/update.sh
```

## Benchmark performance

To benchmark the CPU:

    anduin@server
    $ sudo apt install sysbench
    $ sysbench cpu run --threads=64
