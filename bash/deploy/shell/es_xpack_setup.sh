#!/bin/bash
#===============================================================================
#
#          FILE:  es_xpack_setup.sh
#
#         USAGE:   elasticsearch xpack setup password
#
#   DESCRIPTION:  
#
#       OPTIONS:  ---
#        AUTHOR:  dongni, 2303134@qq.com
#       VERSION:  1.0
#       CREATED:  11/08/2018 12:11:34 CST
#      REVISION:  ---
#===============================================================================

##usage:
# 1.check xpack:
#		xpack.security.enabled: true
#		execute command:
			echo "xpack.security.enabled: true" >> /opt/elasticsearch-6.3.2/config/elasticsearch.yml
# 2.open xpack:
#		execute command:
#			curl -H "Content-Type:application/json" -XPOST http://localhost:9200/_xpack/license/start_trial?acknowledge=true
# 3.setup elasticsearch password:
#			interactive mode execute:
#				/opt/elasticsearch-6.3.2/bin/elasticsearch-setup-passwords interactive
#			auto mode execute:
#				/opt/elasticsearch-6.3.2/bin/elasticsearch-setup-passwords auto 
#===============================================================================

#get elasticsearch dir
es_dir=$(ls /opt/ | grep elasticsearch*)

# check xpack.security.enabled: true
grep "xpack.security.enabled: true" /opt/$es_dir/config/elasticsearch.yml 1>/dev/null 2>&1
[ 0 -ne $? ] && echo "xpack.security.enabled: true" >> /opt/$es_dir/config/elasticsearch.yml 1>/dev/null 2>&1
chown -R es:es /opt/$es_dir

while [ 0 -eq $(lsof -i:9200 1>/dev/null 2>&1; echo $?) ]; do
	#enable xpack
	read -p "Your will setup elasticsearch password, please confirm[y/n]:" confirm_vir
	if [ $confirm_vir == "y" ]; then
		curl -I localhost:9200 | grep "401" 1>/dev/null 2>&1
		[ 0 -eq $? ] && echo "The password for the 'elastic' user has already been changed on this cluster" && exit 1

		echo "open xpack function"
		curl -H "Content-Type:application/json" -XPOST http://localhost:9200/_xpack/license/start_trial?acknowledge=true

		sleep 2
		while [ 0 -eq $? ]; do
			echo "setup elasticsearch password:"
			/opt/$es_dir/bin/elasticsearch-setup-passwords interactive
			#/opt/$es_dir/bin/elasticsearch-setup-passwords auto 

			curl -i localhost:9200 | grep 401
			echo "elasticsearch setup password success!"
		done	
	else
		echo "If you setup es passwd, Please enter 'y'"
	fi
done

################################################################################
