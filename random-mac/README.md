# Configure MAC address randomization

Copy the configuration file to system,

    cp random_mac.conf /etc/NetworkManager/conf.d/

Restart the NetworkManager service,

    systemctl restart NetworkManager
