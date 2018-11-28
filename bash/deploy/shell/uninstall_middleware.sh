#!/bin/bash
#===============================================================================
#
#          FILE:  uninstall_mid_service.sh
# 
#         USAGE:  ./uninstall_mid_service.sh 
# 
#   DESCRIPTION:  uninstall middleware servie shell
#                   MIDDLEWARE                  Port    Path
#                   Redis                       6379    /opt/redis*
#                   Elasticsearch               9200    /opt/elasticsearch*
#                   Zookeeper(QuorumPeerMain)   2181    /opt/zookeeper*
#                   Kafka                       9092    /opt/kafka*
#                   Logstash                    9600    /opt/logstash*
#                   Kibana                      5601    /opt/kibana*
# 
#       OPTIONS:  ---
#        AUTHOR:  dongni, 2303134@qq.com
#       VERSION:  1.0
#       CREATED:  09/26/2018 16:39:36 CST
#      REVISION:  ---
#===============================================================================

echo -e "\ninstall execute $0"

echo "Uninstall elashticsearch"
ps -ef | grep elasticsearch | grep -v grep 1>/dev/null 2>&1
[ 0 -eq $? ] && kill -9 $(ps -ef | grep  elasticsearch | grep -v grep | awk '{print $2}')
id es 1>/dev/null 2>&1 
[ 0 -eq $? ] && userdel -r es
rm -rf /opt/elasticsearch*
echo -e "\tuninstall elasticsearch success!"

echo "Uninstall redis"
ps -ef | grep redis | grep -v grep 1>/dev/null 2>&1
[ 0 -eq $? ] && kill -9 $(ps -fe | grep redis | grep -v grep | awk '{print $2}')
rm -rf /opt/redis*
echo -e "\tuninstall redis success!"

echo "Uninstall zookeeper"
ps -ef | grep zookeeper | grep -v grep 1>/dev/null 2>&1
[ 0 -eq $? ] && kill -9 $(ps -ef | grep  zookeeper | grep -v grep | awk '{print $2}')
rm -rf /opt/zookeeper*
echo -e "\tuninstall zookeeper success!"

echo "Uninstall kafka-manager"
ps -ef | grep kafka-manager | grep -v grep 1>/dev/null 2>&1
[ 0 -eq $? ] && kill -9 $(ps -ef | grep  kafka-manager | grep -v grep | awk '{print $2}')
rm -rf /opt/kafka-manager*
echo -e "\tuninstall kafka-manager success!"

echo "Uninstall kafka"
ps -ef | grep kafka | grep -v grep 1>/dev/null 2>&1
[ 0 -eq $? ] && kill -9 $(ps -ef | grep  kafka | grep -v grep | awk '{print $2}')
rm -rf /opt/kafka*
echo -e "\tuninstall kafka success!"

# hava a questions
echo "Uninstall kibana"
ps -ef | grep kibana | grep -v grep 1>/dev/null 2>&1
[ 0 -eq $? ] && kill -9 $(ps -ef | grep  kibana | grep -v grep | awk '{print $2}')
rm -rf /opt/kibana*
echo -e "\tuninstall kibana success!"

echo "Uninstall logstash"
ps -ef | grep logstash | grep -v grep 1>/dev/null 2>&1
[ 0 -eq $? ] && kill -9 $(ps -ef | grep  logstash | grep -v grep | awk '{print $2}')
rm -rf /opt/logstash*
echo -e "\tuninstall logstash success!"

#echo "Uninstall tomcat"
#ps -ef | grep tomcat | grep -v grep 1>/dev/null 2>&1
#[ 0 -eq $? ] && kill -9 $(ps -ef | grep  tomcat | grep -v grep | awk '{print $2}')
#rm -rf /opt/tomcat*
#echo -e "\tuninstall tomcat success!"

echo "Uninstall dmdbms"
read -p "Are you sure you want to uninstall the dm database [y/n] " undm_var
if [ x$undm_var == x"y" -o x$undm_var == x"Y" ]; then
	ps -ef | grep dmdbms | grep -v grep 1>/dev/null 2>&1
	[ 0 -eq $? ] && kill -9 $(ps -ef | grep  dmdbms | grep -v grep | awk '{print $2}')
	rm -rf /opt/dmdbms*
	echo -e "\tuninstall dmdbms success!"
elif [ x$undm_var == x"n" -o x$undm_var == x"N" ]; then
	echo -e "\t\033[40;31mYou cannot continue to install the service!\033[0m"
else
	echo -e "\t\033[40;36mYou did not do anything. \n\tIf you want to continue the installation, please type: \033[0m\033[41;36m[y/n]\033[0m"
	exit 0
fi
