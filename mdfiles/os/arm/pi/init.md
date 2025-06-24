[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

官网
> https://www.raspberrypi.org

镜像下载地址（包括64位）
> https://downloads.raspberrypi.org/

参考文章：
- [Install 64 bit OS on Raspberry Pi 4 + USB boot](https://qengineering.eu/install-raspberry-64-os.html)
- [系统配置、OpenCV.Yolo等各种系列文章](https://www.pyimagesearch.com/category/raspberry-pi/)

# 1. 烧镜像
## 1.1 网线直连
打开SD卡根文件cmdline.txt，在第一行最前面添加用于网线直连的ip：
```txt
# console开始的是文件原始内容
ip=192.168.137.100 console=seria10,115200 console=tty1 ......
```
用网线把电脑和pi直连后即可通过该ip连接pi了。

## 1.2 配置WiFi

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
* key_mgmt: 可以不写。使用WPA/WPA2加密填写“WPA-PSK”，否则填写“NONE”
* priority: 协议不写。连接优先级，数字越大优先级越高（不可以是负数）
* scan_ssid: 可以不写（连接隐藏WiFi时需要指定该值为1）

（开机后，可编辑文件： /etc/wpa_supplicant/wpa_supplicant.conf）

### Ubuntu IOT 配置wifi
自ubuntu17开始使用netplan配置网络了。连上显示器和键盘开机
```shell
su
echo "network: {config: disabled}" > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
vi /etc/netplan/01-netcfg.yaml 或 50-cloud-init.yaml
# -------
network:
  version: 2
  wifis:
    wlan0:
      dhcp4: true
      dhcp6: true       # 可以没有
      optional: true    # 可以没有
      access-points: 
        "wifi名":
          password: "密码"
# ------- 也可以把上面内容写到TF卡的network-config文件中，试试是不是直接就可以用wifi了

netplan generate    # 或许可以不用执行这个命令
netplan apply    # 可能会报错：netplan-wpa-wlan0.service not found。不用管，重启就可以了
reboot
```

## 1.3 开启 SSH 服务

在SD卡根新建文件：ssh。

（也可以在树莓派开机后创建：sudo touch /boot/ssh）

# 2. 开机后的初始化
## 2.0 必做工作
### 修正vi
修正vi不能使用上下左右键的问题：
```
sudo vi /etc/vim/vimrc.tiny

# 把compatible加上no。再增加一行backspace
set nocompatible
set backspace=2
```

### 设置 root 密码
```shell
sudo passwd root  # hyren188

sudo mkdir /data   # 放各种软件
```

### mount U盘
```shell
sudo mkdir /mnt/usb1
echo "sudo mount /dev/sda1 /mnt/usb1" > ~/mount
chmod 700 init
```

### 建立工作用户
```shell
sudo mkdir /hyren  # 放项目的东西
# -m: 自动在/home下创建主目录
sudo useradd -d /hyren -s /bin/bash hyren
# sudo userdel -r hyren  # 包括主目录一起删除
sudo passwd hyren

sudo cp /home/pi/.bashrc /hyren
sudo cp /home/pi/.profile /hyren

# sudo chown -R hyren:sudo /opt
sudo mkdir -p /hyren/python/venv
sudo chown -R hyren:sudo /hyren
sudo chmod -R g+w /hyren

# 验证hyren用的环境
su - hyren
```

## 2.1 换源
### raspi
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
### ubuntu iot
```shell
cp sources.list sources.list.orgn
sed -i "s%http://ports.ubuntu.com/ubuntu-ports%https://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports%g" sources.list
```

## 2.2 修改系统时间
```shell
sudo dpkg-reconfigure tzdata
# 选择： Asia -> Shanghai
```

## 2.3 系统软件
### Ubuntu IOT
#### 关闭apt自动更新
```shell
sudo systemctl stop apt-daily.service
sudo systemctl stop apt-daily.timer
sudo systemctl stop apt-daily-upgrade.service
sudo systemctl stop apt-daily-upgrade.timer
sudo systemctl disable apt-daily.service
sudo systemctl disable apt-daily.timer
sudo systemctl disable apt-daily-upgrade.service
sudo systemctl disable apt-daily-upgrade.timer
```
#### 安装桌面
```shell
sudo apt-get install -y xubuntu-desktop
# ----> 选择 lightDM 作为桌面管理器

# 卸载office
sudo dpkg -l | grep office
sudo apt remove --purge libreoffice-逐个卸载
sudo apt autoremove
```
安装好桌面后，如果wifi没了，需要将先前netplan中的wifis配置全部注释掉，重启后通过图形页面打开网络连接WiFi。

### python
将python改成成python3
```shell
sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 100 
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 150
```

### docker
* [Docker官方文档](https://docs.docker.com/)
```shell
curl -sSL https://get.docker.com | sh
# 树莓派专属脚本福利，一句搞定！

sudo docker --version
# 确认版本号，返回类似：Docker version 19.03.5, build 633a0ea

sudo nano /etc/docker/daemon.json
# 添加国内镜像，写入如下内容：

{
  "registry-mirrors": ["https://registry.docker-cn.com"]
}
# 保存（ctrl+o）退出（ctrl+x）

sudo systemctl restart docker.service 
sudo systemctl enable docker.service
# 重启docker并常驻服务

sudo docker pull portainer/portainer
# 安装docker图形化UI

sudo docker volume create portainer_data
sudo docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
# 创建UI容器，可以在浏览器中输入树莓派IP:9000 访问，设置帐号密码后选择local（本地）
```

# 3 其他-可选
## 安装CSI摄像头
1. 把CSI接口上的黑色横条向上提起
2. 把摄像头蓝色面对着USB接口端（也就是摄像头对着USB接口），轻轻插进去
3. 把黑色横条下压，即可固定了
4. 执行raspi-config，把Camera设置成Enable，重启即可

重启后，执行以下命令验证摄像头是否可用
```shell
raspistill -o test.jpg -t 5000    # 5秒后拍摄一张照片，保存为test.jpg

raspivid -o test.n264 -t 5000 -w 1280 -h 720     # 拍摄一段时长5秒，分辨率1280x720的视频
```
- 在/dev/video中创建节点

## 桌面版设置
### 中文及输入法
```shell
# 字体。不装也行，乱装字体，可能在某些输入框内会出现光标漂移
sudo apt install -y ttf-wqy-zenhei ttf-wqy-microhei
# 更改菜单界面语言：选zh_CN.UTF8。
sudo raspi-config 或 dpkg-reconfigure locales
reboot
# 重启后，如果没有中文，选菜单：Preferences->RasPi Configuration->Localisation->Set Locale，选中文的语言国家等

# 输入法
sudo apt install fcitx fcitx-googlepinyin  # fcitx-module-cloudpinyin fcitx-sunpinyin
# Preferences(首选项)->Fcitx配置->InputMethod(输入法)，添加"Google拼音"
```

## 开启蓝牙并设置开机启动
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

## 设置固定IP
vi /etc/dhcpcd.conf
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
