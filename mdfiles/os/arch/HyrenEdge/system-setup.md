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

## 1.2 初始化系统软件
### 修正vi不能使用上下左右键
```
sudo vi /etc/vim/vimrc.tiny

# 把compatible加上no。再增加一行backspace
set nocompatible
set backspace=2
```
### 设置密码
```shell
sudo echo "root:hre@188" | chpasswd
sudo echo "pi:hre@188" | chpasswd
sudo mkdir /data  # 放各种软件
sudo chown -R pi:sudo /opt
```
### mount U盘
```shell
sudo mkdir /mnt/usb1 /mnt/usb2
echo "sudo mount /dev/sda1 /mnt/usb1" > ~/mount
chmod 700 ~/mount
```

### 建立工作用户
```shell
sudo mkdir /hyren  # 放项目的东西
sudo useradd -d /hyren -s /bin/bash hyren
# sudo userdel -r hyren  # 包括主目录一起删除
sudo echo "pi:hre118" | chpasswd

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

### 修改系统时间
```shell
sudo dpkg-reconfigure tzdata
# 选择： Asia -> Shanghai
```

### 禁用python2
```shell
sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 100 
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 150
```

### 安装常用软件
```shell
sudo apt install htop
```

## 1.3 安装软件
### 系统工具
```shell
sudo apt install htop
```

# 2. Nano
烧录后开机，按照画面步骤填写内容，语言选择英语，初始用户创建为hyren，密码hre118。
### 设置密码
```shell
sudo echo "root:hre@188" | chpasswd
# 解决每次sudo都要输入密码
su
echo "hyren ALL=(ALL:ALL)  NOPASSWD:ALL" >> /etc/sudoers
exit

sudo mkdir /data  # 放各种软件
```

## 2.1 配置网络

## 2.2 修改系统性能配置
### 增加swap
```shell
su -

# 省SD，设置为全部用内存
vi /etc/sysctl.conf
vm.swappiness=0
reboot

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

# -m 对应的是 mode ID, 比如 0 或 1。
# 10w模式：
sudo /usr/sbin/nvpmodel -m 0
# 5w模式：
sudo /usr/sbin/nvpmodel -m 1

sudo /usr/bin/jetson_clocks
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

## 2.3 初始化系统软件
### mount U盘
```shell
sudo mkdir /mnt/usb1 /mnt/usb2
echo "sudo mount /dev/sda1 /mnt/usb1" > ~/mount
chmod 700 ~/mount
```

### 建立工作用户
```shell
sudo mkdir /hyren  # 放项目的东西
sudo chown -R hyren:sudo /hyren
sudo chmod -R g+w /hyren

vi ~/.bashrc  # uncomment 'force_color_prompt=yes' , PS1's w to W , alias ll='ls -lAh'

echo "" >> ${HOME}/.bashrc
echo "export CUBA_HOME=/usr/local/cuda" >> ${HOME}/.bashrc
echo "export PATH=/usr/local/cuda/bin:\${PATH}" >> ${HOME}/.bashrc
echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64:\${LD_LIBRARY_PATH}" >> ${HOME}/.bashrc

source .bashrc
nvcc -V  # see CUDA info
```

### 换源
```shell
# 清华源对于 nano 来说，是最好的
su -
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

# 3. 安装 Frp
```shell
# Pi上：
tar xf frp_0.33.0_linux_arm.tar.gz -C /opt
mv /opt/frp_0.33.0_linux_arm/ /opt/frp_0.33.0/
# Nano上：
tar xf frp_0.33.0_linux_arm64.tar.gz -C /opt
mv /opt/frp_0.33.0_linux_arm64/ /opt/frp_0.33.0/

cd /opt/frp_0.33.0/
rm -rf frps*
mkdir log

# ----- ssh.ini ----- Start
HRE_ORG_NO=400  # 3位企业编号。该企业使用的端口会后缀两位数字，即每个企业可以有99个端口。
EdgeName="pi"  # 该端口在哪台设备上，可用名字为：pi , nano1 , nano2
cat > ssh.ini << EOF
[common]
server_addr = 139.9.126.19
server_port = 39001
log_file = /opt/frp_0.33.0/log/ssh.log
log_level = info
log_max_days = 3

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
server_port = 39001
log_file = /opt/frp_0.33.0/log/apps.log
log_level = info
log_max_days = 3

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

echo "nohup /opt/frp_0.33.0/frpc -c /opt/frp_0.33.0/ssh.ini &" > start.sh
echo "nohup /opt/frp_0.33.0/frpc -c /opt/frp_0.33.0/apps.ini &" > start-apps.sh

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

sudo systemctl start frpc
sudo systemctl enable frpc
```

## 登录 Nano

---

[首 页](https://patrickj-fd.github.io/index)
