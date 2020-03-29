[首 页](https://patrickj-fd.github.io/index)

---

# 从服务更新本地
## 强制使用服务器覆盖本地
```
git fetch --all 
git reset --hard origin/master 
git pull
```
## 保留本地
```
git stash        # 将本地修改保存起来。 这样本地就干净了（git status后看不见修改的文件）
git pull
git stash pop    # 恢复最新的进度到工作区
```

# 分支
## 查看分支
```
git branch       # 查看分支
git branch -v    # 查看各个分支最后一个提交对象的信息
```
## 创建分支
```
git branch testing
```
注意：git branch 命令仅仅创建一个新分支，并不会自动切换到新分支中去。
也就是说，HEAD 这个特殊指针，仍然指向在 master 分支上
## 切换分支
```
git checkout testing    # 这样 HEAD 就指向 testing 分支了。

# 同样道理，切换回 master 分支的方式：
git checkout master
```
## 提交新分支
```
git push origin 本地分支名:远程分支名

# 远程分支名就是一个名字，不需要带地址。
# 例如，本地新拉出来一个分支，提交到远程仓库：
git branch v0.0.5                       # 本地创建一个新分支
git checkout v0.0.5                     # 切换到该分支
git push origin v0.0.5:v0.0.5           # 把这个新建的分支提交到远程仓库
git checkout master
```
## 删除分支
```
git branch -d testing
```

# 删除提交记录
将最近两次提交的记录合并为一次完美记录为例：
```
git rebase -i HEAD~4
# 1. 该命令执行后，会弹出一个编辑窗口，4次提交的commit倒序排列，最上面的是最早的提交，最下面的是最近一次提交。
# 2. 修改第2-4行的第一个单词pick为squash（看一下屏幕上对各个指令的含义）
# 3. 保存退出。
# 如果有冲突，需要修改，修改的时候要注意，保留最新的历史，不然我们的修改就丢弃了

# 修改以后执行如下命令：（没修改不用执行）
git add .
git rebase --continue    # 如果想放弃这次处理，执行以下命令： git rebase --abort
# 如果没有冲突，或者冲突已经解决，则会出现新的编辑窗口
# 把后面的几次提交的说明文字注释掉（前面加上 # ），保存退出
git push -f    # 提交到远程仓库
```

# 账户密码
- git push 时需要输入用户名密码的问题
```
vi ~/.gitconfig
# 添加如下代码
[credential]
helper = store --file .git-credentials
```
# add 的3种方式
git add . -A -all -u 的区别
  * git add .  ：他会监控工作区的状态树，使用它会把工作时的所有变化提交到暂存区，包括文件内容修改(modified)以及新文件(new)，但不包括被删除的文件。
  * git add -u ：他仅监控已经被add的文件（即tracked file），他会将被修改的文件提交到暂存区。add -u 不会提交新文件（untracked file）。（git add --update的缩写）
  * git add -A ：提交所有变化。是上面两个功能的合集（git add --all的缩写）

# 优美简洁的显示log
```
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
```

# Pull Request操作
1. fork : 把源仓库 fork 到自己在github上的工作空间中
2. clone: 从自己的github上的这个新库中取到本地 - git clone
3. 本地开始各种开发和修改，最终push到自己的github上
4. pull request给原始仓库，等待管理员做合并处理

# 创建新项目并提交
```
git init
git add README.md
git commit -m "first commit"
git remote add origin 自己git库的地址
git push -u origin master
```

---

[首 页](https://patrickj-fd.github.io/index)
