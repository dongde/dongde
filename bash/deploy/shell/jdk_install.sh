#!/bin/bash
#===============================================================================
#
#          FILE:  jdk_install.sh
#
#         USAGE:  ./jdk_install.sh
#
#   DESCRIPTION:  
#
#       OPTIONS:  ---
#        AUTHOR:  dongni, 2303134@qq.com
#       VERSION:  1.0
#       CREATED:  11/08/2018 12:11:34 CST
#      REVISION:  ---
#===============================================================================

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin 
export PATH

echo "install java start"
java -version 1>/dev/null 2>&1
if [ 0 -ne $? ]; then
	jdk_file=$(find ./ -name "*jdk*tar*")
	if [ "$jdk_file" ]; then
		tar xf $jdk_file -C /opt/
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
