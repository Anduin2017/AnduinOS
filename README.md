# AnduinOS

AnduinOS 是一个 Ubuntu 自定义设置包。旨在方便用户快速从 Windows 迁移到 Linux。

![Screenshot](./Screenshot/desktop.png)

AnduinOS 是在 Ubuntu 的基础上额外提供了一些扩展，包括：

* 提供了中文输入法
* 提供了一个类似 Windows 11 的UI
* 提供了一些常用软件
* 删除了 snap

AnduinOS 测试了这些软件和UI的整合体验，因此在使用时一般不会遇到奇怪的问题。

## 部署 AnduinOS

显然，AnduinOS 并不是独立的操作系统。因此必须先安装 Ubuntu 。

在这里下载 Ubuntu ： [Ubuntu Desktop Download](https://ubuntu.com/download/desktop)

安装用户喜欢的方式部署 Ubuntu 即可。不需要特别的设置。

在第一次登录 Ubuntu 后，打开终端（Ctrl + Alt + T），然后运行：

```bash
bash -c "$(wget -O- https://gitlab.aiursoft.cn/anduin/anduinos/-/raw/master/install.sh)"
```

即可完成 AnduinOS 的部署。

## 致敬

AnduinOS 通过额外安装了大量第三方软件来提供体验。这其中包括大量开源软件。

包括但不限于：

*
