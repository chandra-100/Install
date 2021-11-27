#!/bin/bash
#boot-backup-hook

mkdir /etc/pacman.d/hooks
echo "Directory "hooks" created"
echo
#cat > /etc/pacman.d/hooks/50-bootbackup.hook
echo "starting config file "50-bootbackup.hook" "
echo "[Trigger]" >> /etc/pacman.d/hooks/50-bootbackup.hook
echo "Operation = Upgrade" >> /etc/pacman.d/hooks/50-bootbackup.hook
echo "Operation = Install" >> /etc/pacman.d/hooks/50-bootbackup.hook
echo "Operation = Remove" >> /etc/pacman.d/hooks/50-bootbackup.hook
echo "Type = Path" >> /etc/pacman.d/hooks/50-bootbackup.hook
echo "Target = boot/*" >> /etc/pacman.d/hooks/50-bootbackup.hook
echo
echo "[Action]" >> /etc/pacman.d/hooks/50-bootbackup.hook
echo "Depends = rsync" >> /etc/pacman.d/hooks/50-bootbackup.hook
echo "Description = Backing up /boot..." >> /etc/pacman.d/hooks/50-bootbackup.hook
echo "When = PreTransaction" >> /etc/pacman.d/hooks/50-bootbackup.hook
echo "Exec = /usr/bin/rsync -a --delete /boot /.bootbackup" >> /etc/pacman.d/hooks/50-bootbackup.hook
echo "Successfully generated bootback up hook !!!..installing rsync..."
sleep 3
sudo pacman -S --noconfirm rsync



