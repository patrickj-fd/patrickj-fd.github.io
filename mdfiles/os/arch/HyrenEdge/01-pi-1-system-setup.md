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
### 开启 SSH 服务
在SD卡根新建文件：ssh。（也可以在树莓派开机后创建：sudo touch /boot/ssh）

## 1.2 初始化系统环境

### 设置设备编号
```shell
HRE_CODE=400
```

### 设置主机名
```shell
sudo hostnamectl set-hostname hre${HRE_CODE}-pi
cp /etc/hosts ./hosts.bak # backup
# 把里面的raspberrypi修改为：hre400-pi (127.0.1.1 开头的一行)
sudo sed -i "s/raspberrypi/hre${HRE_CODE}-pi/g'" /etc/hosts
cat /etc/hosts
sudo reboot
hostname  # check
cat /etc/hosts
```

### 修正vi不能使用上下左右键
```
sudo vi /etc/vim/vimrc.tiny

# 把compatible加上no。再增加一行backspace
set nocompatible
set backspace=2
```
### 设置密码
```shell
sudo echo "root:hre@188" | sudo chpasswd
sudo echo "pi:hre@188" | sudo chpasswd
sudo mkdir /data  # 放各种软件
sudo chown -R pi /data
sudo chown -R pi /opt
vi .bashrc  # alias ll = 'ls -lhF'
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
sudo mkdir /hyren  # 放项目的东西
sudo useradd -d /hyren -s /bin/bash hyren
# sudo userdel -r hyren  # 包括主目录一起删除
sudo echo "hyren:hre118" | sudo chpasswd

sudo cp /home/pi/.bashrc /hyren
sudo cp /home/pi/.profile /hyren

sudo chown -R hyren:sudo /hyren
sudo chmod -R g+w /hyren
# 验证hyren用的环境
su - hyren
```

### 换源
```shell
# 切换到root
su
cp /etc/apt/sources.list /etc/apt/sources.list.bak
cp /etc/apt/sources.list.d/raspi.list /etc/apt/sources.list.d/raspi.list.bak
#修改成国内源
echo "deb http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ buster main contrib non-free rpi" > /etc/apt/sources.list
echo "deb-src http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ buster main contrib non-free rpi" >> /etc/apt/sources.list
echo "deb http://mirrors.tuna.tsinghua.edu.cn/raspberrypi/ buster main ui" > /etc/apt/sources.list.d/raspi.list
echo "deb-src http://mirrors.tuna.tsinghua.edu.cn/raspberrypi/ buster main ui" >> /etc/apt/sources.list.d/raspi.list

apt update
apt upgrade
exit
```

### 修改系统时间
```shell
sudo dpkg-reconfigure tzdata
# 选择： Asia -> Shanghai
date
```

## 1.3 系统软件安装
### java
```shell
su
mkdir /usr/java
tar -xf /mnt/usb1/hre/pi/OpenJDK8U-jdk_arm_linux_hotspot_8u275b01.tar.gz -C /usr/java
ln -s /usr/java/jdk8u275-b01 /usr/java/default
echo "export JAVA_HOME=/usr/java/default" >> /etc/profile
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile
exit
# 验证java
su - pi
java -version
```

### 安装AI环境
- [参考](../pi/ai-mkenv)

#### 以下作废
#### 删除 python2
```shell
sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 100 
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 150
python -V
# ----- 或者彻底卸载python2
sudo apt remove --purge python
sudo apt remove --auto-remove python2.7
sudo apt clean
# 确认
ll /usr/bin/py*
# ----- 卸载方式暂时没有试
```

