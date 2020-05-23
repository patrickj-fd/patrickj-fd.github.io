[首 页](https://patrickj-fd.github.io/index)

---

# 安装
```
sudo apt-get install git
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

---

[首 页](https://patrickj-fd.github.io/index)

