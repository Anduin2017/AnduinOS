# Contributor test checklist

* Ensure during boot, it shall show the logo of our distro.
* Ensure the image can be installed with both BIOS and UEFI.
* Boot the image with **UEFI**. (This is to test the UEFI grub installation)
* Ensure there is no overview on startup.
* Ensure the cursor theme is applied.
* Ensure the timezone and language is localized.
* Ensure right clicking the desktop can open console here.
* Ensure user can configure desktop icons when right click the desktop.
* Ensure there is start button on the task bar with the logo of our distro.
* Right click the icon on taskbar, ensure the menu is localized, shows `Unpin from taskbar`.
* Right click the icon on start menu, ensure the menu is localized, shows `Pin to taskbar` and `Unpin from Start menu`.
* Ensure Super + Tab, Alt + Tab, Super + I are functional. (Super + I is (UNDER DEVELOPMENT))
* Ensure Super + U can toggle network stat display.
* Ensure Super + Shift + S will take a screenshot.
* Ensure Super + u will toggle network stat display.
* Ensure if the device has a battery, battery is shown on the task bar. Otherwise, it's hidden.
* Ensure sound theme, icon theme, shell theme are all set.
* Ensure there will be a `DO` sound (Yaru) when typing tab on terminal.
* Ensure when running `sudo apt update`, it's connecting to localized apt source.
* Ensure `lsb_release` with arg `-i -d -r -c -a` will show the correct information.
* Ensure folders are sorted before files in nautilus.
* Ensure `/opt` folder is empty.
* Ensure double click a photo file is opened with shotwell.
* Download a png file and a mp4 file. Ensure the photo and video files have previews on nautilus.
* Ensure double clicking a .deb file will open gdebi.
* Try start instllation (Ubiquty) and ensure all language texts are shown correctly. (Without square boxes)
* Try running installation. Select `中文`. Ensure in the log there is no error like ``Gtk-WARNING **: Locale not supported by C library. `
* After installation, ensure the start menu apps' names are localized.
* Open terminal and type `ubuntu-` with `Tab`. Ensure it can auto complete to `ubuntu-drivers`.
* Ensure the printer tab in settings can show the printer.
* Ensure the Chinese input can be switched by `Windows + Space` in gedit.
* Ensure Chinese users won't see ibus-libpinyin.
* Ensure the candidate words are shown correctly when typing in gedit.
* Ensure the text `遍角次亮采之门` in gedit is shown correctly.
* Ensure the text `http://` in gedit is shown correctly.
* Try installing Motrix and see if it can be shown successfully on the tray.
* Download a H264 video and try to play with `totem` and ensure it can play.
* Try switching from dark and light theme in the bottom drop down menu. And the text should be localized. Both GTK and QT apps should be switched.
* Try pressing `Ctrl + Alt + F6` and ensure it can switch to tty6. Message is `AnduinOS`.
* Try logout. On login screen, correct cursor theme and branding should be applied.

## Release steps

* Build the code, test the image.
* Checkout a new branch with the version number.
* Write the release notes.
* Build the image with the new version number.
* Copy the image and the hash to the server.
* Create the torrent file.
* Update the website with the new version number.
* Write the upgrade script for OTA updates.
* Copy the OSS software lists.

## Helpfull commands

To rename the built binary to release format:

```bash
for file in AnduinOS-1.0.1-*{.iso,.sha256}; do mv "$file" "$(echo "$file" | sed -E 's/-[0-9]{10}//')"; done
```
