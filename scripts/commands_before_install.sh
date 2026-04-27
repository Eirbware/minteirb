#!/bin/bash
ID=1000 #Id of the first user
USER=$(id -nu $ID)

### This file contains the commands that are ran just before the installation

### Adding minteirb theme and background
cp /cdrom/assets/minteirb_theme /usr/share/plymouth/themes/minteirb -r
cp /cdrom/assets/minteirb_background.png /usr/share/backgrounds
cp /cdrom/assets/ubuntu-logo.png /usr/share/plymouth/ubuntu-logo.png

XDG_RUNTIME_DIR=/run/user/$ID

### Changing cinnamon default background and theme
sudo -u $USER DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus" gsettings set org.cinnamon.desktop.background picture-uri file:///usr/share/backgrounds/minteirb_wallpaper.png
sudo -u $USER DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus" gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-Sand'
sudo -u $USER DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus" gsettings set org.cinnamon.desktop.interface icon-theme 'Mint-Y-Sand'
sudo -u $USER DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus" gsettings set org.cinnamon.desktop.interface font-name 'Noto-Sans-10'
sudo -u $USER DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus" gsettings set org.cinnamon.desktop.wm.preferences theme 'Mint-Y'
sudo -u $USER DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus" gsettings set org.cinnamon.desktop.wm.preferences title-bar-uses-system-font true
sudo -u $USER DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus" gsettings set org.cinnamon.desktop.wm.preferences audible-bell false

### Adding desktop files
cp /cdrom/desktop_files/* /home/$USER/Desktop -r
