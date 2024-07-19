# AnduinOS

[![ManHours](https://manhours.aiursoft.cn/r/gitlab.aiursoft.cn/anduin/anduinos.svg)](https://gitlab.aiursoft.cn/anduin/anduinos/-/commits/master?ref_type=heads)

<img align="right" width="100" height="100" src="./src/logo/logo.svg">

AnduinOS is a custom Debian-based Linux distribution that aims to facilitate users transitioning from Windows to Ubuntu by maintaining familiar operational habits and workflows.

AnduinOS is built on the Ubuntu Jammy package base.

[Download AnduinOS (ISO)](https://github.com/Anduin2017/AnduinOS/releases)

## Preview

![Screenshot](./screenshot.png)

## System Requirements

Minimum system requirements:

- 2 GHz processor
- 1 GB RAM
- 25 GB disk space
- 1024x768 screen resolution
- USB port or DVD drive

System requirements for the best experience:

- 2.5 GHz quad-core processor
- 4 GB RAM
- 50 GB disk space
- Internet access

## Virtual Machine Installation

First, download AnduinOS from releases page.

Then, create a new virtual machine with any virtualization software (e.g. VirtualBox, VMware, etc.) and attach the downloaded ISO file to the virtual machine.

Finally, boot the virtual machine and follow the on-screen instructions to install AnduinOS.

> For UEFI boot, please make sure to disable secure boot in the virtual machine settings.

## Bare-mental Installation

First, download the latest release of AnduinOS from the releases page.

If you are using a Windows machine, you can use Rufus to create a bootable USB drive. If you are using a Linux machine, you can use the `dd` command.

```shell
sudo dd if=./AnduinOS-jammy-1.0.0-2407181704.iso of=<device> status=progress oflag=sync bs=4M
```

Then, boot the computer from the USB drive and follow the on-screen instructions to install AnduinOS.

## License

This project is licensed under the GNU GENERAL PUBLIC LICENSE - see the [LICENSE](LICENSE) file for details

The open-source software included in AnduinOS is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY.

[List of open-source software included in AnduinOS](OSS.md)

## Support

For community support and discussion, please join our [AnduinOS Discussions](https://github.com/Anduin2017/AnduinOS/discussions).

For bug reports and feature requests, please use the [Issues](https://github.com/Anduin2017/AnduinOS/issues) page.
