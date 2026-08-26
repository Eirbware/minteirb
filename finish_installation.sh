#!/bin/bash
EDITOR_PKGS="vim emacs codium" # we will install neovim separately due to the VERY old version that is available on the Mint repos
COMPILER_PKGS="gcc g++ clang gfortran make nodejs npm clang-format clang-tidy yasm texlive" # some compilers
PYTHON_PKGS="python-is-python3 python3-pip python3-numpy python3-matplotlib" # useful python packages
DEVTOOLS_PKGS="gdb valgrind gnuplot sl wireshark" # some other useful tools for dev
OTHER_PKGS="numlockx"
TOOLS_PKGS="wget gpg git" # these are needed for other commands, so we should install them first

PKGS="$EDITOR_PKGS $COMPILER_PKGS $DEVTOOLS_PKGS $PYTHON_PKGS $OTHER_PKGS"

CWD=$(pwd)

ID=1000 #Id of the first (and probably sole) user
USER=$(id -nu $ID)

set -e # exit on error


echo -e "\033[33m"
echo "╭────────────────╮"
echo "│ Check perms... │"
echo "╰────────────────╯"
echo -e "\033[0m"

sudo echo -e "\033[32mCan use sudo\!\033[0m" || (echo -e "\033[31mCannot use sudo\!\033[0m" && exit 67)

echo -e "\033[33m"
echo "╭───────────────────────────╮"
echo "│ Setting Minteirb theme... │"
echo "╰───────────────────────────╯"
echo -e "\033[0m"

## Copy files
### Adding minteirb theme and background files

# if script was previously run, deleting the directories allows to update files
sudo rm -rf /usr/local/share/minteirb
sudo rm -rf /usr/share/plymouth/themes/minteirb

