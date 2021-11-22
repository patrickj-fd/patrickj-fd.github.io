[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

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

# 配置文件 .git/config
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

[diff]
    tool = meld
[difftool]
    prompt = false					阻止git提示您是否要启动meld
[difftool "meld"]
    cmd = meld "$LOCAL" "$REMOTE"	$LOCAL和$REMOTE用来控制左右两个窗口显示本地还是远程顺序
[merge]
    tool = meld
	conflictstyle = diff3
[mergetool "meld"]
    cmd = meld "$LOCAL" "$BASE" "$REMOTE" --output="$MERGED" --auto-merge
	# 或者。二选一
	cmd = meld "$LOCAL" "$MERGED" "$REMOTE" --output="$MERGED"
```

最后这5段设置，是为了把meld集成进来，方便进行文件比较。[注：这些设置不会改变将继续正常工作的git diff的行为]
集成后，可以使用如下命令比较差异：
```shell
# 本地文件和远程的差异
git difftool file_name
# 其他诸如：
git difftool <COMMIT_HASH> file_name
git difftool <BRANCH_NAME> file_name
git difftool <COMMIT_HASH_1> <COMMIT_HASH_2> file_name

# 合并时使用原始命令
git merge branch_name
# 但是，如果出现了冲突，为了直观看到，可使用meld
git mergetool
# $LOCAL是当前分支(如master)中的文件。
# $REMOTE是要合并的分支中的文件(例如分支名称)。
# $MERGED是包含合并冲突信息的部分合并文件。
# $BASE是$LOCAL和$REMOTE的共享提交祖先，这就是说，包含$REMOTE的分支最初创建时的文
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

