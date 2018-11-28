#!/bin/bash
#===============================================================================
#
#          FILE:  port_whitelist.sh
#
#         USAGE:  ./port_whitelist.sh
#
#   DESCRIPTION: Check if the whitelist port can be used.
#
#       OPTIONS:  ---
#        AUTHOR:  dongni, 2303134@qq.com
#       VERSION:  1.0
#       CREATED:  11/14/2018 15:50:19 CST
#      REVISION:  ---
#===============================================================================

# Check lsof tool and white_port file
lsof -v 1>/dev/null 2>&1 || exit 0
[ -f ./conf/whitelist_port ] || exit 0

# Get port whitelist
port_whitelist=($(grep -E '[[:digit:]]' conf/whitelist_port | sort | uniq))

# Subscript of the array
n=0
# Save an array of valid/invalid ports
port_valid=()
port_invalid=()

# Traversing port whitelist
for i in "${port_whitelist[@]}"
do
	lsof -i :$i 1>/dev/null 2>&1
	[ 0 -ne $? ] && port_valid[$n]=$i || port_invalid[$n]=$i
	n=$(expr $n+1)
done

echo -e "\033[41;36mport_valid:\033[0m\n\t${port_valid[@]}"
echo -e "\033[41;36mport_invalid:\033[0m\n\t${port_invalid[@]}"
