#!/bin/bash

#################################################################################
#
# This utility is to test if you're connected to the network you want to (or NOT connected) 
# by Steven Saus
#
# Licensed under a MIT License
#
################################################################################

show_help () {
 
    echo "network_detect.sh --[match|unmatch] [MAC address|SSID|html file]"
    echo "exit code of 0 on success, 99 on fail. Also emits success|fail to STDOUT"
    exit 1
    
}

# is looking for positive match
if [ "$1" == "--match" ]; then  
    MatchType=True
else 
    if [ "$1" == "--unmatch" ]; then  
        MatchType=False
    else
        show_help
    fi
fi


scratch=$(echo "$2" | grep -o : | wc -l)

if [ $scratch = 5 ];then
    MatchMethod=MAC
    MatchString="${2,,}"
else
    scratch=$(echo "$2" | grep -c "://")
    if [ $scratch = 1 ];then
        MatchMethod=URL
        # cannot be tolowered, due to possible caps of URL
        MatchString="$2"
    else
        MatchMethod=SSID
        MatchString="${2,,}"
    fi
fi



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
