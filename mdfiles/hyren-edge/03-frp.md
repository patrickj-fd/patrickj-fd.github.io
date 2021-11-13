[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

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
dashboard_port = 49902
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

# 1. 获取软件
# ***方式一 *** 
scp fd@172.168.0.216:/data3/HyrenEdge/pi/soft/frp_0.34.3_linux_arm.tar.gz /hyren/frp.tar.gz   # For pi
# OR:
scp fd@172.168.0.216:/data3/HyrenEdge/nano/frp_0.34.3_linux_arm64.tar.gz /hyren/frp.tar.gz   # For Nano

tar -xf /hyren/frp.tar.gz -C /opt && ls /opt
rm /hyren/frp.tar.gz && ls /hyren

# ***方式二 ***
# Pi
# 华为云上也可以下载软件：sftp root@139.9.126.19 get /data/hre/pi/frp_0.34.3_linux_arm.tar.gz
FRP_DIST_PATH=pi
FRP_DIST_NAME=frp_0.34.3_linux_arm
# Nano
# 华为云上也可以下载软件：sftp root@139.9.126.19 get /data/hre/nano/frp_0.34.3_linux_arm64.tar.gz
FRP_DIST_PATH=nano
FRP_DIST_NAME=frp_0.34.3_linux_arm64
#ssh root@172.168.0.100 "cat /data1/HyrenEdge/${FRP_DIST_PATH}/${FRP_DIST_NAME}.tar.gz" | tar -zxf - -C /opt  # 5t6y0524A!
curl -s ftp://ftp:@172.168.0.100/${FRP_DIST_PATH}/${FRP_DIST_NAME}.tar.gz | tar -zxf - -C /opt
#tar -zxf ${FRP_DIST_NAME}.tar.gz  -C /opt && rm -f ${FRP_DIST_NAME}.tar.gz

# 2. 开始安装
mv /opt/frp_*/ /opt/HRETNC/ && ls /opt
chown -R root:root /opt/HRETNC/ && ls -l /opt/HRETNC/

cd /opt/HRETNC/ && rm -rf frps* *.ini LICENSE systemd && ls # only left frpc
mv frpc HRETNC && ls -l

# 3. 设置server端的端口
Server_Port=49901

# 4. 设置3位设备编号。和主机名的编号相同。该设备使用的端口会后缀两位数字，即每个设备可以有99个端口。
# [ 内部测试的机器设置为：499 ]
HRE_ORG_NO=$(hostname) && HRE_ORG_NO=${HRE_ORG_NO:3:3} && echo $HRE_ORG_NO  # show : 400 or 401 or 402 ......

# 5. 设置设备名。可用名字为：pi , nano1 , nano2。
EdgeName=

# 6. 设置对外端口最后两位数字
# pi设置为00；两个nano分别设置为：01/02。
# [ 内部测试的机器设置为：pi/10, nano1/11, nano2/12 ...... 并且，不要执行下面的if语句 ]
if [ "$EdgeName" == "pi" ]; then PortSuffix="00"; elif [ "$EdgeName" == "nano1" ]; then PortSuffix="01"; elif [ "$EdgeName" == "nano2" ]; then PortSuffix="02"; else echo "========== ERROR EdgeName=$EdgeName =========="; fi
echo; echo PortSuffix=$PortSuffix; echo;  # should be [ pi : 00 , nano : 01 , 02 ]
```

### 2.1 配置 ssh

**关于frpc的日志文件**

因为本操作使用root，会用root用户临时启动用于验证，会生成root权限的日志文件。
而在最后创建的开机启动service文件中，会设置：User=nobody。
为避免开机启动时无权限写日志，所以在ini文件中把log文件放到了tmp目录下。

#### 配置 ssh.ini
```shell
cat > ssh.ini << EOF
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
cat ssh.ini
cat ssh.ini | grep ${HRE_ORG_NO}  # show tow line with HRE_ORG_NO
```

#### 临时启动验证是否可用
```shell
nohup /opt/HRETNC/HRETNC -c /opt/HRETNC/ssh.ini &

# 查看启动日志。最后一行应该类似 :
# ...... [hre400-pi/nano-ssh] start proxy success
tail /tmp/HRETNC-ssh.log

# 验证
ssh -oPort=${HRE_ORG_NO}${PortSuffix} hyren@139.9.126.19
exit

# 显示该进程，并且 kill 掉！！！
ps -ef | grep "HRETNC" | grep "ssh.ini" | grep -v grep

# 务必要删除掉日志文件，否则后续设置完开机启动后，会因为没有权限写这个日志文件导致启动失败！！！！
rm /tmp/HRETNC-ssh*.log
# 看看是不是已经没有apps的日志文件了
ls -l /tmp/HRETNC*.log
```

### 2.2 设置开机启动 ssh

```shell
# for ssh port
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

systemctl start HRETNC-ssh && systemctl status HRETNC-ssh  # check : Active: active (running)
tail /tmp/HRETNC-ssh.log | grep "start proxy success"

systemctl enable HRETNC-ssh

# 重启主机并验证
# LOCAL_WIFI_IP=$(ifconfig wlan0 | grep inet | grep -v inet6 | awk '{print $2}')
echo "$(ifconfig eth0 | grep inet | grep -v inet6 | awk '{print $2}') $(date +'%Y-%m-%d %H:%M:%S')" > /hyren/.hretnc.done && cat /hyren/.hretnc.done
reboot
# 自己笔记本上验证可以ssh上去（hyren 登陆）
ssh hyren@139.9.126.19 -oPort=上面设置的端口（例如：40100）
cat .hretnc.done
exit

# 再次登陆到新安装的设备上(pi/nano)
# 查看服务是否启动了。应该显示类似以下信息：
# nobody     574     1  0 12:20 ?        00:00:00 /opt/HRETNC/HRETNC -c /opt/HRETNC/ssh.ini
sudo ps -ef|grep HRE
# 查看开发服务的启动日志是否有错误。pi应该没有任何输出, nano有错误输出，显示的是服务restart，可以忽略
sudo journalctl | grep HRE

# 查看启动日志。最后一行应该类似 :
# ...... [hre400-pi/nano-ssh] start proxy success
sudo tail /tmp/HRETNC-ssh.log | grep "start proxy success"

```

---

[首 页](https://patrickj-fd.github.io/index)
