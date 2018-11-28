#!/bin/bash
#===============================================================================
#
#          FILE:  make_start.sh
#
#         USAGE:  ./make_start.sh
#				  Let the middleware service script boot up
#
#   DESCRIPTION:
#
#       OPTIONS:  ---
#        AUTHOR:  dongni, 2303134@qq.com
#       VERSION:  1.0
#       CREATED:  11/05/2018 14:02:18 CST
#      REVISION:  ---
#===============================================================================

# make bootup file
cp ./bootup_mid_service.sh /etc/init.d/bootup_mid_service
chmod +x /etc/init.d/bootup_mid_service
chmod +x /etc/rc.d/rc.local
chmod +x /etc/rc.local

# make bootup file to /etc/rc.local, and new record.log file
grep "bootup" /etc/rc.local 1>/dev/null 2>&1
if [ 0 -ne $? ]; then
cat >> /etc/rc.local <<EOF
source /etc/profile
echo \$(date +'%y%m%m%H') >> /tmp/bootup_mid_service_record.log
bash /etc/init.d/bootup_mid_service >> /tmp/bootup_mid_service_record.log &
EOF
fi

#deal with bootup
cat > /etc/systemd/system/rc-local.service <<EOF
[Unit]
Description=/etc/rc.d/rc.local Compatibility
ConditionFileIsExecutable=/etc/rc.d/rc.local
After=network.target

[Service]
Type=forking
ExecStart=/etc/rc.d/rc.local start
TimeoutSec=5
RemainAfterExit=yes
EOF

#modify the default timeout of systemd
sed -i 's/#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=30s/g' /etc/systemd/system.conf

systemctl daemon-reload

exit 0
