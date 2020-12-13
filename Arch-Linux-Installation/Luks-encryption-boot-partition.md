# Installing Arch Linux on a fully encrypted system (including boot partition) using LUKS

1. Prepare the USB device as bootable medium. In my case, `disk3` is USB device.
 ```BASH
  dd if=/Users/saravanan/Downloads/archlinux-2020.04.01-x86_64.iso of=/dev/disk3 bs=1m
  ```

2. Boot the system with USB and select the `Arch Linux archiso x86_64 UEFI CD` from the boot menu
by pressing `F12`

3. You should be logged into the Arch Linux console. You can install Arch Linux from here.

4. Prior to creating any partitions, we should securely erase the disk.
```BASH
shred -v /dev/sda
```

5. Partitioning Disk
```BASH
cfdisk /dev/sda
```
Its `gpt` partition table, so I have created the partitioning as below.

Partition 1 should be EFI System Partition (Type: EFI system) of about 256MB.
Partition 2 should be the boot partition (Type: Linux filesystem) of about 512MB.
Partition 3 should be the root partition (Type: Linux filesystem) and give it the rest of the free space.

6. Configuring LUKS Encryption on the Disk,
First load the dm-crypt and dm-mod kernel module.
```BASH
modprobe dm-crypt
modprobe dm-mod
```

7. Encrypt the boot partition,
It will ask the passphrase to encrypt the partition.
```BASH
cryptsetup luksFormat --type luks1 /dev/sda2
cryptsetup open /dev/sda2 luks_boot
```
GRUB does not support LUKS2. Use LUKS1 (--type luks1) on boot partition.

8. Encrypt the root OS partition (in my case /dev/sda3) with LUKS.
```BASH
cryptsetup luksFormat -v -s 512 -h sha512 /dev/sda3
```
It will ask the passphrase to encrypt the partition.

9. Now open the /dev/sda3 device with the following command, so we can install Arch Linux on it.
```BASH
cryptsetup open /dev/sda3 luks_root
```

10. Formatting and Mounting the Partitions
```BASH
mkfs.vfat -n "EFI System Partition" /dev/sda1
mkfs.ext4 -L boot /dev/mapper/luks_boot
mkfs.ext4 -L root /dev/mapper/luks_root
```

```BASH
 mount /dev/mapper/luks_root /mnt
 mkdir /mnt/boot
 mount /dev/mapper/luks_boot /mnt/boot
 mkdir /mnt/boot/efi
 mount /dev/sda1 /mnt/boot/efi
 ```

11. Configure the network(in my case its wi-fi).
```BASH
wifi-menu
```
Choose your wifi network and enable it.

12. Run the following command to install Arch Linux under /mnt
```BASH
pacstrap -i /mnt base base-devel efibootmgr grub vim linux linux-firmware netctl dialog wpa_supplicant
```

13. Generate fstab file
```BASH
genfstab -U /mnt > /mnt/etc/fstab
```

14. chroot into the newly installed Arch Linux.
```BASH
arch-chroot /mnt
```

15. First set up a root password.
```BASH
passwd
```

16. Configure the locale settings with `en_US.UTF-8`.
```BASH
vim /etc/locale.gen #uncomment the line en_US.UTF-8
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
```

17. Configure the timezone settings.
```BASH
ln -sf /usr/share/zoneinfo/YOUR_REGION/YOUR_CIT /etc/localtime
hwclock --systohc --utc #set clock
```

18. set hostname and hosts file.
```BASH
echo YOUR_HOSTNAME > /etc/hostname
touch /etc/hosts
echo "127.0.0.1 localhost" > /etc/hosts
echo "::1 localhost" >> /etc/hosts
```

19. Configure `Grub` settings with LUKS encryption.
```BASH
vim /etc/default/grub
```
Set `GRUB_CMDLINE_LINUX="cryptdevice=/dev/sda3:luks_root"`,`GRUB_ENABLE_CRYPTODISK=y` and save the file.

20. Configure mkinitcpio.
```BASH
vim /etc/mkinitcpio.conf
```
In the HOOKS section, add `encrypt` after `block`.
```BASH
mkinitcpio -p linux
```
Run the above command to generate initrmfs

21. Install GRUB and generate GRUB configuration.
```BASH
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub --recheck
```

22. It is necessary to unlock the boot partition without manual password request.
```BASH
dd bs=512 count=8 if=/dev/urandom of=/etc/key
chmod 400 /etc/key
cryptsetup luksAddKey /dev/sda2 /etc/key
echo "luks_boot /dev/sda2 /etc/key luks" >> /etc/crypttab
```
We need to unlock the boot partition twice: once for GRUB and once for the kernel(initramfs stage).

The boot partition holding the kernel and the initramfs image is unlocked by GRUB, but the boot partition needs to be unlocked again at initramfs stage, regardless whether it’s the same device or not. This is because GRUB boots with the given vmlinuz and initramfs images, but there is currently no way to securely pass cryptographic material (or Device Mapper information) to the kernel. Hence the Device Mapper table is initially empty at initramfs stage; in other words, all devices are locked, and the boot device needs to be unlocked again.

23. Some additional security
```BASH
chmod 700 /boot
```

24. Exit out of chroot and reboot the system.
```BASH
exit
reboot
```

25. Booting in to the LUKS Encrypted Arch Linux.

You should be prompted for your LUKS encryption passphrase that you set earlier in step 7(Boot partition encryption).
Then again you should be prompted for passphrase that you set in step 8(Root partition encryption).
After this, Arch linux will start.

23. (Optional) Use `SoloKey` for [LUKS Encryption](https://github.com/saravanan30erd/solokey-full-disk-encryption).

It is more secure to use hardware secure keys(such as SoloKey) for [LUKS Encryption](https://github.com/saravanan30erd/solokey-full-disk-encryption) passphrase.
