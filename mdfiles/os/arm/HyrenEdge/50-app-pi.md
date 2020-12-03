
# 在 Pi 上安装 mis 应用

---

## 1. 说明

1. 配置frpc（如果用户环境有公网IP，或者不需要通过公网直接访问mis端，则不需要配置frpc）
2. 安装项目
3. 把项目配置成开机启动

## 2. 配置frpc

### 2.1 应用的frpc配置文件
#### 配置 apps.ini
```shell
su -
cd /opt/HRETNC

# 从ssh.ini中得到frp server的服务端口
Server_Port=$(cat ssh.ini|grep server_port|awk '{print $3}')
echo Server_Port=${Server_Port}

cat > apps.ini << EOF
[common]
server_addr = 139.9.126.19
server_port = ${Server_Port}
log_file = /tmp/HRETNC-apps.log
log_level = info
log_max_days = 100

EOF
cat apps.ini
```

#### 给 apps.ini 追加写入每个要开放出去的端口
有多个需要开放的端口，顺序递增PortSuffix变量的值，执行以下脚本代码
```shell
# 从 ssh.ini 中得到 HRE_ORG_NO 的值。取hre后面的3位数字
HRE_ORG_NO=$(cat ssh.ini|grep "^\[hre")
HRE_ORG_NO=${HRE_ORG_NO:4:3}
echo $HRE_ORG_NO  # show : 400 or 401 or 402 ......

EdgeName="pi"
# 设置：[ PortSuffix= ]  从10开始分配给app使用。因为0-9保留（其中0-3分别是3个设备的ssh端口）
PortSuffix=10

cat >> apps.ini << EOF
[hre${HRE_ORG_NO}-${EdgeName}-app${PortSuffix}]
type = tcp
local_ip = 127.0.0.1
local_port = ${HRE_ORG_NO}${PortSuffix}
remote_port = ${HRE_ORG_NO}${PortSuffix}

EOF
cat apps.ini
```

#### 临时启动验证是否可用
```shell
nohup /opt/HRETNC/HRETNC -c /opt/HRETNC/apps.ini &

# 查看启动日志。最后一行应该类似： ...... [hre400-pi-app10] start proxy success
tail -f /tmp/HRETNC-apps.log

# 显示该进程，并且 kill 掉
ps -ef | grep "HRETNC" | grep "apps.ini" | grep -v grep

# 务必要删除掉日志文件，否则后续设置完开机启动后，会因为没有权限写这个日志文件导致启动失败！！！！
rm /tmp/HRETNC-apps*.log
# 看看是不是已经没有apps的日志文件了
ls -l /tmp/HRETNC*.log
```

### 2.2 编写开机启动的脚本
```shell
cat > /opt/HRETNC/startApps.sh << EOF
#!/bin/bash

if [ -f /opt/HRETNC/apps.ini ]; then
    /opt/HRETNC/HRETNC \$1 -c /opt/HRETNC/apps.ini
else
    echo "Missing apps.ini"
fi
EOF
chmod 755 startApps.sh && ls -l
```

### 2.3 开机服务配置文件
```shell
cat > /etc/systemd/system/HRETNC-apps.service << EOF
[Unit]
Description=HyrenEdgeNetApps
After=network.target

[Service]
Type=simple
ExecStart=/opt/HRETNC/startApps.sh
ExecReload=/opt/HRETNC/startApps.sh reload
Restart=on-failure
RestartSec=5s
User=nobody

[Install]
WantedBy=multi-user.target
EOF

systemctl start HRETNC-apps
systemctl enable HRETNC-apps

systemctl stop HRETNC-apps
systemctl disable HRETNC-apps
```

### 2.4 重启主机并验证
```shell
reboot
su -
# 查看服务是否启动了
ps -ef|grep HRE
# 查看开发服务的启动日志是否有错误
journalctl | grep HRE

# 验证
ssh -oPort=40000 hyren@139.9.126.19
```

## 3. 安装项目
```shell
su - hyren

PROJECT_ROOT=/hyren/hrsapp
mkdir -p ${PROJECT_ROOT}
cd ${PROJECT_ROOT}

git clone http://139.9.126.19:38111/.....
```

## 3. 把项目配置成开机启动
```shell
su -
# java -jar /hyren/hrsapp/dist/java/zhna/zhna-1.0.jar
cat > /etc/systemd/system/hre-appmis.service << EOF
[Unit]
Description=HyrenEdgeAppMis
After=network.target

[Service]
Type=simple
ExecStart=java -version
ExecReload=echo reload
Restart=on-failure
RestartSec=5s
User=hyren

[Install]
WantedBy=multi-user.target
EOF

su - pi
sudo systemctl start hre-appmis
sudo systemctl enable hre-appmis

sudo systemctl restart hre-appmis
sudo systemctl status hre-appmis

sudo systemctl stop hre-appmis
sudo systemctl disable hre-appmis
```



# 调试用的启动应用的脚本
因为应用是开机启动的，所有这个脚本仅仅是临时debug时用一下。
```shell
# cat > ${PROJECT_ROOT}/start-for-debug.sh << EOF
#!/bin/bash

BINDIR=$(cd $(dirname $0); pwd)

# [ Func 1 ] : kill process
if [ "x$1" == "xstop" ]; then
    PID=$(cat ${BINDIR}/zhna.pid)
    kill $PID && sleep 1
    echo
    ps -ef | grep "java" | grep "zhna-1.0.jar" | grep -v grep
    echo
    exit
fi

# [ Func 2 ] : just show process
if [ "x$1" == "xshow" ]; then
    echo 
    ps -ef | grep "java" | grep "zhna-1.0.jar" | grep -v grep
    echo
    exit
fi

# [ Func 3 ] : start process and show log
LOGFILE=${BINDIR}/zhna.log
echo "" >> $LOGFILE
echo "========== $(date) ==========" >> $LOGFILE
nohup java -jar /hyren/hrsapp/dist/java/zhna/zhna-1.0.jar >> $LOGFILE 2>&1 &
sleep 2
PID=$(ps -ef | grep "java" | grep "zhna-1.0.jar" | grep -v grep | awk '{print $2}')
if ps -p $PID > /dev/null
then
    echo "$PID" > ${BINDIR}/zhna.pid
    echo
    tail -f -n100 $LOGFILE
else
    echo "[ java ... zhna-1.0.jar ] PID(=$PID) not exist!"
    exit 1
fi
```

---

