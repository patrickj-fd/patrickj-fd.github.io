[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

> https://github.com/jlevy/the-art-of-command-line/blob/master/README-zh.md

# 一、系统命令

## 1.1 初始化相关

### 添加新用户
#### Ubuntu
```shell
USER_NAME=用户名
PASSWORD=密码
HOME_DIR=用户主目录全路径

sudo mkdir $HOME_DIR
sudo useradd -d $HOME_DIR -s /bin/bash $USER_NAME
# sudo userdel -r hyren  # 包括主目录一起删除
sudo echo "$USER_NAME:$PASSWORD" | sudo chpasswd

cp /home/fd/.bashrc $HOME_DIR
cp /home/fd/.profile $HOME_DIR && ls -la $HOME_DIR

chown -R $USER_NAME:sudo $HOME_DIR
chmod -R g+w $HOME_DIR && ls -la $HOME_DIR
```

- 给用户赋予免密sudo的权限
```shell
su -
echo "hyren ALL=(ALL:ALL)  NOPASSWD:ALL" >> /etc/sudoers
```

### 开机启动
```shell
# 设置服务名
SERVICE_NAME=服务名
cat > /etc/systemd/system/${SERVICE_NAME}.service << EOF
[Unit]
Description=服务描述
After=network.target

[Service]
Type=simple
ExecStart=执行程序
ExecReload=执行程序
Restart=on-failure
RestartSec=5s
User=nobody

[Install]
WantedBy=multi-user.target
EOF

systemctl start ${SERVICE_NAME} && systemctl status ${SERVICE_NAME}  # check : Active: active (running)

systemctl enable ${SERVICE_NAME}
```


## 1.2 常用命令

### grep 和 egrep
参数：  
* -i : 不区分大小写
* -w : 全字符精确匹配

两者区别：  
使用egrep，能够用更加丰富的正则表达式。例如：
```shell
egrep -w '[a-z]{5,6}' test.txt
```
* [a-z] 配合着前面的'-w'，把所有小写英文字符组成的字符串找到
* {5,6} 配合着前面的'-w'，代表只取>=5位，<=6位的字符串

而grep不支持{5,6}这种正则语法

### find 查找文件
- 按文件时间查找
  * -m : 指定时间曾被改动过的文件，意思是文件內容被更改过
  * -c : 指定时间曾被更改过的文件，意思是文件权限被更改过
  * -a : 指定时间曾被存取过的文件，意思是文件被读取过
  * time/min : 查找的单位，time是天/min是分钟

```shell
find . -mtime +3 -type f -print # 最近3天内被修改过的文件
find . -mmin  +3 -type f -print # 最近3分钟内被修改过的文件
```

- 查找且移动到bak目录
```shell
find ./ -mtime +3 -type f -name "mkimg*" -exec mv {} bak \;
```

- 查找指定大文件
```shell
find ./ -type f -size +200M
# 去掉查找结果中诸如无权限访问的提示，并且同时显示文件大小，并且按照大小排序
find ./ -type f -size +200M 2>/dev/null|xargs du -shm|sort -nr
```

### xargs 的用法
```shell
find . -mindepth 2 -name “*.txt” | xargs -I file mv file ./
```
- '-I file' ：指定输入的别名为file。可替换为：[ xargs mv -t ./ ]。'mv -t' 颠倒了原路径和目标路径，免除了-I参数，但若文件名含有空格，则不能正常执行
- '-mindepth 2' ：排除当前层级

### vi 的用法
- 多行按列编辑
  * 光标定位到要操作首行或尾行。
  * CTRL+v 进入visual block模式，上下键选取多行
  * SHIFT+i(I) 输入要插入的内容。
  * ESC 按两次

- 删除多列
  * CTRL+v 进入visual block模式，上下键选取多行多列
  * 按 x 即可删除这些选中的列

- 删除多行
  * :1,10d  --  1到10行
  * :.,$d  --  从当前行到文件末尾全删除。gg到文件头执行则删除了整个文件内容
  * ndd  --  光标所在行以下的n行
  * d$ -- 删除以当前字符开始的一行字符


## 1.3 查看系统信息
### 目录占用
```shell
du -sh                 # 当前目录总大小
du -sh *               # 当前目录的每个文件和目录的大小
du -h --max-depth=1    # 等价'du -sh *'，指定不同数字，可看不同级别目录的大小
```

### 系统硬件信息
```shell
#!/bin/bash
echo
echo 物理CPU个数 :  $(cat /proc/cpuinfo |grep "physical id" |sort |uniq |wc -l)
echo 逻辑CPU个数 :  $(cat /proc/cpuinfo |grep "processor" |wc -l)
echo 　　CPU核数 :  $(cat /proc/cpuinfo |grep "cores" |uniq)
echo 　　CPU主频 :  $(cat /proc/cpuinfo |grep MHz |uniq)
echo 　　CPU位数 :  $(getconf LONG_BIT)

echo 物理Mem大小 :  $(grep MemTotal /proc/meminfo)
echo 可用Mem大小 :  $(free -g |grep "Mem" || free -g |grep "内存" |awk '{print $2}')GB
echo
# 其他方式看CPU个数
# cat /proc/cpuinfo | grep physical | uniq -c
# cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c
```

### lsof
他是一个列出当前系统打开文件的工具，也就可以用来查看端口占用情况。
```
lsof -i:8080：查看8080端口占用
lsof abc.txt：显示开启文件abc.txt的进程
lsof -c abc：显示abc进程现在打开的文件
lsof -c -p 1234：列出进程号为1234的进程所打开的文件
lsof -g gid：显示归属gid的进程情况
lsof +d /usr/local/：显示目录下被进程开启的文件
lsof +D /usr/local/：同上，但是会搜索目录下的目录，时间较长
lsof -d 4：显示使用fd为4的进程
lsof -i -U：显示所有打开的端口和UNIX domain文件
```

# 二、包管理器使用（apt/yum）
## apt 安装软件
允许apt使用HTTPS安装软件
```
sudo apt-get install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg-agent \
     software-properties-common
```

## 彻底卸载软件
#### Ubuntu
```
apt --purge remove <package>            # 删除软件及其配置文件
dpkg -l |grep ^rc|awk '{print $2}' |sudo xargs dpkg -P		# 清理dpkg的列表中有“rc”状态的软件包

# 删除为了满足依赖而安装的，但现在不再需要的软件包（包括已安装包），保留配置文件
# 慎用！！！它会在你不知情的情况下，一股脑删除很多“它认为”你不再使用的软件! 
apt-get autoremove
```
#### CentOS
```shell
rpm -qa | grep <package>    # 找到需要卸载软件的确切名字
yum remove <package>        # 卸载（同时卸载其依赖的软件）
rpm -e <package>            # 仅卸载这个软件，不管依赖
```

## 查看已安装软件
```
dpkg -l | grep softname
```
list状态:  
- 期望状态=未知(u)/安装(i)/删除(r)/清除(p)/保持(h)
- 当前状态=未(n)/已安装(i)/仅存配置(c)/仅解压缩(U)/配置失败(F)/不完全安装(H)

# 三、系统使用
## 磁盘测速
```shell
su -
RW_DIR=/mnt/usb3_30
# 如果测U盘，先挂载
fdisk -l
mkdir $RW_DIR
mount /dev/sdb1 $RW_DIR
 
## 测试写入300MB速度
sync; time dd if=/dev/zero of=$RW_DIR/largefile bs=300k count=1024 conv=fdatasync; time sync
 
## 测试读取300MB速度
sync; echo 3 > /proc/sys/vm/drop_caches && time dd if=$RW_DIR/largefile of=/dev/null bs=500k iflag=direct
```

## 设置目录-文件的颜色
比如，终端下看U盘的目录，所有目录都被增加了底色，很难看。

在用户主目录创建文件：vi ~/.dir_colors
```
TERM xterm-256color
TERM xterm-88color
TERM xterm-color
TERM xterm-debian

# EIGHTBIT, followed by '1' for on, '0' for off. (8-bit output)
EIGHTBIT 1

# Below are the color init strings for the basic file types. A color init
# string consists of one or more of the following numeric codes:
# Attribute codes:
# 00=none 01=bold 04=underscore 05=blink 07=reverse 08=concealed
# Text color codes:
# 30=black 31=red 32=green 33=yellow 34=blue 35=magenta 36=cyan 37=white
# Background color codes:
# 40=black 41=red 42=green 43=yellow 44=blue 45=magenta 46=cyan 47=white
#NORMAL 00      # no color code at all
#FILE 00        # normal file, use no color at all
RESET 0         # reset to "normal" color
DIR 01;34       # directory blod:blue
LINK 01;36      # symbolic link (If you set this to 'target' instead of a
                # numerical value, the color is as for the file pointed to.)
MULTIHARDLINK 00        # regular file with more than one link
FIFO 40;33      # pipe
SOCK 01;35      # socket
DOOR 01;35      # door
BLK 40;33;01    # block device driver
CHR 40;33;01    # character device driver
ORPHAN 40;31;01  # symlink to nonexistent file, or non-stat'able file
MISSING 01;05;37;41 # ... and the files they point to
SETUID 37;41    # file that is setuid (u+s)
SETGID 30;43    # file that is setgid (g+s)
CAPABILITY 30;41        # file with capability
STICKY_OTHER_WRITABLE 30;42 # dir that is sticky and other-writable (+t,o+w)
OTHER_WRITABLE 34;42 # dir that is other-writable (o+w) and not sticky
STICKY 37;44    # dir with the sticky bit set (+t) and not other-writable

# This is for files with execute permission:
EXEC 01;32

# List any file extensions like '.sh' to colorize below. 
.sh  01;32
```
在 ~/.bashrc 中，增加：
```
eval `dircolors $HOME/.dir_colors`
```

## 屏幕截图
屏幕截图：print； 窗口截图：Alt + print； 区域截图：Shift + print。图片被自动保存到了home-文档目录下。如果要存到剪切板中，以上命令都加上 Ctrl 即可。  
“系统 -> 设备 -> 键盘” 可以修改截图快捷键。


# 九、安装Nvidia显卡
> https://www.cnblogs.com/2sheep2simple/p/10787371.html  
> https://www.cnblogs.com/cenariusxz/p/10841099.html 实测有效！  

---

[首 页](https://patrickj-fd.github.io/index)
