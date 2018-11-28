#!/bin/bash
#===============================================================================
#
#          FILE:  middleware_install.sh
#
#         USAGE:  ./middleware_install.sh
#
#   DESCRIPTION:  install/deploy dcp middleware service
#                   MIDDLEWARE                  Port    Path
#                   Redis                       6379    /opt/redis*
#                   Elasticsearch               9200    /opt/elasticsearch*
#                   Zookeeper(QuorumPeerMain)   2181    /opt/zookeeper*
#                   Kafka                       9092    /opt/kafka*
#                   Logstash                    9600    /opt/logstash*
#                   Kibana                      5601    /opt/kibana*
#
#       OPTIONS:  ---
#        AUTHOR:  dongni, 2303134@qq.com
#       VERSION:  1.0
#       CREATED:  09/19/2018 15:23:38 CST
#      REVISION:  ---
#===============================================================================

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin 
export PATH

echo -e "\nexecute $0"

cd $(pwd | awk -Fdeploy '{print $1}')/deploy
work_dir=$(pwd)
install_dir=/opt

#0# install basic tools/env
echo "install tools"
source shell/tools_install.sh

#1# check root accout
echo -e "\033[40;32mcheck valid root account: \033[0m"
[ $(id -u) -eq 0 ] && echo -e "\troot accout ok!" || {
		echo -e "\t root accout invalid";
		exit 1; }

#2# get host ip
echo -e "\033[40;32mGet localhost ip: \033[0m"
local_host_ip=$(ip addr | grep inet\ | awk '{print $2}' | grep -v 127* | awk -F/ '{print $1}')
echo -e "\tlocalhost ip: $local_host_ip"


echo -e "\033[41;33mJust install, don't start the service\033[0m"

middleware_install_files=($(ls -1 shell/*_install.sh | grep -v "jdk\|tools"))
declare -a installed_service not_installed_service

for sh_file in "${middleware_install_files[@]}"
do
	# back to work_dir
	cd $work_dir
	echo -e "\033[40;32minstall $sh_file:\033[0m"

	service_name=$(basename $sh_file | awk -F_ '{print $1}')

	sleep 1
	read -p "please confirm whether to install $service_name: [y/n] " para_ins
	[ x"y" == x"$para_ins" ] && { source $sh_file;installed_service+=($sh_file); }
	[ x"n" == x"$para_ins" ] && not_install_service+=($sh_file)
done

echo "installed service list:"
echo -e "\t$(echo ${installed_service[@]} | sed 's/\ /\n\t/g')"

echo "not installed service list:"
echo -e "\t$(echo ${not_installed_service[@]} | sed 's/\ /\n\t/g')"

## notice
echo -e "\033[41;36mFor set elasticsearch/kibana/logstash_system/beats_system password:\033[0m"
echo -e "\t\033[41;36mPlease execute:\033[0m \033[40;32mbash es_xpack_setup.sh\033[0m, setup elasticsearch service password"

###############################################################################
