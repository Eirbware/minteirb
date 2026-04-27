#!/bin/bash
cd /tmp
wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
zcat < install-tl-unx.tar.gz | tar xf -
cd install-tl-2*
sudo perl ./install-tl --no-interaction
YEAR=$(date +%G)
echo 'export PATH=$PATH:/usr/local/texlive/'$YEAR'/bin/x86_64-linux"' >> ~/.bashrc 
source ~/.bashrc 
echo "LaTeX installed!"
