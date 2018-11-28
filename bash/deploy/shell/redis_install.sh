#!/bin/bash
#===============================================================================
#
#          FILE:  redis_install.sh
#
#         USAGE:  ./redis_install.sh
#
#   DESCRIPTION:  install/deploy dcp middleware service
#                   MIDDLEWARE      Port    Conf		Path
#                   Redis			6379    redis.conf	/opt/redis*
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
i=$(find $work_dir/ -name "*redis*tar*" -type f)

gcc --version 1>/dev/null 2>&1
if [ 0 -eq $? ]; then
	if [ "$i" ]; then
		[ "$(echo $i | grep zip)" ] && unzip $i -d $install_dir 1>/dev/null 2>&1 || tar xf $i -C $install_dir
		redis_dir=$(find $install_dir/redis* -maxdepth 0 -type d)

		cd $redis_dir
		make malloc=libc && make install 1>/dev/null 2>&1
   		cd $work_dir
		redis_conf=$(find ./ -name "redis.conf" -type f)
		/bin/cp -r $redis_conf /etc/
		echo -e "\t\033[40;32minstall redis success!\033[0m"
	else
		echo -e "\033[31;36mredis install file  does not exist\033[0m"
		exit 1
	fi
else
	echo -e "\033[31;36mplease check gcc\033[0m"
	exit 1
fi
