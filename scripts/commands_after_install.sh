#!/bin/bash
# Ran after install

ID=1000 #Id of the first user
USER=$(id -nu $ID)
XDG_RUNTIME_DIR=/run/user/$ID

### Unpack and install preinstalled packages
dpkg -i -R -G /cdrom/preinstalled_packages
dpkg -i -R -G /cdrom/packages_to_install

### Adding minteirb theme and background files
cp /cdrom/assets/minteirb_theme /usr/share/plymouth/themes/minteirb -r
cp /cdrom/assets/minteirb_wallpaper.png /usr/share/backgrounds
cp /cdrom/assets/ubuntu-logo.png /usr/share/plymouth/ubuntu-logo.png

### Changing cinnamon default background and theme
sudo -u $USER DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus" gsettings set org.cinnamon.desktop.background picture-uri file:///usr/share/backgrounds/minteirb_wallpaper.png
sudo -u $USER DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus" gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-Sand'
sudo -u $USER DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus" gsettings set org.cinnamon.desktop.interface icon-theme 'Mint-Y-Sand'
sudo -u $USER DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus" gsettings set org.cinnamon.desktop.interface font-name 'Noto-Sans-10'
sudo -u $USER DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus" gsettings set org.cinnamon.desktop.wm.preferences theme 'Mint-Y'
sudo -u $USER DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus" gsettings set org.cinnamon.desktop.wm.preferences title-bar-uses-system-font true
sudo -u $USER DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus" gsettings set org.cinnamon.desktop.wm.preferences audible-bell false

### Adding default desktop files
mkdir /etc/skel/Desktop
cp /cdrom/desktop_files/* /etc/skel/Desktop -r

### Changing default plymouth theme to minteirb to change the boot image
ln -sf /usr/share/plymouth/themes/minteirb/minteirb.plymouth /etc/alternatives/default.plymouth
update-initramfs -u

### Setting up the systemd service to rename the os in grub
cp /cdrom/scripts/change_os_name.sh /opt
cp /cdrom/scripts/change_os_name.service /etc/systemd/system
systemctl daemon-reload
systemctl enable change_os_name.service
/opt/change_os_name.sh
