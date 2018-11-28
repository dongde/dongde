#!/bin/bash
#===============================================================================
#
#          FILE:  uninstall.sh
# 
#         USAGE:  ./uninstall.sh
# 
#   DESCRIPTION:  uninstall basic/tools/middleware
# 
#       OPTIONS:  ---
#        AUTHOR:  dongni, 2303134@qq.com
#       VERSION:  1.0
#       CREATED:  09/26/2018 16:39:36 CST
#      REVISION:  ---
#===============================================================================

echo -e "\ninstall execute $0"

echo "uninstall jdk"
read -p "Whether to confirm uninstall: [y/n]" para_j
if [ x"y" == x"$para_j" ]; then
	rm -rf /opt/jdk*
	temp=$(cat /etc/profile | grep -n JAVA_HOME | awk -F: '{print $1}' | awk 'NR==1{print}')
	[ $temp > 0 ] && sed -i "$temp,$"d /etc/profile || echo "uninstall jdk ok!"
fi

echo "uninstall tomcat"
read -p "Whether to confirm uninstall: [y/n]" para_t
if [ x"y" == "x$para_t" ]; then
	ps -ef | grep -i tomcat | grep -iv tomcat 1>/dev/null 2>&1 && echo "uninstall tomcat ok" || rm -rf /opt/tomcat* 
fi

echo "uninstall node"
read -p "Whether to confirm uninstall: [y/n]" para_n
if [ x"y" == x"$para_m" ]; then
	rm -rf /opt/node*
	rm -f /usr/local/bin/npm
	rm -f /usr/local/bin/node
fi

echo "uninstall mysql"
read -p "Whether to confirm uninstall: [y/n]" para_m
if [ x"y" == x"$para_m" ]; then
	ps -ef | grep -i mysql | grep -iv grep 1>/dev/null 2>&1
	if [ 0 -eq $? ]; then
		/usr/local/mysql/support-files/mysql.server stop
		rm -rf /etc/init.d/mysql
		rm -rf /usr/local/mysql
		rm -rf /usr/local/bin/mysql*
		rm -rf /tmp/mysql.sock
	fi
fi


echo "uninstall dmdbms"
read -p "Whether to confirm uninstall: [y/n]" para_d
if [ x"y" == x"$para_d" ]; then
	ps -ef | grep -i dmserver | grep -iv grep 1>/dev/null 2>&1
	if [ 0 -eq $? ]; then
		/usr/local/mysql/support-files/mysql.server stop
		rm -rf /etc/init.d/mysql
		rm -rf /usr/local/mysql
		rm -rf /usr/local/bin/mysql*
		rm -rf /tmp/mysql.sock
	fi
fi
[ 0 -eq $? ] && echo "###### Uninstall completed! ######"
