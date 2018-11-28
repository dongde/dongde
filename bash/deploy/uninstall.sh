#!/bin/bash
#===============================================================================
#
#          FILE:  uninstall.sh
# 
#         USAGE:  ./uninstall.sh
# 
#   DESCRIPTION:  uninstall basic/tools/middleware
# 
#       OPTIONS:  ---
#        AUTHOR:  dongni, 2303134@qq.com
#       VERSION:  1.0
#       CREATED:  09/26/2018 16:39:36 CST
#      REVISION:  ---
#===============================================================================

read -p "Whether to confirm execution: [y/n]" para_confirm
[ x"n" == x"$para_confirm" ] && exit 1

echo "install execute $0"

echo "uninstall jdk"
rm -rf /opt/jdk*
temp=$(cat /etc/profile | grep -n JAVA_HOME | awk -F: '{print $1}' | awk 'NR==1{print}')
[ $temp > 0 ] && sed -i "$temp,$"d /etc/profile

echo "uninstall tomcat"
ps -ef | grep -i tomcat | grep -iv grep 1>/dev/null 2>&1 && echo "uninstall tomcat ok" || rm -rf /opt/tomcat* 

echo "uninstall mysql"
ps -ef | grep -i mysql | grep -iv grep 1>/dev/null 2>&1
if [ 0 -eq $? ]; then
	/usr/local/mysql/support-files/mysql.server stop
	rm -rf /etc/init.d/mysql
	rm -rf /usr/local/mysql
	rm -rf /usr/local/bin/mysql*
	rm -rf /tmp/mysql.sock
fi

echo "uninstall node"
rm -rf /opt/node*
rm -f /usr/local/bin/npm
rm -f /usr/local/bin/node

echo "uninstall elashticsearch"
ps -ef | grep elasticsearch | grep -v grep 1>/dev/null 2>&1
[ 0 -eq $? ] && kill -9 $(ps -ef | grep  elasticsearch | grep -v grep | awk '{print $2}')
id es 1>/dev/null 2>&1 
[ 0 -eq $? ] && userdel -r es
rm -rf /opt/elasticsearch*
echo -e "\tuninstall elasticsearch success!"

echo "uninstall redis"
ps -ef | grep redis | grep -v grep 1>/dev/null 2>&1
[ 0 -eq $? ] && kill -9 $(ps -fe | grep redis | grep -v grep | awk '{print $2}')
rm -rf /opt/redis*
echo -e "\tuninstall redis success!"

echo "uninstall zookeeper"
ps -ef | grep zookeeper | grep -v grep 1>/dev/null 2>&1
[ 0 -eq $? ] && kill -9 $(ps -ef | grep  zookeeper | grep -v grep | awk '{print $2}')
rm -rf /opt/zookeeper*
echo -e "\tuninstall zookeeper success!"

echo "uninstall kafka-manager"
ps -ef | grep kafka-manager | grep -v grep 1>/dev/null 2>&1
[ 0 -eq $? ] && kill -9 $(ps -ef | grep  kafka-manager | grep -v grep | awk '{print $2}')
rm -rf /opt/kafka-manager*
echo -e "\tuninstall kafka-manager success!"

echo "uninstall kafka"
ps -ef | grep kafka | grep -v grep 1>/dev/null 2>&1
[ 0 -eq $? ] && kill -9 $(ps -ef | grep  kafka | grep -v grep | awk '{print $2}')
rm -rf /opt/kafka*
echo -e "\tuninstall kafka success!"


# hava a questions
echo "uninstall kibana"
ps -ef | grep kibana | grep -v grep 1>/dev/null 2>&1
[ 0 -eq $? ] && kill -9 $(ps -ef | grep  kibana | grep -v grep | awk '{print $2}')
rm -rf /opt/kibana*
echo -e "\tuninstall kibana success!"

echo "uninstall logstash"
ps -ef | grep logstash | grep -v grep 1>/dev/null 2>&1
[ 0 -eq $? ] && kill -9 $(ps -ef | grep  logstash | grep -v grep | awk '{print $2}')
rm -rf /opt/logstash*
echo -e "\tuninstall logstash success!"

echo "uninstall dmdbms"
ps -ef | grep dmdbms | grep -v grep 1>/dev/null 2>&1
[ 0 -eq $? ] && kill -9 $(ps -ef | grep  dmdbms | grep -v grep | awk '{print $2}')
rm -rf /opt/dmdbms*
echo -e "\tuninstall dmdbms success!"

[ 0 -eq $? ] && echo "###### Uninstall completed! ######"
