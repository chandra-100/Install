#!/bin/bash

#script to install pamac-all created on Nov 24-2021
#pre-requisite :- yay to be installed
#script to run as user only not root using ./path/to/scriptfile.sh

yay -S archlinux-appstream-data-pamac
sleep 3
echo "About to install snapd and libraries "
yay -S snapd
sleep 3
yay -S snapd-glib
sleep 3
yay -S libpamac-full
sleep 3
echo "About to install pamac-all"
yay -S pamac-all
sleep 3
echo
echo "Successfully installed pamac-all !"


