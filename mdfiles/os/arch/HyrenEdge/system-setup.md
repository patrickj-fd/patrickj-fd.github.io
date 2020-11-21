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

### 设置主机名
```shell
sudo hostnamectl set-hostname hre400-pi
sudo vi /etc/hosts
# 把里面的raspberrypi修改为：hre400-pi (127.0.1.1 开头的一行)
sudo reboot
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
sudo chown -R pi:sudo /opt
```
### mount U盘
```shell
sudo mkdir /mnt/usb1 /mnt/usb2
echo "sudo mount /dev/sda1 /mnt/usb1 && ls /mnt/usb1" > ~/mount
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

# 2. Nano
烧录后开机，按照画面步骤填写内容：
- 语言选择英语
- 初始用户创建为hyren，密码hre118
- 主机名设置为：hre400-n1 | 后面的数字400，是每个设备的编号，依次增加即可。第2个nano后缀为n2。

### 设置密码
```shell
sudo echo "root:hre@188" | sudo chpasswd
# 解决每次sudo都要输入密码
su
echo "hyren ALL=(ALL:ALL)  NOPASSWD:ALL" >> /etc/sudoers
exit

sudo mkdir /data  # 放各种软件
```

## 2.1 配置网络
```shell
# 解决ssh缓慢/卡顿问题
sudo vi /etc/ssh/ssh_config
# 最后修改为：
    GSSAPIAuthentication no
    UseDNS no
```

## 2.2 修改系统性能配置
### 增加swap
```shell
su
# 省SD，设置为全部用内存
echo "vm.swappiness = 0" >> /etc/sysctl.conf
swapoff -a && swapon -a   # 将SWAP里的数据转储回内存，并清空SWAP里的数据
reboot  # 不重启生效的方式：sysctl -p

# 验证交换区是否可用
sudo swapon --show
```

### 设置 10w 功率模式
默认即为：MaxN（10W）模式。两种模式的主要区别：

| Info class   | 10W  | 5W   |
| :-----       | :--: | :--: |
| Online CPU   | 4    | 2    |
| CPU Max Freq | 1479 | 918  |
| GPU Max Freq | 921  | 640  |

```shell
# 查看功率模式
sudo /usr/sbin/nvpmodel -q
# 查看处理器状态
sudo jetson_clocks --show

# -m 对应的是 mode ID, 比如 0 或 1。
# 10w模式：
sudo /usr/sbin/nvpmodel -m 0
# 5w模式：
sudo /usr/sbin/nvpmodel -m 1
```

### 关闭自动更新
不关闭的话，如果它在自动更新时，碰巧自己在apt装软件，会出现锁。

System Settings | Software & Updates，在Updates页，Automatically check for updates，选择Never。

### 清理不用的软件
```shell
sudo apt remove --purge wolfram-engine
sudo apt remove --purge libreoffice*    # 如果不行，就对每个软件用本命令逐个卸载
sudo apt clean
#sudo apt autoremove
```

## 2.3 初始化系统环境
### mount U盘
```shell
sudo mkdir /mnt/usb1 /mnt/usb2
echo "sudo mount /dev/sda1 /mnt/usb1 && ls /mnt/usb1" > ~/mount
chmod 700 ~/mount
```

### 建立工作用户
```shell
sudo mkdir /hyren /data # hyren放项目的东西, data放各种软件
sudo chown -R hyren:sudo /hyren
sudo chmod -R g+w /hyren
sudo chown -R hyren:sudo /data
sudo chmod -R g+w /data

vi ~/.bashrc  # uncomment 'force_color_prompt=yes' , PS1's w to W , alias ll='ls -lAh'

echo "" >> ${HOME}/.bashrc
echo "export CUBA_HOME=/usr/local/cuda" >> ${HOME}/.bashrc
echo "export PATH=/usr/local/cuda/bin:\${PATH}" >> ${HOME}/.bashrc
echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64:\${LD_LIBRARY_PATH}" >> ${HOME}/.bashrc

source .bashrc
nvcc -V  # see CUDA info
```

### 换源-装完tf后再考虑换
```shell
# 清华源对于 nano 来说，是最好的。
# 为了避免后面安装tf出问题，先不要换源！
su
cd /etc/apt && cp sources.list sources.list.orgn && echo "" > sources.list && vi sources.list
# 加入以下内容
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic main multiverse restricted universe
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-security main multiverse restricted universe
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-updates main multiverse restricted universe
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-backports main multiverse restricted universe
deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic main multiverse restricted universe
deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-security main multiverse restricted universe
deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-updates main multiverse restricted universe
deb-src http://mirrors.tuna.tsinghua.edu.cn/ubuntu-ports/ bionic-backports main multiverse restricted universe

apt update
# 可能报错： Failed to fetch https://repo.download.nvidia.cn/jetson/t210/dists/r32.4/main/binary-arm64/Packages.gz  File has unexpected size ...
# 解决办法： clean一下
apt-get clean
apt-get update

