# Contributor test checklist

* Ensure during boot, it shall show the logo of our distro.
* Ensure the image can be installed with both BIOS and UEFI.
* Ensure there is no overview on startup.
* Ensure right clicking the desktop can open console here.
* Ensure user can configure desktop icons when right click the desktop.
* Ensure there is start button on the task bar with the logo of our distro.
* Ensure Super + Tab, Alt + Tab, Super + I are functional. (Super + I is (UNDER DEVELOPMENT))
* Ensure Super + Shift + S will take a screenshot. (UNDER DEVELOPMENT)
* Ensure on `Tweaks` app sound theme, icon theme, shell theme are all set.
* Ensure there will be a `DO` sound (Yaru) when typing tab on terminal.
* Ensure `lsb_release` with arg `-i -d -r -c -a` will show the correct information.
* Ensure the text `遍角次亮采之门` in gnome-text-editor is shown correctly.
* Ensure folders are sorted before files in nautilus.
* Ensure `/opt` folder is empty.
* Ensure double click a photo file is opened with shotwell.
* Download a png file and a mp4 file. Ensure the photo and video files have previews on nautilus.
* Ensure double clicking a .deb file will open gdebi.
* Try start instllation (Ubiquty) and ensure all language texts are shown correctly. (Without square boxes)
* Try running installation. Ensure in the log there is no error like ``Gtk-WARNING **: Locale not supported by C library. `
* After installation, ensure the start menu apps' names are localized.
* Open terminal and type `ubuntu-` with `Tab`. Ensure it can auto complete to `ubuntu-drivers`.
* Try installing Motrix and see if it can be shown successfully on the tray.
* Try pressing `Ctrl + Alt + F6` and ensure it can switch to tty6. Message is `AnduinOS`.
