[首 页](https://patrickj-fd.github.io/index)

---



# 安装 Frp
## 1. Server端
```shell
HRETNS_NAME=HRETNS
FRPS_DIST_NAME=frp_0.34.3_linux_amd64
tar -xf ${FRPS_DIST_NAME}.tar.gz -C /opt
mv /opt/${FRPS_DIST_NAME}/ /opt/${HRETNS_NAME}/
cd /opt/${HRETNS_NAME}/
rm -rf frpc* && ls
mv frps ${HRETNS_NAME}
mkdir log

# 给企业用的端口：40000-49899
# 内部测试用的端口：49910-49929,7456
cat > server.ini << EOF
[common]
bind_port = 49901
dashboard_port = 49911
dashboard_user = aoot
dashboard_pwd = lhy1025
allow_ports = 40000-49899,49910-49929,7456
log_file = log/running.log
log_level = info
log_max_days = 300
EOF

echo "#! /bin/bash" > start.sh
echo "nohup /opt/${HRETNS_NAME}/${HRETNS_NAME} -c /opt/${HRETNS_NAME}/server.ini &" >> start.sh
chmod 700 start.sh
./start.sh
tail -f log/running.log
```

## 2. Client端
### 2.0 环境变量
```shell
su -

HRETNC_NAME=HRETNC

# Pi
# 华为云上也可以下载软件：sftp root@139.9.126.19 get /data/hre/pi/frp_0.34.3_linux_arm.tar.gz
FRP_DIST_PATH=/mnt/usb1/hre/pi
FRP_DIST_NAME=frp_0.34.3_linux_arm
# Nano
# 华为云上也可以下载软件：sftp root@139.9.126.19 get /data/hre/nano/frp_0.34.3_linux_arm64.tar.gz
FRP_DIST_PATH=/mnt/usb1/hre/nano
FRP_DIST_NAME=frp_0.34.3_linux_arm64

FRP_DIST_PATH=${FRP_DIST_PATH:+"${FRP_DIST_PATH}/"} && echo FRP_DIST_PATH=$FRP_DIST_PATH
tar -xf ${FRP_DIST_PATH}${FRP_DIST_NAME}.tar.gz -C /opt
mv /opt/${FRP_DIST_NAME}/ /opt/${HRETNC_NAME}/
chown -R root:root /opt/${HRETNC_NAME}/ && ls -l

cd /opt/${HRETNC_NAME}/
rm -rf frps* && ls
rm -rf *.ini LICENSE systemd && ls
mv frpc ${HRETNC_NAME}
mkdir log && ls -l

# 1. 设置server端的端口
Server_Port=49901
# 2. 设置3位设备编号。该设备使用的端口会后缀两位数字，即每个设备可以有99个端口。 内部测试用 499
HRE_ORG_NO=400

# 3. 设置该端口开放在哪台设备上。可用名字为：pi , nano1 , nano2
EdgeName=

# 4. 设置端口最后两位数字
# pi设置为00；两个nano分别设置为：01/02。
# [ 内部测试的机器用：pi/10, nano1/11, nano2/12 ...... 并且，不要执行下面的if语句 ]
if [ "$EdgeName" == "pi" ]; then PortSuffix="00"; elif [ "$EdgeName" == "nano1" ]; then PortSuffix="01"; elif [ "$EdgeName" == "nano2" ]; then PortSuffix="02"; else echo "========== ERROR EdgeName=$EdgeName =========="; fi
echo PortSuffix=$PortSuffix
```

### 2.1 配置 ssh

**关于frpc的日志文件**

因为本操作使用root，会用root用户临时启动用于验证，会生成root权限的日志文件。
而在最后创建的开机启动service文件中，会设置：User=nobody。
为避免开机启动时无权限写日志，所以在ini文件中把log文件放到了tmp目录下。

#### ssh.ini
```ini
# cat > ssh.ini << EOF
[common]
server_addr = 139.9.126.19
server_port = ${Server_Port}
log_file = /tmp/${HRETNC_NAME}-ssh.log
log_level = info
log_max_days = 100

[hre${HRE_ORG_NO}-${EdgeName}-ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = ${HRE_ORG_NO}${PortSuffix}
# EOF
```

#### ssh-start.sh for start ssh
```shell
cat > ssh-start.sh << EOF
#! /bin/bash

# just for show process
if [ "x\$1" == "xshow" ]; then
    ps -ef | grep "HRETNC" | grep "ssh.ini" | grep -v grep
    exit
fi

nohup /opt/${HRETNC_NAME}/${HRETNC_NAME} -c /opt/${HRETNC_NAME}/ssh.ini &
sleep 1
echo
tail -f /opt/${HRETNC_NAME}/log/ssh.log
EOF

# 临时启动验证是否可用
chmod 700 ssh-start.sh && ls -l
./ssh-start.sh
# 验证
ssh -oPort= hyren@139.9.126.19
```

### 2.2 配置 apps
#### apps.ini
- 是给除了pi上面的ssh之外，需要开放出去的端口。
- 创建前，先确认 **HRETNC_NAME** 环境变量是否正确（等于前面设置的值 HRETNC）
```ini
# cat > apps.ini << EOF
[common]
server_addr = 139.9.126.19
server_port = ${Server_Port}
log_file = /tmp/${HRETNC_NAME}-apps.log
log_level = info
log_max_days = 100

# EOF
```

#### apps.ini 追加写入每个要开放出去的端口
有多个需要开放的端口，顺序递增PortSuffix变量的值，执行以下脚本代码
```ini
# (1) 确认：[ EdgeName ] 是否正确。该端口开放在哪台设备上。可用名字为：pi , nano1 , nano2
# (2) 设置：[ PortSuffix= ]  从10开始分配给app使用。0-9保留，其中0-3分别是3个设备的ssh端口

# cat >> apps.ini << EOF
[hre${HRE_ORG_NO}-${EdgeName}-app${PortSuffix}]
type = tcp
local_ip = 127.0.0.1
local_port = ${HRE_ORG_NO}${PortSuffix}
remote_port = ${HRE_ORG_NO}${PortSuffix}

# EOF
```

#### 启动apps的脚本 apps-start.sh
```shell
cat >> apps-start.sh << EOF
#! /bin/bash

# just for show process
if [ "x\$1" == "xshow" ]; then
    ps -ef | grep "HRETNC" | grep "apps.ini" | grep -v grep
    exit
fi

nohup /opt/${HRETNC_NAME}/${HRETNC_NAME} -c /opt/${HRETNC_NAME}/apps.ini &
sleep 1
echo
tail -f /opt/${HRETNC_NAME}/log/apps.log
EOF

# 临时启动验证是否可用
chmod 700 apps-start.sh && ls -l
./apps-start.sh
```

### 2.3 设置开机启动
```shell
echo HRETNC_NAME=${HRETNC_NAME}  # for check : HRETNC_NAME=HRETNC

# 以下startAll.sh方式没有成功，所以后面要分别创建两个文件
cat > startAll.sh << EOF
#! /bin/bash

nohup /opt/${HRETNC_NAME}/${HRETNC_NAME} \$1 -c /opt/${HRETNC_NAME}/ssh.ini &

if [ -f /opt/${HRETNC_NAME}/apps.ini ]; then
    nohup /opt/${HRETNC_NAME}/${HRETNC_NAME} \$1 -c /opt/${HRETNC_NAME}/apps.ini &
fi
EOF
chmod 755 startAll.sh

# 分别赋值为：ssh , apps。各执行一次
TYPE=

cat > /etc/systemd/system/${HRETNC_NAME}-${TYPE}.service << EOF
[Unit]
Description=HyrenEdgeNet${TYPE}
After=network.target

[Service]
Type=simple
ExecStart=/opt/${HRETNC_NAME}/${HRETNC_NAME} -c /opt/${HRETNC_NAME}/${TYPE}.ini
ExecReload=/opt/${HRETNC_NAME}/${HRETNC_NAME} -c /opt/${HRETNC_NAME}/${TYPE}.ini
Restart=on-failure
RestartSec=5s
User=nobody

[Install]
WantedBy=multi-user.target
EOF

systemctl start ${HRETNC_NAME}-${TYPE}
systemctl enable ${HRETNC_NAME}-${TYPE}

# systemctl stop ${HRETNC_NAME}-${TYPE}
# systemctl disable ${HRETNC_NAME}-${TYPE}


reboot

# 查看服务是否启动了
ps -ef|grep HRE
# 查看开发服务的启动日志是否有错误
journalctl | grep HRE

# 验证ssh（hyren 登陆）
ssh -oPort= hyren@139.9.126.19
```

---

[首 页](https://patrickj-fd.github.io/index)
