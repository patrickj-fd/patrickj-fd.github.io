
# 在 Pi 上安装 mis 应用

---

# 总体说明

1. 配置frpc（如果用户环境有公网IP，或者不需要通过公网直接访问mis端，则不需要配置frpc）
2. 安装项目
3. 把项目配置成开机启动

# 操作步骤

## 1. 配置frpc

**如果用户环境有公网IP，或者不需要通过公网直接访问mis端，则不需要配置frpc**

## 2. 安装项目
```shell
su - hyren

# 1. 获取应用程序。应该在主目录解压出来 hrsapp 目录
#ssh root@172.168.0.100 "cat /data1/HyrenEdge/pi/hrsapp.tar.gz" | tar -zxf - -C /hyren  # 5t6y0524A!
curl -s ftp://ftp:@172.168.0.100/pi/hrsapp.tar.gz | tar -zxf - -C /hyren

# 2. 得到本设备的编号（从本设备的主机名中截取）
HRE_ORG_NO=$(hostname) && HRE_ORG_NO=${HRE_ORG_NO:3:3} && echo $HRE_ORG_NO  # show : 400 or 401 or 402 ......

# 3. 修改配置文件
# 设置web服务端口。默认的设置规则为设备3位编号+10。除非用户真实环境不允许使用这个端口
HRE_MISWEB_PORT=${HRE_ORG_NO}10
sed -i "s/    port : .*/    port : ${HRE_MISWEB_PORT}/" /hyren/hrsapp/dist/java/zhna/resources/fdconfig/httpserver.conf
grep -C 1 "${HRE_MISWEB_PORT}" /hyren/hrsapp/dist/java/zhna/resources/fdconfig/httpserver.conf  # check

# 修改IP。设备进入正式环境后，得到用户网络真实IP后，还要再修改。以下命令仅仅是为了公司内部测试环境用
# LOCAL_WIFI_IP=$(ifconfig wlan0 | grep inet | grep -v inet6 | awk '{print $2}')
NANO_IP=
sed -i "s%algo_url=.*%algo_url=http://${NANO_IP}:38010/%" /hyren/hrsapp/dist/java/zhna/resources/fdconfig/comm.conf
grep -C 1 "${NANO_IP}" /hyren/hrsapp/dist/java/zhna/resources/fdconfig/comm.conf  # check

```

## 3. 把项目配置成开机启动

### 应用脚本文件zhna.sh
**除非必要，zhna.sh永远不用直接执行，应该通过systemctl进行启停**
```shell
vi /hyren/hrsapp/bin/zhna.sh
# 清空文件内容：
# gg     到第1行
# dG     先按d，再按 Shift+G
# zhna.sh ========= Start

#!/bin/bash

set -e

JAVA_HOME=/usr/java/default
PATH=$JAVA_HOME/bin:$PATH

BINDIR=/hyren/hrsapp/bin
echo BINDIR=$BINDIR
echo PATH=$PATH

APP_SYSTEMOUT_LOGFILE=${BINDIR}/zhna-systemout.log
echo Start At : $(date)
echo LogFile=$APP_SYSTEMOUT_LOGFILE
java -version
echo "" >> $APP_SYSTEMOUT_LOGFILE
echo "========== $(date) ==========" >> $APP_SYSTEMOUT_LOGFILE
java -jar /hyren/hrsapp/dist/java/zhna/zhna-1.0.jar >> $APP_SYSTEMOUT_LOGFILE 2>&1

# zhna.sh ========= End


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
ExecStart=${PROJECT_ROOT}/bin/zhna.sh
User=hyren

[Install]
WantedBy=multi-user.target
EOF
# check
cat /etc/systemd/system/hre-appmis.service
grep "${PROJECT_ROOT}" /etc/systemd/system/hre-appmis.service  # see : ExecStart=/hyren/hrsapp/bin/zhna.sh

# 返回 pi用户
su - pi

# 启用服务
sudo systemctl start hre-appmis && sudo systemctl status hre-appmis  # show : BINDIR, PATH, Start At, LogFile, Openjdk version ......

# 查看一下应用的运行日志
# 这个日志文件位置，通过上条命令(status)能看到
sudo systemctl restart hre-appmis && sudo systemctl status hre-appmis  # if need do this!
tail /hyren/hrsapp/bin/zhna-systemout.log  # see : Web Server started successfully at 'current date time'
ps -ef | grep java | grep zhna | grep -v grep

# 激活开机启动
sudo systemctl enable hre-appmis

# 重启机器，验证是否开机启动了
echo "$(ifconfig wlan0 | grep inet | grep -v inet6 | awk '{print $2}') $(date +'%Y-%m-%d %H:%M:%S')" > ~/.done && cat ~/.done
sudo reboot

# login pi
cat .done
# check log
tail /hyren/hrsapp/bin/zhna-systemout.log  # see : Web Server started successfully at 'current date time'
# check process
ps -ef | grep java | grep zhna | grep -v grep

# 以下为调试用命令
# systemctl daemon-reload
# systemctl restart hre-appmis
# systemctl status hre-appmis
# systemctl stop hre-appmis
# systemctl disable hre-appmis
```

---

