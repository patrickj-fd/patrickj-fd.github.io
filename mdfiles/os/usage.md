[首 页](https://patrickj-fd.github.io/index)

---

# 系统命令
## 常用命令
1. find 3天前的文件，并且移动到bak目录
```shell
find ./ -mtime +3 -type f -name "mkimg*" -exec mv {} bak \;
```
2. xargs 的用法
```shell
find . -mindepth 2 -name “*.txt” | xargs -I file mv file ./
```
- '-I file' ：指定输入的别名为file。可替换为：[ xargs mv -t ./ ]。'mv -t' 颠倒了原路径和目标路径，免除了-I参数，但若文件名含有空格，则不能正常执行
- '-mindepth 2' ：排除当前层级

## lsof
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

# 查看已安装软件
```
dpkg -l | grep softname
```
list状态:  
- 期望状态=未知(u)/安装(i)/删除(r)/清除(p)/保持(h)
- 当前状态=未(n)/已安装(i)/仅存配置(c)/仅解压缩(U)/配置失败(F)/不完全安装(H)


# 彻底卸载软件
```
apt --purge remove <package>            # 删除软件及其配置文件
dpkg -l |grep ^rc|awk '{print $2}' |sudo xargs dpkg -P		# 清理dpkg的列表中有“rc”状态的软件包

# 删除为了满足依赖而安装的，但现在不再需要的软件包（包括已安装包），保留配置文件
# 慎用！！！它会在你不知情的情况下，一股脑删除很多“它认为”你不再使用的软件! 
apt-get autoremove
```
# apt 安装软件
允许apt使用HTTPS安装软件
```
sudo apt-get install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg-agent \
     software-properties-common
```

# 安装Nvidia显卡
> https://www.cnblogs.com/2sheep2simple/p/10787371.html  
> https://www.cnblogs.com/cenariusxz/p/10841099.html 实测有效！  

---

[首 页](https://patrickj-fd.github.io/index)
