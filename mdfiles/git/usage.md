[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

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

## 拉取和提交原理
```shell
git pull origin <远程分支名>:<本地分支名>    # 将远程指定分支拉取到本地【指定分支】
git pull origin <远程分支名>               # 将远程指定分支拉取到本地【当前分支】
git pull                                 # 将与本地当前分支同名的远程分支拉取到本地当前分支

# 查看远程分支
git branch -r
# 拉取远程分支
git checkout -b <本地分支名> origin/<远程分支名>
```

**在克隆远程项目的时候，本地分支会自动与远程仓库建立追踪关系，可以使用默认的origin来替代远程仓库名**

## 2.1 强制覆盖
### 1) 强制覆盖本地 - 与远程仓库保持一致
```shell
git fetch --all                    # 会将数据拉取到本地仓库 - 但不会自动合并或修改当前的工作
git reset --hard origin/master     # master为远程分支名称,若远程分支为haha,则 origin/haha 即可
git pull

# 强制覆盖本地分支
git fetch --all
git reset --hard origin/远程分支名字
git pull origin 远程分支名字:本地分支名字

# 命令含义：
# 比如，取回origin主机的next分支，与本地的master分支合并，需要写成下面这样
git pull origin next:master
# 如果远程分支是与当前分支合并，则冒号后面的部分可以省略。
# 实质上，这等同于先做git fetch，再做git merge
git fetch origin
git merge origin/next
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
git rm --cached file 本地要保留的文件(支持通配符*)
git rm --cached -r 本地要保留的目录
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

## 2.5 提交指定文件
```shell
git status -s        # 1. 查看仓库状态
git add <filepath>   # 2. 添加需要提交的文件名（用上面显示出来文件全路径）
git stash -u -k      # 3. 忽略其他文件，把现修改的隐藏起来，这样提交的时候就不会提交未被add的文件
                     #    -k 保持文件的完整。-u 包括无路径的文件(那些新的和未添加到git的)。
git commit -m "xxx"  # 4.
git pull             # 5. 拉取合并。如果远程没有过变化，跳过本步骤
git push             # 6. 推送到远程
git stash pop        # 7. 恢复之前忽略的文件（非常重要的一步）
```

## 2.6 拉取冲突解决
执行`git pull`时出现以下错误：
```txt
error: Your local changes to the following files would be overwritten by merge:
.......
Please commit your changes or stash them before you merge.
```
意思是说更新下来的内容和本地修改的内容有冲突，先提交你的改变或者先将本地修改暂时存储起来。处理的方式非常简单，主要是使用git stash命令进行处理：

- 1) 先将本地修改存储起来： `git stash`

查看保存的信息： `git stash list` 。可以看到类似如下内容：
```shell
stash@{0}: WIP on master: 569373b update
stash@{1}: WIP on master: 8f6e855 v1.0.8 Desktop 第一次发布
```
其中stash@{0}就是刚才保存的标记。

- 2) 重新拉取： `git pull`
- 3) 还原暂存的内容： `git stash pop stash@{0}`

系统提示如下类似的信息：
```txt
Auto-merging DeskTop/src/META-INF/MANIFEST.MF
CONFLICT (content): Merge conflict in DeskTop/src/META-INF/MANIFEST.MF
Auto-merging Android/app/build.gradle
CONFLICT (content): Merge conflict in Android/app/build.gradle
The stash entry is kept in case you need it again.
```
意思是说，系统自动合并修改的内容，但是其中有冲突，需要解决其中的冲突。碰到这种情况，git也不知道哪行内容是需要的，所以要自行确定需要的内容。

查看以上两个文件的内容，会看到冲突的位置：
- 【Updated upstream 和 =====】 之间的内容就是pull下来的内容
- 【===== 和 stashed changes】  之间的内容就是本地修改的内容

解决完成之后，就可以正常的提交了。

## 拉取本地不存在的远程分支
```shell
git checkout -t origin/远程分支名

# 如果报错：fatal: ‘origin/XXX‘ is not a commit and a branch ‘XXX‘ cannot be created from it
# 查看本地缓存的所有远程分支
git branch -r

# 应该是看不到远程分支的，需要先fetch过来，然后再执行上面的git checkout命令
git fetch origin
```


# 3. 分支

## 3.1 branch

**应该在分支上工作！**  
从第一次向远程仓库push后，每次修改都应该先创建一个分支，在分支上工作：
- 发现做错了，就直接干掉分支重来
- 都做好了，合并到master，push master到远程，并且干掉分支

### 3.1.1 查看分支
```
git branch       # 查看分支
git branch -v    # 查看各个分支最后一个提交对象的信息
git branch --no-merged   # 查看所有包含未合并工作的分支
git branch --no-merged master  # 查看未合并到 master 分支的有哪些
```
### 3.1.2 创建分支
```
git branch testing
```
注意：git branch 命令仅仅创建一个新分支，并不会自动切换到新分支中去。
也就是说，HEAD 这个特殊指针，仍然指向在 master 分支上
### 3.1.3 切换分支
```
git checkout testing    # 这样 HEAD 就指向 testing 分支了。
# 同样道理，切换回 master 分支的方式：
git checkout master
```
### 3.1.4 提交新分支
```
git push origin 本地分支名:远程分支名

# 远程分支名就是一个名字，不需要带地址。
# 例如，本地新拉出来一个分支，提交到远程仓库：
git branch v0.0.5                       # 本地创建一个新分支
git checkout v0.0.5                     # 切换到该分支
git push origin v0.0.5:v0.0.5           # 把这个新建的分支提交到远程仓库
git checkout master
```
### 3.1.5 删除分支
```
git branch -d testing
```

## 3.1 tag

- tag就像是一个里程碑一个标志一个点，branch是一个新的征程一条线
- tag是静态的，branch要向前走
- 稳定版本备份用tag，新功能多人开发用branch（开发完成后merge到master）

创建 tag 是基于本地分支的 commit，而且与分支的推送是两回事，就是说分支已经推送到远程了，但是 tag 并没有，如果把 tag 推送到远程分支上，需要另外执行 tag 的推送命令。

### 3.2.1 创建tag
```shell
# 基于本地当前分支的最后的一个 commit 创建的 tag
git tag <tagName>           # 创建本地tag
git push origin <tagName>   # 推送到远程仓库

# 如果不想以最后一个，只想以某一个特定的提交为 tag
git log --pretty=oneline    # 查看当前分支的提交历史，里面包含 commit id
git tag -a <tagName> <commitId>
```

### 3.2.2 查看tag
```shell
git tag                 # 列出所有本地tag
git show <tagName>      # 查看本地某个 tag 的详细信息
git ls-remote --tags origin  # 列出所有远程tag
```

### 3.2.3 检出tag
因为 tag 本身指向的就是一个 commit，所以和根据 commit id 检出分支是一个道理。
```shell
git checkout -b <branchName> <tagName>
```

**注意：** 如果修改 tag 检出代码分支，那么虽然分支中的代码改变了，但是 tag 标记的 commit 还是同一个，标记的代码是不会变的

### 3.2.4 删除tag
```shell
git tag -d <tagName>        # 删除本地
git push origin :<tagName>  # 删除远程
```

说明：删除远程，实际上就是推送空的源标签refs。  
```txt
git push origin 标签名
等同于：
git push origin refs/tags/源标签名:refs/tags/目的标签名

所以，推送空的源标签的命令是：
git push origin :refs/tags/标签名
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

## 已经推送（push）过的文件，想在以后的提交时忽略此文件（即使本地已经修改过），但是，不删除远程库中相应文件
```shell
git update-index --assume-unchanged 文件名

# 如果要忽略一个目录：
cd 目标目录
git update-index --assume-unchanged $(git ls-files | tr '\n' ' ') 
```

# 9. 其他
## 9.1 查看各种信息
### 9.1.1 查看库状态
查看有哪些文件被修改、添加、删除了，是否在暂存区，等等信息。  
```shell
git status     # 显示详细的信息
git status -s  # 显示简短信息
```

### 9.1.2 查看日志获得信息（如：commitid）
```shell
# 只看上5次提交的信息，也同时看到版本号，以便决定是否使用新的版本号。
git log --pretty=oneline -5

# 查看每一次提交的文件名
git log --name-status
```

### 9.1.3 查看某次提交的信息
```shell
# 查看指定 commit id 提交的全部信息
git show <commitId>

# 只看状态信息
git show <commitId> --stat
# 看受影响的文件及状态
git show <commitId> --name-status
# 只看本次提交受影响的文件
git show <commitId> --name-only
```

## 9.2 中文文件乱码
git 默认中文文件名是 \xxx\xxx 等八进制形式，是因为 对0x80以上的字符进行quote。  
```shell
git config --global core.quotepath false
```

## 9.3 比较本地和远程的区别
区别有两种：  
1. 远程有比本地更加新的变化。比如别人提交了文件

```shell
git fetch origin      # 把远程的变化情况更新到本地
git diff master origin/master
```

2. 本地有比远程更加新的变化。比如自己修改了本地文件还没有推送给远程

```shell
git status           # 看本地仓库的状态即可知道本地有变化的文件，然后逐个文件用diff比较即可
git diff a.txt a.txt # 第1个a.txt指本地的文件名，第2个a.txt即远程仓库上的文件名
```

## 9.4 删除提交记录
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

## 9.5 优美简洁的显示log
```
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
```

# 10. 账户密码
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


---

[首 页](https://patrickj-fd.github.io/index)
