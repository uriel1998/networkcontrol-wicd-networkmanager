# networkcontrol-wicd-networkmanager
==================================

A program to automagically call (and shut down) network utilities like Dropbox and traffic shaping programs.  Written to work with both WICD and Network-Manager

This originally started with this and has grown into something quite a big larger.
<http://ideatrash.net/2013/10/getting-auto-login-window-on-public.html>
<https://gist.github.com/uriel1998/6942365>


## Contents
 1. [About](#1-about)
 2. [License](#2-license)
 3. [Prerequisites](#3-prerequisites)
 4. [Installation](#4-installation)
 5. [Usage](#5-usage)
 6. [TODO](#6-todo)

***
 
## 1. About


## 2. License

This project is licensed under the MIT license. For the full license, see `LICENSE`.

## 3. Prerequisites

### These may already be installed on your system.


### Optional


## 4. Installation

### For **both** Network Manager *and* WICD

* Clone or download the repository and place it in a directory of your choice.  
* Edit `02networkcontrol` (in the `emitters` directory) with the USERNAME to be used.  
* Edit `02networkcontrol` (in the `emitters` directory) with the full path to `network-middle-manager.sh`.  
* Put `02networkcontrol` in `/etc/NetworkManager/dispatcher.d/02networkcontrol`.  
* `sudo chmod +x /etc/NetworkManager/dispatcher.d/02networkcontrol`
* Edit `network-middle-manager.ini` (see below).  
* You can leave `network-middle-manager.ini` in the same directory or copy it to `$HOME/.config/network-middle-manager.ini`  
* Set up your automatic processes.  

### WICD only steps

* Put `up.sh`  (in the `emitters` directory) in `/etc/wicd/scripts/preconnect`
* Put `down.sh` (in the `emitters` directory) in `/etc/wicd/scripts/postconnect`
* `sudo chmod +x /etc/wicd/scripts/preconnect/up.sh`
* `sudo chmod +x /etc/wicd/scripts/preconnect/down.sh`

### network-middle-manager.ini

The format is simple; all networks are considered **UN**trusted except for the 
ones you mark as trusted.  Trusted networks can be identified either by the 
SSID or the MAC address of the gateway.  `wan_detect.sh` will give you that 
information for the **first** connected network.  (Network Manager will connect 
to both a wired and wireless connection at the same time.)  The gateway MAC 
address should not change, even if you have a VPN running.  `latency` is planned 
for future use; just leave it as it is.

**IMPORTANT** Do not have any extra blank SSID or MAC lines

```
[DEFAULT]
latency=10

[Trusted]
SSID=mySSIDisboring
MAC=1a:2b:3c:4d:5e:6f
```

### Set up actions

This part requires `YAD`, or manually editing files. 

All actions are designed to happen in *userspace*.  Run `setup-function.sh` in 
the directory where you placed `network-middle-manager`.  Put the full path to 
the command you wish to run, any arguments on the next line, and use the dropdown 
to determine whether the command should be run on a *trusted* network, an *untrusted* 
network, or upon **any** network disconnect.

For example, I use [Private Internet Access](http://www.privateinternetaccess.com/pages/buy-a-vpn/1218buyavpn?invite=U2FsdGVkX1-SlyUtdYwtLcS0OJw83in87Dz9uyrKJUg%2CrHt7_wHO3z0c-uDZrCuQPIxALTo) (referral link).  

I am going to only use it with untrusted networks, so my first setup task is: 

```
Task: /usr/local/bin/piactl
Args: connect
ActionType: untrusted
```

My second is 

```
Task: /usr/local/bin/piactl
Args: disconnect
ActionType: disconnect
```

This creates the plugins using the `template.txt` file and puts them in the right 
directory.  If you decide to manually create these, BASENAME is the basename of 
the command, TASKNAME and TASKARGS are hopefully obvious, and they should be 
copied into the appropriate plugin directory.

This *will* fail if you have multiple commands with the same command (e.g. `/bin/bash`),
so in that case I recommend making (or using) a script with the commands with the 
same base command name to run.  It's all in userspace, so it's up to you!

Likewise, if you have a script that you need to run as another user (or root), 
(such as my [script for UFW](https://uriel1998.github.io/ufw-iptables-archer/)), 
contain that inside another script as well.  

Note: PIA requires either the applet running or for you to have the daemon running 
by issuing the command `/usr/local/bin/piactl background enable` beforehand. 

## 5. Usage

Relog or reboot to make sure that network-manager or wicd is aware of the new 
scripts. `network-middle-manager` will run the commands you told it to on network 
connection or disconnection as the user you defined. 

## 6. Todo

 * Have wan_detect be able to deal with multiple simultaneous connections.
 * Actually use the latency bit.
 * the .keep files are literally so the empty directories exist; maybe set those up instead?
