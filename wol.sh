#!/bin/bash

# Get a list of available network interfaces
interfaces=$(ip link | awk -F: '$0 !~ "lo|vir|^[^0-9]"{print $2;getline}')

# Display the list of interfaces to the user with a number for each interface
echo "Available interfaces:"
select interface in $interfaces; do
  if [ -n "$interface" ]; then
    break
  fi
done

sudo apt install ethtool >/dev/null 2>&1
sudo ethtool --change $interface wol g
ethtool_path=$(which ethtool)

#Create Service for startup
cat <<-EOF > /tmp/wol.service
[Unit]
Description=Enable Wake On Lan

[Service]
Type=oneshot
ExecStart = $ethtool_path --change $interface wol g

[Install]
WantedBy=basic.target
EOF

sudo mv /tmp/wol.service /etc/systemd/system/wol.service
sudo systemctl daemon-reload >/dev/null 2>&1
sudo systemctl enable wol.service >/dev/null 2>&1

MAC=$(cat /sys/class/net/$interface/address)
echo -e "\n\033[0;32mWakeOnLan Enabled. Your MAC Address is: $MAC\033[0;32m\n"