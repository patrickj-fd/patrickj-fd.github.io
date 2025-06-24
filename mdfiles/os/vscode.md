[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 安装
下载地址：
> https://code.visualstudio.com/

# 定制

### 修改默认shell
Ctrl+Shift+P，搜索shell，在下拉列表中“select Default shell”选自己要用的shell，比如PowerShell 7、Git Bash等。

### 全局修改CRLF为LF
Settings中搜索 'eol'，会定位到：Text Editor -> Files: Eol，下拉框里面选择\n即可

### 制表符
VS Code 会根据所打开的文件来决定该使用空格还是制表。也就是说，如果项目中使用的都是制表符，那么，在写新的代码时，按下tab 键后，编辑器就会识别成制表符。
定制这个设置的方式：在“文件->首选项->设置”的“用户设置”里搜索下面3个选项：
- detectIndentation（不勾选） ：目的是不要检测到第一个是tab，就后面都用tab（因为这样会覆盖默认设置）
- renderControlCharacters（选中）
- renderWhitespace（选 all）

### Project Manager
提供了专门的视图来展示项目，可以把常用的项目保存在这里，需要时一键切换，十分方便。  
Ctrl+Shift+P，输入：Project Manager: Edit Projects，编辑配置文件添加本地项目即可

### 远程开发插件 Remote Development
1. 搜索安装Remote Development（会自动包含SSH等包）
2. 点击远程资源管理器，在SSH TARGETS配置远程服务器
   点击齿轮图标，打开弹出的config文件，分别配置：Host、Hostname、User
   Host随意命名；Hostname是远程服务器的IP；User是用于登录远程服务器的账户名
3. 打开vs code设置，搜索Show Login Terminal，勾选下方"Always reveal the SSH login terminal"，一定要操作这一步，不然会一直提示报错。
4. 打开远程连接窗口
   把鼠标放在上一步配置的远程连接条目上，点击Connect to Host in New Window，然后就会在新的窗口打开我们想要的远程连接。
5. 配置免密登录
6. 点击“open folder”，即可访问远程目录了

### Markdown All in One
可媲美Typora。支持TOC标签、自动完成、列表编辑、转HTML/PDF、Github风格文档等。  
- 加粗/取消： Ctrl + b 。支持多选
- 表格编辑：Alt+Shift+f

### TODO Tree
### Better Comments
让注释信息更加人性化，可以根据告警、查询、TODO、高亮等标记对注释进行不同的展示。
### Better Align
用于代码的上下对齐。把冒号（：）、赋值（=，+=，-=，*=，/=）和箭头（=>）两端的代码进行自动对齐。  
使用方法：Ctrl+Shift+p输入“Align”确认即可。


# 基本知识
## 工作区
VSCode中的工作区是为了让你配置一个工作环境,让你更好地针对不同地环境（如JAVA环境，C++环境）设定不同地配置体验更好的VSCode

我们在JAVA环境，无需使用Python的插件，但是Python的插件默认开启，占有很多系统不必要的内存，我们就可以在不同的工作区进行不同的配置。

VS Code没有“新建工作区”的选项，而是“将工作区另存为”这个功能。  
如果在打开的文件夹的情况下保存工作区，会自动将此文件夹放入工作区，也建议这样使用。  
工作区文件建议直接放置在你的工作文件夹（如Java文件夹）下，若打开文件夹的情况下，建议不要更改路径，直接放置此文件夹下。  


## 系统设置
VS Code的层级设置关系为：  
> 系统默认设置（不可修改）--> 用户设置 --> 工作区设置 --> 文件夹设置
1. 用户设置　：即全局设置，用户自行设定好后，每次打开VSCode即使用的此设定，若某项无设定即使用默认设置
2. 工作区设置：即工作环境设置，可对不同的工作环境是用不同的工作环境，若某项无设定，即使用上述设置
3. 文件夹设置：即为项目设置，将一个文件夹当成一个项目，对同一个工作环境下的不同项目，使用不同的设置，若某项无设定，即使用上述设置

# 建立Python环境

- [官方说明](https://code.visualstudio.com/docs/python/python-tutorial)

1. 安装 Python 插件
2. 为新项目生成 setting.json 文件
  按ctrl+shift+p，找到“Python: Select Interpreter"。会跳出系统已经安装的所有python解释器，随便选一个，以便生成setting.json，之后就可以根据实际情况进行修改了
3. 为项目运行时指定入口文件和参数
  "Run"菜单中选"Add Configuration"，再选"Python"，会自动生成launch.json配置文件：  
  program ： 指定项目运行时的入口文件的。其中${file}表示当前文件，${workspaceFolder}表示项目根目录
  args ： 指定项目运行时，跟在入口文件后面的参数。如："args":["xxx","0.0.0.0:8080"]
4. Ctrl+F5运行程序；F5调试程序

因为不同项目，用到python环境不一样，所以，可以在每个项目下建立一个虚拟环境。

## setting.json和launch.json
其实，上面4步就是生成setting.json和launch.json，所以，也可以全手工配置：在workspace目录下建立'.vscode'目录，下面存放setting.json和launch.json两个文件。在VS中即可Run/Debug程序了。
- [官方说明-关于环境变量定义](https://code.visualstudio.com/docs/python/environments#_environment-variable-definitions-file)

### （1）setting.json
```json
{
    "editor.detectIndentation": false,
    "editor.renderControlCharacters": true,
    "editor.renderWhitespace": "all",
    "remote.SSH.showLoginTerminal": true,
    "python.pythonPath": "python的执行全路径（包括虚拟环境）",
    "python.linting.pylintEnabled": false,
    "python.linting.pep8Enabled": true,
    "python.linting.lintOnSave": true,
    "python.formatting.provider": "yapf",
    "files.autoSave": "onFocusChange",      // 离开页面自动保存
    "editor.formatOnSave": true,            // 每次保存的时候自动格式化。 Or: formatOnType

    // 启动pytest测试框架。
    "python.testing.pytestArgs": [
        "test_suite"   // 当前workspace下，存在测试用例的根目录
    ],
    "python.testing.pytestPath": "pytest",  // 要在python执行环境中安装pytest
    "python.testing.unittestEnabled": false,
    "python.testing.nosetestsEnabled": false,
    "python.testing.pytestEnabled": true
}
// 前面4个可以没有，只要有最后一句，即可从VS中Run/Debug程序了。最后一句就是“Python: Select Interpreter"配置的
```
- 前面4个可以没有，有第5句，即可从VS中Run/Debug程序了。这就是“Python: Select Interpreter"配置出来的
- 也可以不加"python.pythonPath"，在launch.json里面配置pythonPath即可
- 如果"python.pythonPath"后面的这些配置行不需要，那么这个文件可以没有。因为前4个复用全局配置，第5个在launch里面配置

### （2）launch.json
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "AnyName eg. project name", // 配置名称，会在启动配置的下拉菜单中显示
            "type": "python",
            "request": "launch", // launch/attach. launch: VS会打开这个程序然后进入调试, attach:已经打开了程序，然后接通内部调试协议进行调试
            "pythonPath": "python可执行文件全路径（包括虚拟环境）", // "${command:python.interpreterPath}",
            "program": "${file}",
            "args": ["-vid", "test.mp4"],  // 执行程序时的命令行参数
            // "cwd": "${fileDirname}",  // 如果没有这句，在VS中执行py时自动进入默认目录
            "cwd": "${workspaceRoot}",  // 把工程添加到workspace并设置这个，以便程序能正确引入包
            "env": {"HRS_RESOURCES_ROOT": "/....../resources"},
            "envFile": "${workspaceRoot}/.yours_envfile",
            "debugOptions": [           // 这个不配置也可以
                "WaitOnAbnormalExit",
                "WaitOnNormalExit",
                "RedirectOutput"
            ],
            "console": "integratedTerminal"
        }
    ]
}
```
#### launch里面的预定义变量
```
${workspaceFolder}          - 当前工作目录(根目录)
${workspaceFolderBasename}  - 当前文件的父目录
${file}                     - 当前打开的文件名(完整路径)
${relativeFile}             - 当前根目录到当前打开文件的相对路径(包括文件名)
${relativeFileDirname}      - 当前根目录到当前打开文件的相对路径(不包括文件名)
${fileBasename}             - 当前打开的文件名(包括扩展名)
${fileBasenameNoExtension}  - 当前打开的文件名(不包括扩展名)
${fileDirname}              - 当前打开文件的目录
${fileExtname}              - 当前打开文件的扩展名
${cwd}                      - 启动时task工作的目录
${lineNumber}               - 当前激活文件所选行
${selectedText}             - 当前激活文件中所选择的文本
${execPath}                 - vscode执行文件所在的目录
${defaultBuildTask}         - 默认编译任务(build task)的名字
```

# 配置
- 控制面板： Ctrl+Shift+P

参考：
> https://www.cnblogs.com/DesignerA/p/11604200.html

## 设置中文支持
在命令面板中，输入 [Configure Display Language] ，选择 [Install additional languages]，然后安装插件 [Chinese (Simplified) Language Pack for Visual Studio Code] 即可。

## 新文件默认文件类型
files.defaultLanguage ：修改自己希望的文件类型，比如：markdown

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

### compareit
文件对比插件。默认支持文件对比，但这个插件提供更好的能力，比如能够对「当前文件」与「剪切板」里的内容进行对比

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

# 内置Git的使用
内置Git插件的操作命令与git命令的对照关系：
- Pull：对应 git pull 命令
- Pull (Rebase)：对应 git pull --rebase 命令
- Pull from：对应 git pull origin --tags 命令
- Push：对应 git push 命令
- Push to：对应 git origin
- Sync：先 pull 再 push
  
- Checkout to：对应 git checkout 命令
- Publish Branch：对应 git push -u origin 命令
  
- Commit All：先 add 再 commit
- Commit All (Amend)：先 add 再 commit --amend
- Commit All (Signed Off)：先 add 再 commit --signoff
- Commit Staged：对应 git commit 命令
- Commit Staged (Amend)：对应 git commit --amend 命令
- Commit Staged (Signed Off)：对应 git commit --signoff 命令
- Undo Last Commit：对应 git reset 命令
  
- Discard All Changes：
- Stage All Changes：对应 git add 命令
- Unstage All Changes：
  
- Apply Latest Stash：
- Apply Stash：
- Pop Latest Stash：
- Pop Stash：
- Stash：
- Stash (Include Untracked)：

- Show Git Output：显示 git 的控制台输出


---

[首 页](https://patrickj-fd.github.io/index)
