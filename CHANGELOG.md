# AnduinOS Changelog

## v0.0.5-alpha-jammy

* First open terminal nolonger shows the `sudo` hint.
* By default install with `ubuntu-session`, `yaru-theme-sound` and `yaru-theme-gnome-shell`
* Nolonger install `MissionCenter` since it's an app image and may increase the size of the ISO file.
* Install `gnome-system-monitor` and `gnome-sound-recorder` by default.
* Patch Chinese localization for `shotwell.desktop`.
* Reset arcmenu (start menu) icons to default for better localization.
* Start menu added some buttons for files, settings, console. Next to Power button.

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
