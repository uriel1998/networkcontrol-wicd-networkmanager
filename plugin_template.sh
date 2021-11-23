#!/bin/bash

##############################################################################
#
#  base template for netocto plugin
#  (c) Steven Saus 2021
#  Licensed under the MIT license
#
##############################################################################

function command_name_plugin {

local COMMAND=
local ARGS=
local commandstring=$(printf "%s %s" "$COMMAND" "$ARGS")
eval "${commandstring}"

}

##############################################################################
# Are we sourced?
# From http://stackoverflow.com/questions/2683279/ddg#34642589
##############################################################################

# Try to execute a `return` statement,
# but do it in a sub-shell and catch the results.
# If this script isn't sourced, that will raise an error.
$(return >/dev/null 2>&1)

# What exit code did that give?
if [ "$?" -eq "0" ];then
    echo "[info] Function ready to go."
else
    echo -e "This is only meant to be sourced, mate."
fi
