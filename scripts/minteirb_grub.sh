#!/bin/bash

# Utils to make Minteirb grub

# changing the name in grub
sed -i -e 's/Ubuntu/Minteirb/g' /etc/default/grub
# set timeout before boot to 5 seconds
sed -i -e 's/^GRUB_TIMEOUT_STYLE=hidden$/# GRUB_TIMEOUT_STYLE=hidden/' /etc/default/grub
sed -i -e 's/^GRUB_TIMEOUT=0$/GRUB_TIMEOUT=5/' /etc/default/grub
# set a nice grub theme
sudo sed -i -E -e 's/^GRUB_THEME=.*$/GRUB_THEME="\/boot\/grub\/themes\/darkmatter\/theme.txt"' /etc/default/grub
# apply grub config
update-grub
# Make sure that Minteirb is show in the menu (and not Ubuntu or Linux Mint)
sed -i -e 's/Linux Mint/Minteirb/g' /boot/grub/grub.cfg
sed -i -e 's/Ubuntu/Minteirb/g' /boot/grub/grub.cfg
