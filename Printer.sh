#!/bin/bash

#My name is Dakota. This script is to automate testing for unsecure printers.
#Copyright (C) 2015  Dakota Glassburn
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.

IP="0.0.0.0"            # IP to start scanning from
SUB="0"                 # Subnet - How big of a range to scan
MSG="Test"              # What will display on the printer
setIP=false             # To see whether or not an IP and subnet have been set
MAP=0                   # What *map command to use

function msg
{
	clear
	echo "What message do you want displayed?"
	read -e MSG
}

function ip
{
	clear
	echo "Please enter desired IP CORRECTLY!"
	read IP
	echo "Please enter desired subnet i.e. 8,16,24"
	read SUB
	setIP=true
}

function map
{
	MAPS="nmap zmap"
	clear
	echo "Please select which comman (nmap/zmap) you would like to use:"
	select choice in $MAPS; do
		if [ $choice == "zmap" ]; then
			MAP=1
		else
			MAP=0
		fi
	done
}

function run
{
	cd ~/pjllib/pft
	
	if [ $MAP == 1 ]; then
		sudo zmap -p 9100 -o output.txt $IP/$SUB
	else
		nmap -p 9100 -oG - $IP/$SUB | grep "9100" | grep "open" | cut -d " " -f 2 > output.txt
	fi	

	FILE="output.txt"

	cat $FILE | while read LINE
	do
		echo "server $LINE" > mypftscript.txt
		echo "connect" >> mypftscript.txt
		echo "message \"$MSG\"" >> mypftscript.txt
		echo "close" >> mypftscript.txt
	done
	echo "quit" >> mypftscript.txt
	./pft < mypftscript.txt
	cd ~
	
	sleep 1
	clear
	echo "Finished."
	sleep 3
	clear
	exit
}

OPTIONS="Change_IP Change_Message Change_Map Run_Script Print2Printer Exit"
while [ true ]; do
	clear
	echo "Current IP to scan ~>    $IP"
	echo "Current subnet mask ~>   $SUB"
	echo "Message to be displayed:"
	echo "$MSG"
	echo ""
	echo "Please select an option..."
	select opt in $OPTIONS; do
		if [ $opt == "Change_IP" ]; then
			ip
		elif [ $opt == "Change_Message" ]; then
			msg
		elif [ $opt == "Change_Map" ]; then
			map
		elif [ $opt == "Run_Script" ]; then
			if [ $setIP != true ]; then
				echo "IP and Subnet not set"
				sleep 3
			else
				run
			fi
		elif [ $opt == "Exit" ]; then
			clear
			exit
		else
			echo "Not an option silly..."
			sleep 3
		fi
		clear
		echo "Current IP to scan ~>    $IP"
		echo "Current subnet mask ~>   $SUB"
		echo "Message to be displayed:"
		echo "$MSG"
		echo ""
		echo "Please select an option..."
		echo "1) Change_IP"
		echo "2) Change_Message"
		echo "3) Change_Map"
		echo "4) Run_Script"
		echo "5) Print2Printer"
		echo "6) Exit"
	done
done

# Things to get done:
# 	Mess with other settings
