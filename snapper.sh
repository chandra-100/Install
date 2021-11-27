#!/bin/bash

#to create a snapshot :- snapper -c root create -c timeline --description BeforeGUI
#to list snapshots :- snapper -c root list
#install snap-pac-grub &snapper-gui using 'yay' post install to this

echo "Starting Unmouting .snapshots DIR and further..."
echo
sudo umount /.snapshots
sudo rm -r /.snapshots
sudo snapper -c root create-config /
sudo btrfs subvolume delete /.snapshots
sleep 3
sudo mkdir /.snapshots
sleep 3
sudo mount -a
#sudo chmod 750 /.snapshots
sudo chmod a+rx /.snapshots
sudo chown :chandra /.snapshots
echo
#search and replace from https://askubuntu.com/questions/837384/sed-replace-specific-line-in-file
#sudo sed -i 's/# autologin=dgod/autologin=ubuntu/' /etc/snapper/configs/root
read -p ".snpashots jobs are done...Enter to continue attpeting snapper cfg"

sudo sed -i 's/ALLOW_USERS=""/ALLOW_USERS="chandra"/' /etc/snapper/configs/root

#sudo sed -i 's/TIMELINE_MIN_AGE="1800"/TIMELINE_MIN_AGE="1800"

sudo sed -i 's/TIMELINE_LIMIT_HOURLY="10"/TIMELINE_LIMIT_HOURLY="5"/' /etc/snapper/configs/root 

sudo sed -i 's/TIMELINE_LIMIT_DAILY="10"/TIMELINE_LIMIT_DAILY="7"/' /etc/snapper/configs/root

#sudo sed -i 's/TIMELINE_LIMIT_WEEKLY="0"/TIMELINE_LIMIT_WEEKLY="0"/' /etc/snapper/configs/root

sudo sed -i 's/TIMELINE_LIMIT_MONTHLY="10"/TIMELINE_LIMIT_MONTHLY="0"/' /etc/snapper/configs/root

sudo sed -i 's/TIMELINE_LIMIT_YEARLY="10"/TIMELINE_LIMIT_YEARLY="0"/' /etc/snapper/configs/root

echo "Snapper config generated !!! now enabling snapper Timeline &clean up services... please wait "
echo 
sudo systemctl start snapper-timeline.timer
sleep 3
sudo systemctl enable snapper-timeline.timer
sleep 3
sudo systemctl start snapper-cleanup.timer
sleep 3
sudo systemctl enable snapper-cleanup.timer
sleep 3
#sudo systemctl start grub-btrfs.path
sleep 3
#sudo systemctl enable grub-btrfs.path
sleep 3



