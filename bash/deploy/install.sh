#!/bin/bash
#===============================================================================
#
#          FILE:  install.sh
#
#         USAGE:  ./install.sh
#
#   DESCRIPTION:
#
#       OPTIONS:  ---
#        AUTHOR:  dongni, 2303134@qq.com
#       VERSION:  1.0
#       CREATED:  11/09/2018 16:11:08 CST
#      REVISION:  ---
#===============================================================================

# Deploy Scheme List:
#-------------------------------------------------------------------------------
#	Scheme 1(all in one)
#-------------------------------------------------------------------------------
#		|dmdbms|mysql		|	install_dmdbms.sh | install_mysql
#		|middleware			|	middleware.sh(include tools_install.sh)
#-------------------------------------------------------------------------------
#	Scheme 2
#-------------------------------------------------------------------------------
#		|dmdbms|mysql		|	install_dmdbms.sh | install_mysql
#		|middleware	select	|	middleware_select.sh(include tools_install.sh)
#--------------------------------------------------------------------------------

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin

unset work_dir
cd $(pwd | awk -Fdeploy '{print $1}')/deploy
work_dir=$(pwd)
install_dir=/opt

while :
do
	echo "install database: mysql[m], dameng[d]"
	read -p "Please select the installed database: [d/m] " para_d
	if [ x"d" == x"$para_d" ]; then
		echo -e "\tinstall dameng database"
		source shell/install_dmdbms.sh
		break
	elif [ x"m" == x"$para_d" ]; then
		echo -e "\tinstall mysql database"
		source shell/install_mysql.sh
		break
	#else
	#	echo "must choose a database installation"
	#	exit 0
	fi
done

sleep 1

echo -e "\033[41;39mmiddleware deploy 1: \033[0m\033[40;32mall in one\033[0m"
echo -e "\033[41;39mmiddleware deploy 2: \033[0m\033[40;32mselect install\033[0m"

read -p "please select deploy scheme[1/2]: " para_s

case $para_s in
1)
	echo -e "\033[41;39mdeploy scheme 1: \033[0m\033[40;32mAll in one\033[0m"
	echo -e "\tinstall middleware"
	source shell/middleware.sh
	;;
2)
	echo -e "\033[41;38mdeploy scheme 2: \033[0m\033[40;32mselect install\033[0m"
	echo -e "\tchoose to install middleware"
	source shell/middleware_select.sh
	;;
*)
	echo "please input number:[1/2]"
esac

#################################################################################
