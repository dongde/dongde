#!/bin/bash
#===============================================================================
#
#          FILE:  dmdbms_install.sh
#
#         USAGE:  ./dmdbms_install.sh
#
#   DESCRIPTION:  install dameng database system
#
#       OPTIONS:  ---
#        AUTHOR:  dongni, 2303134@qq.com
#       VERSION:  1.0
#       CREATED:  11/08/2018 11:57:48 CST
#      REVISION:  ---
#===============================================================================

echo -e "execute $0"

# check root accout
echo -e "\033[40;32mCheck valid root account: \033[0m"
[ $(id -u) -eq 0 ] && echo -e "\troot accout ok!" || {
		echo -e "\t root accout invalid";
		exit 1; }

cd $(pwd | awk -Fdeploy '{print $1}')/deploy
work_dir=$(pwd)
install_dir=/opt

unset i
i=$(find $work_dir/ -name "*dmdbms*" -type f)

## install DMdbms
echo -e "\033[40;32minstall dmdbms\033[0m"
if [ "$i" ]; then
	dm_dir=$(find /opt/ -name "dmdbms")
	if [ "$dm_dir" ]; then
		echo -e "\tdmdbms already exist"
	else
		echo -e "\tinstalling dmdbms, please wait"
		[ $(echo $i | grep zip) ] && unzip $i -d $install_dir || tar xf $i -C $install_dir
	fi
else
	echo -e "\tdmdbms install package does not exist"
	exit 1
fi

echo -e "\tPlease refer to dmdbms_install.sh Initialization dameng DB"

#echo "##usage:"
#echo -e "\tinit dmdbms"
#echo -e "\tcd $install_dir/dmdbms/bin"
#echo -e "\t./dminit"
#echo -e "\t initdb V7.1.6.46-Build(2018.02.08-89107)ENT"
#echo -e "\t db version: 0x7000a"
#echo -e "\t file dm.key not found, use default license!"
#echo -e "\t License will expire on 2019-02-08"
#echo -e "\tinput system dir: /opt/dmdbms"
#echo -e "\tinput db name: dcp7777"
#echo -e "\tinput port num: 7777"
#echo -e "\tinput page size(4, 8, 16, 32): 32"
#echo -e "\textent size(16, 32): 32"
#echo -e "\tinput time zone(-12:59,+14:00): +8:00"
#echo -e "\tstring case sensitive? ([Y]es, [N]o): n"
#echo -e "\twhich charset to use? (0[GB18030], 1[UTF-8], 2[EUC-KR]): 1"
#echo -e "\tlength in char? ([Y]es, [N]o): n"
#echo -e "\tenable database encrypt? ([Y]es, [N]o): n"
#echo -e "\tpage check mode? (0/1/2): 0"
#echo -e "\tinput elog path: /opt/dmdbms/errorlog"
#echo -e "\tauto_overwrite mode? (0/1/2): 0"
#echo -e "\t log file path: $install_dir/dmdbms/dcp7777/dcp777701.log"
#echo -e "\t log file path: $install_dir/dmdbms/dcp7777/dcp777702.log"
#echo -e "\t write to dir [$install_dir/dmdbms/dcp7777]."
#echo -e "\t create dm database success. 2018-11-07 18:16:26"

#echo "start service"
#echo -e "\tcd $install_dir/dmdbms/bin"
#echo -e "\tnohup ./dmserver ../dcp/dm.ini  &      		## listen 5236"
#echo -e "\tnohup ./dmserver ../dcp7777/dm.ini  &		## listen 7777"
################################################################################
