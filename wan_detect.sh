#!/bin/bash

##############################################################################
# wan_detect, by Steven Saus 17 Nov 2021
# steven@stevesaus.com
# Licenced under the MIT
# Checks for first interface, LAN ip4 address, WAN ip4 address.
# Checks WAN address multiple ways if the others fail.
# -q : No headers on output.
# -s : Only the WAN ip, and exit code 99 if fail, 0 if success
# -v : Only the exit code 99 if fail, 0 if success
# eg result=$(./wan_detect.sh -v; echo $?); if [ $result -eq 0 ];then ... ; fi
##############################################################################  

IFACE=""
LAN_IP=""
WAN_IP=""

get_iface (){
    # -m1 only matches the first - can put in a loop later to catch all
    IFACE=$(netstat -nr | grep -m1 ^0.0.0.0 | awk -F " " '{print $8}')
}

get_lan_ip (){
    LAN_IP=$(ip -4 addr show dev "$IFACE" | grep inet | awk '{print $2}' | cut -d '/' -f 1)
}

get_wan_ip_dig (){
    result=$(dig +short myip.opendns.com @resolver1.opendns.com)
    if [ -z "$result" ];then
        result=$(dig +short myip.opendns.com @resolver2.opendns.com)
        if [ -z "$result" ];then
            result=$(dig +short myip.opendns.com @resolver3.opendns.com)
            if [ -z "$result" ];then
                result=$(dig +short myip.opendns.com @resolver4.opendns.com)
            fi
        fi
    fi
    # last sanity check
    if [ -n "$result" ];then
        if [[ $result =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            WAN_IP="$result"
        else
            WAN_IP=""
        fi
    fi

    
}


get_wan_ip_3rdparty () {
	result=$(curl --silent ipecho.net/plain)
	if [ -n $result ]; then
		WAN_IP="$result"
	else
		result=$(curl --silent ident.me)
        if [ -n $result ]; then
            WAN_IP="$result"
		else
            result=$(curl --silent checkip.amazonaws.com)
            if [ -n $result ]; then
        		WAN_IP="$result"
            else
                result=$(curl --silent ifconfig.me)
                if [ -n $result ]; then
                    WAN_IP="$result"
                else
                    result=$(curl --silent icanhazip.com)
                    if [ -n $result ]; then
                        WAN_IP="$result"
                    else
                        result=$(curl --silent ifconfig.co)
                        if [ -n $result ]; then
                            WAN_IP="$result"
                            echo "$WAN_IP"
                        fi
                    fi
                fi
            fi
        fi
    fi
}





main (){
    get_iface
    get_lan_ip "$IFACE"
    get_wan_ip_dig
    if [ -z "$WAN_IP" ];then
        get_wan_ip_3rdparty
    fi

    if [ "$QUIET" = 3 ];then 
        if [ "$WAN_IP" != "" ];then
            exit 0
        else
            exit 99
        fi
    fi


    if [ "$QUIET" = 2 ];then 
        if [ "$WAN_IP" != "" ];then
            echo "$WAN_IP"
            exit 0
        else
            exit 99
        fi
    fi
        

    if [ "$QUIET" = 1 ];then
        echo "$IFACE"
        echo "$LAN_IP"
        echo "$WAN_IP"
    else    
        echo "Interface: $IFACE"
        echo "LAN: $LAN_IP"
        echo "WAN: $WAN_IP"
    fi
    exit 0
}

# Quiet, for parsing
if [ "$1" == "-q" ];then 
    QUIET=1
fi

# super quiet - just emits WAN ip and exit code 99 if not there.
if [ "$1" == "-s" ];then 
    QUIET=2
fi

# VERY quiet - just emits WAN ip and exit code 99 if not there.
if [ "$1" == "-v" ];then 
    QUIET=3
fi


main
