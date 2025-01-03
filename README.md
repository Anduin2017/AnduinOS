# AnduinOS

[![GPL licensed](https://img.shields.io/badge/license-GPL-blue.svg)](https://gitlab.aiursoft.cn/anduin/anduinos/-/blob/1.2/LICENSE)
[![Discussions](https://img.shields.io/badge/discussions-join-blue)](https://github.com/Anduin2017/AnduinOS/discussions)
[![Website](https://img.shields.io/website?url=https%3A%2F%2Fwww.anduinos.com%2F)](https://www.anduinos.com/)
[![ManHours](https://manhours.aiursoft.cn/r/gitlab.aiursoft.cn/anduin/anduinos.svg)](https://gitlab.aiursoft.cn/anduin/anduinos/-/commits/1.2?ref_type=heads)

<img align="right" width="100" height="100" src="./src/mods/30-gnome-extension-arcmenu-patch/logo.svg">

AnduinOS is a custom Debian-based Linux distribution that aims to facilitate developers transitioning from Windows to Ubuntu by maintaining familiar operational habits and workflows.

AnduinOS is built on the Ubuntu Noble package base.

[Download AnduinOS](https://www.anduinos.com/)

![Screenshot](./screenshot.png)

## How to build

You MUST install AnduinOS first.

To edit the build parameters, modify the `./src/args.sh` file.

To build the OS, run the following command:

```bash
cd ./src
./build.sh
```

That's it. The built file will be an ISO file in the `./src/dist` directory.

Simply mount the built ISO file to an virtual machine, and you can install it.

## Document

[Read the document](https://docs.anduinos.com/)

## License

This project is licensed under the GNU GENERAL PUBLIC LICENSE - see the [LICENSE](LICENSE) file for details

The open-source software included in AnduinOS is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY.

[List of open-source software included in AnduinOS](OSS.md)

## Support

For community support and discussion, please join our [AnduinOS Discussions](https://github.com/Anduin2017/AnduinOS/discussions).

For bug reports and feature requests, please use the [Issues](https://github.com/Anduin2017/AnduinOS/issues) page.
