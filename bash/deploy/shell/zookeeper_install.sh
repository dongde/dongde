#!/bin/bash
#===============================================================================
#
#          FILE:  zookeeper_install.sh
#
#         USAGE:  ./zookeeper_install.sh
#
#   DESCRIPTION:  install/deploy middleware service
#                   MIDDLEWARE      Port    Conf		Path
#                   Zookeeper		2181   	zoo.cfg		/opt/zookeeper*
#       OPTIONS:  ---
#        AUTHOR:  dongni, 2303134@qq.com
#       VERSION:  1.0
#       CREATED:  11/19/2018 15:23:38 CST
#      REVISION:  ---
#===============================================================================

# check root accout
echo -e "\033[40;32mCheck valid root account: \033[0m"
[ $(id -u) -eq 0 ] && echo -e "\troot accout ok!" || {
		echo -e "\t root accout invalid";
		exit 1; }

[ "$local_host_ip" ]  || local_host_ip=$(ip addr | grep inet\ | awk '{print $2}' | grep -v 127* | awk -F/ '{print $1}')


cd $(pwd | awk -Fdeploy '{print $1}')/deploy
work_dir=$(pwd)
install_dir=/opt

unset i
i=$(find $work_dir/ -name "*zookeeper*tar*" -type f)

if [ "$i" ]; then
	[ "$(echo $i | grep zip)" ] && unzip $i -d $install_dir 1>/dev/null 2>&1 || tar xf $i -C $install_dir

	zk_dir=$(find $install_dir/zookeeper* -maxdepth 0 -type d)

	mkdir -p $zk_dir/{data,logs}
	/bin/cp -r $work_dir/conf/zoo.cfg $zk_dir/conf/zoo.cfg
	echo "dataDir=$zk_dir/data"    >> $zk_dir/conf/zoo.cfg
	echo "dataLogDir=$zk_dir/logs" >> $zk_dir/conf/zoo.cfg

	## add zk env /etc/profile
	declare +x ZOOKEEPER_HOME

	ZOOKEEPER_HOME=$zk_dir
cat >>/etc/profile<<EOF

ZOOKEEPER_HOME=$zk_dir
PATH=$ZOOKEEPER_HOME/bin:$PATH
export ZOOKEEPER_HOME PATH
EOF
	source /etc/profile
	echo -e "\tinstall zookeeper success!"
else
	echo -e "\t\033[40;32mzookeeper install package does not exist\033[0m"
	exit 1	
fi
