# SecureOS

## steps

1. Prepare the USB device as bootable medium. In my case, `disk3` is USB device.
```
  dd if=/Users/saravanan/Downloads/archlinux-2020.04.01-x86_64.iso of=/dev/disk3 bs=1m
```

2. Boot the system with USB and select the `Arch Linux archiso x86_64 UEFI CD` from the boot menu
by pressing `F12`.

3. You should be logged into the Arch Linux console. You can install Arch Linux from here.

4. Clone the SecureOS script in the system.
You need to configure the Wi-Fi using wifi-menu command.
```
  wifi-menu
```
```
  git clone https://github.com/saravanan30erd/SecureOS
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

11. Enable Secure Boot in UEFI.
```
  ./secureos secure-boot
```

12. Encrypt the boot partition using TPM 2.0.
```
  ./secureos tpm2luks
```
