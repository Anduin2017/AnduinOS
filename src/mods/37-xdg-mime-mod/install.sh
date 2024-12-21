set -e                  # exit on error
set -o pipefail         # exit on pipeline error
set -u                  # treat unset variable as error

# Web with Mozila Firefox
xdg-mime default firefox.desktop x-scheme-handler/http
xdg-mime default firefox.desktop text/html
xdg-mime default firefox.desktop application/xhtml+xml
xdg-mime default firefox.desktop x-scheme-handler/https
# images with shotwell
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/jpeg # jpeg
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/jpg
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/pjpeg
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/png
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/tiff
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-3fr
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-adobe-dng
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-arw
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-bay
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-bmp
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-canon-cr2
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-canon-crw
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-cap
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-cr2
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-crw
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-dcr
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-dcraw
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-dcs
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-dng
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-drf
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-eip
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-erf
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-fff
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-fuji-raf
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-iiq
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-k25
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-kdc
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-mef
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-minolta-mrw
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-mos
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-mrw
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-nef
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-nikon-nef
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-nrw
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-olympus-orf
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-orf
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-panasonic-raw
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-pef
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-pentax-pef
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-png
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-ptx
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-pxn
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-r3d
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-raf
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-raw
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-rw2
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-rwl
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-rwz
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-sigma-x3f
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-sony-arw
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-sony-sr2
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-sony-srf
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-sr2
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-srf
xdg-mime default org.gnome.Shotwell-Viewer.desktop image/x-x3f
# videos with totem
xdg-mime default org.gnome.Totem.desktop video/x-ogm+ogg # ogm+ogg
xdg-mime default org.gnome.Totem.desktop video/3gp
xdg-mime default org.gnome.Totem.desktop video/3gpp
xdg-mime default org.gnome.Totem.desktop video/3gpp2
xdg-mime default org.gnome.Totem.desktop video/dv
xdg-mime default org.gnome.Totem.desktop video/divx
xdg-mime default org.gnome.Totem.desktop video/fli
xdg-mime default org.gnome.Totem.desktop video/flv
xdg-mime default org.gnome.Totem.desktop video/mp2t
xdg-mime default org.gnome.Totem.desktop video/mp4
xdg-mime default org.gnome.Totem.desktop video/mp4v-es
xdg-mime default org.gnome.Totem.desktop video/mpeg
xdg-mime default org.gnome.Totem.desktop video/mpeg-system
xdg-mime default org.gnome.Totem.desktop video/msvideo
xdg-mime default org.gnome.Totem.desktop video/ogg
xdg-mime default org.gnome.Totem.desktop video/quicktime
xdg-mime default org.gnome.Totem.desktop video/vivo
xdg-mime default org.gnome.Totem.desktop video/vnd.divx
xdg-mime default org.gnome.Totem.desktop video/vnd.mpegurl
xdg-mime default org.gnome.Totem.desktop video/vnd.rn-realvideo
xdg-mime default org.gnome.Totem.desktop video/vnd.vivo
xdg-mime default org.gnome.Totem.desktop video/webm
xdg-mime default org.gnome.Totem.desktop video/x-anim
xdg-mime default org.gnome.Totem.desktop video/x-avi
xdg-mime default org.gnome.Totem.desktop video/x-flc
xdg-mime default org.gnome.Totem.desktop video/x-fli
xdg-mime default org.gnome.Totem.desktop video/x-flic
xdg-mime default org.gnome.Totem.desktop video/x-flv
xdg-mime default org.gnome.Totem.desktop video/x-m4v
xdg-mime default org.gnome.Totem.desktop video/x-matroska
xdg-mime default org.gnome.Totem.desktop video/x-mjpeg
xdg-mime default org.gnome.Totem.desktop video/x-mpeg
xdg-mime default org.gnome.Totem.desktop video/x-mpeg2
xdg-mime default org.gnome.Totem.desktop video/x-ms-asf
xdg-mime default org.gnome.Totem.desktop video/x-ms-asf-plugin
xdg-mime default org.gnome.Totem.desktop video/x-ms-asx
xdg-mime default org.gnome.Totem.desktop video/x-msvideo
xdg-mime default org.gnome.Totem.desktop video/x-ms-wm
xdg-mime default org.gnome.Totem.desktop video/x-ms-wmv
xdg-mime default org.gnome.Totem.desktop video/x-ms-wmx
xdg-mime default org.gnome.Totem.desktop video/x-ms-wvx
xdg-mime default org.gnome.Totem.desktop video/x-nsv
xdg-mime default org.gnome.Totem.desktop video/x-theora
xdg-mime default org.gnome.Totem.desktop video/x-theora+ogg
xdg-mime default org.gnome.Totem.desktop video/x-totem-stream
# audio with rhythmbox
xdg-mime default org.gnome.Rhythmbox3.desktop audio/x-vorbis+ogg
xdg-mime default org.gnome.Rhythmbox3.desktop audio/vorbis
xdg-mime default org.gnome.Rhythmbox3.desktop audio/x-vorbis
xdg-mime default org.gnome.Rhythmbox3.desktop audio/x-scpls
xdg-mime default org.gnome.Rhythmbox3.desktop audio/x-mp3
xdg-mime default org.gnome.Rhythmbox3.desktop audio/x-mpeg
xdg-mime default org.gnome.Rhythmbox3.desktop audio/mpeg
xdg-mime default org.gnome.Rhythmbox3.desktop audio/x-mpegurl
xdg-mime default org.gnome.Rhythmbox3.desktop audio/x-flac
xdg-mime default org.gnome.Rhythmbox3.desktop audio/mp4
xdg-mime default org.gnome.Rhythmbox3.desktop audio/x-it
xdg-mime default org.gnome.Rhythmbox3.desktop audio/x-mod
xdg-mime default org.gnome.Rhythmbox3.desktop audio/x-s3m
xdg-mime default org.gnome.Rhythmbox3.desktop audio/x-stm
xdg-mime default org.gnome.Rhythmbox3.desktop audio/x-xm
# books with evince
xdg-mime default org.gnome.Evince.desktop application/pdf
xdg-mime default org.gnome.Evince.desktop application/epub+zip
# zip with file-roller
xdg-mime default org.gnome.FileRoller.desktop application/zip
xdg-mime default org.gnome.FileRoller.desktop application/x-7z-compressed
xdg-mime default org.gnome.FileRoller.desktop application/x-rar
xdg-mime default org.gnome.FileRoller.desktop application/x-tar
xdg-mime default org.gnome.FileRoller.desktop application/gzip
# txt with gedit
xdg-mime default org.gnome.gedit.desktop text/plain
# torrent with transmission-gtk
xdg-mime default transmission-gtk.desktop application/x-bittorrent
xdg-mime default transmission-gtk.desktop application/x-utorrent
# deb
xdg-mime default gdebi.desktop application/vnd.debian.binary-package

print_ok "Copying root's default applications to /etc/skel"
mkdir -p /etc/skel/.config
cp /root/.config/mimeapps.list /etc/skel/.config/
judge "Copy root's default applications to /etc/skel"