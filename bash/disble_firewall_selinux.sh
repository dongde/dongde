#!/bin/bash
#================================================================
#
#  @Author        : dongde
#  @Mail          : dongde@dongde.org
#  @github        : https://github.com/dongde
#  @Created Time  : 2019-03-19 18:52:26
#  @Last Modified : 2019-03-19 18:52:26

#  @File Name     : disble_firewall_selinux.sh
#  @Description   :

#================================================================

# stop firewalld
systemctl stop firewalld

# disable firewall
systemctl disable firewalld
#output info
#/systemd/system/multi-user.target.wants/firewalld.service.
#/systemd/system/dbus-org.fedoraproject.FirewallD1.service.

# check firewall stae
firewall-cmd --state


# disable selinux
#setenforce - modify the mode SELinux is running in
#setenforce [Enforcing|Permissive|1|0]
setenforce 0

# vi /etc/selinux/config
#SELINUX=enforcing -> SELINUX=disabled
grep "SELINUX=enforcing" /etc/selinux/config && sed 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
