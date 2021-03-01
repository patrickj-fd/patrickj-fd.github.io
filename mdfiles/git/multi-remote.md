[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# gitee和github共存

## 1) 清除 git 的全局设置

因为不同的仓库，对应了各自使用的gitee或github，所以全局配置不能再用。
```
git config --global --list  # 查看全局配置
# 把所有配置都都清除掉。除非有什么配置真的需要全局通用
git config --global --unset user.name "用户名"
git config --global --unset user.email "邮箱"
git config --global --unset credential.helper
```

## 2) 生成新的 SSH keys

```
ssh-keygen -t rsa -f ~/.ssh/id_rsa.github -C "邮箱"
ssh-keygen -t rsa -f ~/.ssh/id_rsa.gitee -C "邮箱"
```

## 3) 多账号必须配置 [~/.ssh/config] 文件
- Host 可以是任意字符，下面的自定义配置会覆盖默认的/etc/ssh/ssh_config

```
mv ~/.ssh/config ~/.ssh/config.bak
cat >~/.ssh/config <<EOF
Host github.com
HostName github.com
IdentityFile ~/.ssh/id_rsa.github

Host gitee.com
HostName gitee.com
IdentityFile ~/.ssh/id_rsa.gitee
EOF
```

## 4) 把公钥文件分别添加给gitee或github

第2步生成的[id_rsa.github]和[id_rsa.gitee]，添加上去：  
  - github : https://github.com/settings/keys
  - gitee : https://gitee.com/profile/sshkeys

## 5) 测试是否连接成功

```
ssh -T git@github.com
ssh -T git@gitee.com
```

## 6) clone 项目

```
# 注意：这里不要用https的地址了！因为上面已经配置了SSH
git clone git@gitlab.com:用户名/项目.git
```

## 7) 本地仓库设置

给每个clone下来的项目，都分别配置上”用户名和邮箱“，避免每次提交修改时被git要求输入邮箱和密码。
```
cd 本地仓库目录
git config user.name "用户名"
git config user.email "邮箱"
```

或者，直接编辑本地仓库的配置文件  
**重点：确认url使用的是：git@github.com，而不是https！**   
vi .git/config
```
[remote "origin"]
        url = git@github.com:用户名/项目.git  # 这个地址可以在github clone项目时，点选SSH看到
        fetch = +refs/heads/*:refs/remotes/origin/*
[user]
        email = 邮箱
        name = 用户名
```

---

[首 页](https://patrickj-fd.github.io/index)
