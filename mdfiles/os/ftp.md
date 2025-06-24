[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 安装 vsftp
```shell
sudo apt install vsftp

yum install vsftp

sudo systemctl restart vsftpd && sudo systemctl status vsftpd
sudo systemctl enable vsftpd
```

# 创建 ftp 用户
```shell
# 创建一个不能登录主机的ftp用户
sudo useradd -m -s /usr/sbin/nologin ftpgets
sudo echo "ftpgets:hre118" | sudo chpasswd

# 这个用户是通过分配一个不存在的shell从而做到不能登录主机的，所以要把这个shell添加进shell清单中
grep "nologin" /etc/shells || sudo echo "/usr/sbin/nologin" >> /etc/shells
```
实际上，不需要专门创建ftp用户，任何本机用户都是可用的。
这里创建这个不能登录主机的用户，是为了使用curl进行ftp下载用，而且避免其他人使用这个用户登录ftp主机。


# 配置
`sudo vi /etc/vsftpd.conf`
```ini
listen=YES
listen_port=10021       # 指定端口。不设置的话，在ubuntu上服务总是无法启动

listen_ipv6=YES         # 一般可注释掉。尤其是如果无法连接，可以先注释掉listen_ipv6试试。
anonymous_enable=YES

local_root=/path/...    # 指定ftp主目录。如果不指定，则默认为登录用户的主目录
```

如果ftp无法登录，可关闭pam过度验证试试。
`sudo vi /etc/pam.d/vsftpd`，注释掉下面这行：
```ini
auth       required    /lib/security/pam_shells.so
```


# 用curl下载文件
```shell
curl -O ftp://USERNAME:PASSWORD@IP:PORT/path/file
```