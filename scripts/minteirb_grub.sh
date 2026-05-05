#!/bin/bash

# Make sure that Minteirb is show in the menu (and not Ubuntu or Linux Mint)
sed -i -e 's/Linux Mint/Minteirb/g' /boot/grub/grub.cfg
sed -i -e 's/Ubuntu/Minteirb/g' /boot/grub/grub.cfg
