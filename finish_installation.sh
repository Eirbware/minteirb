#!/bin/bash
EDITOR_PKGS="vim emacs codium" # we will install neovim separately due to the VERY old version that is available on the Mint repos
COMPILER_PKGS="gcc g++ clang gfortran make nodejs npm clang-format clang-tidy yasm texlive"
PYTHON_PKGS="python-is-python3 python3-pip python3-numpy python3-matplotlib"
DEVTOOLS_PKGS="gdb valgrind gnuplot sl"
TOOLS_PKGS="curl wget gpg git" # these are needed for other commands, so we should install them first

PKGS="$EDITOR_PKGS $COMPILER_PKGS $DEVTOOLS_PKGS $PYTHON_PKGS"

CWD=$(pwd)

set -e

echo -e "\033[33m"
echo "╭───────────────────────────╮"
echo "│ Setting Minteirb theme... │"
echo "╰───────────────────────────╯"
echo -e "\033[0m"

### Adding minteirb theme and background files
sudo cp $CWD/assets/minteirb_theme /usr/share/plymouth/themes/minteirb -r
sudo cp $CWD/assets/minteirb_wallpaper.png /usr/share/backgrounds
sudo cp $CWD/assets/ubuntu-logo.png /usr/share/plymouth/ubuntu-logo.png

### Changing cinnamon default background and theme
gsettings set org.cinnamon.desktop.background picture-uri file:///usr/share/backgrounds/minteirb_wallpaper.png
gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-Sand'
gsettings set org.cinnamon.desktop.interface icon-theme 'Mint-Y-Sand'
gsettings set org.cinnamon.desktop.interface font-name 'Noto Sans 10'
gsettings set org.nemo.desktop font 'Noto Sans 10'
gsettings set org.cinnamon.desktop.interface document-font-name 'Noto Sans 10'
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

echo -e "\033[33m"
echo "╭───────────────────────╮"
echo "│ Adding cheatsheets... │"
echo "╰───────────────────────╯"
echo -e "\033[0m"

sudo mkdir -p /etc/skel/Desktop
sudo cp -r $CWD/desktop_files/* /etc/skel/Desktop
sudo chmod +x /etc/skel/Desktop/eirb.fr.desktop

echo -e "\033[33m"
echo "╭───────────────────────────────╮"
echo "│ Installing important utils... │"
echo "╰───────────────────────────────╯"
echo -e "\033[0m"

sudo apt-get update
sudo apt-get install -y $TOOLS_PKGS

echo -e "\033[33m"
echo "╭────────────────────────╮"
echo "│ Installing packages... │"
echo "╰────────────────────────╯"
echo -e "\033[0m"

### Add codium in sources (https://vscodium.com/#install)
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg

echo -e 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' \
| sudo tee /etc/apt/sources.list.d/vscodium.sources

sudo apt-get update
sudo apt-get install -y $PKGS

echo -e "\033[33m"
echo "╭───────────────────────────────╮"
echo "│ Adding some configurations... │"
echo "╰───────────────────────────────╯"
echo -e "\033[0m"

# doom emacs
git clone --depth 1 https://github.com/doomemacs/doomemacs $HOME/.config/emacs
# installing doom emacs packages
(yes | "${XDG_CONFIG_HOME:-$HOME/.config}"/emacs/bin/doom install)&

# for neovim now. I know, that's a lot of stuff but you know "When it's ready" doesn't mean the same thing for Debian and for Neovim
archi=$(uname -m)
cd /usr/local/bin/

sudo wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux-$archi.tar.gz # download latest nvim releases for the computer's architecture
sudo tar xzf nvim-linux-$archi.tar.gz # extract archive
ln -rs nvim-linux-$archi/bin/nvim nvim # create a link for nvim to be in the Path

# nvim MiniMax
# (I know, kickstart is good, but I do not want to waste my time installing the f*****g 1.5GB of tree-sitter-cli when setting up a new machine
# MiniMax does not complains about this missing tree-sitter-cli)
git clone --filter=blob:none https://github.com/nvim-mini/MiniMax $HOME/.MiniMax
nvim -l $HOME/.MiniMax/setup.lua # setup MiniMax

sudo rm nvim-linux-$archi.tar.gz # remove archive (we do not need it anymore)

# install a nerd font (JetBrains Mono NF) / otherwise, nvim looks buggy because of glyphs and icons
cd /tmp
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.tar.xz
sudo mkdir -p /usr/local/share/fonts/JetBrainsMono
sudo tar xJf JetBrainsMono.tar.xz -C /usr/local/share/fonts/JetBrainsMono # extract archive
sudo fc-cache -f # rebuild font cache
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 10' # set as default monospace font
