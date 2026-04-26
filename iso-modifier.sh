#!/bin/bash
VERSION=minimal.fr
PREINSTALLED_PACKAGES="dbus-x11" # Necessary for installation (separated to avoid being deleted by mistake)
PACKAGES_TO_INSTALL="vim neovim emacs git valgrind gdb wireshark sl gcc tmux feh clang-format clang-tidy make nodejs npm"
# Codium is also installed, but not directly from apt, thus not in the list above
set -x
set -e

# Uses ubuntu autoinstall

### Update and install necesary packages
apt-get update
apt-get install -y xorriso dpkg-repack dpkg-dev gpg wget $PREINSTALLED_PACKAGES $PACKAGES_TO_INSTALL

### Install codium (https://vscodium.com/#install)
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg

echo -e 'Types: deb\nURIs: https://download.vscodium.com/debs\nSuites: vscodium\nComponents: main\nArchitectures: amd64 arm64\nSigned-by: /usr/share/keyrings/vscodium-archive-keyring.gpg' \
| tee /etc/apt/sources.list.d/vscodium.sources
apt-get update && apt-get install -y codium

### Set scripts and eirb.fr shortcut as executable
chmod +x scripts/* desktop-files/eirb.fr.desktop

### Creating tmp dir to work in
TMP_DIR=/iso-modif
mkdir -p $TMP_DIR

# Extracting iso
ISO=iso/$(ls iso | head -n 1)
xorriso -osirrox on -indev $ISO -extract / $TMP_DIR &> /dev/null

### Copying autoinstall and commands-at-install and assets
cp autoinstall.yaml $TMP_DIR
cp scripts $TMP_DIR -r
cp assets $TMP_DIR -r
cp desktop-files $TMP_DIR -r
cp gnome-files $TMP_DIR -r

### Copying dbus-x11 in the iso (necessary to make gnome modification work)
dpkg-repack $PREINSTALLED_PACKAGES
mkdir $TMP_DIR/preinstalled-packages
cp *.deb $TMP_DIR/preinstalled-packages

### Put packages to install in /packages-to-install to be able to be installed offline
mkdir $TMP_DIR/packages-to-install
cd $TMP_DIR/packages-to-install
for package in $PACKAGES_TO_INSTALL
do
  dpkg-repack $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances $package | grep "^\w") $package
done
# Also for codium
dpkg-repack $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances codium | grep "^\w") codium
cd /app

### Updates the package list
#mkdir -p $TMP_DIR/dists/noble/extras/binary-amd64
#dpkg-scanpackages $TMP_DIR/pool/extras /dev/null | gzip -9c > $TMP_DIR/dists/noble/extras/binary-amd64/Packages.gz

#sed -i -e 's/^Components\([a-z: ]*\)$/Components\1 extras/' $TMP_DIR/dists/noble/Release
#cd $TMP_DIR/dists/noble
#filename="extras/binary-amd64/Packages.gz"
#echo " $(sha256sum $filename | awk '{print $1}') $(stat -c%s $filename) $filename" >> Release
#cd /app

### Changing the name in grub
sed -i -e 's/Linux Mint/Minteirb/g' $TMP_DIR/boot/grub/loopback.cfg
sed -i -e 's/Linux Mint/Minteirb/g' $TMP_DIR/boot/grub/grub.cfg

### Removing splash screen (ubuntu logo during boot)
sed -i -e 's/splash//' $TMP_DIR/boot/grub/grub.cfg
sed -i -e 's/splash//' $TMP_DIR/boot/grub/loopback.cfg

### Copying MBR partition (necessary to boot from usb)
MBR_FILE=/mbr_copy.bin
dd if=$ISO bs=1 count=432 of=$MBR_FILE

### Repackaging iso
NEW_ISO_PATH=/app/new-iso/$(ls /app/iso | head -n 1 | sed 's/ubuntu/minteirb/')
xorriso -as mkisofs -r -V "minteirb" \
  -o $NEW_ISO_PATH\
  -J -l -c boot.catalog\
  -isohybrid-mbr $MBR_FILE \
  -b boot/grub/i386-pc/eltorito.img\
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot -e EFI/boot/grubx64.efi \
  -no-emul-boot -isohybrid-gpt-basdat \
  $TMP_DIR

