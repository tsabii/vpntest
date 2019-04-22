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

function valid_port()
{
  # check if it is an unsigned integer
  if ! ((($1&65535)==$1)) 2>/dev/null
  then
    # echo "Invalid port number: $1"
    return 1
  fi
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
# How about ignoring non-matching lines (value comma value) and handling them as comments?
# Try it in console, the BASH_REMATCH array:
# # [[ $line =~ ^([0-9.]+),([0-9]+) ]]; echo ${BASH_REMATCH[@]:1}
  IPADDR=${line%,*}
  PORT=${line#*,}

#  validate IPADDR with ipcalc
#  if ipcalc -s -c $IPADDR ;  # does not work due to ipcalc version mismatch
  if valid_ip $IPADDR && valid_port $PORT;
  then # IP address is valid, get to work. In case PORT is not a valid port, netcat will hiss anyways
    # using the return value of netcat with a bashism:
    if MESSAGE=$(nc -z -v -w $NCTO $IPADDR $PORT 2>&1);
    then
      echo "Connection to $IPADDR on port $PORT is OK!"
    else
      echo "Connection to $IPADDR on port $PORT is NOK, message: $MESSAGE"
    fi

   sleep $DBT # slow it down to avoid IPS blocks - we are scanning ports after all

  else # ip address invalid, skip
    echo "  $0: Error in the following line: $IPADDR $PORT"
  fi

done < $1 # the only reason to open a subshell is the implicit declaration of locals like IPADDR etc.

# So long, and thanX for all the fish
exit $?
