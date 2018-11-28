#!/bin/bash
#===============================================================================
#
#          FILE:  elasticsearch_install.sh
#
#         USAGE:  ./elasicsearch_install.sh
#
#   DESCRIPTION:  install/deploy dcp middleware service
#                   MIDDLEWARE      Port    Conf		Path
#                   Elasticsearch	9200    			/opt/elasticsearch*
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

cd $(pwd | awk -Fdeploy '{print $1}')/deploy
work_dir=$(pwd)
install_dir=/opt

unset i
i=$(find $work_dir/ -name "*elasticsearch*tar*" -type f | grep -v ik)

if [ "$i" ]; then
	[ "$(echo $i | grep zip)" ] && unzip $i -d $install_dir 1>/dev/null 2>&1 || tar xf $i -C $install_dir

	es_dir=$(find $install_dir/elasticsearch* -maxdepth 0)
	es_ik_file=$(find $work_dir/middleware -name "elasticsearch*ik*")

	if [ "$es_ik_file" ]; then
		if echo $es_ik_file | grep tar 1>/dev/null 2>&1; then
			tar xf $es_ik_file -C $es_dir/plugins 
		elif echo $es_ik_file | grep zip 1>/dev/null 2>&1; then
			unzip $es_ik_file -d $es_dir/plugins 1>/dev/null 2>&1
		fi
	else
		echo -e "\t\033[40;32minstall elasticsearch-analysis-ik failed, please check ./middleware/elasticsearch-analysis-ik file\033[0m"
		exit 1
	fi

	echo -e "\t\033[40;32m setup elasticsearch linux-login account \033[0m"
	if ! id es 1>/dev/null 2>&1; then
		echo -e "\t\033[40;32m add user elasticsearch account: 'es/123456' \033[0m"
		adduser es && echo '123456' | passwd --stdin es	
	else
		echo '123456' | passwd --stdin es
		echo -e "\t\033[40;36m elasticsearch login account: es/123456 \033[0m"
	fi

	echo -e "network.host: 0.0.0.0\nxpack.security.enabled: true" >> $es_dir/config/elasticsearch.yml
	echo -e "\tchange own elasticsearch directory"
	chown -R es:es $es_dir

	echo -e "\t\033[40;32melasticsearch install success!\033[0m"
else
	echo -e "\033[31;36melasticsearch install file  does not exist\033[0m"
	exit 1
fi
