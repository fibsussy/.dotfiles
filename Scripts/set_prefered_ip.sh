#!/bin/bash

# Ensure NetworkManager and tools are installed
command -v nmcli >/dev/null 2>&1 || { echo "NetworkManager not installed"; exit 1; }
command -v arping >/dev/null 2>&1 || { echo "arping not installed"; exit 1; }
command -v ping >/dev/null 2>&1 || { echo "ping (iputils) not installed"; exit 1; }

# Get active connection and interface
CONNECTION=$(nmcli -t -f NAME,DEVICE con show --active | grep -v '^$' | head -n1)
[ -z "$CONNECTION" ] && { echo "No active connection found"; exit 1; }
CON_NAME=$(echo "$CONNECTION" | cut -d: -f1)
INTERFACE=$(echo "$CONNECTION" | cut -d: -f2)

# Detect network base IP, subnet, and gateway
NET_INFO=$(ip -4 addr show "$INTERFACE" | grep inet | awk '{print $2}' | head -n1)
[ -z "$NET_INFO" ] && { echo "No IP info for $INTERFACE"; exit 1; }
BASE_IP=$(echo "$NET_INFO" | cut -d. -f1-3)
SUBNET_MASK=$(echo "$NET_INFO" | cut -d/ -f2)
GATEWAY=$(ip route | grep default | grep "$INTERFACE" | awk '{print $3}' | head -n1)

# Fallback defaults
[ -z "$BASE_IP" ] && BASE_IP="192.168.1"
[ -z "$SUBNET_MASK" ] && SUBNET_MASK="24"
[ -z "$GATEWAY" ] && GATEWAY="$BASE_IP.1"

echo "Warning: Ensure IPs $BASE_IP.69 to $BASE_IP.100 are outside DHCP range to avoid conflicts."

# Get current IP from connection profile
CURRENT_IP=$(nmcli -t -f ipv4.addresses con show "$CON_NAME" | cut -d: -f2 | cut -d/ -f1)

# Find first available IP starting from .69
START=69
END=100
DESIRED_IP=""
for i in $(seq $START $END); do
    IP="$BASE_IP.$i"
    # Skip conflict check if IP matches current interface IP
    if [ "$IP" = "$CURRENT_IP" ]; then
        DESIRED_IP="$IP"
        break
    fi
    if ! arping -c 1 -w 1 -I "$INTERFACE" "$IP" >/dev/null 2>&1 && ! ping -c 1 -W 1 "$IP" >/dev/null 2>&1; then
        DESIRED_IP="$IP"
        break
    fi
done

[ -z "$DESIRED_IP" ] && { echo "No available IP in range $START to $END"; exit 1; }

# Check if current IP matches desired IP
if [ "$CURRENT_IP" = "$DESIRED_IP" ]; then
    echo "IP already set to $DESIRED_IP/$SUBNET_MASK with Gateway $GATEWAY for $CON_NAME"
    exit 0
fi

# Set IP and gateway in NetworkManager
nmcli con mod "$CON_NAME" ipv4.method manual ipv4.addresses "$DESIRED_IP/$SUBNET_MASK" ipv4.gateway "$GATEWAY"
nmcli con up "$CON_NAME"
echo "Assigned IP: $DESIRED_IP/$SUBNET_MASK, Gateway: $GATEWAY to $CON_NAME"
exit 0
