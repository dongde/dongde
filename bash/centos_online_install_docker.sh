#!/bin/bash
#================================================================
#
#  @Author        : dongde
#  @Mail          : dongde@dongde.org
#  @github        : https://github.com/dongde
#  @Created Time  : 2019-03-19 16:24:44
#  @Last Modified : 2019-03-19 16:24:44

#  @File Name     : centos_online_install_docker.sh
#  @Description   :

#================================================================

# check root

# remove system docker component element
yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

# SET UP THE REPOSITORY
yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# install docker ce
yum install docker-ce docker-ce-cli containerd.io

# list the available version in the repo
yum list docker-ce --showduplicates | sort -r

# start docker ce
# systemctl start docker
