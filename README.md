# SecureOS

## steps

1. Prepare the USB device as bootable medium. In my case, `disk3` is USB device.
```
  dd if=/Users/saravanan/Downloads/archlinux-2020.04.01-x86_64.iso of=/dev/disk3 bs=1m
```

2. Boot the system with USB and select the `Arch Linux archiso x86_64 UEFI CD` from the boot menu
by pressing `F12`.

3. You should be logged into the Arch Linux console. You can install Arch Linux from here.

Note: You need to use `iwctl` command to manually connect the Wi-Fi at this stage.
```
  $ setfont iso01-12x22.psfu.gz
  
  $ iwctl
  [iwd]# device list
  [iwd]# station [device] scan
  [iwd]# station [device] get-networks
  [iwd]# staion [device] connect [SSID]

  # onliner
  $ iwctl --passphrase [password] station [device] connect [SSID]
```
Note: Use the below commands to install prerequisites
  ```
  $ pacman -Sy
  $ pacman -S git glibc
  ```
4. Clone the SecureOS script in the system.
```
  git clone https://github.com/saravanan30erd/SecureOS # on local network http://192.168.2.84/secure-laptop/secureos.git
  cd SecureOS
  chmod +x secureos
```

5. Arch Linux Installation before chroot.
```
  ./secureos install
```

6. Arch Linux Installation after chroot.
```
  arch-chroot /mnt
  ./secureos install-chroot
```

In this stage, Arch Linux Installation will be completed.
Reboot the system and enter into the newly installed Arch Linux system.
You can use `nmcli` command to manually connect the Wi-Fi at this stage.
Also you need to repeat the step 4.

```
   nmcli device wifi connect [SSID] password [WiFi Password]
```

7. Automatically reboot if any USB device is removed from the system.
```
  ./secureos usb-auto-reboot
```

8. Wipe the RAM during shutdown and reboot.
```
  ./secureos ram-wipe
```

9. Configure MAC address randomization.
```
  ./secureos random-mac
```

10. Encrypt the root partition using SoloKey.
```
  ./secureos solokey
```
Reboot and login the system using SoloKey.
Once the SoloKey authentication works, please remove the weak manual password we set for `/dev/sda3`.
```
cryptsetup luksRemoveKey /dev/sda3
```

11. Enable Secure Boot in UEFI.
Note: Refer [here](https://github.com/saravanan30erd/secureboot) for prerequisites
```
  ./secureos secure-boot
```
Reboot and verify the secure boot status using `bootctl status`

12. Encrypt the boot partition using TPM 2.0.
```
  ./secureos tpm2luks
```
# secureos-laptop
