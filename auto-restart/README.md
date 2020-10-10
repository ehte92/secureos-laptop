# Auto Restart when SoloKey is removed

You can use the below command to obtain the device-specific information,

    udevadm monitor --kernel --property --subsystem-match=usb

With the command running, remove the SoloKey device from the system.
You can find many properties, copy the `PRODUCT` under `ACTION=remove`.
Example,

    PRODUCT=90c/1000/1100

Replace the `SOLOKEY_PRODUCT_ID` with value of `PRODUCT` in 85-remove-solokey.rules.

You can copy the udev rules and script to the system,

    cp 85-remove-solokey.rules /etc/udev/rules.d/
    cp solo-restart /usr/local/bin/
    chmod +x /usr/local/bin/solo-restart

Reload the udev rules,

    udevadm control --reload-rules
    systemctl reload systemd-udevd

Now you can remove the SoloKey device and system should auto restart.

# Auto Restart if any USB device is removed

Copy the udev rules,

    cp 85-remove-usb.rules /etc/udev/rules.d/
    cp solo-restart /usr/local/bin/
    chmod +x /usr/local/bin/solo-restart

Reload the udev rules,

    udevadm control --reload-rules
    systemctl reload systemd-udevd
