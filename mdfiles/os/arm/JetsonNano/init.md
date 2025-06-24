[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

- [jkjung Blog](https://jkjung-avt.github.io/)
- [elinux.org/Jetson_Nano](https://elinux.org/Jetson_Nano)
- [NVIDIA Developer Forum](https://devtalk.nvidia.com/default/board/371/jetson-nano/)
- [系统安装教程](https://developer.nvidia.com/zh-cn/embedded/learn/get-started-jetson-nano-devkit)

# 查看系统环境
```shell
# JetPack 版本信息。 例如 JetPack 4.4： R32 (release), REVISION: 4.3
head -n 1 /etc/nv_tegra_release

# 查看CPU、GPU的占用、温度，内存占用 等等实时信息
tegrastats
```

# 1. 必做的工作
## 1.1 初始化工作环境
```shell
# 设置 root 密码
sudo passwd root
# 解决每次sudo都要输入密码
su -
echo "hyren ALL=(ALL:ALL)  NOPASSWD:ALL" >> /etc/sudoers
exit

# mount U盘
sudo mkdir /mnt/usb1
echo "sudo mount /dev/sda1 /mnt/usb1" > init && chmod 700 init

# 建立工作用户。 -m: 自动在/home下创建主目录
sudo useradd -m -s /bin/bash hyren 
# sudo userdel -r hyren  # 包括主目录一起删除
sudo passwd hyren
su - hyren
vi .bashrc  # uncomment 'force_color_prompt=yes' , PS1's w to W , alias ll='ls -lAh'
source .bashrc
exit

# 设置工作目录
sudo chown -R hyren:sudo /opt
sudo mkdir -p /data1/python/venv /data1/ai/app
sudo chown -R hyren:sudo /data1
sudo chmod -R g+w /data1

echo "" >> ${HOME}/.bashrc
echo "export CUBA_HOME=/usr/local/cuda" >> ${HOME}/.bashrc
echo "export PATH=/usr/local/cuda/bin:\${PATH}" >> ${HOME}/.bashrc
echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64:\${LD_LIBRARY_PATH}" >> ${HOME}/.bashrc
source .bashrc
nvcc -V  # see CUDA info
```

## 1.2 修改系统性能配置
### 增加swap
```shell
su -

# 省SD，设置为全部用内存
vi /etc/sysctl.conf
vm.swappiness=0

# 当进行 OpenCV 等大软件编译时，临时增加交换区。
# Create the file for swap.
# If the fallocate command fails or isn’t installed :
# sudo dd if=/dev/zero of=/mnt/8GB.swap bs=8192 count=1048576
fallocate -l 8G /mnt/8GB.swap
chmod 600 /mnt/8GB.swap
# Format the swap file
mkswap /mnt/8GB.swap
# Add the file to the system as a swap file
swapon /mnt/8GB.swap

echo "/mnt/8GB.swap  none  swap  sw 0  0" >> /etc/fstab

# Check that the swap file was created
swapon -s

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

## 1.3 清理系统默认设置
##### 关闭自动更新
不关闭的话，如果它在自动更新时，碰巧自己在apt装软件，会出现锁。

System Settings | Software & Updates，在Updates页，Automatically check for updates，选择Never。

##### 清理不用的软件
```shell
sudo apt remove --purge wolfram-engine
sudo apt remove --purge libreoffice*
sudo apt clean
#sudo apt autoremove
```

## 1.4 更换源
### apt 源
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

deb http://mirrors.aliyun.com/ubuntu-ports/ trusty main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu-ports/ trusty-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu-ports/ trusty-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu-ports/ trusty-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu-ports/ trusty-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu-ports/ trusty main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu-ports/ trusty-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu-ports/ trusty-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu-ports/ trusty-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu-ports/ trusty-backports main restricted universe multiverse

deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-updates main restricted
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic universe
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-updates universe
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic multiverse
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-updates multiverse
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-backports main restricted universe multiverse
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-security main restricted
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-security universe
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-security multiverse

# 下面是原来用的，废弃前暂留一阵
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-backports main multiverse restricted universe
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-proposed main multiverse restricted universe
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-security main multiverse restricted universe
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-updates main multiverse restricted universe
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic main multiverse restricted universe
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-backports main multiverse restricted universe
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-proposed main multiverse restricted universe
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-security main multiverse restricted universe
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ bionic-updates main multiverse restricted universe

apt update
# 可能报错： Failed to fetch https://repo.download.nvidia.cn/jetson/t210/dists/r32.4/main/binary-arm64/Packages.gz  File has unexpected size ...
# 解决办法： clean一下
apt-get clean
apt-get update

apt-get upgrade
```

**注意：**如果以后安装软件时，报错类似如下：
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
echo "trusted-host = pypi.mirrors.ustc.edu.cn" >> ~/.pip/pip.conf
echo "index-url = https://pypi.mirrors.ustc.edu.cn/simple/" >> ~/.pip/pip.conf
```

## 1.5 安装常用软件

由于在使用时经常查看CPU和共享的内存占用，系统自带的top命令并不好用。使用 htop 可以看到每个CPU核心的使用率、共享内存的使用率，方便直观
```shell
sudo apt install htop
```

官方推出jtop工具，专门用来查看jetson的CPU、GPU等信息，使用方法也很简单
```shell
# 装好python环境后再装这个
sudo python3 -m pip install jetson-stats
sudo jtop
```

## 1.6 设置AI环境

- 看看Nano系统自带的软件：
  * TensorRT ： /usr/src/tensorrt/samples/
  * CUDA ： /usr/local/cuda-/samples/
  * cuDNN ： /usr/src/cudnn_samples_v7/
  * Multimedia API ： /usr/src/tegra_multimedia_api/
  * VisionWorks ： /usr/share/visionworks/sources/samples/ , /usr/share/visionworks-tracking/sources/samples/ , /usr/share/visionworks-sfm/sources/samples/
  * OpenCV ： /usr/share/OpenCV/samples/

- 安装配置AI环境[参见 ai-mkenv](ai-mkenv)

# 其他可选工作

## 查看系统情况
```shell
# Jetson Nano L4T版本：
head -n 1 /etc/nv_tegra_release

lscpu
lsusb   # 查看USB设备
lspci   # 查看PCI总线
lsmod   # 查看系统已载入的相关模块
lshw    # 查看硬件
```

## 验证系统环境
```shell
cd /usr/src/cudnn_samples_v8/mnistCUDNN
sudo make
./mnistCUDNN 
```
从运行结果中，可以看到CUDA版本，GPU的信息

## 禁止启动时进入桌面
```shell
sudo systemctl set-default multi-user.target   #关闭图形界面
sudo reboot
systemctl set-default graphical.target    #打开图形界面
sudo reboot
```

- 其他Linux的处理方式：
  - 编辑配置文件：sudo vi /etc/default/grub   
    * 注释掉：GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"   
    * 修改为：GRUB_CMDLINE_LINUX_DEFAULT="text"   
  - 执行 “update-grub” 以生效   
  - 重启系统


## 安装 Frp
```shell
tar xf frp_0.33.0_linux_arm64.tar.gz -C /opt
cd /opt/ && mv frp_0.33.0_linux_arm64/ frp && cd frp
```
## 开启远程桌面访问
- 服务器：通过RDP（Remote Desktop Protocol）：apt install xrdp
- 客户机：使用Remmina Remote Desktop Client软件
  * 由于Jetson Nano并不支持两个客户端同时登录，修改/etc/gdm3/custom.conf，注释掉：AutomaticLoginEnable和Automatic Login

---

[首 页](https://patrickj-fd.github.io/index)
