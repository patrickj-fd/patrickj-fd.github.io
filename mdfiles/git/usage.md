[首 页](https://patrickj-fd.github.io/index)

---

# 使用git的第一原则
**要使用分支！！！！！**  
开始修改程序前，正确的工作方式：
1. 创建一个新分支，并切换过去： git checkout -b tempdev
2. 各种工作完成后，提交本次工作： git add && git commit
3. 合并到主分支(master)上：
  * 切换到主分支上：git checkout master
  * 取远程最新版本：git pull/fetch等 ： 。直接覆盖，不需要解决冲突。因为必须用最新的
  * 合并临时分支　：git merge --no-ff tempdev -m "说明"
  * 删除临时分支　：git branch -d tempdev
4. 把本地的master提交到远程仓库： git add && git commit && git push

[参考 Learning Git Branching](https://learngitbranching.js.org/?locale=zh_CN)


# 1. 创建仓库

## 把本地项目建立git管理并提交远程
假定本地有一个目录，已经有了大量文件，现在希望使用git进行版本管理：
```
cd "你的这个目录"
git init
git add .
git commit -m "first commit"
git remote add origin 远程git仓库地址，例如：http://139.9.126.19:38111/xxx/yyy.git
git push -u origin master
```

# 2. 拉取和提交相关

## 2.1 强制覆盖
### 1) 强制覆盖本地 - 与远程仓库保持一致
```
git fetch --all 
git reset --hard origin/master 
git pull
```
### 2) 保留本地的前提下，取远程仓库
```
git stash        # 将本地修改保存起来。 这样本地就干净了（git status后看不见修改的文件）
git pull
git stash pop    # 恢复最新的进度到工作区
```
### 3) 强制覆盖远程仓库
```
git push -u -f origin master
```

## 2.2 仅拉取指定目录
```shell
# 本地目录初始化仓库
git init
# 编辑 .git/config 文件，配置好远程仓库的url等信息
git config core.sparsecheckout true

# 设置需要拉取的目录，例如：
echo "develop"  >>.git/info/sparse-checkout
echo "web/assets/*"  >>.git/info/sparse-checkout  # '*' 表示所有

# 之后即可拉取和提交了
git pull
```
在sparse-checkout文件中，也可以设置不拉取什么文件：
```
*
!unwanted
```
参考：
> http://schacon.github.io/git/git-read-tree.html#_sparse_checkout


## 2.3 仅拉取最新提交的版本
当项目过大时，git clone会很慢，解决方法很简单，在git clone时加上'--depth=1'即可解决。
> depth用于指定克隆深度，为1即表示只克隆最近一次commit.

这种方法克隆的项目只包含最近的一次commit的一个分支，体积很小。  
但是，这样会把默认分支clone下来，其他远程分支并不在本地。解决办法：
```shell
git clone --depth 1 url
git remote set-branches origin 'remote_branch_name'
git fetch --depth 1 origin remote_branch_name
git checkout remote_branch_name
```

## 2.4 删除服务器文件,但保留本地
```
git rm --cached -r 本地要保留的目录
git rm --cached file 本地要保留的文件
git commit -m "del xxx"
git push -u origin master
```
如果要保留很多本地文件，可以利用gitigore，将不需要的文件过滤掉
```
git rm -r --cached .
git add .
git commit
git push -u origin master
```

# 3. 分支

**应该在分支上工作！**  
从第一次向远程仓库push后，每次修改都应该先创建一个分支，在分支上工作：
- 发现做错了，就直接干掉分支重来
- 都做好了，合并到master，push master到远程，并且干掉分支

## 查看分支
```
git branch       # 查看分支
git branch -v    # 查看各个分支最后一个提交对象的信息
git branch --no-merged   # 查看所有包含未合并工作的分支
git branch --no-merged master  # 查看未合并到 master 分支的有哪些
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

# 4. Pull Request操作
1. fork : 把源仓库 fork 到自己在github上的工作空间中
2. clone: 从自己的github上的这个新库中取到本地 - git clone
3. 本地开始各种开发和修改，最终push到自己的github上
4. pull request给原始仓库，等待管理员做合并处理

# 5. gitignore
基本语法：
- 斜杠“/”开头表示目录
- 星号“*”通配多个字符
- 问号“?”通配单个字符
- 方括号“[]”包含单个字符的匹配列表
- 叹号“!”表示不忽略(跟踪)匹配到的文件或目录


**ignore 配置文件是按行从上到下进行规则匹配的，意味着如果前面的规则匹配的范围更大，则后面的规则将不会生效**

```
1. xxx/*
   忽略目录 xxx 下的全部内容
   注意：不管是根目录下的 /xxx/ 目录，还是某个子目录 /child/xxx/ 目录，都会被忽略；
2. /xxx/*
   忽略根目录下的 /xxx/ 目录的全部内容

例子：
/*
!.gitignore
!/fw/bin/
说明：忽略全部内容，但是不忽略 .gitignore 文件、根目录下的 /fw/bin/ 目录；

忽略doc文件夹下所有以及包含的 .txt文件,不包括类似doc/test/tell.txt 这样的文件
doc/*.txt

忽略doc文件夹中所有 .txt文件
doc/**/*.txt
```

# 9. 其他
## 查看仓库状态
查看有哪些文件被修改、添加、删除了，是否在暂存区，等等信息。
```shell
git status     # 显示详细的信息
git status -s  # 显示简短信息
```
显示简短信息，可以直观了解变动的文件，并且配合git add来提交指定文件。例如：只提交部分文件的处理方式：
```shell
git status -s        # 1. 查看仓库状态
git add <filepath>   # 2. 添加需要提交的文件名（用上面显示出来文件全路径）
git stash -u -k      # 3. 忽略其他文件，把现修改的隐藏起来，这样提交的时候就不会提交未被add的文件
                     #    -k 保持文件的完整。-u 包括无路径的文件(那些新的和未添加到git的)。
git commit -m "xxx"  # 4.
git pull             # 5. 拉取合并
git push             # 6. 推送到远程
git stash pop        # 7. 恢复之前忽略的文件（非常重要的一步）
```

## 删除提交记录
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

## 账户密码
解决 git push 时需要输入用户名密码的问题  
- 方式一
```
vi ~/.gitconfig
# 添加如下代码
[credential]
helper = store --file .git-credentials
```
- 方式二
**推荐** ： 把本地主机的公钥添加到github上，并且，使用SSH方式访问（不要用https方式）

## 优美简洁的显示log
```
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
```

---

[首 页](https://patrickj-fd.github.io/index)
