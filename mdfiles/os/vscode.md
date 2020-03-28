---
[首 页](https://patrickj-fd.github.io/index)
---

# 安装
下载地址：
> https://code.visualstudio.com/

# 配置
- 控制面板： Ctrl+Shift+P

参考：第一次使用VS Code时你应该知道的一切配置
> https://github.com/qianguyihao/Web/blob/master/00-前端工具/01-VS Code的使用.md

## 设置中文支持
在命令面板中，输入 [Configure Display Language] ，选择 [Install additional languages]，然后安装插件 [Chinese (Simplified) Language Pack for Visual Studio Code] 即可。

## 制表符
VS Code 会根据所打开的文件来决定该使用空格还是制表。也就是说，如果项目中使用的都是制表符，那么，在写新的代码时，按下tab 键后，编辑器就会识别成制表符。
- editor.detectIndentation ：打开/关闭上面的这个功能
- editor.insertSpaces ：按 Tab 键时插入空格（默认）

## 新文件默认文件类型
files.defaultLanguage ：修改自己希望的文件类型，比如：markdown

## 文件对比
默认支持，也可以安装插件：compareit，能够对「当前文件」与「剪切板」里的内容进行对比

## 函数调用情况
比如在a.js文件里调用了 foo()函数。那么，如果想知道foo()函数在其他文件中是否也被调用了？  
做法如下：在 a.js 文件里，选中foo()函数（或者将光标放置在foo()函数上），然后按住快捷键「Shift + F12」，就能看到 foo()函数在哪些地方被调用了。

## 重构
- 命名重构：
当我们尝试去修改某个函数（或者变量名）时，我们可以把光标放在上面，然后按下「F2」键，那么，这个函数（或者变量名）出现的地方都会被修改。

- 方法重构：
选中某一段代码，这个时候，代码的左侧会出现一个「灯泡图标」，点击这个图标，就可以把这段代码提取为一个单独的函数。

## Git版本管理
默认支持，可安装插件GitLens，获得更强大的能力：
- 将光标放置在代码的当前行，可以看到提交者是谁，以及提交时间
- 查看某个 commit 的代码改动记录
- 查看不同的分支
- 可以将两个 commit 进行代码对比
- 可以将两个 branch 分支进行整体的代码对比。这一点，简直是 GitLens 最强大的功能。当我们在不同分支review代码的时候，就可以用到这一招。

## 好用的插件
### sftp
安装插件sftp。  
配置 sftp.json文件：
控制面板中输入：sftp:config。当前工程的.vscode文件夹下就会自动生成一个sftp.json文件，在这个文件里配置的内容可以是：
- host：服务器的IP地址
- username：工作站自己的用户名
- privateKeyPath：存放在本地的已配置好的用于登录工作站的密钥文件（也可以是ppk文件）
- remotePath：工作站上与本地工程同步的文件夹路径，需要和本地工程文件根目录同名，且在使用sftp上传文件之前，要手动在工作站上mkdir生成这个根目录
- ignore：指定在使用sftp: sync to remote的时候忽略的文件及文件夹，注意每一行后面有逗号，最后一行没有逗号

### Project Manager
工作中，我们经常会来回切换多个项目，每次都要找到对应项目的目录再打开，比较麻烦。  
它提供了专门的视图来展示你的项目，我们可以把常用的项目保存在这里，需要时一键切换，十分方便。

### TabNine
基于GPT-2语言模型的自动补全工具，AI智能代码补全。

### Bookmarks
经过一系列的跳转之后想回到最初的位置。  
能够使用Ctrl+Alt+K、Ctrl+Alt+J、Ctrl+Alt+L快捷键添加标签，并且可以快速调整到指定标签位置。

### Code Runner
支持C、C++、Java、Python等主流编程语言快速运行。  
它能够便捷的运行当前活动页代码文件、能够运行选定代码段、运行自定义命令。

### Live Share
实现你和你的同伴一起写代码

### highlight-icemode
选中相同的代码时，让高亮显示更加明显。  
VSCode自带的高亮显示，实在是不够显眼。用插件支持一下吧。  
所用了这个插件之后，VS Code自带的高亮就可以关掉了：  
在用户设置里添加"editor.selectionHighlight": false即可

### TODO Highlight
支持代码中用TODO、FIXME这样关键字了

### Settings Sync
- 作用：多台设备之间，同步 VS Code 配置。通过登录 GitHub 账号来使用这个同步工具。
- 地址：https://github.com/shanalikhan/code-settings-sync

### RemoteHub
可以在本地查看 GitHub 网站上的代码，而不需要将代码下载到本地。

### open in browser
右键在浏览器中打开文件

## 工作区放大/缩小
如果想要缩放整个工作区（包括代码的字体、左侧导航栏的字体等），按下「ctrl +/-」  
如果想要恢复默认的工作区大小，可以在命令面板输入重置缩放（英文是reset zoom）

## 其他
- 使用命令行启动 VS Code
```
# 命令行输入如下命令，即可通过 VS Code 软件打开指定目录/指定文件
code pathName/fileName
```

# 远程开发配置
1. 安装Remote Development插件
2. 点击远程资源管理器，在SSH TARGETS配置远程服务器
   点击齿轮图标，打开弹出的config文件，分别配置：Host、Hostname、User
   Host随意命名；Hostname是远程服务器的IP；User是用于登录远程服务器的账户名
3. 打开vs code设置，搜索Show Login Terminal，勾选下方"Always reveal the SSH login terminal"，一定要操作这一步，不然会一直提示报错。
4. 打开远程连接窗口
   把鼠标放在上一步配置的远程连接条目上，点击Connect to Host in New Window，然后就会在新的窗口打开我们想要的远程连接。
5. 配置免密登录