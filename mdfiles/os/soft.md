[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 必备工具软件
- Terminator ： 最好用的终端
- tmux ： 
- htop 和 glances
- bat ： 代替cat。github.com/sharkdp/bat
  * [下载](https://github.com/sharkdp/bat/releases/download/v0.15.4/bat_0.15.4_amd64.deb)
- Starship ： 为shell扩展出很多优秀的能力。https://starship.rs
- ripgrep ： 代替grep。github.com/BurntSushi/ripgrep
- fd : 代替find。github.com/sharkdp/fd
- httpie ： 终端下适用，完美代替curl。https://httpie.org/
- lazydocker ： github.com/jesseduffield/lazydocker
- Aria2 ： 多线程下载，支持磁力/BT/HTTPS/FTP/Metalink等等
- asciinema ： 终端会话录制。https://asciinema.org
- litecli 和 pgcli ： 分别用于sqlite和pgsql的cli优秀工具

## httpie
```shell
sudo apt isntall -y httpie
```
用法：
```shell
http https://httpie.org/hello
# submit forms:
http -f POST httpbin.org/post hello=World
# Upload a file using redirected input:
http httpbin.org/post < files/data.json
# Download a file and save it via redirected output:
http httpbin.org/image/png > image.png
# Download a file wget style:
http --download httpbin.org/image/png
# Use named sessions
http --session=logged-in -a username:password httpbin.org/get API-Key:123
http --session=logged-in httpbin.org/headers
# Set a custom Host header to work around missing DNS records:
http localhost:8000 Host:example.com
# Custom HTTP method, HTTP headers and JSON data:
http PUT httpbin.org/put X-API-Token:123 name=John
# See the request that is being sent using one of the output options:
http -v httpbin.org/get
# Build and print a request without sending it using offline mode: 
http --offline httpbin.org/post hello=offline
# Use Github API to post a comment on an issue with authentication:
http -a USERNAME POST https://api.github.com/repos/jakubroztocil/httpie/issues/83/comments body='HTTPie is awesome! :heart:'
```

<<<<<<< HEAD
=======
## Starship
* 根据仓库中增改文件等情况，用相应的符号表示 git 仓库的状态
* 根据所在的 Python 项目目录，展示 Python 的版本号（也适用Go/Rust/Node等）
* 显示上个命令的执行时间
* 如果上个命令失败，显示错误提示符

>>>>>>> dbfbedcad4764a7369a4c517424bb5da877c89e2
# Trash-cli
代替 rm
```
sudo apt install trash-cli

trash 删除文件或文件夹
restore-trash 恢复文件
trash-empty 清空回收站
trash-list 回收站文件列表
```

# DBeaver
数据库管理工具，稍逊于Navicat

# DesktopNaoTu
思维导图

# calibre
阅读器。支持大量格式，包括Kindle的mobi

# Kazam
截屏、录屏

# KolourPaint
类似WIN的画图，简单编辑图片用

# Shutter  
截屏软件，捕获、编辑和轻松的共享截屏。支持修改图片，也算是一个图片的管理器

# SimpleScreenRecorder  
免费而轻量级的屏幕录制工具
```
$ sudo add-apt-repository ppa:marten-baert/simplescreenrecorder
$ sudo apt-get update
$ sudo apt-get install simplescreenrecorder
```

# Etcher USB 镜像写入器  
Etcher 是一个由 http://resin.io 开发的 USB 镜像写入器。它是一个跨平台的应用，可以帮助你将 ZIP、ISO、IMG 格式的镜像文件写入到 USB 存储中。如果你经常尝试新的操作系统，那么 Ethcher 是你必有的简单可靠的工具。

# Citra
最流畅的3ds模拟器

# Dropbox  
Dropbox 是一个出色的云存储客户端

# Notepadqq  
Notepad++的Linux移植版

# Anbox  
Android 模拟器

# Franz  
即时消息客户端，它将聊天和信息服务结合到了一个应用中.支持了 Facebook Messenger、WhatsApp、Telegram、微信、Google Hangouts、 Skype。

# boot-repair
双系统时，WIN把引导扇区覆盖时，用他恢复
```
sudo add-apt-repository ppa:yannubuntu/boot-repair
sudo apt-get update
sudo apt-get install boot-repair
```
---

[首 页](https://patrickj-fd.github.io/index)