apt-get upgrade
# 更新过程中，会要求选择X，随便选gdm3即可，后面会关闭X的。
exit
```
**注意：**
如果以后安装软件时，报错类似如下：
```
The following packages have unmet dependencies: 
    xxx : Depends: yyy but it is not going to be installed
          Depends: zzz but it is not going to be installed
E: Unable to correct problems, you have held broken packages.
```
试试：
```shell
sudo apt-add-repository universe
sudo apt-get update
```

### python 源
```shell
mkdir ~/.pip
echo "[global]" > ~/.pip/pip.conf
echo "trusted-host = pypi.tuna.tsinghua.edu.cn" >> ~/.pip/pip.conf
echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple/" >> ~/.pip/pip.conf
echo "timeout = 150" >> ~/.pip/pip.conf
```

### 安装常用软件
```shell
sudo apt install htop

# 官方推出jtop工具，专门用来查看jetson的CPU、GPU等信息，使用方法也很简单
# 装好python环境后再装这个
sudo python3 -m pip install jetson-stats
sudo jtop
```

### 禁止启动时进入桌面
```shell
sudo systemctl set-default multi-user.target   #关闭图形界面
sudo reboot
systemctl set-default graphical.target    #打开图形界面
sudo reboot
```

## 2.4 查看系统情况
```shell
# Jetson Nano L4T版本：
head -n 1 /etc/nv_tegra_release

lscpu
lsusb   # 查看USB设备
lspci   # 查看PCI总线
lsmod   # 查看系统已载入的相关模块
lshw    # 查看硬件
```

## 2.5 设置AI环境

[参 见](ai-mkenv-nano)

# 3. 安装 Frp
```shell
# Pi上：
tar -xf /mnt/usb1/hre/pi/frp_0.33.0_linux_arm.tar.gz -C /opt
mv /opt/frp_0.33.0_linux_arm/ /opt/frp_0.33.0/
# Nano上：
tar xf frp_0.33.0_linux_arm64.tar.gz -C /opt
mv /opt/frp_0.33.0_linux_arm64/ /opt/frp_0.33.0/

cd /opt/frp_0.33.0/
rm -rf frps* && ls
rm -rf *.ini && ls
mkdir log

# ----- ssh.ini ----- Start
Server_Port=39002
HRE_ORG_NO=400  # 3位企业编号。该企业使用的端口会后缀两位数字，即每个企业可以有99个端口。
EdgeName="pi"  # 该端口在哪台设备上，可用名字为：pi , nano1 , nano2
cat > ssh.ini << EOF
[common]
server_addr = 139.9.126.19
server_port = ${Server_Port}
log_file = /opt/frp_0.33.0/log/ssh.log
log_level = info
log_max_days = 100

[hre${HRE_ORG_NO}-${EdgeName}-ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = ${HRE_ORG_NO}00
EOF

# 以下是给除了pi上面的ssh之外，需要开放出去的端口。
cat > apps.ini << EOF
[common]
server_addr = 139.9.126.19
server_port = ${Server_Port}
log_file = /opt/frp_0.33.0/log/apps.log
log_level = info
log_max_days = 100

EOF

# 有多个需要开放的端口，顺序递增PortSuffix变量的值，执行以下脚本代码
EdgeName="pi"    # 该端口在哪台设备上，可用名字为：pi , nano1 , nano2
PortSuffix="01"
cat >> apps.ini << EOF
[hre${HRE_ORG_NO}-${EdgeName}-app${PortSuffix}]
type = tcp
local_ip = 127.0.0.1
local_port = ${HRE_ORG_NO}${PortSuffix}
remote_port = ${HRE_ORG_NO}${PortSuffix}

EOF
# ----- ssh.ini ----- End

echo "#! /bin/bash" > start.sh
echo "nohup /opt/frp_0.33.0/frpc -c /opt/frp_0.33.0/ssh.ini &" >> start.sh
echo "#! /bin/bash" > start-apps
echo "nohup /opt/frp_0.33.0/frpc -c /opt/frp_0.33.0/apps.ini &" > start-apps.sh
chmod 700 start*.sh
# 验证
./start.sh
cat log/ssh.log
ssh -oPort=40000 pi@139.9.126.19
ps -ef|grep frpc
# kill -9 PID


# 设置开机启动
su
cat > /etc/systemd/system/frpc.service << EOF
[Unit]
Description=HyrenEdgeNetServer
After=network.target

[Service]
Type=simple
ExecStart=/opt/frp_0.33.0/frpc -c /opt/frp_0.33.0/ssh.ini
ExecReload=/opt/frp_0.33.0/frpc reload -c /opt/frp_0.33.0/ssh.ini
Restart=on-failure
RestartSec=5s
User=nobody

[Install]
WantedBy=multi-user.target
EOF

systemctl start frpc
systemctl enable frpc

reboot
```

## 登录 Nano

---

[首 页](https://patrickj-fd.github.io/index)
