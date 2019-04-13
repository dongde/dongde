#!/bin/bash
#================================================================
#
#  @Author        : dongde
#  @Mail          : dongde@dongde.org
#  @github        : https://github.com/dongde
#  @Created Time  : 2019-04-13 10:09:07
#  @Last Modified : 2019-04-13 10:09:07

#  @File Name     : install_docker_el7.sh
#  @Description   : 

#================================================================

# Usage:
# curl -fsSL https://raw.githubusercontent.com/dongde/dongde/master/bash/install_docker_el7.sh | sh

# uninstall old docker
yum remove docker \
    docker-client \
    docker-client-latest \
    docker-common \
    docker-latest \
    docker-latest-logrotate \
    docker-logrotate \
    docker-engine

# install docker-ce
#  Install using the repository
yum install -y yum-utils \
    device-mapper-persistent-data \
    lvm2

# set up the stable repository
#yum-config-manager \
#    --add-repo \
#    https://download.docker.com/linux/centos/docker-ce.repo

wget -O /etc/yum.repos.d/docker-ce.repo https://download.docker.com/linux/centos/docker-ce.repo

# Replace the depot address with TUNA
sed -i 's+download.docker.com+mirrors.tuna.tsinghua.edu.cn/docker-ce+' /etc/yum.repos.d/docker-ce.repo

# install docker-ce
yum makecache fast
yum install -y docker-ce

# check install
docker version >/dev/null 2>&1 && echo "install ok" || echo "install failed"
