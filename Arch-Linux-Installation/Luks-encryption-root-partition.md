# Installing Arch Linux on a fully encrypted Root partition using LUKS

1. Prepare the USB device as bootable medium. In my case, `disk3` is USB device.
 ```BASH
  dd if=/Users/saravanan/Downloads/archlinux-2020.04.01-x86_64.iso of=/dev/disk3 bs=1m
  ```

2. Boot the system with USB and select the `Arch Linux archiso x86_64 UEFI CD` from the boot menu
by pressing `F12`

3. You should be logged into the Arch Linux console. You can install Arch Linux from here.

4. Partitioning Disk
```BASH
cfdisk /dev/sda
```
Its `gpt` partition table, so I have created the partitioning as below.

Partition 1 should be EFI System Partition (Type: EFI system) of about 256MB.
Partition 2 should be the boot partition (Type: Linux filesystem) of about 512MB.
Partition 3 should be the root partition (Type: Linux filesystem) and give it the rest of the free space.

5. Configuring LUKS Encryption on the Disk,
First load the dm-crypt and dm-mod kernel module.
```BASH
modprobe dm-crypt
modprobe dm-mod
```

6. Encrypt the root OS partition (in my case /dev/sda3) with LUKS.
```BASH
cryptsetup luksFormat -v -s 512 -h sha512 /dev/sda3
```
It will ask the passphrase to encrypt the partition.

7. Now open the /dev/sda3 device with the following command, so we can install Arch Linux on it.
```BASH
cryptsetup open /dev/sda3 luks_root
```

8. Formatting and Mounting the Partitions
```BASH
mkfs.vfat -n "EFI System Partition" /dev/sda1
mkfs.ext4 -L boot /dev/sda2
mkfs.ext4 -L root /dev/mapper/luks_root
```

```BASH
 mount /dev/mapper/luks_root /mnt
 mkdir /mnt/boot
 mount /dev/sda2 /mnt/boot
 mkdir /mnt/boot/efi
 mount /dev/sda1 /mnt/boot/efi
 ```

9. Configure the network(in my case its wi-fi).
```BASH
wifi-menu
```
Choose your wifi network and enable it.

10. Run the following command to install Arch Linux under /mnt
```BASH
pacstrap -i /mnt base base-devel efibootmgr grub vim linux linux-firmware netctl dialog networkmanager
```

11. Generate fstab file
```BASH
genfstab -U /mnt > /mnt/etc/fstab
```

12. chroot into the newly installed Arch Linux.
```BASH
arch-chroot /mnt
```

13. First set up a root password.
```BASH
passwd
```

14. Configure the locale settings with `en_US.UTF-8`.
```BASH
vim /etc/locale.gen #uncomment the line en_US.UTF-8
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
```

15. Configure the timezone settings.
```BASH
ln -sf /usr/share/zoneinfo/YOUR_REGION/YOUR_CIT /etc/localtime
hwclock --systohc --utc #set clock
```

16. set hostname and hosts file.
```BASH
echo YOUR_HOSTNAME > /etc/hostname
touch /etc/hosts
echo "127.0.0.1 localhost" > /etc/hosts
echo "::1 localhost" >> /etc/hosts
```

17. Configure `Grub` settings with LUKS encryption.
```BASH
vim /etc/default/grub
```
Set `GRUB_CMDLINE_LINUX="cryptdevice=/dev/sda3:luks_root"` and save the file.

18. Configure mkinitcpio.
```BASH
vim /etc/mkinitcpio.conf
```
In the HOOKS section, add `encrypt` after `block`.
```BASH
mkinitcpio -p linux
```
Run the above command to generate initrmfs

19. Install GRUB and generate GRUB configuration.
```BASH
grub-install --boot-directory=/boot --efi-directory=/boot/efi /dev/sda2
grub-mkconfig -o /boot/grub/grub.cfg
grub-mkconfig -o /boot/efi/EFI/arch/grub.cfg
```

20. Run the below commands to configure network interfaces,
```BASH
systemctl enable NetworkManager
systemctl disable wpa_supplicant
```

21. Exit out of chroot and reboot the system.
```BASH
exit
reboot
```

22. Booting in to the LUKS Encrypted Arch Linux.

You should be prompted for your LUKS encryption passphrase that you set earlier in step 6.
After this, Arch linux will start.

23. (Optional) Use `SoloKey` for [LUKS Encryption](https://github.com/saravanan30erd/solokey-full-disk-encryption).

It is more secure to use hardware secure keys(such as SoloKey) for [LUKS Encryption](https://github.com/saravanan30erd/solokey-full-disk-encryption) passphrase.


# Installing X server, Desktop Environment and Display Manager

24. Before installing a desktop environment (DE), you will need to install the X server which is the most popular display server.
```BASH
pacman -S xorg
```

25. To install Cinnamon,
```BASH
pacman -S cinnamon nemo-fileroller
```

26. You will also need a display manager to log in to your desktop environment. For the ease, you can install LXDM.
```BASH
pacman -S lxdm
systemctl enable lxdm.service
```
