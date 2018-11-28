#!/bin/bash
#===============================================================================
#
#          FILE:  logstash_install.sh
#
#         USAGE:  ./logstash_install.sh
#
#   DESCRIPTION:  install/deploy middleware service
#                   MIDDLEWARE      Port    Conf			Path
#                   Kibana			5601    kibana.yml		/opt/kibana*
#       OPTIONS:  ---
#        AUTHOR:  dongni, 2303134@qq.com
#       VERSION:  1.0
#       CREATED:  11/19/2018 15:23:38 CST
#      REVISION:  ---
#===============================================================================

# check root accout
echo -e "\033[40;32mcheck valid root account: \033[0m"
[ $(id -u) -eq 0 ] && echo -e "\troot accout ok!" || {
		echo -e "\t root accout invalid";
		exit 1; }

[ "$local_host_ip" ]  || local_host_ip=$(ip addr | grep inet\ | awk '{print $2}' | grep -v 127* | awk -F/ '{print $1}')

cd $(pwd | awk -Fdeploy '{print $1}')/deploy
work_dir=$(pwd)
install_dir=/opt

unset i
i=$(find $work_dir/ -name "*kibana*tar*" -type f)


if [ "$i" ]; then
	[ "$(echo $i | grep zip)" ] && unzip $i -d $install_dir 1>/dev/null 2>&1 || tar xf $i -C $install_dir
	kibana_dir=$(find $install_dir/kibana* -maxdepth 0)
	sed "s/localhost/$local_host_ip/" $work_dir/conf/kibana.yml > $kibana_dir/config/kibana.yml
	echo -e "\tinstall kibana success!"
else
	echo -e "\t\033[40;32mkibana install package does not exist\033[0m"
	exit 1	
fi
