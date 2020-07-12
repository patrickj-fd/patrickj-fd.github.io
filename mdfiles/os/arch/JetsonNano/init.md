[首 页](https://patrickj-fd.github.io/index)

---

# 1. 初始设置
## 1.0 
```shell
sudo chown -R hyren:hyren /opt
sudo mkdir -p /data1/python/venv
sudo chown -R hyren:hyren /data1

echo "export PATH=/usr/local/cuda/bin:\${PATH}" >> ${HOME}/.bashrc
echo "export LD_LIBRARY_PATH=/usr/local/cuda/lib64:\${LD_LIBRARY_PATH}" >> ${HOME}/.bashrc
```

#### 增加swap
网上版本：
1. 创建8G大小的swapfile
fallocate -l 8G swapfile
2. 更改swapfile的权限
chmod 600 swapfile
3. 创建swap区
mkswap swapfile
4. 激活swap区
sudo swapon swapfile
5. 确认swap区在用
swapon -s

和下面的比较一下：
[初始化工作参考](https://jkjung-avt.github.io/setting-up-nano/)


sudo nvpmodel -m 0
sudo jetson_clocks

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
su -
cd /etc/apt && cp sources.list sources.list.orgn && echo "" > sources.list && vi sources.list
# 加入以下内容
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

## 1.3 禁止启动时进入桌面
- 编辑配置文件：sudo vi /etc/default/grub   
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

# 其他
## 安装 Frp
```shell
tar xf frp_0.33.0_linux_arm64.tar.gz -C /opt
cd /opt/ && mv frp_0.33.0_linux_arm64/ frp && cd frp

## 开启远程桌面访问
- 服务器：通过RDP（Remote Desktop Protocol）：apt install xrdp
- 客户机：使用Remmina Remote Desktop Client软件
  * 由于Jetson Nano并不支持两个客户端同时登录，修改/etc/gdm3/custom.conf，注释掉：AutomaticLoginEnable和Automatic Login


---

[首 页](https://patrickj-fd.github.io/index)
