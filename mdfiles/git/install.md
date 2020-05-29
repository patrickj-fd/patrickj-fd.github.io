[首 页](https://patrickj-fd.github.io/index)

---

# 安装
#### Ubuntu
```
sudo apt-get install git
```

#### CentOS 7
CentOS 7 默认是1.8.3，直接yum安装没办法升级。使用源码编译方式安装。
```shell
# 找到系统上git，卸载掉
yum remove git
rpm -qa |grep -i git
# 还有的话，用找到的确切名字再次卸载
yum remove git-1.8.3.1-22.el7_8.x86_64

# 安装依赖软件
yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel
yum install gcc perl-ExtUtils-MakeMaker

# 下载并安装
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.26.2.tar.xz
tar xf git-2.26.2.tar.xz
cd git-2.26.2
# 编译
make prefix=/usr/local/git all
make prefix=/usr/local/git install
# 也可以：
./configure --prefix=/usr/local/git
make -j
make install

# 把git/bin加到PATH里面即可
echo "export PATH=\$PATH:/usr/local/git/bin" >> /etc/bashrc
source /etc/bashrc
git --version
```

# 初始设置
如果只有一个远程仓库，可以设置全局配置
```shell
git config --global user.name "Your Name"
git config --global user.email "email@example.com"
```

如果有多个远程仓库，则需要到每个仓库下单独配置
```shell
git config user.name "Your Name"
git config user.email "email@example.com"
```

# 配置文件
```ini
[core]
	repositoryformatversion = 0
	filemode = false
	bare = false
	logallrefupdates = true
	symlinks = false
	ignorecase = true
[user]
	name = 远程仓库的用户名
	email = 远程仓库的邮箱
[remote "origin"]
	url = 例如：git@gitee.com:hyren/pan.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
	remote = origin
	merge = refs/heads/master
```

# 忽略文件的通用规则
```
# git file
.git*
!.gitignore

# package file
*.zip
*.gz
*.bz2
*.rar
*.tar
*.xz

# temp file
*.log
*.out
*.cache
*.diff
*.patch
*.tmp

# ---> VisualStudioCode
.settings
.vscode*

# ---> Linux
*~
*.o
*.so

# system ignore
.DS_Store
.DS_Store?
ehthumbs.db
Thumbs.db
*.dll
*.exe

# KDE directory preferences
.directory

# Linux trash folder which might appear on any partition or disk
.Trash-*
```

---

[首 页](https://patrickj-fd.github.io/index)