# Copy all assets
sudo cp -r $CWD/assets /usr/local/share/minteirb
sudo cp -r $CWD/assets/minteirb_theme /usr/share/plymouth/themes/minteirb
sudo cp $CWD/assets/wallpapers/minteirb.png /usr/share/backgrounds
sudo mkdir -p /usr/share/wallpapers/Minteirb
sudo cp $CWD/assets/wallpapers/* /usr/share/wallpapers/Minteirb
sudo cp $CWD/assets/ubuntu-logo.png /usr/share/plymouth/ubuntu-logo.png

### Set cinnamon theme
chmod u+x $CWD/scripts/cinnamon_theme.sh
$CWD/scripts/cinnamon_theme.sh

## Set grub theme

### Changing default plymouth theme to minteirb to change the boot image
sudo ln -srf /usr/share/plymouth/themes/minteirb/minteirb.plymouth /etc/alternatives/default.plymouth
sudo update-initramfs -u

### Add a cool grub theme
sudo mkdir -p /boot/grub/themes
sudo tar -xzf $CWD/assets/darkmatter_grub.tar.gz -C /boot/grub/themes/

### Setting grub defaults
### || true allows the script to run multiple times (else, sed returns an error and the script stop)
### changing the name in grub defaults
sudo sed -i -e 's/Ubuntu/Minteirb/g' /etc/default/grub || true
### set timeout before boot to 5 seconds
sudo sed -i -e 's/^GRUB_TIMEOUT_STYLE=hidden$/# GRUB_TIMEOUT_STYLE=hidden/' /etc/default/grub || true
sudo sed -i -e 's/^GRUB_TIMEOUT=0$/GRUB_TIMEOUT=5/' /etc/default/grub || true
### set a nice grub theme
if ! sudo grep -q -E '^GRUB_THEME=.*$' /etc/default/grub
then
    echo 'GRUB_THEME="/boot/grub/themes/darkmatter/theme.txt"' | sudo tee -a /etc/default/grub
else
    sudo sed -i -E -e 's/^GRUB_THEME=.*$/GRUB_THEME="\/boot\/grub\/themes\/darkmatter\/theme.txt"' /etc/default/grub
fi

### apply grub config
sudo update-grub


### Setting up the systemd service to rename the os in grub and other grub custom options
### needed after some updates that overwrites the os name
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

### Sometimes, Desktop is in french (Bureau) so make sure the cheatsheets are in the correct location
if [[ -e "$HOME/Desktop" ]]; then
    sudo cp -r $CWD/desktop_files/* $HOME/Desktop
    sudo chown --recursive $USER $HOME/Desktop
    sudo chmod +x $HOME/Desktop/eirb.fr.desktop
elif [[ -e "$HOME/Bureau" ]]; then
    sudo cp -r $CWD/desktop_files/* $HOME/Bureau
    sudo chown --recursive $USER $HOME/Bureau
    sudo chmod +x $HOME/Bureau/eirb.fr.desktop
else
    sudo mkdir -p $HOME/Desktop
    sudo cp -r $CWD/desktop_files/* $HOME/Desktop
    sudo chown --recursive $USER $HOME/Desktop
    sudo chmod +x $HOME/Desktop/eirb.fr.desktop
fi

echo -e "\033[33m"
echo "╭───────────────────────────────╮"
echo "│ Installing important utils... │"
echo "╰───────────────────────────────╯"
echo -e "\033[0m"

# TODO: change mirror repo

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
# try to skip the popup to confirm some things while installing packages: doesn't work always
sudo DEBIAN_FRONTED=noninteractive apt-get install -y $PKGS

cd /usr/local/bin/
archi=$(uname -m) # supports only aarch64 and x86_64: glhf if arch is something else

# Install Typst
typst_folder="typst-$archi-unknown-linux-musl"
sudo wget https://github.com/typst/typst/releases/download/v0.14.2/$typst_folder.tar.xz
sudo tar xJf $typst_folder.tar.xz # extract archive
sudo chmod +x $typst_folder/typst # make file executable
sudo ln -rfs $typst_folder/typst typst # create a link for typst to be in the Path
sudo rm $typst_folder.tar.xz # remove archive (we do not need it anymore)

# for neovim now. I know, that's a lot of stuff but you know "When it's ready" doesn't mean the same thing for Debian and for Neovim
nvim_folder="nvim-linux-$archi"
sudo wget https://github.com/neovim/neovim/releases/download/stable/$nvim_folder.tar.gz # download latest nvim releases for the computer's architecture
sudo tar xzf $nvim_folder.tar.gz # extract archive
sudo chmod +x $nvim_folder/bin/nvim # make file executable
sudo ln -rfs $nvim_folder/bin/nvim nvim # create a link for nvim to be in the Path
sudo rm $nvim_folder.tar.gz # remove archive (we do not need it anymore)

echo -e "\033[33m"
echo "╭───────────────────────────────╮"
echo "│ Adding some configurations... │"
echo "╰───────────────────────────────╯"
echo -e "\033[0m"

# set num lock at startup
echo "greeter-setup-script=/usr/bin/numlockx on" | sudo tee -a /etc/lightdm/lightdm.conf

# for vim
cp $CWD/assets/.vimrc $HOME/.vimrc

# for emacs
cp $CWD/assets/.emacs $HOME/.emacs

# nvim MiniMax
# (I know, kickstart is good, but I do not want to waste my time installing the fucking 1.5GB of tree-sitter-cli when setting up a new machine
# MiniMax does not complains about this missing tree-sitter-cli)
rm -rf $HOME/.MiniMax
git clone --filter=blob:none https://github.com/nvim-mini/MiniMax $HOME/.MiniMax
nvim -l $HOME/.MiniMax/setup.lua # setup MiniMax

# install a nerd font (JetBrains Mono NF) / otherwise, nvim looks buggy because of glyphs and icons
# plus nerd fonts are cool and JetBrains Mono is nice
cd /tmp
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.tar.xz
sudo rm -rf /usr/local/share/fonts/JetBrainsMono
sudo mkdir -p /usr/local/share/fonts/JetBrainsMono
sudo tar xJf JetBrainsMono.tar.xz -C /usr/local/share/fonts/JetBrainsMono # extract archive
sudo fc-cache -f # rebuild font cache

echo -e "\033[32m"
echo "╭───────────────────────────╮"
echo "│ Installation complete! ✅ │"
echo "╰───────────────────────────╯"
echo -e "\033[0m"

echo -e "\tneovim will be opened in a new window to achieve it's installation"
echo -e "\tthis terminal will close automatically: press ENTER."
read

# because changing monospace font it's quite buggy, we need to close and then reopen a terminal to make the font displaying correctly
# doesn't work always but it's okay
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 10' # set as default monospace font
(gnome-terminal -- nvim)& disown # open a terminal to install nvim plugins
(gnome-terminal -- emacs --no-window-system)& disown # open emacs to install emacs plugins
sleep 2 # wait a moment (need a moment to disown before killing parent pid)
(kill -9 $PPID) # close the parent terminal: I know that's ugly, but it's cool.
