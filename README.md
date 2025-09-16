# AnduinOS

[![GPL licensed](https://img.shields.io/badge/license-GPL-blue.svg)](https://gitlab.aiursoft.cn/anduin/anduinos/-/blob/1.1/LICENSE)
[![Discussions](https://img.shields.io/badge/discussions-join-blue)](https://github.com/Anduin2017/AnduinOS/discussions)
[![Join the AnduinOS Community on Revolt](https://img.shields.io/badge/Revolt-Join-fd6671?style=flat-square)](https://rvlt.gg/dPwPs8e6)
[![Website](https://img.shields.io/website?url=https%3A%2F%2Fwww.anduinos.com%2F)](https://www.anduinos.com/)
[![ManHours](https://manhours.aiursoft.cn/r/gitlab.aiursoft.cn/anduin/anduinos.svg)](https://gitlab.aiursoft.cn/anduin/anduinos/-/commits/1.1?ref_type=heads)

<img align="right" width="100" height="100" src="./src/mods/30-gnome-extension-arcmenu-patch/logo.svg">

AnduinOS is a custom Ubuntu-based Linux distribution that offers a familiar and easy-to-use experience for anyone moving to Linux.

[Download AnduinOS](https://www.anduinos.com/)

![Screenshot](./screenshot.png)

AnduinOS is funded by user donations. We are grateful for your support.

<span class="paypal"><a href="https://www.paypal.com/paypalme/anduinxue2017" title="Donate to this project using Paypal"><img src="https://www.paypalobjects.com/webstatic/mktg/Logo/pp-logo-100px.png" alt="PayPal donate button" /></a></span>

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