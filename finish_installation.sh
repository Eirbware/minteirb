#!/bin/bash
EDITOR_PKGS="vim neovim emacs micro codium"
COMPILER_PKGS="gcc clang gfortran make nodejs npm clang-format clang-tidy"
DEVTOOLS_PKGS="git gdb valgrind gnuplot wireshark sl tmux feh"
TOOLS_PKGS="curl wget gpg"
PKGS= $EDITOR_PKGS $COMPILER_PKGS $DEVTOOLS_PKGS $TOOLS_PKGS

CWD=$(pwd)

set -e

echo "╭───────────────────────────╮"
echo "│ Setting Minteirb theme... │"
echo "╰───────────────────────────╯"
### Adding minteirb theme and background files
sudo cp $CWD/assets/minteirb_theme /usr/share/plymouth/themes/minteirb -r
sudo cp $CWD/assets/minteirb_wallpaper.png /usr/share/backgrounds
sudo cp $CWD/assets/ubuntu-logo.png /usr/share/plymouth/ubuntu-logo.png

### Changing cinnamon default background and theme
gsettings set org.cinnamon.desktop.background picture-uri file:///usr/share/backgrounds/minteirb_wallpaper.png
gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-Sand'
gsettings set org.cinnamon.desktop.interface icon-theme 'Mint-Y-Sand'
gsettings set org.cinnamon.desktop.interface font-name 'Noto Sans 10'
gsettings set org.cinnamon.desktop.wm.preferences theme 'Mint-Y'
gsettings set org.cinnamon.desktop.wm.preferences titlebar-uses-system-font true
gsettings set org.cinnamon.desktop.wm.preferences audible-bell false

### Changing default plymouth theme to minteirb to change the boot image
sudo ln -sf /usr/share/plymouth/themes/minteirb/minteirb.plymouth /etc/alternatives/default.plymouth
sudo update-initramfs -u

### Setting up the systemd service to rename the os in grub and other grub custom options
sudo cp $CWD/scripts/minteirb_grub.sh /opt/minteirb_grub.sh
sudo chmod +x /opt/minteirb_grub.sh
sudo cp $CWD/scripts/minteirb_grub.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable minteirb_grub.service
sudo /opt/minteirb_grub.sh


echo "╭───────────────────────╮"
echo "│ Adding cheatsheets... │"
echo "╰───────────────────────╯"

### Adding default desktop files
sudo mkdir -p /etc/skel/Desktop
sudo cp -r $CWD/desktop_files/* /etc/skel/Desktop
sudo chmod +x /etc/skel/Desktop/eirb.fr.desktop


echo "╭────────────────────────╮"
echo "│ Installing packages... │"
echo "╰────────────────────────╯"

### Add codium in sources (https://vscodium.com/#install)
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg

echo -e 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' \
| sudo tee /etc/apt/sources.list.d/vscodium.sources

sudo apt-get update
sudo apt-get install -y $PKGS
