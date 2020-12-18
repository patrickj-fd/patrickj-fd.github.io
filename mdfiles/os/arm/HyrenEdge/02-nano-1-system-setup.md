[首 页](https://patrickj-fd.github.io/index)

---

# 1. 系统环境安装
1. 烧录后开机，按照画面步骤填写内容
  - 语言选择英语
  - 时区选择上海
  - Your name : pi , password : Hre2188
  - 主机名设置为：hre${HRE_CODE}-nano1
    * HRE_CODE(400, 401, ...)，是每个设备的编号，每安装一个新设备，依次增加即可
    * 第2个nano后缀为nano2

2. 首次进入系统时，显示的Clipit保存历史的提示框，选择：No

3. 关闭自动更新
  - 不关闭的话，如果它在自动更新时，碰巧自己在apt装软件，会出现锁。
  - 打开这个画面，可能会卡顿假死，不用乱点，等一会就可以了。

```
System Settings -> Software & Updates -> Updates tab :
Automatically check for updates : change to 'Never' and then close.
```

## 1.1 初始配置

```shell
# >>>>> 设置 root 密码
sudo echo "root:Hre1088" | sudo chpasswd

# >>>>> 解决每次sudo都要输入密码
su -
echo "pi ALL=(ALL:ALL)  NOPASSWD:ALL" >> /etc/sudoers

# >>>>> 解决ssh缓慢/卡顿问题
sed -i "s/^#GSSAPIAuthentication no/GSSAPIAuthentication no/g" /etc/ssh/sshd_config
grep "GSS" /etc/ssh/sshd_config  # check
sed -i "s/^#UseDNS no/UseDNS no/g" /etc/ssh/sshd_config
grep "DNS" /etc/ssh/sshd_config  # check

# service sshd restart
systemctl restart sshd

# >>>>> 目录权限
# data 放各种软件
mkdir /data
chown -R pi /data
chown -R pi /opt
ls -l / | grep pi  # check

# >>>>> 禁用swap。为了节省SD卡，设置为全部用内存
echo "vm.swappiness = 0" >> /etc/sysctl.conf
# 将SWAP里的数据转储回内存，并清空SWAP里的数据
swapoff -a && swapon -a
# 不重启生效的方式：sysctl -p
reboot
```

## 1.2 检查和清理

**重启后，以下工作，使用 pi 用户操作**

```shell
# 可以先看看前面修改的交换区是否可用
sudo swapon --show
```

### * 检查功率模式
```shell
sudo /usr/sbin/nvpmodel -q  # show : MAXN
# 查看处理器状态，各个值应该符合下面表格中 10W 这一列的数值
sudo jetson_clocks --show
```

10W/5W，两种模式的主要区别：
| Info class   | 10W  | 5W   |
| :-----       | :--: | :--: |
| Online CPU   | 4    | 2    |
| CPU Max Freq | 1479 | 918  |
| GPU Max Freq | 921  | 640  |

**以下修改命令仅供参考，不需要执行！**
```shell
# 修改方式：
# -m 对应的是 mode ID, 比如 0 或 1。
# 10w模式：
sudo /usr/sbin/nvpmodel -m 0
# 5w模式：
sudo /usr/sbin/nvpmodel -m 1
```

### * 清理不用的软件
```shell
sudo apt remove -y --purge wolfram-engine
sudo apt remove -y --purge libreoffice*
sudo apt clean
#sudo apt autoremove
```

### * 更新系统
```shell
sudo apt update
# 可能报错： Failed to fetch https://repo.download.nvidia.cn/jetson/t210/dists/r32.4/main/binary-arm64/Packages.gz  File has unexpected size ...
# 解决办法： clean一下，再重新update：
# sudo apt clean
# sudo apt update

sudo apt upgrade -y
# 更新过程中，会要求选择X，随便选gdm3即可，后面会关闭X的。
```

## 1.3 初始化工作环境

### 1.3.1 mount U盘的脚本
```shell
sudo mkdir /mnt/usb1 /mnt/usb2
cat > ~/mount << EOF
#!/bin/bash
sudo mount /dev/sda1 /mnt/usb1
echo
echo USB : /mnt/usb1
ls /mnt/usb1
echo
EOF
chmod 700 ~/mount
```


### 1.3.2 安装常用软件
```shell
sudo apt install htop

# 官方推出jtop工具，专门用来查看jetson的CPU、GPU等信息，使用方法也很简单
# 装好python环境后再装这个
# sudo python3 -m pip install jetson-stats
# sudo jtop
```

### 1.3.3 建立工作用户
```shell
sudo mkdir /hyren
sudo useradd -d /hyren -s /bin/bash hyren
# sudo userdel -r hyren  # 包括主目录一起删除
sudo echo "hyren:hre118" | sudo chpasswd

sudo cp /home/pi/.bashrc /hyren
sudo cp /home/pi/.profile /hyren

sudo chown -R hyren:sudo /hyren
sudo chmod -R g+w /hyren
```

#### 设置工作用户 hyren 的环境
```shell
su - hyren

# 修改环境参数
# vi ~/.bashrc
# 46行：去掉 force_color_prompt 注释
# 60行：PS1's w to W
# 91行：alias ll='ls -lhF'
# 删除 92 和 93 行的两个 alias la / l
sed -i '46c force_color_prompt=yes' ~/.bashrc
sed -i '60s%\]\\w\\\[%\]\\W\\\[%' ~/.bashrc
sed -i '62s%:\\w\\%:\\W\\%' ~/.bashrc
sed -i "91c alias ll='ls -lhF'" ~/.bashrc
sed -i "93d" ~/.bashrc
sed -i "92d" ~/.bashrc

echo "" >> ~/.bashrc
echo "export CUBA_HOME=/usr/local/cuda" >> ~/.bashrc
echo "export PATH=/usr/local/cuda/bin:\${PATH}" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64:\${LD_LIBRARY_PATH}" >> ~/.bashrc

source ~/.bashrc
# 看命令行是不是只显示当前目录了， ll 命令是否可用

nvcc -V  # see CUDA info

# 设置 python 源
mkdir ~/.pip
echo "[global]" > ~/.pip/pip.conf
echo "trusted-host = pypi.tuna.tsinghua.edu.cn" >> ~/.pip/pip.conf
echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple/" >> ~/.pip/pip.conf
echo "timeout = 150" >> ~/.pip/pip.conf

exit  # for going to pi
```

### 1.3.5 设置 Pi 过来的免密

**在Pi主机上使用 pi 用户执行**
```shell
# pi -> pi 的免密
ssh-keygen -t rsa
NANO_IP=nano的ip
ssh-copy-id -i ~/.ssh/id_rsa.pub pi@${NANO_IP}
ssh ${NANO_IP}  # for check

# hyren -> hyren 的免密
su - hyren
ssh-keygen -t rsa
NANO_IP=nano的ip
ssh-copy-id -i ~/.ssh/id_rsa.pub hyren@${NANO_IP}
ssh ${NANO_IP}  # for check
```

### 1.3.6 关闭图形界面(禁止启动时进入桌面)
```shell
sudo systemctl set-default multi-user.target
sudo reboot

# 恢复(启动时进入桌面)
# sudo systemctl set-default graphical.target
# sudo reboot
```

## 1.4 查看系统情况
```shell
# Jetson Nano L4T版本：
head -n 1 /etc/nv_tegra_release

lscpu
lsusb   # 查看USB设备
lspci   # 查看PCI总线
lsmod   # 查看系统已载入的相关模块
lshw    # 查看硬件
```

# 2. AI环境安装

[参 见](02-nano-2-ai-env)

# 3. 安装项目

1. [安装frp Client端-ssh](03-frp)
2. [安装项目运行环境](60-app-nano)

# 4. 清理
```shell
# su 成 root/pi/hyren 分别执行下面的清理工作
history -c
echo > ~/.bash_history
history -r
```

# 5. 参考命令
## 5.1 连接wifi（命令行下）
```shell
# 查看wifi列表
sudo nmcli device wifi list
# 连接
sudo nmcli device wifi connect 'boyan-dev-5G' password 'hongzhitech'

ifconfig
```

## 5.2换源
**装完tensorflow后再考虑是否要换源。一般情况下不需要更换**
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

---

[首 页](https://patrickj-fd.github.io/index)

