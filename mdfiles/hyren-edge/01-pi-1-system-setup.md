[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 1. Pi
## 1.1 初始设置

### 1.1.1 WiFi
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

### 1.1.2 开启 SSH 服务
在SD卡根新建文件：ssh。（也可以在树莓派开机后创建：sudo touch /boot/ssh）

### 1.1.3 网线直连
打开SD卡根文件cmdline.txt，在第一行最前面添加用于网线直连的ip：
```txt
# console开始的是文件原始内容
ip=192.168.137.100 console=seria10,115200 console=tty1 ......
```
用网线把电脑和pi直连后即可通过该ip连接pi了。

**注意：用完后，务必要把新加进去的'ip=192.168.137.100'删除掉！否则，每次开机都会等待很久的网络（持续出现：waiting up to 100 more seconds for network）**

**注意：**网线直连（包括内网网线连接）时，刚开机后要稍等一会才能连接上。

### 1.1.4 HDMI连接显示器
修改 config.txt 文件，把hdmi_force_hotplug=1的注释去掉（目的：启用HDMI热插拔功能）

## 1.2 系统基础环境设置

pi/raspberry 登陆机器

### 设置键盘
因为都是用ssh连接操作设备，所以本步骤可以不做。除非需要使用键盘直连操作。
```shell
sudo raspi-config
```
1. Localisation Options
2. Change Keyboard Layout
3. Generic 101-key PC / Or : 102-key PC (intl.)  / Or : 105-key PC (intl.)
4. English(US)
5. The default for the keyboard layout
6. No compose key
7. Finish (这时已经回到了主画面)

重启生效
```shell
sudo reboot
```

### 设置设备编号
```shell
HRE_CODE=设备编号，例如：400
```

### 设置主机名
```shell
sudo hostnamectl set-hostname hre${HRE_CODE}-pi
cp /etc/hosts ./hosts.bak # backup
# 把里面的raspberrypi修改为：hre400-pi (127.0.1.1 开头的一行)。执行后忽略报错：sudo: unable to resolve host hre415-pi: Name or service not known
[ -n "$HRE_CODE" ] && sudo sed -i "s/127\.0\.1\.1\t\traspberrypi/127\.0\.1\.1\t\thre${HRE_CODE}-pi/g" /etc/hosts
cat /etc/hosts
sudo reboot  # raspberry
hostname  # show : hre400-pi
# 再次确认 hosts 中 127.0.1.1 开头的一行是否已经修改为 hre400-pi
cat /etc/hosts
```

### 修正vi不能使用上下左右键
```shell
# sudo vi /etc/vim/vimrc.tiny
# 把compatible加上no。再增加一行："set backspace=2"
# set nocompatible
# set backspace=2

sudo sed -i "/set compatible/c set nocompatible" /etc/vim/vimrc.tiny
sudo sed -i "/set nocompatible/a set backspace=2" /etc/vim/vimrc.tiny
cat /etc/vim/vimrc.tiny  # check
```
### 设置初始值
```shell
# 设置密码不要用特殊符号，USB键盘直接操作时，这些符合是全乱套的，导致无法输入正确的密码
sudo echo "root:Hre1088" | sudo chpasswd
sudo echo "pi:Hre2188" | sudo chpasswd
sudo mkdir /data
sudo chown -R pi /data
sudo chown -R pi /opt
ls -l / | grep pi  # show tow line, and 'data/opt' is pi

# vi .bashrc
# 46行： 把 force_color_prompt=yes 注释掉。以便从颜色上，让 pi 用户区别于其他用户。注意：如果用vscode连接上，这个颜色依然会有。
# 91行启用 ll 命令别名
#sed -i "/force_color_prompt=yes/c #force_color_prompt=yes" .bashrc
sed -i '46c #force_color_prompt=yes' .bashrc
sed -i "91c alias ll='ls -lhF'" .bashrc
sed -n '46p;91p' .bashrc  # check modify result
source .bashrc
# 应该不再有颜色了，且 ll 可用
```

### 建立工作用户
```shell
sudo mkdir /hyren
sudo useradd -d /hyren -s /bin/bash hyren
# sudo userdel -r hyren  # 包括主目录一起删除
sudo echo "hyren:hre118" | sudo chpasswd

sudo cp /home/pi/.bashrc /hyren
sudo cp /home/pi/.profile /hyren && ls -la /hyren

# 修改hyren用户环境 : /hyren/.bashrc
# 46行： 把 force_color_prompt=yes 打开
# 60行： PS1 最后 [\w ... '] 改为：[\W\[\033[00m\]\$ '] 。即 w 改成大写，并且把 $ 挪到最后。
# 62行： PS1 把 w 改成大写。
# 91行： alias ll='ls -lhF'
sudo sed -i '46c force_color_prompt=yes' /hyren/.bashrc
sudo sed -i '60s%\\w \\\$\\\[\\033\[00m\\\] %\\W\\\[\\033\[00m\\\]\\\$ %' /hyren/.bashrc
sudo sed -i '62s%:\\w\\\$ %:\\W\\\$ %' /hyren/.bashrc
sudo sed -i "91c alias ll='ls -lhF'" /hyren/.bashrc

sudo chown -R hyren:sudo /hyren
sudo chmod -R g+w /hyren && ls -la /hyren

# 验证hyren用户的环境
su - hyren
# 登陆后，看命令行颜色是不是上面修改后的。执行：ll看权限 , pwd看主目录位置
ll
pwd

# 配置开发机的免密登录
mkdir ~/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIJUTIXbAiyaFdD3KsBPVsjKeHI2ZwqzcqbJZK+/KJ66eeaEmtGhLUREhGJHmbv2bZ+zAFMeJCu09uKQiNJogEoKTF3Am9Z2+Y99tV/YWbfVb6bbfpnPHVbEYoneG9ZKOknHfCo8u/7D5gXTfW9fy/fGeRygUV+T+31QN8fMidBbs4tzBQFSv2Yog0NPn3RXqET9BO4yoSYUEt0X9c8kUQZuzDnMOZLPm8fl7tHXvSfHUZIiFKn+npGSBTG+9h7ypAoZuPhmAK0AIvczs6xK1qSCji3BvOHvSVocrWNm2JVTCkclbnJ0uEqhQrn3eRpXHqIREic4XiApNGc+UNL8Tf hyren@hre499-nano1" >> ~/.ssh/authorized_keys
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPz53qsyUrTXm39sf5RefqeEIa5pqoLm1y4iqHNAxh2AdYBc8EPRFkhaHrI5UF28dUyj+1FSHiOOGjL4QSX74Tk0hfkP4Yj8TSmNAJWXKTj+jjQBCyAq1Vf9/xeuQrKGLIDDUb3t0DssIZHsJCwZJvRpn03Awg7/3g/2Ah4A5yG18jFgXQVRs8pCaClULLzl8h+5hdSDaNOKGM2igxapSyEOAIULqKMLwsaOzXEIwkQg8+PH/keuHcji2wiC8iIlcPUkjj1ygPPSvJZbzKvI3+1H0Qh0uMELxJjyPagmrHODzxd09Lzix9aViDg3y3oNSIC1alvkCPLF1pQIg0/Mf1 fd@fdubt18" >> ~/.ssh/authorized_keys

exit  # back to pi
```

### 换源
```shell
# 切换到root
su -
cp /etc/apt/sources.list /etc/apt/sources.list.bak
cp /etc/apt/sources.list.d/raspi.list /etc/apt/sources.list.d/raspi.list.bak
# change to china source
echo "deb http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ buster main contrib non-free rpi" > /etc/apt/sources.list
echo "deb-src http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ buster main contrib non-free rpi" >> /etc/apt/sources.list
echo "deb http://mirrors.tuna.tsinghua.edu.cn/raspberrypi/ buster main ui" > /etc/apt/sources.list.d/raspi.list
echo "deb-src http://mirrors.tuna.tsinghua.edu.cn/raspberrypi/ buster main ui" >> /etc/apt/sources.list.d/raspi.list

apt update
apt upgrade -y
```

### 设置免密
```shell
cp /etc/ssh/sshd_config ~/sshd_config.bak

# set: StrictModes no
sed -i "s/#StrictModes yes/StrictModes no/" /etc/ssh/sshd_config
grep -C 2 StrictModes /etc/ssh/sshd_config

# AuthorizedKeysFile      .ssh/authorized_keys .ssh/authorized_keys2
#sed -i "s/#AuthorizedKeysFile /AuthorizedKeysFile /" /etc/ssh/sshd_config
#grep -C 2 AuthorizedKeysFile /etc/ssh/sshd_config

systemctl restart ssh
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

scp fd@172.168.0.216:/data3/HyrenEdge/pi/soft/OpenJDK8U-jdk_arm_linux_hotspot_8u275b01.tar.gz .
tar -xf OpenJDK8U-jdk_arm_linux_hotspot_8u275b01.tar.gz -C /usr/java
# OR:
curl -s ftp://ftp:@172.168.0.100/pi/OpenJDK8U-jdk_arm_linux_hotspot_8u275b01.tar.gz | tar -zxf - -C /usr/java
# curl -O ftp://ftp:@172.168.0.100/pi/OpenJDK8U-jdk_arm_linux_hotspot_8u275b01.tar.gz
# tar -zxf OpenJDK8U-jdk_arm_linux_hotspot_8u275b01.tar.gz  -C /usr/java

ln -s /usr/java/jdk8u275-b01 /usr/java/default && ls -l /usr/java
echo "export JAVA_HOME=/usr/java/default" >> /etc/profile
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile

# 验证java
su - hyren
java -version
exit
```

### 工具软件
```shell
apt install -y htop nmap
```

# 2. 安装AI环境
- [参考](../pi/ai-mkenv) - 不做！

# 3. 安装项目

1. [安装frp Client端-ssh](03-frp)
2. [安装项目运行环境](50-app-pi)

# 4. 清理工作

**分别切换到3个用户(root/pi/hyren)下，执行以下命令**

```shell
history -c
echo > ~/.bash_history
history -r

su - hyren
echo "$(date '+%Y-%m-%d %H:%M:%S')" > .done && cat .done
history -c
echo > ~/.bash_history
history -r
```

# 5. 参考
## 5.1 连接wifi（命令行下）
```shell
# 查看wifi列表
sudo iwlist wlan0 scan | grep SSID

# 配置wifi
# 如果网络没有密码，则添加一行：key_mgmt=NONE
# 如果网络是隐藏的，则添加一行：scan_ssid=1
sudo vi /etc/wpa_supplicant/wpa_supplicant.conf
# 该文件保存后，一般等待几秒就可以连上网络了
ifconfig

# 如果不行试试：
sudo ifdown wlan0
sudo ifup wlan0     # or reboot 
# 如果执行ifdown/ifup出错，执行下面命令即可
sudo wpa_cli -i wlan0 reconfigure
```

## 5.2 连接显示器不亮
- 换一个hdmi口试试
- 如果能ssh上去，那么换一个hmdi后再重启下试试
- 修改启动配置文件：config.txt

```
hdmi_force_hotplug=1  ：启用HDMI热插拔功能。
config_hdmi_boost=4   ：启用加强HDMI信号。

如果还不行，就修改下面配置项：
hdmi_drive=2
hdmi_group=2
hdmi_mode=9
```

---

[首 页](https://patrickj-fd.github.io/index)
