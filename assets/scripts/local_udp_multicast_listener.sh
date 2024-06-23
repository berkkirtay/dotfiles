#!/bin/bash
# Copyright (c) 2024 Berk Kirtay

MULTICAST_ADDRESS="224.0.0.1"
MULTICAST_PORT="9999"

connected_interfaces=$(nmcli device status | grep -w 'connected' )
echo "Current connected interfaces are:\n$connected_interfaces"

active_interface=$(echo $connected_interfaces | head -n 1 | awk '{print $1}')

echo $active_interface

# Joining the multicast group:
sudo ip maddr add ${MULTICAST_ADDRESS} dev ${active_interface}

# Peeking into UDP multicast messages:
nc -vv -l -s ${MULTICAST_ADDRESS} -p ${MULTICAST_PORT} -u