# AnduinOS

[![GPL licensed](https://img.shields.io/badge/license-GPL-blue.svg)](https://gitlab.aiursoft.com/anduin/anduinos/-/blob/1.5/LICENSE)
[![Discussions](https://img.shields.io/badge/discussions-join-blue)](https://github.com/Anduin2017/AnduinOS/discussions)
[![Join the AnduinOS Community on Revolt](https://img.shields.io/badge/Revolt-Join-fd6671?style=flat-square)](https://rvlt.gg/dPwPs8e6)
[![Website](https://img.shields.io/website?url=https%3A%2F%2Fwww.anduinos.com%2F)](https://www.anduinos.com/)
[![ManHours](https://manhours.aiursoft.com/r/gitlab.aiursoft.com/anduin/anduinos.svg)](https://gitlab.aiursoft.com/anduin/anduinos/-/commits/1.1?ref_type=heads)

<img align="right" width="100" height="100" src="./src/mods/30-gnome-extension-arcmenu-patch/logo.svg">

AnduinOS is a custom Ubuntu-based Linux distribution that offers a familiar and easy-to-use experience for anyone moving to Linux.

[Download AnduinOS](https://www.anduinos.com/)

![Screenshot](./screenshot.png)

AnduinOS is funded by user donations. We are grateful for your support.

<a href="https://ko-fi.com/anduinxue/goal?g=0" target="_blank" title="Support AnduinOS on Ko-fi">
  <img height="36" style="border:0px;height:36px;" src="https://storage.ko-fi.com/cdn/kofi3.png?v=3" border="0" alt="Support AnduinOS at ko-fi.com" />
</a>

## How to build

It is suggested to use AnduinOS to build AnduinOS.

To build the OS, run the following command:

```bash
make
```

To edit the build parameters, modify the `./src/args.sh` file.

That's it. The built file will be an ISO file in the `./src/dist` directory.

Simply mount the built ISO file to an virtual machine, and you can start testing it.

## Document

[Read the document](https://docs.anduinos.com/)

## License

This project is licensed under the GNU GENERAL PUBLIC LICENSE - see the [LICENSE](LICENSE) file for details

The open-source software included in AnduinOS is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY.

[List of open-source software included in AnduinOS](OSS.md)

## Support

For community support and discussion, please join our [AnduinOS Discussions](https://github.com/Anduin2017/AnduinOS/discussions).

For bug reports and feature requests, please use the [Issues](https://github.com/Anduin2017/AnduinOS/issues) page.

<!-- Planned future work:

* ARM support.
* WSL support.
* Docker container support.
* Layer based OS. Including: WSL\Server\Pro\Lite\Home\Workstation
* LiberOS.
* Customized installer instead of ubiquity.
* Customized apt source with our own override.
* Customized kernel with our own override. -->