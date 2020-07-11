[首 页](https://patrickj-fd.github.io/index)

---

# 1. 初始设置
## 1.1 清理默认的各种东东
##### 关闭自动更新
不关闭的话，如果它在自动更新时，碰巧自己在apt装软件，会出现锁。

System Settings | Software & Updates，在Updates页，Automatically check for updates，选择Never。

##### 清理不用的软件
```shell
sudo apt-get purge wolfram-engine
sudo apt-get purge libreoffice*
sudo apt-get clean
sudo apt-get autoremove
```

## 1.2 更换源
```shell
cd /etc/apt && sudo cp source.list source.list.orgn && sudo echo "" > source.list && sudo vi source.list
# 加入以下内容
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-backports main multiverse restricted universe
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-proposed main multiverse restricted universe
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-security main multiverse restricted universe
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-updates main multiverse restricted universe
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic main multiverse restricted universe
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-backports main multiverse restricted universe
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-proposed main multiverse restricted universe
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-security main multiverse restricted universe
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-updates main multiverse restricted universe

sudo apt update
```

## 1.3 禁止启动时进入桌面
- 编辑配置文件：vi /etc/default/grub   
  * 注释掉：GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"   
  * 修改为：GRUB_CMDLINE_LINUX_DEFAULT="text"   
- 执行 “update-grub” 以生效   
- 重启系统

** Ubuntu 18.04 另外一种方式 (未验证) **
```shell
sudo systemctl set-default multi-user.target   #关闭图形界面
sudo reboot
systemctl set-default graphical.target    #打开图形界面
sudo reboot

# 关闭：在图形界面下 终端输入 
sudo service lightdm stop
# 开启：在命令行输入
sudo service lightdm start
```

## 1.x 其他
- 开启远程桌面访问
  * 服务器：通过RDP（Remote Desktop Protocol）：apt install xrdp
  * 客户机：使用Remmina Remote Desktop Client软件
  * 由于Jetson Nano并不支持两个客户端同时登录，修改/etc/gdm3/custom.conf，注释掉：AutomaticLoginEnable和Automatic Login

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
