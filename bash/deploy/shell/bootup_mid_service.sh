#!/bin/bash
#===============================================================================
#
#          FILE:  bootup_mid_service.sh
#
#         USAGE:  ./bootup_mid_service.sh
#
#   DESCRIPTION:  bootup middleware service
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
#       CREATED:  10/19/2018 15:13:59 CST
#      REVISION:  ---
#===============================================================================

#save middleware server logs
mkdir -p /opt/service_logs

#1# check root accout
echo -e "\033[40;32mCheck valid root account: \033[0m"
[ $(id -u) -eq 0 ] && echo -e "\tRoot accout OK!" || exit 1

#2# check tools env
echo -e "\n\033[40;32mCheck lsof: \033[0m"
lsof 1>/dev/null 2>&1
if [ 0 -ne $? ]; then
	echo -e "\tPlease install: \033[40;34mlsof\033[0m"
	exit 1
else
	echo -e "\t\033[40;32m tools:lsof is ok! \033[0m"
fi

echo -e "\n\033[40;32mCheck jdk: \033[0m"
java -version 1>/dev/null 2>&1
if [ 0 -ne $? ]; then
	echo -e "\tPlease install: \033[40;34m jdk \033[0m"
	exit 1
else
	echo -e "\t\033[40;32m env:jdk is ok! \033[0m"
fi

# START REDIS #
echo -e "\n\033[40;32mStart redis server\033[0m"
#ps -ef | grep redis 1>/dev/null 2>&1
lsof -i :6379 1>/dev/null 2>&1
if [ 0 -ne $? ]; then
	rts1=$(date +%s)
	nrts1=$(date +%s.%N)
	cd /opt/redis*
	nohup redis-server /etc/redis.conf >/opt/service_logs/redis & 
	[ 0 -eq $? ] && echo -e "\tstart redis server \033[40;32msuccess!\033[0m" || echo -e "\tstart redis server \033[41,35mfailed\033[0m!"
	rts2=$(date +%s)
	nrts2=$(date +%s.%N)

	bc -v 1>/dev/null 2>&1
	if [ 0 -ne $? ]; then 
		echo -e "\tIt takes \033[40;32m$((rts2-rts1))\033[0m seconds to start the Redis service and port."
	else
		nrts=$(echo "scale=9; $nrts2-$nrts1" | bc)
		echo -e "\tIt takes \033[40;32m$nrts\033[0m seconds to start the Redis service and port."
	fi
else
	echo -e "\t\033[41;36mredis service already exists!\033[0m"	
fi

# START ELASTICSEARCH #
echo -e "\n\033[40;32mStart elasticsearch server\033[0m"
#ps -ef | grep elasticsearch 1>/dev/null 2>&1
lsof -i :9200 1>/dev/null 2>&1
if [ 0 -ne $? ]; then
	su es -c "nohup /opt/elasticsearch-6.3.2/bin/elasticsearch -d"
	ps -ef | grep elasticsearch 1>/dev/null 2>&1
	[ 0 -eq $? ] && echo -e "\tstart elasticsearch server \033[40;32msuccess\033[0m!" || echo -e "\tstart elasticsearch server \033[41,35mfailed\033[0m!"

	echo -e "\twait for the elasticsearc service 9200 port to start, \033[41;36mdo not operate!\033[0m"

	ets1=$(date +%s)
	nets1=$(date +%s.%N)
	lsof -i :9200 1>/dev/null 2>&1
	re_val=$?
	while [ 0 -ne $re_val ]
	do
		lsof -i :9200 1>/dev/null 2>&1 
		re_val_1=$?
		if [ $re_val -ne $re_val_1 ]; then
			echo -e "\tstart elasticsearch server and port \033[40;32msuccess\033[0m!" 
			break
		else
			continue
		fi
	done

	ets2=$(date +%s)
	nets2=$(date +%s.%N)

	bc -v 1>/dev/null 2>&1
	if [ 0 -ne $? ]; then 
		echo -e "\tit takes \033[40;32m$((ets2-ets1))\033[0m seconds to start the elasticsearch service and port."
	else
		nets=$(echo "scale=9; $nets2-$nets1" | bc)
		echo -e "\tit takes \033[40;32m$nets\033[0m seconds to start the elasticsearch service and port."
	fi
else
	echo -e "\t\033[41;36melasticsearch service already exists!\033[0m"	
fi

# START ZOOKEEPER(QUORUMPEERMAIN) #
echo -e "\n\033[40;32mStart zookeeper(QuorumPeerMain) server\033[0m"
#ps -ef | grep zookeeper 1>/dev/null 2>&1
lsof -i :2181 1>/dev/null 2>&1
if [ 0 -ne $? ]; then
	nohup /opt/zookeeper-3.4.11/bin/zkServer.sh start > /opt/service_logs/zk.log.$(date +'%y%m%d-%H%M%S')

	zts1=$(date +%s)
	nzts1=$(date +%s.%N)

	lsof -i:2181 1>/dev/null 2>&1
	zre_val=$?
	while [ 0 -ne $zre_val ]
	do
		lsof -i :2181 1>/dev/null 2>&1 
		zre_val_1=$?
		if [ $zre_val -ne $zre_val_1 ]; then
			echo -e "\tstart zookeeper(QuorumPeerMain) server and port \033[40;32msuccess\033[0m!" 
			break
		else
			continue
		fi
	done

	zts2=$(date +%s)
	nzts2=$(date +%s.%N)
	bc -v 1>/dev/null 2>&1
	if [ 0 -ne $? ]; then
		echo -e "\tIt takes \033[40;32m$((zts2-zts1))\033[0m seconds to start the Zookeeper service and port."
	else
		nzts=$(echo "scale=9; $nzts2-$nzts1" | bc)
		echo -e "\tIt takes \033[40;32m$nzts\033[0m seconds to start the Zookeeper service and port."
	fi
