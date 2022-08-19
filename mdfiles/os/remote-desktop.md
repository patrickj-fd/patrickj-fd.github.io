
远程连接到ubuntu桌面，有很多种方式，但归根到底其实就两种VNC和RDP

# VNC方式连接
ubuntu桌面版系统自带了一个vnc服务端，叫vino，设置开关中的共享屏幕其实就是这个vnc服务端。据说比较坑。

# RDP方式连接
Rdp代表远程桌面协议。Rdp是用于远程登录Windows的Microsoft协议。  
Xrdp是Rdp协议的开源实现。Xrdp提供了远程图形界面。

## 安装
### 创建一个用户远程桌面连接的用户
**很重要！！！**：因为这个用户无法进入主机桌面，所以要单独建立一个用户！

### 方式1：直接apt安装
```shell
# 检查Xrdp是否已安装。
sudo systemctl status xrdp

# 安装
sudo apt install xrdp -y
sudo systemctl status xrdp

# 将xrdp添加到ssl-cert组，以便它可以访问/etc/ssl/private/ssl-cert-snakeoil.key
sudo adduser xrdp ssl-cert
groups xrdp # see: xrdp : xrdp ssl-cert
sudo systemctl restart xrdp
```

### 方式2：官网下载安装
1. [C-Nergy官网](http://www.c-nergy.be/products.html) 下载最新版本： https://c-nergy.be/downloads/xRDP/xrdp-installer-1.4.2.zip
2. 进入官网的`How to`，按照他所给出的步骤安装即可
   - 解压缩
   - 修改权限：chmod +x 〜/Downloads/xrdp-installer-1.2.sh
   - 运行脚本：./xrdp-installer-1.2.sh
   - 安装完成 ：reboot


安装后，如果通过远程桌面连上后是黑屏，解决办法：[参考](https://blog.csdn.net/Fatmear/article/details/122037566)
```shell
# 下面这句加上，会导致该用户无法登录桌面。所以，应该单独建立一个用户用于远程桌面连接！！！！！！
echo gnome-session > ~/.xsession

sudo apt install  lightdm
# 安装过程的弹出界面上选择： lightdm
```

修改`sudo vim  /etc/xrdp/startwm.sh`：  
在`test -x /etc/X11/Xsession && exec /etc/X11/Xsession`一行前面，加上：  
```
gnome-session
. /etc/X11/Xsession
```
也有说：把最下面的test和exec两行注释掉，添加一行`gnome-session`
我使用的是上面的办法

```shell
sudo systemctl restart xrdp
sudo reboot
```

其他可参考的安装步骤：
```shell
sudo apt-get update
sudo apt-get install xserver-xorg-core
sudo apt-get install xrdp
sudo apt-get install xserver-xorg-core
sudo apt-get -y install xserver-xorg-input-all
sudo apt-get install xorgxrdp
```

**安装碰到任何问题**，比如键盘鼠标无响应了等等，都要先去看官网的Blog：
[Issues with xRDP and Ubuntu 18.04.2 - How to fix it](http://c-nergy.be/blog/?p=13390)
[How to Fix Theme issues in Ubuntu 18.04 remote session](http://c-nergy.be/blog/?p=12155)


## 配置Xrdp
`whereis xrdp.ini`
显示结果如下：  
xrdp: /usr/sbin/xrdp /usr/lib/x86_64-linux-gnu/xrdp /etc/xrdp /usr/share/xrdp /usr/share/man/man8/xrdp.8.gz

在上述所有文件中，/etc/xrdp/xrdp.ini是最重要的一个。
每当对xrdp.ini文件进行更改时，都将必须重新启动xrdp服务器。

默认情况下，xrdp侦听端口3389
```shell
sudo lsof -i :3389
```
显示结果如下：
COMMAND PID USER FD TYPE DEVICE SIZE/OFF NODE NAME
xrdp 23164 xrdp 11u IPv6 236866 0t0 TCP *:3389 (LISTEN)

打开端口3389：
```shell
sudo ufw allow 3389
```

PC并搜索“Remote Desktop Connection”远程桌面连接，然后输入Ubuntu服务器的IP，用户名和密码。
登录画面上点“详细信息”，开启剪贴板和视频捕获设备（获得更高分辨率）

**注意：Ubuntu主机需要重启，并且不要登录，否则windows端无法连接上来**

