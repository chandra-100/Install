#!/bin/bash

echo "Starting script ..."
pacman -Syy reflector openssh
read -p "Initial update of repositories & install reflector in progress... press Enter when done..." 
sudo timedatectl set-ntp true
echo "Backing up& Updating reflector...please wait..."
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
read -p "Successfully updated reflector... press Enter to continue..."
#sleep 5
echo "Updating repositories..."   
sudo pacman -Syy
read -p "Successfully updated repositories... press Enter to continue..."
echo "Starting Disk Partitioning ..."
fdisk /dev/vda <<EOF
n
p
1

+1000M
n
p
2

+8G
n
p
3


w
EOF
sleep 3
#############depreciated##########################################
#(echo n; echo p; echo 1; echo 2048; echo 1679769; echo w) | fdisk /dev/vda
#sleep 5
#(echo n; echo p; echo 2; echo 1679770; echo 25165823; echo w) | fdisk /dev/vda
#sleep 5
#(echo n; echo p; echo 3; echo 25165824; echo 41943039; echo w) | fdisk /dev/vda
#sleep 5
####################################################

echo "Creating Filesystems..."
mkfs.fat -F32 /dev/vda1
sleep 5
mkswap /dev/vda2
sleep 5
mkfs.btrfs /dev/vda3
read -p "Creating BTRFS file systems...please wait... press Enter to continue when done..."
mount /dev/vda3 /mnt
btrfs su cr /mnt/@
btrfs su cr /mnt/@home
btrfs su cr /mnt/@var
btrfs su cr /mnt/@opt
btrfs su cr /mnt/@tmp
btrfs su cr /mnt/@snapshots #comment this if you plan on using Timeshift
umount /mnt
echo "Starting Mounting Opeartions...this will take a while...please wait..."
swapon /dev/vda2
sleep 5
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@ /dev/vda3 /mnt
# You need to manually create folder to mount the other subvolumes at
sleep 5
mkdir /mnt/{boot,home,var,opt,tmp,.snapshots}
#add .snapshots as well in case timeshift is not using for snapper
sleep 5
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@home /dev/vda3 /mnt/home
sleep 5
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@opt /dev/vda3 /mnt/opt
sleep 5
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@tmp /dev/vda3 /mnt/tmp
sleep 5
mount -o noatime,commit=120,compress=zstd,space_cache,subvol=@snapshots /dev/vda3 /mnt/.snapshots
sleep 5
mount -o subvol=@var /dev/vda3 /mnt/var
sleep 5
#Mounting the boot partition at /boot folder
mount /dev/vda1 /mnt/boot
sleep 5
lsblk 
read -p "Mounting is over... press Enter to continue...!"
echo "Installation starting Base & Linux ..."
pacstrap /mnt base linux linux-firmware vim git intel-ucode
read -p "Installtion in progress... please wait...  press Enter to continue when done..."
echo "Configuring FSTAB..."
genfstab -U /mnt >> /mnt/etc/fstab
read -p "Please wait FSTAB config in progress...press Enter to continue..." 
cat /mnt/etc/fstab
read -p "Here's the FSTAB!...please check & press Enter to continue..."

################this is copied from https://gist.github.com/rasschaert/0bb7ebc506e26daee585####
#echo "Entering Chroot ..." 
echo "Setting and generating locale, Time Zone, Host Name& Root User..."

arch-chroot /mnt /bin/bash <<EOF
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
export LANG=en_US.UTF-8
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
#echo "Setting time zone"
ln -s /usr/share/zoneinfo/Asia/Calcutta /etc/localtime
#echo "Setting hostname"
echo "arch" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1       localhost" >> /etc/hosts
echo "127.0.1.1 arch.localdomain arch" >> /etc/hosts
echo root:chandra | chpasswd
EOF
sleep 5

