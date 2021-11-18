#!/bin/bash

#################################################################################
#
# This utility is to be able to easily and quickly return the network characteristics
# I'm interested in for NMM.  Yes, you can do this by hand or by looking at interface loops. 
# by Steven Saus
#
# Licensed under a MIT License
#
################################################################################

MAC=""
SSID=""

case "$MatchMethod" in 
    MAC)
        scratch=$(arp -n -a $(ip route show 0.0.0.0/0 | awk '{print $3}') | awk '{print $4}' | head -1)
        ActualString="${scratch,,}"
        if [ "$ActualString" == "$MatchString" ];then
            Status="MATCH"
        fi
        ;;
    URL)
        if curl --head --fail --silent "$MatchString" >/dev/null;then
            Status="MATCH"
        fi       
        ;;
    SSID)
        scratch=$(iwgetid -r)
        ActualString="${scratch,,}"
        if [ "$ActualString" == "$MatchString" ];then
            Status="MATCH"
        fi
        ;;
    *)
        ;;
esac

# using both exit codes and emitting a result so it can be used either way.

if [ "$MatchType" = "True" ];then
    if [ "$Status" = "MATCH" ];then       
        echo "success"  # wanted match, found match
        exit 0
    else
        echo "fail"     # wanted match, no match found
        exit 99
    fi
else
    if [ -z "$Status" ];then
        echo "success"  # wanted no match, no match found
        exit 0
    else
        echo "fail"     # wanted no match, match found
        exit 99
    fi        
fi
