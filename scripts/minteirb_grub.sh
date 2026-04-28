#!/bin/bash
### Changing the name in grub
sed -i -e 's/Linux Mint/Minteirb/g' /boot/grub/loopback.cfg
sed -i -e 's/Linux Mint/Minteirb/g' /boot/grub/grub.cfg
### Removing splash screen (mint logo during boot)
sed -i -e 's/splash//' /boot/grub/grub.cfg
sed -i -e 's/splash//' /boot/grub/loopback.cfg
