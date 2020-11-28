# Boot partition encryption with SoloKey

1. Create the new config file for boot parition encryption.
```
cp /etc/skfde.conf /etc/skfde-boot.conf
```

2. Configure the new config file created for boot parition encryption.
```
SKFDE_LUKS_DEV="/dev/sda2"
```
`sda2` is boot partition

```
SKFDE_LUKS_NAME="luks_boot"
```

Use `skfde-cred` to create new solokey credential for `SKFDE_CREDENTIAL`,
```
SKFDE_CREDENTIAL="<solokey credential>"
```

Set the challenge,
```
SKFDE_CHALLENGE="<random text>"
```

3. Use `skfde-enroll` to add solokey passphrase for boot partition,
```
skfde-enroll -d /dev/sda2 -c /etc/skfde-boot.conf
```

4. Create new skfde `hook` file for boot partition
```
cp /usr/lib/initcpio/hooks/skfde /usr/lib/initcpio/hooks/skfde-boot
sed -i s,/etc/skfde.conf,/etc/skfde-boot.conf,g /usr/lib/initcpio/hooks/skfde-boot
```

```
cp /usr/lib/initcpio/install/skfde /usr/lib/initcpio/install/skfde-boot
sed -i s,/etc/skfde.conf,/etc/skfde-boot.conf,g /usr/lib/initcpio/install/skfde-boot
```

5. Update new skfde hook `skfde-boot` in intiramfs stage,
Edit `/etc/mkinitcpio.conf` and add the `skfde-boot` hook after `skfde`.

After making the changes, run the below command to regenerate the initramfs.

```
skfde-load
```
