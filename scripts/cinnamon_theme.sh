#!/bin/bash
### Changing cinnamon default background and theme
gsettings set org.cinnamon.desktop.background picture-uri file:///usr/share/backgrounds/minteirb_wallpaper.png
gsettings set org.cinnamon.desktop.interface gtk-theme 'Mint-Y-Dark-Sand'
gsettings set org.cinnamon.desktop.interface icon-theme 'Mint-Y-Sand'
gsettings set org.cinnamon.desktop.interface font-name 'Noto Sans 10'
gsettings set org.nemo.desktop font 'Noto Sans 10'
gsettings set org.gnome.desktop.interface document-font-name 'Noto Sans 10'
gsettings set org.cinnamon.desktop.wm.preferences theme 'Mint-Y'
gsettings set org.cinnamon.desktop.wm.preferences titlebar-uses-system-font true
gsettings set org.cinnamon.desktop.wm.preferences audible-bell false
