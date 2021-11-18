#!/bin/bash

########################################################################
#
#   Controls automatic operations on network connect or disconnect
#   Operates in USERSPACE after shedding root privileges
#
########################################################################

# should be put in /usr/local/bin/....
# $1 is up/down
# use wan_detect to feed current connection information into this script 
# ensure is not already running!!! Only one copy running at a time!
# if down, read ini for down conditions, do it, and exit
# if up, see if any of the network attributes are in "trusted"
# if not, execute "untrusted" 
# otherwise execute "trusted"
