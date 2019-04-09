#!/bin/bash
#================================================================
#
#  @Author        : dongde
#  @Mail          : dongde@dongde.org
#  @github        : https://github.com/dongde
#  @Created Time  : 2019-04-09 14:22:01
#  @Last Modified : 2019-04-09 14:22:01

#  @File Name     : install_jdk1.8.0_171.sh
#  @Description   :

#================================================================

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

    chmod -R 755 /opt/jdk1.8.0_171

	java -version 1>/dev/null 2>&1 && echo -e "\tinstall jdk success\n"
else
	echo -e "\tjdk already exist\n"
fi

