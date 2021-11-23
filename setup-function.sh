#!/bin/bash
    
########################################################################
#	Using YAD to make a quick setup for netocto Nmm, whatever i call it
#   by Steven Saus (c)2021
#   Licensed under the MIT license
#
########################################################################
export SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
# Name
# command to run
# args
# trusted, untrusted, down
# why not use --file-selection?  Because that takes over the window.
runupon="\!trusted\!untrusted\!disconnect"

OutString=$(yad --form --title="Configure NMM plugin" --width=400 --center --window-icon=gtk-info --borders 3 --field="Task" New_Task --field="Args" "" --field="ActionType:CBE" ${runupon})


NewTask=$(echo "$OutString" | awk -F '|' '{print $1}') 
if [ "$NewTask" == "New_Task" ];then
    echo "Task not edited; exiting"
    exit 88
fi
if [ "$NewTask" == "" ];then
    echo "Empty task; exiting"
    exit 88
fi

NewArgs=$(echo "$OutString" | awk -F '|' '{print $2}') 

NetType=$(echo "$OutString" | awk -F '|' '{print $3}')
if [ "$NetType" == "" ];then
    echo "Action type not defined;exiting."
    exit 88
fi

NameOfTask=$(basename "${NewTask}")

cat ${SCRIPT_DIR}/template.txt | sed  "s@BASENAME@${NameOfTask}@g" | sed  "s@TASKNAME@${NewTask}@g" | sed  "s@TASKARGS@${NewArgs}@g" > ${SCRIPT_DIR}/${NetType}/${NameOfTask}.sh
