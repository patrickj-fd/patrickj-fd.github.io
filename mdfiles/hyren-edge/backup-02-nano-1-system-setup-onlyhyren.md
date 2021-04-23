[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 1. 系统环境安装
烧录后开机，按照画面步骤填写内容：
- 语言选择英语
- 初始用户创建为hyren，密码hre118
- 主机名设置为：hre400-n1 | 后面的数字400，是每个设备的编号，依次增加即可。第2个nano后缀为n2。

## 设置密码
```shell
sudo echo "root:Hre1088" | sudo chpasswd
# 解决每次sudo都要输入密码
su
echo "hyren ALL=(ALL:ALL)  NOPASSWD:ALL" >> /etc/sudoers
exit

sudo mkdir /data  # 放各种软件
sudo chown -R hyren /data
sudo chown -R hyren /opt
```

## 1.1 配置网络
```shell
# 解决ssh缓慢/卡顿问题
sudo vi /etc/ssh/sshd_config
# 最后修改为：
    GSSAPIAuthentication no
    UseDNS no
service sshd restart
```

## 1.2 修改系统性能配置
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

## 1.3 初始化系统环境
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
sudo mkdir /hyren # hyren放项目的东西, data放各种软件
sudo chown -R hyren:sudo /hyren
sudo chmod -R g+w /hyren

vi ~/.bashrc  # uncomment 'force_color_prompt=yes' , PS1's w to W , alias ll='ls -lAhF'

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

### 更新系统
```shell
sudo apt update
# 可能报错： Failed to fetch https://repo.download.nvidia.cn/jetson/t210/dists/r32.4/main/binary-arm64/Packages.gz  File has unexpected size ...
# 解决办法： clean一下
sudo apt-get clean
sudo apt-get update

sudo apt-get upgrade
# 更新过程中，会要求选择X，随便选gdm3即可，后面会关闭X的。
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

### 设置Pi的免密

**在Pi主机上执行！**
```shell
ssh-keygen -t rsa
NANO_IP=nano的ip
ssh-copy-id -i ~/.ssh/id_rsa.pub hyren@${NANO_IP}
ssh hyren@${NANO_IP}  # for check
```

### 禁止启动时进入桌面
```shell
sudo systemctl set-default multi-user.target   #关闭图形界面
sudo reboot
systemctl set-default graphical.target    #打开图形界面
sudo reboot
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

# 3. 安装 Frp

[参 见](03-frp)

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
sudo nmcli device wifi list
# 连接
sudo nmcli device wifi connect 'boyan-dev-5G' password 'hongzhitech'

ifconfig
```

---

[首 页](https://patrickj-fd.github.io/index)