echo "Installing packages..."
arch-chroot /mnt pacman -S grub grub-btrfs efibootmgr networkmanager network-manager-applet dialog wpa_supplicant mtools dosfstools base-devel linux-headers avahi \
xdg-user-dirs xdg-utils gvfs gvfs-smb nfs-utils inetutils dnsutils bluez bluez-utils cups hplip alsa-utils pipewire pipewire-alsa pipewire-pulse pipewire-jack \
bash-completion rsync acpi acpi_call tlp virt-manager qemu qemu-arch-extra edk2-ovmf bridge-utils dnsmasq vde2 openbsd-netcat iptables-nft ipset firewalld flatpak \
sof-firmware nss-mdns acpid os-prober ntfs-3g terminus-font xf86-video-intel nano neofetch

echo "Instlling GRUB... please wait..."
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
read -p "GRUB insatlled successfully... press Enter to continue...!"
echo "Creating GRUB configuration... please wait..."
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
sleep 5
echo "Enabling System Services ..."
arch-chroot /mnt systemctl enable NetworkManager
arch-chroot /mnt systemctl enable bluetooth
arch-chroot /mnt systemctl enable cups.service
arch-chroot /mnt systemctl enable sshd
arch-chroot /mnt systemctl enable avahi-daemon
arch-chroot /mnt systemctl enable tlp # You can comment this command out if you didn't install tlp, see above
arch-chroot /mnt systemctl enable reflector.timer
arch-chroot /mnt systemctl enable fstrim.timer
arch-chroot /mnt systemctl enable libvirtd
arch-chroot /mnt systemctl enable firewalld
arch-chroot /mnt systemctl enable acpid


arch-chroot /mnt /bin/bash <<EOF
echo "Creating a User ...!"
useradd -m chandra
echo chandra:chandra | chpasswd
usermod -aG libvirt chandra
echo "chandra ALL=(ALL) ALL" >> /etc/sudoers.d/chandra
EOF

#umount -l /mnt
echo "Done ...! Now starting Desktop env GNOME !!!"

###starting Desktop env####
read -p "Press Enter to continue...!"
#echo "Updating Packages..."
#sudo pacman -Sy
echo "Configuring Firewall..."
arch-chroot /mnt firewall-cmd --add-port=1025-65535/tcp --permanent
arch-chroot /mnt firewall-cmd --add-port=1025-65535/udp --permanent
arch-chroot /mnt firewall-cmd --reload
echo "Insatlling Packages...."
arch-chroot /mnt pacman -S xorg gdm baobab cheese evince file-roller gedit gnome-backgrounds gnome-calculator gnome-characters gnome-color-manager \
gnome-control-center gnome-disk-utility gnome-font-viewer gnome-keyring gnome-logs gnome-menus gnome-remote-desktop gnome-screenshot gnome-session \
gnome-settings-daemon gnome-shell gnome-shell-extensions gnome-system-monitor gnome-terminal gnome-themes-extra gnome-user-docs gnome-user-share grilo-plugins \
gvfs gvfs-afc gvfs-goa gvfs-google gvfs-gphoto2 gvfs-mtp gvfs-nfs gvfs-smb mutter nautilus orca rygel sushi tracker tracker3-miners tracker-miners vino \
xdg-user-dirs-gtk yelp firefox gnome-tweaks arc-gtk-theme arc-icon-theme dina-font tamsyn-font bdf-unifont ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid \
gnu-free-fonts ttf-ibm-plex ttf-liberation ttf-linux-libertine noto-fonts ttf-roboto tex-gyre-fonts ttf-ubuntu-font-family ttf-anonymous-pro ttf-cascadia-code \
ttf-fantasque-sans-mono ttf-fira-mono ttf-hack ttf-fira-code ttf-inconsolata ttf-jetbrains-mono ttf-monofur adobe-source-code-pro-fonts cantarell-fonts inter-font \
ttf-opensans gentium-plus-font ttf-junicode adobe-source-han-sans-otc-fonts adobe-source-han-serif-otc-fonts noto-fonts-cjk archlinux-wallpaper

#gnome gnome-extra simplescreenrecorder noto-fonts-emoji obs-studio vlc

# sudo flatpak install -y spotify
# sudo flatpak install -y kdenlive
echo "Enabling GDM..."
arch-chroot /mnt systemctl enable gdm
sleep 5
umount -l /mnt
echo " All Done...! Rebooing in 10 sec...!!!"  
sleep 10
reboot
#Printf "\e[1;32mDone! Type exit, umount -a and reboot.\e[0m"
