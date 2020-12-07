[首 页](https://patrickj-fd.github.io/index)

---

# 1. Pi
## 1.1 配置网络

### 网线直连
打开SD卡根文件cmdline.txt，在第一行最前面添加用于网线直连的ip：
```txt
# console开始的是文件原始内容
ip=192.168.137.100 console=seria10,115200 console=tty1 ......
```
用网线把电脑和pi直连后即可通过该ip连接pi了。

**注意：用完后，务必要把新加进去的'ip=192.168.137.100'删除掉！否则，每次开机都会等待很久的网络（持续出现：waiting up to 100 more seconds for network）**

### WiFi
在SD卡根新建文件：wpa_supplicant.conf
```ini
country=CN
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
    ssid="boyan-dev-5G"
    psk="hongzhitech"
}
```
如果出现连接不成功的情况，有很大的可能是由于配置文件配置错误的原因
```shell
sudo wpa_supplicant -c /etc/wpa_supplicant/wpa_supplicant.conf  -i wlan0
```
通过wpa_supplicant的直接连接，如果配置文件出现问题，则会直接提示配置文件的错误详情

### 开启 SSH 服务
在SD卡根新建文件：ssh。（也可以在树莓派开机后创建：sudo touch /boot/ssh）

## 1.2 初始化系统环境

pi/raspberry 登陆机器

### 设置设备编号
```shell
HRE_CODE=400
```

### 设置主机名
```shell
sudo hostnamectl set-hostname hre${HRE_CODE}-pi
cp /etc/hosts ./hosts.bak # backup
# 把里面的raspberrypi修改为：hre400-pi (127.0.1.1 开头的一行)
sudo sed -i "s/raspberrypi/hre${HRE_CODE}-pi/g" /etc/hosts
cat /etc/hosts
sudo reboot
hostname  # show : hre400-pi
# 再次确认 hosts 中 127.0.1.1 开头的一行是否已经修改为 hre400-pi
cat /etc/hosts
```

### 修正vi不能使用上下左右键
```
sudo vi /etc/vim/vimrc.tiny

# 把compatible加上no。再增加一行backspace
set nocompatible
set backspace=2
```
### 设置初始值
```shell
# 设置密码不要用特殊符号，USB键盘直接操作时，这些符合是全乱套的，导致无法输入正确的密码
sudo echo "root:Hre1088" | sudo chpasswd
sudo echo "pi:Hre2188" | sudo chpasswd
sudo mkdir /data
sudo chown -R pi /data
sudo chown -R pi /opt

vi .bashrc
# 46行： 把 force_color_prompt=yes 注释掉。以便从颜色上，让 pi 用户区别于其他用户。注意：如果用vscode连接上，这个颜色依然会有。
```
### mount U盘
```shell
sudo mkdir /mnt/usb1 /mnt/usb2
cat > ~/mount << EOF
#! /bin/bash

USB_NO=\$1
if [ "x\$USB_NO" == "x" ]; then
  echo "Missing usb number."
  exit 1
fi

sudo mount /dev/sda\$USB_NO /mnt/usb\$USB_NO
echo
echo USB : /mnt/usb\$USB_NO
ls /mnt/usb\$USB_NO
echo
EOF
chmod 700 ~/mount
```

### 建立工作用户
```shell
sudo mkdir /hyren
sudo useradd -d /hyren -s /bin/bash hyren
# sudo userdel -r hyren  # 包括主目录一起删除
sudo echo "hyren:hre118" | sudo chpasswd

sudo cp /home/pi/.bashrc /hyren
sudo cp /home/pi/.profile /hyren

# 修改环境
vi /hyren/.bashrc
# 46行： 把 force_color_prompt=yes 打开
# 60行： PS1 最后 [\w ... '] 改为：[\W\[\033[00m\]\$ '] 。即 w 改成大写，并且把 $ 挪到最后。
# 62行： PS1 把 w 改成大写。
# 91行： alias ll = 'ls -lAhF'

sudo chown -R hyren:sudo /hyren
sudo chmod -R g+w /hyren

# 验证hyren用户的环境
su - hyren
# 登陆后，执行：ll看权限 , pwd看主目录位置
exit  # back to pi
```

### 换源
```shell
# 切换到root
su -
cp /etc/apt/sources.list /etc/apt/sources.list.bak
cp /etc/apt/sources.list.d/raspi.list /etc/apt/sources.list.d/raspi.list.bak
#修改成国内源
echo "deb http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ buster main contrib non-free rpi" > /etc/apt/sources.list
echo "deb-src http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ buster main contrib non-free rpi" >> /etc/apt/sources.list
echo "deb http://mirrors.tuna.tsinghua.edu.cn/raspberrypi/ buster main ui" > /etc/apt/sources.list.d/raspi.list
echo "deb-src http://mirrors.tuna.tsinghua.edu.cn/raspberrypi/ buster main ui" >> /etc/apt/sources.list.d/raspi.list

apt update
apt upgrade -y
```

### 修改系统时间
```shell
dpkg-reconfigure tzdata
# 选择： Asia -> Shanghai
date  # show : CST time and equal yours time
```

## 1.3 系统软件安装
### java
```shell
mkdir /usr/java
/home/pi/mount 1
tar -xf /mnt/usb1/hre/pi/OpenJDK8U-jdk_arm_linux_hotspot_8u275b01.tar.gz -C /usr/java
ln -s /usr/java/jdk8u275-b01 /usr/java/default && ls -l /usr/java
echo "export JAVA_HOME=/usr/java/default" >> /etc/profile
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile

# 验证java
su - hyren
java -version
```
### 工具软件
```shell
su - pi
sudo apt install -y htop nmap
```

# 2. 安装AI环境
- [参考](../pi/ai-mkenv)

# 3. 安装项目

1. [安装frp Client端-ssh](03-frp)
2. [安装项目运行环境](50-app-pi)

# 4. 清理工作
```shell
history -c
echo > ~/.bash_history
history -r
```

# 5. 系统设置
## 4.1 连接wifi（命令行下）
```shell
# 查看wifi列表
sudo iwlist wlan0 scan | grep SSID

# 配置wifi
# 如果网络没有密码，则添加一行：key_mgmt=NONE
# 如果网络是隐藏的，则添加一行：scan_ssid=1
sudo vi /etc/wpa_supplicant/wpa_supplicant.conf
# 该文件保存后，一般等待几秒就可以连上网络了，如果不行试试：
sudo ifdown wlan0
sudo ifup wlan0     # or reboot 
# 也可以试试下面这个：
sudo wpa_cli -i wlan0 reconfigure
```

---

[首 页](https://patrickj-fd.github.io/index)
