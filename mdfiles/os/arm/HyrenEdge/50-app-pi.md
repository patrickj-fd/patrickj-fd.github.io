
# 在 Pi 上安装 mis 应用

---

# 总体说明

1. 配置frpc（如果用户环境有公网IP，或者不需要通过公网直接访问mis端，则不需要配置frpc）
2. 安装项目
3. 把项目配置成开机启动

# 操作步骤

## 1. 配置frpc

**如果用户环境有公网IP，或者不需要通过公网直接访问mis端，则不需要配置frpc**

### 1.1 应用的frpc配置文件
#### 配置 apps.ini
```shell
su -
cd /opt/HRETNC

# 从ssh.ini中得到frp server的服务端口
Server_Port=$(cat ssh.ini|grep server_port|awk '{print $3}')
echo Server_Port=${Server_Port}  # show : 49901

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

# 查看启动日志。最后一行应该类似 :
# ...... [hre400-pi-app10] start proxy success
tail -f /tmp/HRETNC-apps.log

# 显示该进程，并且 kill 掉
ps -ef | grep "HRETNC" | grep "apps.ini" | grep -v grep

# 务必要删除掉日志文件，否则后续设置完开机启动后，会因为没有权限写这个日志文件导致启动失败！！！！
rm /tmp/HRETNC-apps*.log
# 看看是不是已经没有apps的日志文件了
ls -l /tmp/HRETNC*.log
```

### 1.2 开机启动的脚本
```shell
cat > /opt/HRETNC/startApps.sh << EOF
#!/bin/bash

if [ -f /opt/HRETNC/apps.ini ]; then
    echo HRETNC-apps Start At : \$(date)
    /opt/HRETNC/HRETNC \$1 -c /opt/HRETNC/apps.ini
else
    echo "HRETNC-apps failed : Missing apps.ini"
fi
EOF
chmod 755 startApps.sh && ls -l
```

### 1.3 开机服务配置文件
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

# 查看服务是否启动成功
systemctl status HRETNC-apps
# 第2行显示： Active: active (running)
# 最后两行类似如下输出：
# Dec 04 11:56:28 hre401-pi systemd[1]: Started HyrenEdgeNetApps.
# Dec 04 11:56:28 hre401-pi startApps.sh[682]: HRETNC-apps Start At : Fri 4 Dec 11:55:49 CST 2020

systemctl enable HRETNC-apps

# systemctl stop HRETNC-apps
# systemctl disable HRETNC-apps
```

### 1.4 重启主机并验证
```shell
reboot
su -
# 查看服务是否启动了。应该有3个进程：ssh.ini, startApps.sh, apps.ini
ps -ef|grep HRE
# 查看开机服务的启动日志是否有错误。正常会显示startApps.sh脚本里面echo出来的时间
journalctl | grep HRE
```

## 2. 安装项目
```shell
su - hyren

PROJECT_ROOT=/hyren/hrsapp
mkdir -p ${PROJECT_ROOT}
cd ${PROJECT_ROOT}

git clone http://139.9.126.19:38111/.....
```

## 3. 把项目配置成开机启动

### 应用脚本文件zhna.sh
**除非必要，zhna.sh永远不用直接执行，应该通过systemctl进行启停**
```shell
vi /hyren/hrsapp/bin/zhna.sh
# zhna.sh 内容如下
#!/bin/bash

set -e

RunType="$1"

JAVA_HOME=/usr/java/default
PATH=$JAVA_HOME/bin:$PATH

BINDIR=/hyren/hrsapp/bin/
echo RunType=$RunType
echo PATH=$PATH

# [ Func 1 ] : start process
if [ "x$RunType" == "xstart" ]; then
    APP_SYSTEMOUT_LOGFILE=${BINDIR}/zhna-systemout.log
    echo Start At : $(date), APP_SYSTEMOUT_LOGFILE=$APP_SYSTEMOUT_LOGFILE
    java -version
    echo "" >> $APP_SYSTEMOUT_LOGFILE
    java -jar /hyren/hrsapp/dist/java/zhna/zhna-1.0.jar >> $APP_SYSTEMOUT_LOGFILE 2>&1
fi

# [ Func 2 ] : just show process
if [ "x$RunType" == "xshow" ]; then
    echo && ps -ef | grep "java" | grep "zhna-1.0.jar" | grep -v grep && echo
fi

# [ Func 3 ] : kill process. For 'ExecStop=' in hre-appmis.service
if [ "x$RunType" == "xstop" ]; then
    # TODO
    echo "Stopped"
fi

chmod u+x /hyren/hrsapp/bin/zhna.sh
```

**再次重申：**
1. 这个脚本仅仅适用开机启动执行。
2. 如果要启停服务，应该使用systemctl命令。
3. 如果日常运行中需要单独启动应用，应以nohup方式启动到后台去！（见下面的命令）
  - 理论上，不存在需要单独启动应用的情况！

```shell
BINDIR=/hyren/hrsapp/bin
APP_SYSTEMOUT_LOGFILE=${BINDIR}/zhna-systemout.log
nohup java -jar /hyren/hrsapp/dist/java/zhna/zhna-1.0.jar >> $APP_SYSTEMOUT_LOGFILE 2>&1 &

# check log
tail -f -n100 $APP_SYSTEMOUT_LOGFILE
```


### 开机启动配置文件
```shell
su -
# 要和上面设置保持一致！！！
PROJECT_ROOT=/hyren/hrsapp
cat > /etc/systemd/system/hre-appmis.service << EOF
[Unit]
Description=HyrenEdgeAppMis
After=network.target

[Service]
Type=simple
ExecStart=${PROJECT_ROOT}/bin/zhna.sh start
User=hyren

[Install]
WantedBy=multi-user.target
EOF

# 启用服务
systemctl start hre-appmis
systemctl status hre-appmis  # show : RunType, date and java version

# 查看一下应用的运行日志
# 这个日志文件位置，通过上条命令(status)能看到
tail /hyren/hrsapp/bin/zhna-console.log
ps -ef|grep java

# 激活开机启动
systemctl enable hre-appmis

# 重启机器，验证是否开机启动了
reboot

# 以下为调试用命令
# systemctl daemon-reload
# systemctl restart hre-appmis
# systemctl status hre-appmis
# systemctl stop hre-appmis
# systemctl disable hre-appmis

```

---

