# Wipe the RAM during shutdown and reboot

Install the `secure-delete` package from [ArchStrike](https://archstrike.org/wiki/setup),

    pacman -S secure-delete

Copy the wipe script to the server,

    cp shutdown_ramwipe /usr/local/bin/
    chmod +x /usr/local/bin/shutdown_ramwipe

Configure the systemd service,

    cp ram-wipe.service /usr/lib/systemd/system/
    systemctl daemon-reload
    systemctl enable ram-wipe.service
    systemctl start ram-wipe.service
