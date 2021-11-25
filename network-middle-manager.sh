#!/bin/bash

########################################################################
#
#   Controls automatic operations on network connect or disconnect
#   Operates in USERSPACE after shedding root privileges
#
#  (c) Steven Saus 2021
#  Licensed under the MIT license
#
########################################################################

TRUSTED=""
MYPID=""
MYSSID=""
GATEMAC=""
INIFILE=""
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"


# $1 is up/down OR SETUP
# use wan_detect to feed current connection information into this script 
# if down, read ini for down conditions, do it, and exit
# if up, see if any of the network attributes are in "trusted"
# if not, execute "untrusted" 
# otherwise execute "trusted"
# Setup uses YAD and the template

get_pid () {
    MYPID=$(echo "$$")
}

is_already_running () {
    if [ -f "${SCRIPT_DIR}"/nmm.pid ];then
        echo "Network Middle Manager already running. There can be only one." 1>&2
        exit 98
    else
        get_pid
        echo "$MYPID" > "${SCRIPT_DIR}"/nmm.pid
    fi
}

find_ini () {
    if [ -f "$HOME"/.config/network-middle-manager.ini ];then
        INIFILE="$HOME"/.config/network-middle-manager.ini
    else
        if [ -f "$SCRIPT_DIR"/network-middle-manager.ini ];then
            INIFILE="$SCRIPT_DIR"/network-middle-manager.ini
        else
            echo "No INI file found in $HOME/.config or $SCRIPT_DIR!" 1>&2
            exit 96
        fi
    fi
}


run_untrusted () {

    modules=$(/usr/bin/find "$SCRIPT_DIR/plugin_untrusted" -type f | sed 's/.sh//g' | grep -v ".keep" | sed 's/$/.sh&/p' | awk '!_[$0]++' )    

    for m in $modules;do
        modulename=$(basename "$m")
        if [ "$m" != ".keep" ];then 
            echo "Processing ${modulename%.*} for UNtrusted network"
            run_funct="${modulename%.*}_plugin"
            source "$m"
            eval "${run_funct}"
        fi
    done

}

run_trusted () {

    modules=$(/usr/bin/find "$SCRIPT_DIR/plugin_trusted" -type f| sed 's/.sh//g' | grep -v ".keep" | sed 's/$/.sh&/p' | awk '!_[$0]++' )    
    for m in $modules;do
        modulename=$(basename "$m")
        if [ "$m" != ".keep" ];then 
            echo "Processing ${modulename%.*} for trusted network"
            run_funct="${modulename%.*}_plugin"
            source "$m"
            eval "${run_funct}"
        fi
    done
   
}

determine_network_stats () {
    result=$("${SCRIPT_DIR}"/wan_detect.sh -q)
    MYSSID=$(echo "$result" | sed '2!d')
    GATEMAC=$(echo "$result" | sed '3!d')
}

determine_if_trusted () {

if grep -Fxq "$MYSSID" "$INIFILE"; then
    TRUSTED="1"
else
    if grep -Fxq "$GATEMAC" "$INIFILE"; then
        TRUSTED="1"
    else
        TRUSTED=""
    fi
fi

    
}

run_disconnect () {

    modules=$(/usr/bin/find "$SCRIPT_DIR/plugin_disconnect" -type f | sed 's/.sh//g' | grep -v ".keep" | sed 's/$/.sh&/p' | awk '!_[$0]++' )    
    for m in $modules;do
        modulename=$(basename "$m")
        if [ "$m" != ".keep" ];then 
            echo "Processing ${modulename%.*} for disconnection"
            run_funct="${modulename%.*}_plugin"
            source "$m"
            eval "${run_funct}"
        fi
    done
}

show_help () {
    echo "Usage: network-middle-manager.sh [-u|-d|-s|-h]"
    echo -e "-u: Network up\n-d: Network down\n-s: Execute setup\n-h: See this help"
    exit
}

flow_control () {
    case "$1" in
        -u) 
            determine_network_stats
            determine_if_trusted
            if [ "$TRUSTED" == "1" ];then
                run_trusted
            else
                run_untrusted
            fi
            ;;
        -d) 
            run_disconnect
            ;;
        -s) 
            ;;
        -h) 
            show_help
            ;;
    esac
}

cleanup () {
    if [ -f "${SCRIPT_DIR}"/nmm.pid ];then
        VPID=$(head -1 "${SCRIPT_DIR}"/nmm.pid)
        if [ "$VPID" == "$MYPID" ];then
            rm "${SCRIPT_DIR}"/nmm.pid
        fi
    fi
    exit 0
}

# main bit
            
is_already_running
find_ini
flow_control "$1"
cleanup
