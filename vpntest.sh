#!/bin/bash

# simple port tester bash script by tsabi, originally used to check VPN connections
# "There are many like it, but this one is mine."
# Input: text file with lines containing [IP addr],[port] , one per line.
# File name specified in first parameter

# ConstantZ:
NCTO=5 # NetCat TimeOut
DBT=2  # Delay Between Tries


# valid_ip function stolen from 
# http://www.linuxjournal.com/content/validating-ip-address-bash-script
function valid_ip()
{
    [[ .${1:-} =~ ^(\.([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])){4}$ ]] || return 1
}


# check parameter is given or not
if [ $# -ne 1 ];
then
  echo -e "\n$0: Error - Parameter required: filename with [IP addr],[port] format lines.\n"
  exit 1
fi

# check file existence
if [ ! -f $1 ];
then
  echo -e "\n$0: Error - File $1 does not exist!\n"
  exit 2
fi

# echo "OK, file exists"

while read line
do 
  IPADDR=`echo $line | cut -d"," -f1`
  PORT=`echo $line | cut -d"," -f2`

#  validate IPADDR with ipcalc
#  if ipcalc -s -c $IPADDR ;  # does not work due to ipcalc version mismatch
  if valid_ip $IPADDR ; 
  then # IP address is valid, get to work. In case PORT is not a valid port, netcat will hiss anyways.
    MESSAGE=`nc -z -v -w $NCTO $IPADDR $PORT 2>&1`
    # using the return value of netcat:
    if [ $? -eq "0" ];
    then
      echo "Connection to $IPADDR on port $PORT is OK!"
    else
      echo "Connection to $IPADDR on port $PORT is NOK, message: $MESSAGE"
    fi

   sleep $DBT # slow it down to avoid IPS blocks - we are scanning ports after all

  else # ip address invalid, skip
    echo "$0: Warning - Bad IP address found: $IPADDR"
  fi

done < $1

# So long, and thanX for all the fish
exit 0