else
	echo -e "\t\033[41;36mzookeeper service already exists!\033[0m"	
fi

# START KAFKA #
echo -e "\n\033[40;32mStart kafka server\033[0m"
#ps -ef | grep kafka 1>/dev/null 2>&1
lsof -i :9092 1>/dev/null 2>&1
if [ 0 -ne $? ]; then
	nohup /opt/kafka_2.12-1.0.0/bin/kafka-server-start.sh -daemon /opt/kafka_2.12-1.0.0/config/server.properties > /opt/service_logs/kafka.log.$(date +'%y%m%d-%H%M%S') &

	k1ts1=$(date +%s)
	nk1ts1=$(date +%s.%N)

	lsof -i:2181 1>/dev/null 2>&1
	k1re_val=$?
	while [ 0 -ne $k1re_val ]
	do
		lsof -i :2181 1>/dev/null 2>&1 
		k1re_val_1=$?
		if [ $k1re_val -ne $k1re_val_1 ]; then
			echo -e "\tstart kafka server and port \033[40;32msuccess\033[0m!" 
			break
		else
			continue
		fi
	done

	k1ts2=$(date +%s)
	nk1ts2=$(date +%s.%N)
	bc -v 1>/dev/null 2>&1
	if [ 0 -ne $? ]; then
		echo -e "\tIt takes \033[40;32m$((k1ts2-k1ts1))\033[0m seconds to start the Kafka service and port."
	else
		nk1ts=$(echo "scale=9; $nk1ts2-$nk1ts1" | bc)
		echo -e "\tIt takes \033[40;32m$nk1ts\033[0m seconds to start the Kakfa service and port."
	fi
else
	echo -e "\t\033[41;36mkafka service already exists!\033[0m"	
fi


# START LOGSTASH #
echo -e "\n\033[40;32mStart logstash server\033[0m"
#ps -ef | grep logstash 1>/dev/null 2>&1
lsof -i :9600 1>/dev/null 2>&1
if [ 0 -ne $? ]; then
	nohup /opt/logstash-6.3.2/bin/logstash -f /opt/logstash-6.3.2/config/*.conf > /opt/service_logs/logstash.log.$(date +'%y%m%d-%H%M%S') &

	lts1=$(date +%s)
	nlts1=$(date +%s.%N)

	lsof -i:2181 1>/dev/null 2>&1
	lre_val=$?
	while [ 0 -ne $lre_val ]
	do
		lsof -i :2181 1>/dev/null 2>&1 
		lre_val_1=$?
		if [ $lre_val -ne $lre_val_1 ]; then
			echo -e "\tstart logstash server and port \033[40;32msuccess\033[0m!" 
			break
		else
			continue
		fi
	done

	lts2=$(date +%s)
	nlts2=$(date +%s.%N)
	bc -v 1>/dev/null 2>&1
	if [ 0 -ne $? ]; then
		echo -e "\tIt takes \033[40;32m$((lts2-lts1))\033[0m seconds to start the Logstash service and port."
	else
		nlts=$(echo "scale=9; $nlts2-$nlts1" | bc)
		echo -e "\tIt takes \033[40;32m$nlts\033[0m seconds to start the Logstash service and port."
	fi
else
	echo -e "\t\033[41;36mlogstash service already exists!\033[0m"	
fi

# START KIBANA #
echo -e "\n\033[40;32mStart kibana server\033[0m"
#ps -ef | grep kibana 1>/dev/null 2>&1
lsof -i :5601 1>/dev/null 2>&1
if [ 0 -ne $? ]; then
	nohup /opt/kibana-6.3.2-linux-x86_64/bin/kibana > /opt/service_logs/kibana.log.$(date +'%y%m%d-%H%M%S') &

	k2ts1=$(date +%s)
	nk2ts1=$(date +%s.%N)

	lsof -i:2181 1>/dev/null 2>&1
	k2re_val=$?
	while [ 0 -ne $k2re_val ]
	do
		lsof -i :2181 1>/dev/null 2>&1 
		k2re_val_1=$?
		if [ $k2re_val -ne $k2re_val_1 ]; then
			echo -e "\tstart kibana server and port \033[40;32msuccess\033[0m!" 
			break
		else
			continue
		fi
	done

	k2ts2=$(date +%s)
	nk2ts2=$(date +%s.%N)
	bc -v 1>/dev/null 2>&1
	if [ 0 -ne $? ]; then
		echo -e "\tIt takes \033[40;32m$((k2ts2-k2ts1))\033[0m seconds to start the Kibana service and port."
	else
		nk2ts=$(echo "scale=9; $nk2ts2-$nk2ts1" | bc)
		echo -e "\tIt takes \033[40;32m$nk2ts\033[0m seconds to start the Kibana service and port."
	fi
else
	echo -e "\t\033[41;36mkibana service already exists!\033[0m"	
fi
