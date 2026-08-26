#!/bin/bash

# Make sure that Minteirb is shown in the menu (and not Ubuntu or Linux Mint)
# however, somehow this seems to have absolutely no effect, don't ask why I don't even want to know who decided to change /boot/grub/grub.cfg AFTER sending the reboot signal
sed -i -e 's/Linux Mint/Minteirb/g' /boot/grub/grub.cfg
sed -i -e 's/Cinnamon//g' /boot/grub/grub.cfg
sed -i -e 's/Ubuntu/Minteirb/g' /boot/grub/grub.cfg

# This, I think works, but you know, I can't test it...

sed -i -e 's/Linux Mint/Minteirb/g' /etc/linuxmint/info
sed -i -e 's/GRUB_TITLE.*/GRUB_TITLE=Minteirb/g' /etc/linuxmint/info
