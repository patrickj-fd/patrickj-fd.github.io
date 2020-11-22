[首 页](https://patrickj-fd.github.io/index)

---



# 安装 Frp
## Server端
```shell
HRETNS_NAME=HRETNS
FRPS_DIST_NAME=frp_0.34.3_linux_amd64
tar -xf ${FRPS_DIST_NAME}.tar.gz -C /opt
mv /opt/${FRPS_DIST_NAME}/ /opt/${HRETNS_NAME}/
cd /opt/${HRETNS_NAME}/
rm -rf frpc* && ls
mv frps ${HRETNS_NAME}
mkdir log

echo "#! /bin/bash" > start.sh
echo "nohup /opt/${HRETNS_NAME}/${HRETNS_NAME} -c /opt/${HRETNS_NAME}/ssh.ini &" >> start.sh
```

## Client端
```shell
HRETNC_NAME=HRETNC
# Pi
FRP_DIST_PATH=/mnt/usb1/hre/pi
FRP_DIST_NAME=frp_0.34.3_linux_arm
# Nano
FRP_DIST_PATH=/mnt/usb1/hre/nano
FRP_DIST_NAME=frp_0.34.3_linux_arm64

tar -xf ${FRP_DIST_PATH}/${FRP_DIST_NAME}.tar.gz -C /opt
mv /opt/${FRP_DIST_NAME}/ /opt/${HRETNC_NAME}/

cd /opt/${HRETNC_NAME}/
rm -rf frps* && ls
rm -rf *.ini && ls
mv frpc ${HRETNC_NAME}
mkdir log

Server_Port=39002
HRE_ORG_NO=400  # 3位设备编号。该设备使用的端口会后缀两位数字，即每个设备可以有99个端口。
# ----- ini ----- Start
EdgeName="pi"    # 该端口开放在哪台设备上。可用名字为：pi , nano1 , nano2
PortSuffix="00"  # 当设置两外两个nano的ssh时，分别设置为：01/02
if [ "$EdgeName" == "pi" ]; then PortSuffix="00"; elif [ "$EdgeName" == "nano1" ]; then PortSuffix="01"; elif [ "$EdgeName" == "nano2" ]; then PortSuffix="02"; else echo "========== ERROR EdgeName=$EdgeName =========="; fi
echo PortSuffix=$PortSuffix
cat > ssh.ini << EOF
[common]
server_addr = 139.9.126.19
server_port = ${Server_Port}
log_file = /opt/${HRETNC_NAME}/log/ssh.log
log_level = info
log_max_days = 100

[hre${HRE_ORG_NO}-${EdgeName}-ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = ${HRE_ORG_NO}00
EOF
cat ssh.ini

# 以下是给除了pi上面的ssh之外，需要开放出去的端口。
cat > apps.ini << EOF
[common]
server_addr = 139.9.126.19
server_port = ${Server_Port}
log_file = /opt/${HRETNC_NAME}/log/apps.log
log_level = info
log_max_days = 100

EOF

# 有多个需要开放的端口，顺序递增PortSuffix变量的值，执行以下脚本代码
EdgeName="pi"    # 该端口开放在哪台设备上。可用名字为：pi , nano1 , nano2
PortSuffix="10"  # 0-9保留，其中0-3分别是3个设备的ssh端口。所以从10开始分配给app使用
cat >> apps.ini << EOF
[hre${HRE_ORG_NO}-${EdgeName}-app${PortSuffix}]
type = tcp
local_ip = 127.0.0.1
local_port = ${HRE_ORG_NO}${PortSuffix}
remote_port = ${HRE_ORG_NO}${PortSuffix}

EOF
# ----- ini ----- End

echo "#! /bin/bash" > start.sh
echo "nohup /opt/${HRETNC_NAME}/${HRETNC_NAME} -c /opt/${HRETNC_NAME}/ssh.ini &" >> start.sh
echo "#! /bin/bash" > start-apps
echo "nohup /opt/${HRETNC_NAME}/${HRETNC_NAME} -c /opt/${HRETNC_NAME}/apps.ini &" > start-apps.sh
chmod 700 start*.sh
# 验证
./start.sh
cat log/ssh.log
ssh -oPort=40000 pi@139.9.126.19
ps -ef|grep ${HRETNC_NAME}
# kill -9 PID


# 设置开机启动
su
cat > /etc/systemd/system/${HRETNC_NAME}.service << EOF
[Unit]
Description=HyrenEdgeNetServer
After=network.target

[Service]
Type=simple
ExecStart=/opt/${HRETNC_NAME}/${HRETNC_NAME} -c /opt/${HRETNC_NAME}/ssh.ini
ExecReload=/opt/${HRETNC_NAME}/${HRETNC_NAME} reload -c /opt/${HRETNC_NAME}/ssh.ini
Restart=on-failure
RestartSec=5s
User=nobody

[Install]
WantedBy=multi-user.target
EOF

systemctl start ${HRETNC_NAME}
systemctl enable ${HRETNC_NAME}

reboot

# 验证
ssh -oPort=40000 hyren@139.9.126.19
```

---

[首 页](https://patrickj-fd.github.io/index)
