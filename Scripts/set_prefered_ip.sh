#!/bin/bash

# Get primary interface (first non-loopback interface with an IP)
INTERFACE=$(ip -o addr show | awk '$2 !~ /lo/ && $3 == "inet" {print $2; exit}')
if [ -z "$INTERFACE" ]; then
    echo "Error: No network interface found."
    exit 1
fi

# Get current IP and subnet
IP_INFO=$(ip -o addr show dev "$INTERFACE" | awk '$3 == "inet" {print $4; exit}')
if [ -z "$IP_INFO" ]; then
    echo "Error: No IP found for $INTERFACE."
    exit 1
fi

# Extract subnet and mask using ipcalc
SUBNET=$(ipcalc "$IP_INFO" | grep Network | awk '{print $2}' | cut -d'/' -f1)
MASK=$(ipcalc "$IP_INFO" | grep Network | awk '{print $2}' | cut -d'/' -f2)
if [ -z "$SUBNET" ] || [ -z "$MASK" ]; then
    echo "Error: Could not determine subnet or mask."
    exit 1
fi

# Calculate desired IP ending in .69
DESIRED_IP=$(echo "$SUBNET" | sed 's/\.[0-9]*$/.69/')
FULL_IP="$DESIRED_IP/$MASK"

# Check if .69 is in use (using arp-scan, requires root)
if sudo arp-scan --interface="$INTERFACE" --localnet | grep -q "$DESIRED_IP"; then
    echo "Error: $DESIRED_IP is already in use."
    exit 1
fi

# Get gateway
GATEWAY=$(ip route | awk '/default via/ {print $3; exit}')
if [ -z "$GATEWAY" ]; then
    echo "Error: No gateway found."
    exit 1
fi

# Remove existing IP (if any)
sudo ip addr flush dev "$INTERFACE"

# Assign the new IP
sudo ip addr add "$FULL_IP" dev "$INTERFACE"
sudo ip route add default via "$GATEWAY" dev "$INTERFACE"

# Update systemd-networkd config to persist
CONFIG_FILE="/etc/systemd/network/20-wired.network"
sudo mkdir -p /etc/systemd/network
cat << EOF | sudo tee "$CONFIG_FILE" > /dev/null
[Match]
Name=$INTERFACE

[Network]
Address=$FULL_IP
Gateway=$GATEWAY
DNS=8.8.8.8
DNS=8.8.4.4
EOF

# Restart systemd-networkd
sudo systemctl enable systemd-networkd
sudo systemctl restart systemd-networkd

echo "Assigned $FULL_IP to $INTERFACE."
