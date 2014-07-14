#!/bin/bash
#
# You only need this script if you are using WICD
# Copy this script to /etc/wicd/scripts/postconnect

connection_type="$1"
essid="$2"
interface=$(ip route show 0.0.0.0/0 | awk '{print $5}')
/usr/local/bin/02networkcontrol "$interface" down "$essid" &