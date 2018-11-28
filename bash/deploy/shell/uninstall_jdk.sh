#!/bin/bash
#Author: dongde
#Email : dongde@dongde.org
#Date  : 2018-11-19 16:06:23
#Desc  : uninstall jdk

echo "uninstall jdk"
rm -rf /opt/jdk*
temp=$(cat /etc/profile | grep -n JAVA_HOME | awk -F: '{print $1}' | awk 'NR==1{print}')
[ $temp > 0 ] && sed -i "$temp,$"d /etc/profile || echo "uninstall jdk ok!"
