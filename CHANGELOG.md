# AnduinOS Changelog

## v0.0.8-alpha-jammy

* Remove package `update-manager-core` to avoid the user upgraded to Ubuntu next version. (AnduinOS will handle the upgrade)
* Use totem as the default video player instead of vlc.
* Add `https://github.com/tomflannaghan/proxy-switcher` to the default gnome-shell extension list.

## v0.0.7-alpha-jammy

* Refactor the resources files structure during the build process.
* Patch fonts with `CascadiaCode, NerdFontsSymbols, Noto_Sans, Noto_serif, TwitterColorEmoji-SVGinOT` to support more languages.

## v0.0.6-alpha-jammy

* Removed useless system gnome extensions to reduce the size of the ISO file.
* By default disable magnifier. This will disable keyboard shortcut `Super + =` and `Super + -`. But better performance.
* Patch `ArcMenu` to show `Pin to Start menu` instead of `Pin to ArcMenu`.
* Edited taskbar behavior to activate panel menu buttons on click instead of hover.
* Hide date on the taskbar.
* Ubiquity installer will show the AnduinOS wallpaper.
* Added `fonts-noto-cjk fonts-noto-core fonts-noto-mono fonts-noto-color-emoji` to support more languages.
* Compress the squashfs file with `xz` to reduce the size of the ISO file.

## v0.0.5-alpha-jammy

* First open terminal nolonger shows the `sudo` hint.
* By default install with `ubuntu-session`, `yaru-theme-sound` and `yaru-theme-gnome-shell`
* Nolonger install `MissionCenter` since it's an app image and may increase the size of the ISO file.
* Install `gnome-system-monitor` and `gnome-sound-recorder` by default.
* `Ctrl + Shift + ECS` will open `gnome-system-monitor` instead of `MissionCenter`.
* Fixed an issue that `Super + Left` and `Super + Right` may not work.
* Patch Chinese localization for `shotwell.desktop`.
* Reset arcmenu (start menu) icons to default for better localization.
* Start menu added some buttons for files, settings, console. Next to Power button.
* Added keyboard shortcut `Super + =` and `Super + -` to zoom in and out.

## v0.0.4-alpha-jammy

* Fixed an issue that after system boot, gnome may show overview.
* Fixed an issue that `Super + D` may not work.
* Changed keyboard shortcut to make `Super + N` to open notification center.
* Nolonger patch `/etc/fonts/local.conf`. Leave font configuration as default.
* Removed `qtwayland5` package to reduce the size of the image.
* ISO file nolonger has the `Install` folder.
* OS pretty name nolonger has the word `based on Ubuntu Jammy`.
* Grub menu nolonger has the `Check Disk for defects` option.

## v0.0.3-alpha-jammy

* Removed the `Check Disk` option in the boot menu.
* Update README file to include the method about how to burn a bootable USB drive.
* Update the splash screen (Plymouth) to show the logo of AnduinOS.
* Super + Shift + S will take a screenshot.
* Simplify the start menu default apps text.
* Remove the gnome-system-monitor from the default apps because it's duplicate with Mission Center.
* Clean up `/opt/themes` folder to remove unnecessary themes files.

## v0.0.2-alpha-jammy

* Fix an issue that cursor may missing a necessary theme.
* Set version number in /etc/lsb-release and /etc/os-release.
* Added Chinese language pack (12MB larger)

## v0.0.1-alpha-jammy

First release. Able to boot into the desktop environment.
