#!/bin/bash
#===============================================================================
#
#          FILE:  install_tools.sh
#
#         USAGE:  ./install_tools.sh
#
#   DESCRIPTION:  sys optimize, install tools, gcc, node, jdk
#
#       OPTIONS:  ---
#        AUTHOR:  dongni, 2303134@qq.com
#       VERSION:  1.0
#       CREATED:  11/08/2018 09:11:39 CST
#      REVISION:  ---
#===============================================================================

#PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin 
#export PATH

[ "$work_dir" ]    || work_dir=$(pwd)
[ "$install_dir" ] || install_dir=/opt

#1# check root accout
echo -e "\033[40;32mcheck valid root account: \033[0m"
[ $(id -u) -eq 0 ] && echo -e "\troot accout ok" || exit 1

#2# system optimize
echo -e "\033[40;32mstart system optimize: \033[0m"
##1 network card startup
#sed -i 's/ONBOOT=no/ONBOOT=yes/' $(ls /etc/sysconfig/network-scripts/ifcfg-* | grep -v ifcfg-lo)

##2 Disabled firewall, open remote port access
echo -e "\tdisabled firewalld.service"
systemctl list-unit-files firewalld.service | grep enabled 1>/dev/null 2>&1
[ 0 -eq $? ] && systemctl stop firewalld && systemctl disable firewalld

systemctl list-unit-files firewalld.service | grep disabled 1>/dev/null 2>&1
[ 0 -eq $? ] && echo -e "\tdisabled firewalld.sevice success" || exit 0

##3 configurature /etc/sysctl.conf
echo -e "\tconfigurature /etc/sysctl.conf"
cat /etc/sysctl.conf | grep vm.max_map_count=262144 1>/dev/null 2>&1
if [ 0 -ne $? ]; then
cat >>/etc/sysctl.conf<<EOF

vm.max_map_count=262144
EOF
sysctl -p
fi

##4 configurature /etc/security/limits.conf
echo -e "\tconfigurature /etc/security/limits.conf"
ulimit -n | grep 65536 1>/dev/null 2>&1
if [ 0 -ne $? ]; then
cat >>//etc/security/limits.conf<<EOF

* hard nofile 65536
* soft nofile 65536
* soft noproc 65536
* hard noproc 65536
EOF

fi

##5 improve entropy ##
#echo "display system entropy:"
#cat /proc/sys/kernel/random/entropy_avail
# optimize scheme:
#	install haveged  "haveged.1.9.4.tar.xz"
#		tar xvf *.tar.xz
#		./haveged/configure
#		./haveged/autoreconf -ivf
#		./haveged/make && ./haveged/make install
#	https://github.com/jirka-h/haveged
#	https://www.archlinux.org/packages/extra/x86_64/haveged/

#3# install tools: lsof+wget+net-tools
echo -e "\033[40;32minstall basic tools:\033[0m"
#lsof#
rpm -qa | grep lsof 1>/dev/null 2>&1 && echo -e "\tlsof install success" || rpm -ivh tools/lsof-4.87-5.el7.x86_64.rpm
#wget#
rpm -qa | grep wget 1>/dev/null 2>&1 && echo -e "\twget install success" || rpm -ivh tools/wget-1.14-15.el7_4.1.x86_64.rpm
#unzip#
rpm -qa | grep unzip 1>/dev/null 2>&1 && echo -e "\tunzip install success" || rpm -ivh tools/unzip-6.0-19.el7.x86_64.rpm
#net-tools#
rpm -qa | grep net-tools 1>/dev/null 2>&1 && echo -e "\tnetstat install success" || rpm -ivh tools/net-tools-2.0-0.22.20131004git.el7.x86_64.rpm
#tree#
rpm -qa | grep tree 1>/dev/null 2>&1 && echo -e "\ttree install success" || rpm -ivh tools/tree-1.6.0-10.el7.x86_64.rpm
#tmux#
rpm -qa | grep tmux 1>/dev/null 2>&1
if [ 0 -ne $? ]; then
	if [ -f ./tools/tmux_rpm.tar.xz ]; then
		tar xf ./tools/tmux_rpm.tar.xz
		rpm -ivh ./tmux_rpm/*.rpm
		[ 0 -eq $? ] && echo -e "\ttmux install success"
		rm -rf ./tmux_rpm/
	fi
else
	echo -e "\ttmux install success"
fi

#4# install gcc
echo -e "\033[40;32minstall gcc\033[0m"
rpm -qa | grep '\<gcc\>' 1>/dev/null 2>&1 
if [ 0 -ne $? ]; then
	if [ -f ./tools/gcc* ]; then
		tar xf ./tools/gcc*
		rpm -ivh --force --nodeps ./gcc_rpm/*.rpm
		if [ 0 -eq $? ]; then 
			echo -e "\t\033[40;32minstall gcc success!\033[0m"
			rm -rf ./tmux_rpm/
		else
			echo -e "\t\033[40;32minstall gcc failed!\033[0m"
			rm -rf ./tmux_rpm/
			exit 0
		fi
	fi
fi
echo -e "\tgcc install success"

#5# install node
echo -e "\033[40;32minstall node\033[0m"
node -v 1>/dev/null 2>&1
if [ 0 -ne $? ]; then
	if [ -f ./basic/node* ]; then
		tar xf ./basic/node*tar* -C /opt/
		node_dir=$(find /opt/node* -maxdepth 0)
		ln -s $node_dir/bin/npm /usr/local/bin/npm 1>/dev/null 2>&1
		ln -s $node_dir/bin/node /usr/local/bin/node 1>/dev/null 2>&1
		echo -e "\t\033[40;32mnode version:$(node -v)\033[0m"
	fi
fi
echo -e "\tnode install success"

#6# install jdk
echo -e "\033[40;32minstall jdk\033[0m"
source /etc/profile && java -version 1>/dev/null 2>&1
if [ 0 -ne $? ]; then
	jdk_file=$(find ./ -name "*jdk*tar*")
	if [ "$jdk_file" ]; then
		tar xf $jdk_file -C $install_dir
	else
		echo "jdk install package does not exist"
		exit 1
	fi

	declare +x JAVA
	declare +x JRE_HOME

	JAVA_HOME=/opt/jdk1.8.0_171
	JRE_HOME=$JAVA_HOME/jre

cat >>/etc/profile<< EOF

JAVA_HOME=/opt/jdk1.8.0_171
JRE_HOME=$JAVA_HOME/jre
PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH
export JAVA_HOME JRE_HOME PATH CLASSPATH
EOF

	source /etc/profile
	java -version 1>/dev/null 2>&1 && echo -e "\tinstall jdk success\n"
else
	echo -e "\tjdk already exist\n"
fi

################################################################################
