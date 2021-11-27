#!/bin/bash

#this will install yay followed by other pacakges
git clone https://aur.archlinux.org/yay
sleep 3
cd yay/
makepkg -si PKGBUILD
sleep 3
cd
yay -S snap-pac-grub snapper-gui



