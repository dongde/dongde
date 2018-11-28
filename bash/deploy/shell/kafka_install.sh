#!/bin/bash
#===============================================================================
#
#          FILE:  kafka_install.sh
#
#         USAGE:  ./kafka_install.sh
#
#   DESCRIPTION:  install/deploy middleware service
#                   MIDDLEWARE      Port    Conf				Path
#                   Kafka			9092    server.properties	/opt/kafka*
#       OPTIONS:  ---
#        AUTHOR:  dongni, 2303134@qq.com
#       VERSION:  1.0
#       CREATED:  11/19/2018 15:23:38 CST
#      REVISION:  ---
#===============================================================================

# check root accout
echo -e "\033[40;32mcheck valid root account: \033[0m"
[ $(id -u) -eq 0 ] && echo -e "\troot accout ok" || {
		echo -e "\t root accout invalid";
		exit 1; }

[ "$local_host_ip" ]  || local_host_ip=$(ip addr | grep inet\ | awk '{print $2}' | grep -v 127* | awk -F/ '{print $1}')


cd $(pwd | awk -Fdeploy '{print $1}')/deploy
work_dir=$(pwd)
install_dir=/opt

unset i
i=$(find $work_dir/ -name "*kafka*tgz*" -type f)

if [ "$i" ]; then
	[ "$(echo $i | grep zip)" ] && unzip $i -d $install_dir 1>/dev/null 2>&1 || tar xf $i -C $install_dir

	kafka_dir=$(find $install_dir/kafka* -maxdepth 0 -type d | grep -v manager)
	mkdir -p $kafka_dir/logs
	if [ $(grep "localhost" ./conf/server.properties | wc -l) -eq 2 ]; then
		sed "s/localhost/$local_host_ip/" $work_dir/conf/server.properties > $kafka_dir/config/server.properties
	else
		echo -e "Please check file: \033[41;36m server.properties\033[0m"
	fi
else
	echo -e "\t\033[40;32mkafka install package does not exist\033[0m"
	exit 1	
fi
