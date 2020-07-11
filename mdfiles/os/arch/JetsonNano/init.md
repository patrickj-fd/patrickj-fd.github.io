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
su -
cd /etc/apt && cp sources.list sources.list.orgn && echo "" > sources.list && vi sources.list
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

apt update
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

---

[首 页](https://patrickj-fd.github.io/index)
