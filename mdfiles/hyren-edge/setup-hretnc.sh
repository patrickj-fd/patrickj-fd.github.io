#!/bin/bash

set -e
echo
if [ $UID -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# 得到3位设备编号。和主机名的编号相同。该设备使用的端口会后缀两位数字，即每个设备可以有99个端口。
# [ 内部测试的机器设置为：499 ]
HRE_ORG_NO=$(hostname)
HRE_ORG_NO=${HRE_ORG_NO:3:3}
if [[ $HRE_ORG_NO < 400 ]] || [[ $HRE_ORG_NO > 498 ]]; then
    echo "HRE_ORG_NO(=$HRE_ORG_NO) must between 400 and 498"
    exit 1
fi

# 设备名等变量
EdgeName="$(hostname)"
# 从主机名上获得设备名（最后一个'-'字符后面的是设备名）
EdgeName=${EdgeName##*-}
if [ "$EdgeName" == "pi" ]; then
    PortSuffix="00"
    FRP_DIST_NAME=frp_0.34.3_linux_arm
    EdgeDeviceName="pi"
elif [ "$EdgeName" == "nano1" ]; then
    PortSuffix="01"
    FRP_DIST_NAME=frp_0.34.3_linux_arm64
    EdgeDeviceName="nano"
elif [ "$EdgeName" == "nano2" ]; then
    PortSuffix="02"
    FRP_DIST_NAME=frp_0.34.3_linux_arm64
    EdgeDeviceName="nano"
else
    echo "EdgeName(=$EdgeName) is wrong"
    exit 1
fi

# 确认
echo
echo -e "当前用户 ： [$USER] \t\t must be root"
echo -e "设备编码 ： [$HRE_ORG_NO] \t\t must between 400 and 498"
echo -e "设备名称 ： [$EdgeDeviceName] \t\t must be pi/nano"
echo -e "设备别名 ： [$EdgeName] \t\t must be pi/nano1/nano2"
echo
read -p "Confirm the info [Y/N] : " inputKey
[ "$inputKey" != "Y" ] && exit 1

# 安装frp
# 提前把frp软件包放到/tmp目录下
if [ ! -f /tmp/${FRP_DIST_NAME}.tar.gz ]; then
    echo "First, get package from : 172.168.0.100:/data1/HyrenEdge/$EdgeDeviceName/$FRP_DIST_NAME.tar.gz to /tmp"
    scp root@172.168.0.100:/data1/HyrenEdge/$EdgeDeviceName/$FRP_DIST_NAME.tar.gz /tmp
fi

tar -xf /tmp/${FRP_DIST_NAME}.tar.gz -C /opt
mv /opt/${FRP_DIST_NAME}/ /opt/HRETNC/
chown -R root:root /opt/HRETNC/
rm -rf /opt/HRETNC/frps*
rm -rf /opt/HRETNC/*.ini /opt/HRETNC/LICENSE /opt/HRETNC/systemd
mv /opt/HRETNC/frpc /opt/HRETNC/HRETNC

# 构建配置文件
Server_Port=49901

cat > /opt/HRETNC/ssh.ini << EOF
[common]
server_addr = 139.9.126.19
server_port = ${Server_Port}
log_file = /tmp/HRETNC-ssh.log
log_level = info
log_max_days = 100

[hre${HRE_ORG_NO}-${EdgeName}-ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = ${HRE_ORG_NO}${PortSuffix}
EOF

# 临时启动验证是否可用
echo 
echo "... ... Start service for checking ... ..."
nohup /opt/HRETNC/HRETNC -c /opt/HRETNC/ssh.ini > /tmp/HRETNC.nohup.out 2>&1 &
sleep 1
echo "Check starting log"
echo -e "Should be end by : \033[33m [hre${HRE_ORG_NO}-${EdgeName}-ssh] start proxy success \033[0m"
echo "------ [Running Log] Start --------------------------------------"
tail /tmp/HRETNC-ssh.log
echo "------ [Running Log] End   --------------------------------------"
echo 
read -p "Press any key to continue Or Press Ctrl+c to cancel" TB
echo

# 清理掉这个临时测试用的进程
ps -ef | grep "HRETNC" | grep "ssh.ini" | grep -v grep
PID=$(ps -ef | grep "HRETNC" | grep "ssh.ini" | grep -v grep | awk '{print $2}')
if ps -p $PID > /dev/null; then
    kill $PID && echo "Killed the HRETNC(PID=$PID) process" || echo "===== Fail to Kill the HRETNC process ====="
    rm /tmp/HRETNC-ssh*.log
else
    echo "PID(=$PID) not exist!"
    exit 1
fi

# 设置开机启动
echo 
echo "... ... Add service for boot ... ..."
cat > /etc/systemd/system/HRETNC-ssh.service << EOF
[Unit]
Description=HyrenEdgeNetSSH
After=network.target

[Service]
Type=simple
ExecStart=/opt/HRETNC/HRETNC -c /opt/HRETNC/ssh.ini
ExecReload=/opt/HRETNC/HRETNC -c /opt/HRETNC/ssh.ini
Restart=on-failure
RestartSec=5s
User=nobody

[Install]
WantedBy=multi-user.target
EOF

systemctl start HRETNC-ssh
sleep 1
echo "Check systemctl log"
echo -e "Should be seeing : \033[33m Active: active (running) , Started HyrenEdgeNetSSH \033[0m"
echo "------ [systemctl Log] Start --------------------------------------"
systemctl status HRETNC-ssh
echo "------ [systemctl Log] End   --------------------------------------"
echo 
read -p "Press any key to continue Or Press Ctrl+c to cancel" TB
echo
systemctl enable HRETNC-ssh

echo
echo "... ... Reboot for check ssh service on booting ... ..."
echo "ssh hyren@139.9.126.19 -oPort=${HRE_ORG_NO}${PortSuffix}"
echo "see :"
echo "ps -ef|grep HRE          =====>  ssh user is : nobody"
echo "journalctl | grep HRE    =====>  output is nothing"

rm /tmp/${FRP_DIST_NAME}.tar.gz
echo 
read -p "Press any key to reboot Or Press Ctrl+c to cancel" TB
reboot
