[首 页](https://patrickj-fd.github.io/index)

---

# 1. 烧镜像
## 1.1 配置WiFi

将刷好 Raspbian 系统的 SD 卡用电脑读取，在SD卡根新建文件：wpa_supplicant.conf。按照下面例子填写实际信息：
```ini
country=CN
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
 
network={
ssid="WiFi-A"
psk="12345678"
key_mgmt=WPA-PSK
priority=1
scan_ssid=1
}
```

* 多个wifi就写多个network
* ssid:网络的ssid
* psk:密码
* key_mgmt: 使用WPA/WPA2加密填写“WPA-PSK”，否则填写“NONE”
* priority:连接优先级，数字越大优先级越高（不可以是负数）
* scan_ssid: 可以不写（连接隐藏WiFi时需要指定该值为1）

（开机后，可编辑文件： /etc/wpa_supplicant/wpa_supplicant.conf）

## 1.2 开启 SSH 服务

在SD卡根新建文件：ssh。

（也可以在树莓派开机后创建：sudo touch /boot/ssh）

# 2. 开机后的初始化
## 2.1 换源
```shell
# 切换到root
su -
# 备份
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo cp /etc/apt/sources.list.d/raspi.list /etc/apt/sources.list.d/raspi.list.bak

#修改成国内源
echo "deb http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ buster main contrib non-free rpi" > /etc/apt/sources.list
echo "deb-src http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ buster main contrib non-free rpi" >> /etc/apt/sources.list
echo "deb http://mirrors.tuna.tsinghua.edu.cn/raspberrypi/ buster main ui" > /etc/apt/sources.list.d/raspi.list
echo "deb-src http://mirrors.tuna.tsinghua.edu.cn/raspberrypi/ buster main ui" >> /etc/apt/sources.list.d/raspi.list

apt update
apt upgrade

# 切换回 pi 用户
su - pi
mkdir ~/.pip
echo "[global]" > ~/.pip/pip.conf
# trusted-host=mirrors.aliyun.com
# index-url = https://mirrors.aliyun.com/pypi/simple/
echo "trusted-host=pypi.tuna.tsinghua.edu.cn" >> ~/.pip/pip.conf
echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf

```
## 2.2 修改系统时间
```shell
sudo dpkg-reconfigure tzdata
# 选择： Asia -> Shanghai
```

## 2.3 开启蓝牙并设置开机启动
```shell
sudo service bluetooth start
sudo update-rc.d bluetooth enable

sudo apt-get install bluez-tools

# 设置各个系统级配置文件。切换到 root
su -

SysConfFile="/etc/systemd/network/pan0.netdev"
ls $SysConfFile  # 这个文件应该不存在，创建他
echo -e "[NetDev]\nName=pan0\nKind=bridge" > $SysConfFile
cat $SysConfFile

SysConfFile="/etc/systemd/network/pan0.network"
ls $SysConfFile  # 这个文件应该不存在，创建他
echo -e "[Match]\nName=pan0" > $SysConfFile
echo -e "[Network]\nAddress=172.20.1.1/24\nDHCPServer=yes" >> $SysConfFile
cat $SysConfFile

SysConfFile="/etc/systemd/system/bt-agent.service"
ls $SysConfFile  # 这个文件应该不存在，创建他
echo -e "[Unit]\nDescription=Bluetooth Auth Agent" > $SysConfFile
echo -e "[Service]\nExecStart=/usr/bin/bt-agent -c NoInputNoOutput\nType=simple" >> $SysConfFile
echo -e "[Install]\nWantedBy=multi-user.target" >> $SysConfFile
cat $SysConfFile

SysConfFile="/etc/systemd/system/bt-network.service"
ls $SysConfFile  # 这个文件应该不存在，创建他
echo -e "[Unit]\nDescription=Bluetooth NEP PAN\nAfter=pan0.network" > $SysConfFile
echo -e "[Service]\nExecStart=/usr/bin/bt-network -s nap pan0\nType=simple" >> $SysConfFile
echo -e "[Install]\nWantedBy=multi-user.target" >> $SysConfFile
cat $SysConfFile

# 开启各个服务
sudo systemctl enable systemd-networkd
sudo systemctl enable bt-agent
sudo systemctl enable bt-network
sudo systemctl start systemd-networkd
sudo systemctl start bt-agent
sudo systemctl start bt-network
```

修改：sudo vi /etc/rc.local，在最后一行 "exit 0" 前面加上：
```
sleep 10s
bt-adapter --set Discoverable 1
```
reboot 重启可以用手机蓝牙找到 raspberrypi 的蓝牙设备，并且通过 172.20.1.1 可以访问到树莓派的服务

## 2.9 （可选）
### 设置固定IP

编辑文件： /etc/dhcpcd.conf
```ini
interface wlan0
 
static ip_address=192.168.0.123/24
static routers=192.168.0.1
static domain_name_servers=192.168.0.1 114.114.114.114 119.29.29.29
```

有线网络配置，修改 /boot/interfaces 文件
```ini
# interfaces(5) file used by ifup(8) and ifdown(8)
# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d
## Used dhcp ip address set eth0 inet to dhcp,
## or used static ip address set eth0 to static
## and change other ip settings.
## If you wanna let settings to take effect,
## uncomment symbol in front.

#auto eth0
#allow-hotplug eth0

#iface eth0 inet dhcp
#iface eth0 inet static
#address 172.16.192.168
#netmask 255.255.255.0
#gateway 172.16.192.1
#dns-nameservers 8.8.8.8
```

---

[首 页](https://patrickj-fd.github.io/index)
