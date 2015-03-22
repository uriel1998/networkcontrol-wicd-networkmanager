networkcontrol-wicd-networkmanager
==================================

A program to automagically call (and shut down) network utilities like Dropbox and traffic shaping programs.  Written to work with both WICD and Network-Manager

This originally started with this and has grown into something quite a big larger.
<http://ideatrash.net/2013/10/getting-auto-login-window-on-public.html>
<https://gist.github.com/uriel1998/6942365>

# Requirements

* [WICD](https://launchpad.net/wicd)  
OR
* [NetworkManager](https://wiki.gnome.org/Projects/NetworkManager)

AND (these are probably already installed or easily available from your package manager/distro)

* [logger](http://linux.about.com/library/cmd/blcmdl1_logger.htm)
* [arp](http://linux.about.com/library/cmd/blcmdl8_arp.htm)
* [iproute2](http://www.linuxfoundation.org/collaborate/workgroups/networking/iproute2)
* [awk](http://www.gnu.org/software/gawk/manual/gawk.html)
* [grep](http://en.wikipedia.org/wiki/Grep)
* [wireless-tools](http://en.wikipedia.org/wiki/Wireless_tools_for_Linux)

OPTIONAL

* [wondershaper](http://www.hecticgeek.com/2012/02/simple-traffic-shaping-ubuntu-linux/) Here's how you [modify it for LAN use](http://ideatrash.net/2014/07/making-wondershaper-play-nice-on-lan.html)
* [InSync](https://www.insynchq.com/r/109458505937185551876)
* [Dropbox](http://db.tt/PeYcFIot)
* ...and whatever else you would need in some locations but not others.

# Installation

I recommend storing the actual script in your home directory and putting symlinks as appropriate.  The installation assumes that you have put *02networkcontrol* in /home/YOURUSERNAME/scripts, otherwise called ~/scripts .

## Editing the Configuration File

Some manual editing of the configuration file is necessary, as is knowing the MAC address and/**OR** SSID of the networks you wish to connect to.  If you know both the MAC address and SSID it's obviously better and less likely to cause you problems.  

It's pretty easy to find the right gateway MAC address:

	arp -n -a $(ip route show 0.0.0.0/0 | awk '{print $3}') | awk '{print $4}'

But you can use the [MAC address generator](http://www.miniwebtool.com/mac-address-generator/) to make up fake ones.

The configuration file has to be a little finicky, because there is [*no* standard that governs SSIDs](http://stackoverflow.com/questions/4919889/is-there-a-standard-that-defines-what-is-a-valid-ssid-and-password).  So, the configuration file is defaulted to ~/.config/networkcontrol.conf

There are two key lines that **have** to be at the top, each a single word followed by a single space and then a value.  The first is 

	separator 

with the character(s) following not appearing in any saved SSIDs.  The default in the example is @@, but you can do whatever you like.

The next line is 

	latencydelay 

(again, with a single space following) with a number in seconds.  This number is how long the script will wait to make sure you're really offline before doing the network shutdown commands (for example, if you're switching from wireless to wired or vice-versa).  

Then there is a blank line, followed by

	@@shutdown

After that follows any number of commands to be executed when ANY network goes down (e.g. you go offline). At present, variables are NOT passed in the shutdown mode, so the script automatically checks to see if wondershaper is installed and will shut it down.  Anything else is executed *exactly* as it is listed in the configuration file.

After the shutdown commands there is again a blank space, followed by this line that needs to stay intact

	@@interface@@eSSID@@macaddress

Each interface needs to have its own line, followed by the commands you want to run on connection, one per line.  You can even have a default line:

	@@interface@@default@@00:00:00:00:00:00

If there's only one match for a MAC address or SSID, the program will not pay attention to what interface it is.  If there's more than one, however, it makes sure that it has the right interface... which means you can have separate programs fire up on connection if you're on a wired connection instead of a wireless connection.  For example, my wireless card is **wlan0** and my wired card is **eth0**.

	@@eth0@@default@@00:00:00:00:00:00
	/command/to/execute
	@@wlan0@@default@@00:00:00:00:00:00
	/different/commands
	/to/execute/on/the/road

Again, the separator character(s) can be anything you like - they just can't appear in any SSIDs you've configured.

## Debugging - What if my scripts don't run?

If commands are not being executed, your problem may be that WICD (and perhaps network-manager) are running any script commands *as the root user*.  You can get around this by using 

su -l USERNAME /command/to/execute

in networkcontrol.conf



## WICD Installation 

	mkdir -p ~/scripts
	cp ./02networkcontrol ~/scripts
	chmod +x ~/scripts/02networkcontrol
	sudo ln -s ~/scripts/02networkcontrol /usr/local/bin
	cp ./networkcontrol.conf ~/.config
	sudo ln -s ~/.config/networkcontrol.conf /etc
	chmod +x up.sh
	sudo mkdir -p /etc/wicd/scripts/preconnect
	sudo cp up.sh /etc/wicd/scripts/preconnect
	chmod +x down.sh
	sudo mkdir -p /etc/wicd/scripts/postconnect
	sudo cp down.sh /etc/wicd/scripts/postconnect

## Network-Manager Installation

	mkdir -p ~/scripts
	cp ./02networkcontrol ~/scripts
	chmod +x ~/scripts/02networkcontrol
	sudo ln -s ~/scripts/02networkcontrol /etc/NetworkManager/dispatcher.d
	cp ./networkcontrol.conf ~/.config	
	sudo ln -s ~/.config/networkcontrol.conf /etc
	
# One-Liners

To get the gateway MAC address without checking the sticker:

	arp -n -a $(ip route show 0.0.0.0/0 | awk '{print $3}') | awk '{print $4}'

To get the current interface (this only works well with WICD, as Network-Manager will report two simultaneous connections via iptools)

	arp -n -a | awk '{print $7}'

	ip route | head -1 | awk '{print $5}'


## Testing Network-Manager installations

*Test the up condition:* sudo /etc/NetworkManager/dispatcher.d/02networkcontrol wlan0 up  
*Test the down condition:* sudo /etc/NetworkManager/dispatcher.d/02networkcontrol wlan0 down  

## Testing WICD installations

*Test the up condition:* sudo /usr/local/bin/02networkcontrol wlan0 up  
*Test the up condition:* sudo /usr/local/bin/02networkcontrol wlan0 down 

# Credits and where a lot of this started

http://www.techytalk.info/start-script-on-network-manager-successful-connection/

http://askubuntu.com/questions/13963/call-script-after-connecting-to-a-wireless-network

http://sysadminsjourney.com/content/2008/12/18/use-networkmanager-launch-scripts-based-network-location/
