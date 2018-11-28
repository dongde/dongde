#!/bin/bash
#===============================================================================
#
#          FILE:  install_mysql.sh
#
#         USAGE:  ./install_mysql.sh
#
#   DESCRIPTION:  rpm install mysql
#
#       OPTIONS:  ---
#        AUTHOR:  dongni, 2303134@qq.com
#       VERSION:  1.0
#       CREATED:  11/08/2018 11:54:32 CST
#      REVISION:  ---
#===============================================================================

echo -e "\ninstall execute $0"
echo -e "\033[40;32minstall mysql\033[0m"

# check root accout
echo -e "\033[40;32mCheck valid root account: \033[0m"
[ $(id -u) -eq 0 ] && echo -e "\troot accout ok!" || {
		echo -e "\t root accout invalid";
		exit 1; }

cd $(pwd | awk -Fdeploy '{print $1}')/deploy
work_dir=$(pwd)
install_dir=/opt

unset i
i=$(find $work_dir/ -name "*mysql*" -type f)

## install perl
echo "Start install perl"
perl --version 1>/dev/null 2>&1 
if [ 0 -ne $? ];then  
	perl_file=$(find $work_dir/ -name "perl_rpm*")
	if [ "$perl_file" ]; then
		tar xf $perl_file
		rpm -ivh --force --nodeps perl_rpm/*.rpm
		[ 0 -eq $? ] && echo -e "\tInstall perl success"
		rm -rf $work_dir/perl_rpm
	else
		echo "perl install package does not exist"
		exit 1
	fi
fi

## install autoconf
echo "Start install autoconf"
autoconf --version 1>/dev/null 2>&1 
if [ 0 -ne $? ];then  
	autoconf_file=$(find $work_dir/ -name "autoconf_rpm*")
	if [ "$autoconf_file" ]; then
		tar xf $autoconf_file
		rpm -ivh --force --nodeps autoconf_rpm/*.rpm
		[ 0 -eq $? ] && echo -e "\tInstall autoconf success"
		rm -rf $work_dir/autoconf_rpm
	else
		echo "autoconf install package does not exist"
		exit 1
	fi
fi

## install mysql
cd $work_dir
echo "Start install MySQL"
lsof -i:3306 1>/dev/null 2>&1 
if [ 0 -ne $? ]; then
	echo "port:3306 had used!" 
	exit 1
fi

autoconf --version 1>/dev/null 2>&1 && perl --version 1>/dev/null 2>&1
if [ 0 -eq $? ]; then
	db_dir=/usr/local/mysql
	mkdir -p $db_dir
	mysql_file=$(find $work_dir/ -name "mysql*tar*")
	if [ "$mysql_file" ]; then
		tar xf $mysql_file -C $db_dir --strip-components 1
	else
		echo "mysql install package does not exist"
		exit 1
	fi

	mkdir -p /var/log/mysql
	touch /var/log/mysql/mysql.log

	cd $db_dir
	groupadd mysql
	useradd -r -g mysql mysql
	chown -r mysql:mysql ./ 
	./scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data
	chown -r root:root ./ 
	chown -r mysql:mysql data
	cp $db_dir/support-files/mysql.server /etc/init.d/mysql

	/bin/cp -r $work_dir/conf/my.cnf /etc/my.cnf
	ln -s /usr/local/mysql/bin/mysqld /usr/local/bin/mysqld
	ln -s /usr/local/mysql/bin/mysql /usr/local/bin/mysql
	ln -s /usr/local/mysql/bin/mysqladmin /usr/local/bin/mysqladmin
fi

echo "Start Mysql"
/etc/init.d/mysql start
ln -s /usr/local/mysql/data/mysql.sock /tmp/mysql.sock

echo "### Create database: 'kms' (Please press ENTER) ###"
/usr/local/mysql/bin/mysqladmin -uroot -p create kms 

echo "### privileges other machines ip login default passwd "123456" (please press enter) ###"
/usr/local/mysql/bin/mysql -uroot -p -e "grant all privileges on *.* to 'root'@'%' identified by '123456' with grant option; flush privileges;"

echo "### set local root account login password "123456" (please press enter) ###"
#echo "### set localhost root account login password ###"
#read -p "set localhost root account login password:" -s passwd
/usr/local/mysql/bin/mysql -uroot -p -e "set password = password('123456'); flush privileges;"

echo "### Stop mysql service ###"
/usr/local/mysql/support-files/mysql.server stop

echo "### End install mysql ###"

############################################################################
