#!/bin/bash

echo "Starting remounting script ..."
pacman -Syy reflector openssh
timedatectl set-ntp true
sleep 5
echo "Starting Mounting Opeartions...this will take a while...please wait..."
swapon /dev/vda2
sleep 3
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@ /dev/vda3 /mnt
# You need to manually create folder to mount the other subvolumes at
sleep 3
#mkdir -p /mnt/{boot,home,var/log,opt,tmp,.snapshots}
#add .snapshots as well in case timeshift is not using for snapper
#sleep 3
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@home /dev/vda3 /mnt/home
sleep 3
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@opt /dev/vda3 /mnt/opt
sleep 3
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@tmp /dev/vda3 /mnt/tmp
sleep 3
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@snapshots /dev/vda3 /mnt/.snapshots
sleep 3
mount -o subvol=@var_log /dev/vda3 /mnt/var/log
sleep 3
#Mounting the boot partition at /boot folder
mount /dev/vda1 /mnt/boot
sleep 3
lsblk 
read -p "Mounting is over... press Enter to continue Maintenance and reboot when over...!"
clear

#echo "Instlling GRUB... please wait..."
#arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
#read -p "GRUB insatlled successfully... press Enter to continue...!"
#echo "Creating GRUB configuration... please wait..."
#arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
#sleep 5


#umount -l /mnt
#echo " All Done...! Rebooing in 10 sec...!!!"  


