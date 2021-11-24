#!/bin/bash
# Usage: SHELL <pi/nano1/nano2> <HRE_CODE>

set -e

function die() {
    echo; echo "[ERROR] $1"; echo
    exit 1
}

[ $UID -ne 0 ] && die "Must running by <root>"
echo

HOST_TYPE="${1:?'Missing HOST_TYPE(pi/nano1/nano2)'}"
HRE_CODE="${2:?'Missing HRE_CODE(401, 402, ...)'}"
# 设置3位设备编号。和主机名的编号相同。该设备使用的端口会后缀两位数字，即每个设备可以有99个端口。
# [ 内部测试的机器设置为：499 ]
HRE_ORG_NO=$(hostname)
HRE_ORG_NO=${HRE_ORG_NO:3:3}
[ "$HRE_ORG_NO" != "$HRE_CODE" ] && die "hostname<$(hostname)> not match HRE_CODE<$HRE_CODE>"

# 1. 获取软件

RESFILES_HOST="172.168.0.216"
RESFILES_FTP_URL="ftp://ftpgets:hre118:@${RESFILES_HOST}:10021"

if [ "$HOST_TYPE" == "pi" ]; then
    FRP_DIST_PATH="/data3/HyrenEdge/pi/soft"
    FRP_DIST_NAME=frp_0.34.3_linux_arm

    PortSuffix="00"     # 设置内网穿透对外端口最后两位数字

elif [ "$HOST_TYPE" == "nano1" ]; then
    FRP_DIST_PATH="/data3/HyrenEdge/nano"
    FRP_DIST_NAME=frp_0.34.3_linux_arm64

    PortSuffix="01"     # 设置内网穿透对外端口最后两位数字

elif [ "$HOST_TYPE" == "nano2" ]; then
    FRP_DIST_PATH="/data3/HyrenEdge/nano"
    FRP_DIST_NAME=frp_0.34.3_linux_arm64

    PortSuffix="02"     # 设置内网穿透对外端口最后两位数字

else
    die "<arg1> must be 'pi/nano1/nano2'"
fi

if [ -d /opt/HRETNC/ ]; then
    echo "SKIP: </opt/HRETNC> exist"
else
    curl -s ${RESFILES_FTP_URL}/${FRP_DIST_PATH}/${FRP_DIST_NAME}.tar.gz | tar -zxf - -C /opt

    # 2. 开始安装
    mv /opt/frp_*/ /opt/HRETNC/

    cd /opt/HRETNC/
    rm -rf /opt/HRETNC/frps* /opt/HRETNC/*.ini /opt/HRETNC/LICENSE /opt/HRETNC/systemd
    mv frpc HRETNC
fi
# 3. 设置server端的端口
Server_Port=49901


# 2.1 配置 frp 的 ssh 服务端口
cat > /opt/HRETNC/ssh.ini << EOF
[common]
server_addr = 139.9.126.19
server_port = ${Server_Port}
log_file = /tmp/HRETNC-ssh.log
log_level = info
log_max_days = 100

[hre${HRE_ORG_NO}-${HOST_TYPE}-ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = ${HRE_ORG_NO}${PortSuffix}
EOF

cat /opt/HRETNC/ssh.ini | grep ${HRE_ORG_NO} > /dev/null || die "wrong /opt/HRETNC/ssh.ini"


# 配置开机启动
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
systemctl status HRETNC-ssh --no-pager | grep "Active: active (running)" > /dev/null || die "HRETNC-ssh service start failed"

sleep 1
if !tail /tmp/HRETNC-ssh.log | grep "start proxy success" > /dev/null; then
    sleep 1
    tail /tmp/HRETNC-ssh.log | grep "start proxy success" > /dev/null || die "wrong HRETNC-ssh service"
fi

systemctl enable HRETNC-ssh

echo "$(ifconfig eth0 | grep inet | grep -v inet6 | awk '{print $2}') $(date +'%Y-%m-%d %H:%M:%S')" > /hyren/.hretnc.done
echo; echo "Setup info:"
cat /hyren/.hretnc.done

echo;
echo "Setup done, can be reboot for test frp service."
echo "You can test ssh service on yours computer:"
echo "ssh hyren@139.9.126.19 -oPort=${HRE_ORG_NO}${PortSuffix}"
echo "cat .hretnc.done"


