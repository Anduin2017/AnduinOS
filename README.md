# AnduinOS

AnduinOS is a custom Debian-based Linux distribution that aims to facilitate users transitioning from Windows to Ubuntu by maintaining familiar operational habits and workflows.

AnduinOS is built on the Ubuntu Jammy package base.

## Installation

First, download the latest release of AnduinOS from the releases page.

If you are using a Windows machine, you can use Rufus to create a bootable USB drive. If you are using a Linux machine, you can use the `dd` command.

```shell
sudo dd if=ubuntu-from-scratch.iso of=<device> status=progress oflag=sync
```

## License

This project is licensed under the GNU GENERAL PUBLIC LICENSE - see the [LICENSE](LICENSE) file for details

The open-source software included in AnduinOS is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY.

[List of open-source software included in AnduinOS](OSS.md)