#### 安装tensorflow
```shell
#sudo apt install -y --no-install-recommends python3-dev python3-pip python3-setuptools  # 这样好像会吧默认的3.7破坏掉，所以，应该创建虚拟环境来搞
sudo apt install -y build-essential tk-dev libncurses5-dev libncursesw5-dev libreadline6-dev libdb5.3-dev libgdbm-dev libsqlite3-dev libssl-dev libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev libhdf5-dev  python3-dev gfortran libblas-dev liblapack-dev libopenblas-dev libatlas-base-dev

# grpcio 安装非常慢，最好下载下来，用nohup单独装
# https://pypi.tuna.tsinghua.edu.cn/packages/cc/1e/5d65ae830536fdb67f10f4bcedca6eb59190ad60d20d796ef3ccdfda4797/grpcio-1.33.2.tar.gz
nohup python3 -m pip install grpcio &
# grpcio 安装时可能报错：command: 'install_requires' must string or list of strings containing ...
sudo python3 -m pip install -U setuptools

# 安装 numpy 因为旧版本的TF不支持高版本的numpy，所以干脆装一个最后的一个py2.7兼容版 1.16.6
python3 -m pip install numpy==1.16.6

# 截止到 2020年7月1日 ，还是不要装1.14。因为不能和opencv3共存，keras会报错：找不到libhdfs.so
# sudo pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple tensorflow==1.13.1
cd /data
wget -c https://www.piwheels.org/simple/tensorflow/tensorflow-1.13.1-cp37-none-linux_armv7l.whl
sudo python3 -m pip install tensorflow-1.13.1-cp37-none-linux_armv7l.whl

sudo python3 -m pip install h5py pandas
# wget -c https://www.piwheels.org/simple/pandas/pandas-1.0.5-cp37-cp37m-linux_armv7l.whl

sudo python3 -m pip install keras==2.3.1

# 验证
python3

import keras
print(keras.__version__)

import tensorflow as tf
a = tf.placeholder(tf.float32)
b = tf.placeholder(tf.float32)
add = tf.add(a, b)
sess = tf.Session()
binding = {a: 1.5, b: 2.5}
c = sess.run(add, feed_dict=binding)
print(c)
sess.close()
```

如果要同时安装Opencv3和tensorflow，那么只能用python3.7安装tensorflow1.13版本的！

#### OpenCV3
- 方式1
```shell
sudo apt install -y python3-opencv
```

- 方式2

用方式1，安装的是3.2.0（截止2020年6月），而且，创建虚拟环境时，默认无法使用cv。  
可以直接下载指定版本的whl文件进行安装。[下载地址](https://www.piwheels.org/simple/opencv-python/)  
```shell
sudo apt install -y libqtgui4 libqt4-test
sudo apt-get install libjpeg-dev libtiff5-dev libjasper-dev libpng-dev -y
python3 -m pip install opencv_python-3.4.7.28-cp37-cp37m-linux_armv7l.whl
```

如果 import cv2 报错类似： ImportError: ... undefined symbol: ... arm-linux-gnueabihf.so __atomic_fetch_add_8。 这是一个bug，需要加载一个库文件来解决：
```shell
sudo find / -name "libatomic.so*"  # 找到 libatomic.so.1.2.0 的路径，导入环境变量
echo "export LD_PRELOAD=/usr/lib/arm-linux-gnueabihf/libatomic.so.1.2.0" >> ~/.bashrc
source ~/.bashrc
# 或者，把 LD_PRELOAD 加到虚拟环境的启动脚本中（bin/activate）
```

用这种方式，或者也可以装OpenCV4。（未验证）

#### OpenCV4
```shell
sudo apt-get update && sudo apt-get upgrade
sudo apt-get install build-essential cmake pkg-config -y
sudo apt-get install libjpeg-dev libtiff5-dev libjasper-dev libpng-dev -y
sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev -y
sudo apt-get install libxvidcore-dev libx264-dev -y
sudo apt-get install libfontconfig1-dev libcairo2-dev -y
sudo apt-get install libgdk-pixbuf2.0-dev libpango1.0-dev -y
sudo apt-get install libgtk2.0-dev libgtk-3-dev -y
sudo apt-get install libatlas-base-dev gfortran -y
sudo apt-get install libhdf5-dev libhdf5-serial-dev libhdf5-103 -y
sudo apt-get install -y libqtgui4 libqtwebkit4 libqt4-test python3-pyqt5
sudo python3 -m pip install opencv-python
```

### 工具软件
```shell
sudo apt install htop
```

## 2.5 设置AI环境

[参 见](../pi/ai-mkenv-nano)

# 清理工作
```shell
history -c
echo > ~/.bash_history
history -r
```

---

[首 页](https://patrickj-fd.github.io/index)
